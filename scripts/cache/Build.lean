import Lean

/- Native Windows, offline build driver. This is tooling, not a mathematical proof.
   Cache admission is fail-closed: immutable inputs, output hashes, audit log, and
   receipt must all match. No imported predecessor receipt is trusted implicitly. -/
open System

def buildVersion : String := "v0_1_0_construction"

def cacheModeOf (mode : String) : String := if mode == "search" then "core" else mode

def fail (s : String) : IO α := throw <| IO.userError s

def strip (s : String) : String := s.trimAscii.toString

def lines (s : String) : Array String :=
  ((s.splitOn "\n").map strip |>.filter (· != "")).toArray

def exists (p : FilePath) : IO Bool := p.pathExists

/-- Bounded cache discovery only; no recursive walk and no network fallback. -/
def mathlibRootFromCandidate (candidate : FilePath) : IO (Option FilePath) := do
  for root in #[candidate, candidate / ".lake/packages/mathlib"] do
    if (← exists (root / "lean-toolchain")) &&
        (← exists (root / ".lake/build/lib/lean/Mathlib.olean")) then
      let declared := strip (← IO.FS.readFile (root / "lean-toolchain"))
      if declared == "leanprover/lean4:v4.33.0" then return some root
  return none

def resolveMathlibRoot (explicit : String) : IO FilePath := do
  if explicit != "-" then
    let resolved ← mathlibRootFromCandidate (FilePath.mk explicit)
    if let some root := resolved then return root
    fail "RH_MATHLIB_ROOT does not contain a Lean 4.33.0 Mathlib source checkout and cached Mathlib.olean"
  for name in #["MATHLIB_PROJECT_ROOT_OVERRIDE", "MATHLIB_CACHE_ROOT",
      "GOODWORKFLOWFRONTIER_CACHE_BASE", "CACHE_BASE"] do
    let value? ← IO.getEnv name
    if let some value := value? then
      if !value.isEmpty then
        let resolved ← mathlibRootFromCandidate (FilePath.mk value)
        if let some root := resolved then return root
  let profile? ← IO.getEnv "USERPROFILE"
  if let some profile := profile? then
    let base := FilePath.mk profile
    for candidate in #[base / "lean-native/awpi_phi_rh_lean_sieved_v0_1_1",
        base / "Downloads/awpi_phi_rh_lean_sieved_v0_1_1",
        base / "mathlib4", base / "Downloads/mathlib4"] do
      let resolved ← mathlibRootFromCandidate candidate
      if let some root := resolved then return root
  fail "No compatible cached Mathlib source checkout found; set RH_MATHLIB_ROOT"

def run (exe : String) (args : Array String) (leanPath : Option String := none) : IO String := do
  let env := match leanPath with
    | none => #[]
    | some p => #[("LEAN_PATH", some p)]
  let r ← IO.Process.output {cmd := exe, args, env}
  if r.exitCode != 0 then
    fail s!"Process failed ({r.exitCode}): {exe}\n{r.stdout}\n{r.stderr}"
  pure (r.stdout ++ r.stderr)

def hexChar (c : Char) : Bool := c.isDigit || ('a' ≤ c && c ≤ 'f') || ('A' ≤ c && c ≤ 'F')

def sha256 (p : FilePath) : IO String := do
  let out ← run "certutil.exe" #["-hashfile", p.toString, "SHA256"]
  let hs := (lines out).filter fun s => s.length == 64 && s.toList.all hexChar
  if hs.size != 1 then fail s!"Cannot parse SHA256: {p}"
  pure hs[0]!

partial def filesBelow (p : FilePath) : IO (Array FilePath) := do
  let mut result := #[]
  for entry in (← p.readDir) do
    if ← entry.path.isDir then
      result := result ++ (← filesBelow entry.path)
    else
      result := result.push entry.path
  pure <| result.qsort (fun a b => a.toString < b.toString)

def relevantBinary (p : FilePath) : Bool :=
  let s := p.toString
  s.endsWith ".olean" || s.endsWith ".olean.private" || s.endsWith ".olean.server" ||
  s.endsWith ".ir" || s.endsWith ".dll" || s.endsWith ".so" || s.endsWith ".dylib" ||
  s.endsWith ".exe"

def fingerprintTree (p temp : FilePath) : IO String := do
  if !(← exists p) then fail s!"Missing cache/toolchain directory: {p}"
  let fs := (← filesBelow p).filter relevantBinary
  if fs.isEmpty then fail s!"No cached binary files found: {p}"
  -- One certutil process per tree. The aggregate is written one file at a time;
  -- peak memory is bounded by the largest individual cached artifact.
  let _ ← do
    let h ← IO.FS.Handle.mk temp IO.FS.Mode.write
    for f in fs do
      let data ← IO.FS.readBinFile f
      let name := f.toString
      h.write (s!"{name.toUTF8.size}:{name}:{data.size}:").toUTF8
      h.write data
    h.flush
    pure ()
  let digest ← sha256 temp
  IO.FS.removeFile temp
  pure s!"TREE={p}\t{digest}\n"

def write (p : FilePath) (s : String) : IO Unit := do
  if let some parent := p.parent then IO.FS.createDirAll parent
  IO.FS.writeFile p s

def safeModule (s : String) : Bool :=
  !s.isEmpty && s.toList.all (fun c => c.isAlphanum || c == '_' || c == '/') &&
  !(s.startsWith "/") && !(s.endsWith "/") && !(s.splitOn "/").any String.isEmpty

def readPlan (p : FilePath) : IO (Array String) := do
  if !(← exists p) then fail s!"Missing module plan: {p}"
  let a := (lines (← IO.FS.readFile p)).filter (! ·.startsWith "#")
  if a.isEmpty then fail "Module plan is empty"
  let mut seen : Array String := #[]
  for m in a do
    if !safeModule m then fail s!"Unsafe module name in plan: {m}"
    if seen.contains m then fail s!"Duplicate module in plan: {m}"
    seen := seen.push m
  pure a

/-- Verify every printed dependency list, permitting only the standard Lean axioms.
    A named Audit module must contain at least one actual #print axioms result. -/
def auditLog (isAudit : Bool) (log : String) : IO Unit := do
  for bad in #["sorryAx", "Lean.ofReduceBool", "Lean.trustCompiler", "declaration uses 'sorry'"] do
    if (log.splitOn bad).length > 1 then fail s!"Forbidden proof dependency: {bad}"
  let parts := log.splitOn "depends on axioms:"
  let mut count := parts.length - 1
  for part in parts.drop 1 do
    let afterOpen := part.splitOn "["
    if afterOpen.length < 2 then fail "Malformed axiom audit: opening bracket missing"
    let body := ((afterOpen[1]!).splitOn "]")[0]!
    if (afterOpen[1]!.splitOn "]").length < 2 then fail "Malformed axiom audit: closing bracket missing"
    for raw in body.splitOn "," do
      let name := strip raw
      if !name.isEmpty && !(#["propext", "Classical.choice", "Quot.sound"].contains name) then
        fail s!"Unexpected axiom: {name}"
  count := count + (log.splitOn "does not depend on any axioms").length - 1
  if isAudit && count == 0 then fail "Audit module produced no axiom audit results"

structure Config where
  root : FilePath
  lean : String
  mode : String
  lib : FilePath
  meta : FilePath
  logs : FilePath
  stage : FilePath
  leanPath : String
  context : String

/-- Cached output hashes include companion files emitted by Lean 4.33. -/
def moduleOutputs (c : Config) (m : String) : IO String := do
  let base := c.lib / (m ++ ".olean")
  if !(← exists base) then fail s!"Missing object: {base}"
  let mut out := ""
  for suffix in #["", ".private", ".server"] do
    let p := FilePath.mk (base.toString ++ suffix)
    if ← exists p then out := out ++ s!"{suffix}\t{← sha256 p}\n"
  pure out

def keyOf (m : String) : String := m.replace "/" "."

def compileOne (c : Config) (done : Array String) (m : String) : IO Bool := do
  let src := c.root / (m ++ ".lean")
  if !(← exists src) then fail s!"Missing source: {src}"
  let deps ← run c.lean #["--deps", src.toString] (some c.leanPath)
  let sourceHash ← sha256 src
  let mut input := c.context ++ s!"MODULE={m}\nSOURCE={sourceHash}\n"
  let mut importHashes : Array (FilePath × String) := #[]
  for dep in lines deps do
    let p := FilePath.mk dep
    if !(← exists p) then fail s!"Unresolved import for {m}: {dep}"
    let importHash ← sha256 p
    importHashes := importHashes.push (p, importHash)
    input := input ++ s!"IMPORT={dep}\t{importHash}\n"
    -- Project imports must have been admitted earlier in the same ordered run.
    let canonical := dep.replace "\\" "/"
    let prefix := (c.lib.toString.replace "\\" "/") ++ "/"
    if canonical.startsWith prefix then
      let rel := canonical.drop prefix.length |>.toString
      if !rel.endsWith ".olean" then fail s!"Unexpected project dependency: {dep}"
      let imported := rel.dropEnd 6 |>.toString
      if !done.contains imported then fail s!"Plan is not topological, or import is unlisted: {imported}"
      let receipt := c.meta / (keyOf imported ++ ".pass")
      if !(← exists receipt) then fail s!"Imported module has no admitted receipt: {imported}"
      input := input ++ s!"IMPORT_RECEIPT={← sha256 receipt}\n"
  let key := keyOf m
  let inputFile := c.meta / (key ++ ".input")
  let passFile := c.meta / (key ++ ".pass")
  let logFile := c.logs / (key ++ ".log")
  let isAudit := m.endsWith "Audit"
  let mut reuse := false
  if (← exists inputFile) && (← exists passFile) && (← exists logFile) then
    if (← IO.FS.readFile inputFile) == input then
      try
        let outputs ← moduleOutputs c m
        let expected := "NATIVE_WINDOWS_PASS\n" ++ outputs ++ s!"LOG={← sha256 logFile}\n"
        if (← IO.FS.readFile passFile) == expected then
          auditLog isAudit (← IO.FS.readFile logFile)
          reuse := true
      catch _ => pure ()
  if reuse then
    IO.println s!"GOODWORKFLOWFRONTIER::{buildVersion}::REUSE_{key}=VERIFIED"
    return true
  -- An old receipt cannot survive a failed or interrupted replacement.
  if ← exists passFile then IO.FS.removeFile passFile
  let target := c.stage / (m ++ ".olean")
  if let some parent := target.parent then IO.FS.createDirAll parent
  for suffix in #["", ".private", ".server"] do
    let stale := FilePath.mk (target.toString ++ suffix)
    if ← exists stale then IO.FS.removeFile stale
  let r ← IO.Process.output {cmd := c.lean,
    args := #["-j", "1", "-DwarningAsError=true", "-o", target.toString, src.toString],
    env := #[("LEAN_PATH", some c.leanPath)]}
  let log := r.stdout ++ r.stderr
  write logFile log
  if r.exitCode != 0 then fail s!"Lean rejected {m}\n{log}"
  auditLog isAudit log
  if (← sha256 src) != sourceHash then fail s!"Source changed while compiling: {m}"
  for (p, expected) in importHashes do
    if (← sha256 p) != expected then fail s!"Import changed while compiling: {p}"
  if !(← exists target) then fail s!"Lean returned success without an object: {m}"
  let output := c.lib / (m ++ ".olean")
  if let some parent := output.parent then IO.FS.createDirAll parent
  for suffix in #["", ".private", ".server"] do
    let old := FilePath.mk (output.toString ++ suffix)
    let fresh := FilePath.mk (target.toString ++ suffix)
    if ← exists old then IO.FS.removeFile old
    if ← exists fresh then IO.FS.rename fresh old
  let outputs ← moduleOutputs c m
  write inputFile input
  -- Last-write receipt: an interruption before here cannot yield cache admission.
  write passFile ("NATIVE_WINDOWS_PASS\n" ++ outputs ++ s!"LOG={← sha256 logFile}\n")
  IO.println s!"GOODWORKFLOWFRONTIER::{buildVersion}::COMPILE_{key}=PASS"
  pure false

def main (args : List String) : IO UInt32 := do
  let lastRun := match args with
    | root :: _ :: mode :: _ => some (FilePath.mk root / ".rh-cache" / cacheModeOf mode / "last-run.txt")
    | _ => none
  try
    if let some p := lastRun then write p s!"VERSION={buildVersion}\nLEAN_BUILD=RUNNING\nRH_PROVED=NO\n"
    let [rootArg, lean, mode, mathlibArg] := args
      | fail "Usage: Build.lean ROOT LEAN_EXE core|full|search MATHLIB_ROOT_OR_DASH"
    if mode != "core" && mode != "full" && mode != "search" then
      fail "Mode must be core, full or search"
    let cacheMode := cacheModeOf mode
    let root := FilePath.mk rootArg
    let version ← run lean #["--version"]
    if !(version.startsWith "Lean (version 4.33.0,") then fail s!"Expected Lean 4.33.0: {version}"
    if (version.splitOn "windows").length < 2 then fail s!"Native Windows Lean required: {version}"
    let prefix ← run lean #["--print-prefix"]
    let toolchain := FilePath.mk (strip prefix)
    let cache := root / ".rh-cache" / cacheMode
    let lib := cache / "lib"
    let meta := cache / "receipts"
    let logs := cache / "logs"
    let stage := cache / "stage"
    for p in #[lib, meta, logs, stage] do IO.FS.createDirAll p
    let mut leanPath := lib.toString
    let mut context := s!"VERSION={buildVersion}\nMODE={cacheMode}\nFLAGS=-j 1 -DwarningAsError=true\n" ++ version
    context := context ++ s!"LEAN_EXE={lean}\t{← sha256 (FilePath.mk lean)}\n"
    context := context ++ s!"RUNNER={← sha256 (root / "run.cmd")}\nDRIVER={← sha256 (root / "scripts/cache/Build.lean")}\n"
    IO.println s!"GOODWORKFLOWFRONTIER::{buildVersion}::FINGERPRINT=TOOLCHAIN"
    let treeTemp := cache / "fingerprint-stream.tmp"
    let toolchainLib := toolchain / "lib" / "lean"
    let toolchainBin := toolchain / "bin"
    let mut treeRoots : Array FilePath := #[toolchainLib, toolchainBin]
    let mut treeFingerprints : Array String := #[]
    for tree in treeRoots do
      let fp ← fingerprintTree tree treeTemp
      treeFingerprints := treeFingerprints.push fp
      context := context ++ fp
    for envName in #["PATH", "LEAN_SYSROOT", "LEAN_ABORT_ON_PANIC", "LEAN_NUM_THREADS"] do
      context := context ++ s!"ENV_{envName}={(← IO.getEnv envName).getD ""}\n"
    if mode == "full" then
      let mathlib ← resolveMathlibRoot mathlibArg
      let mathlibLib := mathlib / ".lake/build/lib/lean"
      if !(← exists (mathlib / "lean-toolchain")) then fail "Mathlib root must be an existing checkout"
      let mathlibToolchain := strip (← IO.FS.readFile (mathlib / "lean-toolchain"))
      if mathlibToolchain != "leanprover/lean4:v4.33.0" then
        fail s!"Mathlib toolchain mismatch: {mathlibToolchain}"
      leanPath := leanPath ++ ";" ++ mathlibLib.toString
      IO.println s!"GOODWORKFLOWFRONTIER::{buildVersion}::FINGERPRINT=MATHLIB"
      let fp ← fingerprintTree mathlibLib treeTemp
      treeRoots := treeRoots.push mathlibLib
      treeFingerprints := treeFingerprints.push fp
      context := context ++ fp
      for manifest in #["lean-toolchain", "lake-manifest.json", "lakefile.lean", "lakefile.toml"] do
        let p := mathlib / manifest
        if ← exists p then context := context ++ s!"{p}\t{← sha256 p}\n"
      let mut packageRoots := #[mathlib / ".lake/packages"]
      -- In a downstream Lake workspace, dependencies are siblings of mathlib.
      if let some parent := mathlib.parent then
        if parent.fileName == some "packages" then
          packageRoots := packageRoots.push parent
      for packages in packageRoots do
        if ← exists packages then
          let entries ← packages.readDir
          let entries := entries.qsort (fun a b => a.path.toString < b.path.toString)
          for entry in entries do
            if ← entry.path.isDir then
              let pkgLib := entry.path / ".lake/build/lib/lean"
              if (← exists pkgLib) && !treeRoots.contains pkgLib then
                leanPath := leanPath ++ ";" ++ pkgLib.toString
                let fp ← fingerprintTree pkgLib treeTemp
                treeRoots := treeRoots.push pkgLib
                treeFingerprints := treeFingerprints.push fp
                context := context ++ fp
    context := context ++ s!"LEAN_PATH={leanPath}\n"
    let planFile := root / (if mode == "full" then "build-modules-full.txt" else "build-modules.txt")
    let plan ← readPlan planFile
    let config : Config := {root, lean, mode, lib, meta, logs, stage, leanPath, context}
    let mut done := #[]
    let mut sourceHashes : Array (FilePath × String) := #[]
    let mut compiled := 0
    let mut reused := 0
    for m in plan do
      let source := root / (m ++ ".lean")
      sourceHashes := sourceHashes.push (source, ← sha256 source)
      if ← compileOne config done m then reused := reused + 1 else compiled := compiled + 1
      done := done.push m
    if !(plan.any (·.endsWith "Audit")) then fail "Module plan must include an Audit module"
    let searchScope := if mode == "search" then "LOCAL_SYMBOLIC_SOS_DIAGNOSTIC" else "NOT_RUN"
    if mode == "search" then
      if !plan.contains "RHFinal/Search" then fail "Core plan must contain RHFinal/Search before running search"
      let r ← IO.Process.output {cmd := lean,
        args := #["-j", "1", "-DwarningAsError=true", "--run", (root / "RHFinal/Search.lean").toString],
        env := #[("LEAN_PATH", some leanPath)]}
      let searchLog := r.stdout ++ r.stderr
      write (logs / "search.log") searchLog
      if r.exitCode != 0 then fail s!"Local diagnostic search failed\n{searchLog}"
      if !(lines searchLog).contains "SEARCH_SCOPE=LOCAL_SYMBOLIC_SOS_DIAGNOSTIC" then
        fail "Search output is missing the local-only scope marker"
      if !(lines searchLog).contains "RH_WITNESS_ACCEPTANCE=NOT_IMPLEMENTED" then
        fail "Search output is missing the actual RH acceptance status"
      IO.print searchLog
    -- Refuse an overall PASS if an input or admitted output changed during the run.
    IO.println s!"GOODWORKFLOWFRONTIER::{buildVersion}::RECHECK=INPUTS_AND_OUTPUTS"
    for i in [:treeRoots.size] do
      if (← fingerprintTree treeRoots[i]! treeTemp) != treeFingerprints[i]! then
        fail s!"External cache changed during build: {treeRoots[i]!}"
    for (source, expected) in sourceHashes do
      if (← sha256 source) != expected then fail s!"Source changed during build: {source}"
    for m in plan do
      let key := keyOf m
      let logFile := logs / (key ++ ".log")
      let expected := "NATIVE_WINDOWS_PASS\n" ++ (← moduleOutputs config m) ++ s!"LOG={← sha256 logFile}\n"
      if (← IO.FS.readFile (meta / (key ++ ".pass"))) != expected then
        fail s!"Admitted output changed during build: {m}"
    write (cache / "last-run.txt") s!"VERSION={buildVersion}\nMODE={mode}\nCOMPILED={compiled}\nREUSED={reused}\nSEARCH_SCOPE={searchScope}\nLEAN_BUILD=PASS\nACTUAL_XI_CALIBRATION=OPEN\nFINITE_WITNESS_IFF_RH=OPEN\nRH_PROVED=NO\n"
    IO.println s!"GOODWORKFLOWFRONTIER::{buildVersion}::SUMMARY=PASS;MODE={mode};COMPILED={compiled};REUSED={reused};SEARCH_SCOPE={searchScope};RH_PROVED=NO"
    return 0
  catch e =>
    if let some p := lastRun then
      try write p s!"VERSION={buildVersion}\nLEAN_BUILD=FAIL\nRH_PROVED=NO\n" catch _ => pure ()
    IO.eprintln s!"GOODWORKFLOWFRONTIER::{buildVersion}::ERROR={e}"
    IO.println s!"GOODWORKFLOWFRONTIER::{buildVersion}::SUMMARY=FAIL;RH_PROVED=NO"
    return 1
