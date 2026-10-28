#!/usr/bin/env python3
"""Assemble the exact source repair. No Lean or native compiler is run."""
from pathlib import Path
import difflib, hashlib, json, shutil, subprocess

ROOT = Path('/workspace/scratch/f128c1434505')
WORK = ROOT/'tmp/ram_parallel_v0214'
BASE = ROOT/'output/RH_HILBERT_LIMIT_LEAN_v0_2_13_construction'
OUT = ROOT/'output/RH_HILBERT_LIMIT_LEAN_v0_2_14_construction'
EV = OUT/'evidence/repair_v0214'
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,x):
    p.parent.mkdir(parents=True,exist_ok=True)
    p.write_text(json.dumps(x,indent=2)+'\n',encoding='utf-8')
assert sha(BASE/'tools/native_runner.js') == 'f6726db78ef9b532b24e2c09092e44e1e7f855c5eb84a6873c1dc519ef13803f'
assert sha(BASE.with_suffix('.zip')) == '3ca5692793ae9e637de2864b463328b15fb9e10d5babd63e54113ca320832326'
assert not OUT.exists(), 'Do not overwrite an already assembled candidate'
shutil.copytree(BASE,OUT)
(EV/'baseline_v0213_metadata').mkdir(parents=True)
for name in ['README.md','STATUS.json','PROVENANCE.json','STATIC_REVIEW.json','RUNNER_LOGIC_VALIDATION.json',
             'RUNNER_NOTES.txt','SHA256SUMS.txt','runner-version.txt']:
    shutil.copyfile(BASE/name,EV/'baseline_v0213_metadata'/name)
source=(BASE/'tools/native_runner.js').read_text()
old_source=source
def replace_once(old,new):
    global source
    assert source.count(old)==1, old
    source=source.replace(old,new)
replace_once('var PACKAGE = "RH_HILBERT_LIMIT_LEAN_v0_2_13_construction";',
             'var PACKAGE = "RH_HILBERT_LIMIT_LEAN_v0_2_14_construction";')
replace_once('var RUNNER_VERSION = "RH_HILBERT_NATIVE_RUNNER_v0_2_13_MEMORY_FALLBACK";',
             'var RUNNER_VERSION = "RH_HILBERT_NATIVE_RUNNER_v0_2_14_CAST_AND_SHUTDOWN_RECHECK";')
replace_once('if(!p.command){if(snapshot)error("LOCK_STATE_UNKNOWN: cannot exclude an active "+p.name+" worker with unreadable command line. No lock was changed.");continue;}',
             'if(!p.command){if(snapshot)throw unreadableLockWorkerError(p);continue;}')
replace_once('memoryFallback:false, ramDisabledForMemory:false};',
             'memoryFallback:false, ramDisabledForMemory:false, shutdownInventoryAttempts:0};')
replace_once('function parallelReportRamCompletion() {',
             (WORK/'shutdown_retry.js').read_text()+'\nfunction parallelReportRamCompletion() {')
replace_once('try{assertNoLockWorkers(parallelShutdownInventory(),{owner:null},lockSelf);}',
             'try{parallelAssertShutdownInventory();}')
needle='    \'  "preexisting_admitted_unresolved_hosts": \'+lockAdmittedRelativeHosts.length+",",'
replace_once(needle,needle+'\n    \'  "shutdown_inventory_attempts": \'+parallelRuntime.shutdownInventoryAttempts+",",')
(OUT/'tools/native_runner.js').write_text(source,encoding='utf-8')
(OUT/'runner-version.txt').write_text('RH_HILBERT_NATIVE_RUNNER_v0_2_14_CAST_AND_SHUTDOWN_RECHECK\n',encoding='utf-8')
lean_rel=Path('RH_HilbertLimit/CanonicalPowerSums.lean')
candidate=WORK/'proof/CanonicalPowerSums.lean'
assert sha(candidate)=='6dac0ba1d627eae6c5a70d0bb2dbdc52f0fa6474e3984d34a2d53feb48fb2160'
shutil.copyfile(candidate,OUT/lean_rel)
obligations=(BASE/'OPEN_OBLIGATIONS.txt').read_text()
assert obligations.startswith('CURRENT PACKAGE: v0.2.11 construction, native verification pending\n')
obligations=obligations.replace('CURRENT PACKAGE: v0.2.11 construction, native verification pending',
    'CURRENT PACKAGE: v0.2.14 construction, native verification pending\n'
    'Proof frontier inherited from v0.2.11; current repair changes one cast proof.',1)
(OUT/'OPEN_OBLIGATIONS.txt').write_text(obligations,encoding='utf-8')
old_lean=(BASE/lean_rel).read_text(); new_lean=(OUT/lean_rel).read_text()
before=(WORK/'proof/htarget_before.txt').read_text()
after=(WORK/'proof/htarget_after.txt').read_text()
assert old_lean.count(before)==1 and old_lean.replace(before,after)==new_lean
frozen=json.loads((BASE/'evidence/runtime_v0213/FROZEN_PROOF_AND_CACHE_INPUTS.json').read_text())
unchanged={rel:h for rel,h in frozen.items() if rel not in {lean_rel.as_posix(),'OPEN_OBLIGATIONS.txt'}}
assert len(unchanged)==101
for rel,h in unchanged.items(): assert sha(OUT/rel)==h,rel
dump(EV/'PRESERVED_PROOF_AND_CACHE_INPUTS.json',unchanged)
dump(EV/'SOURCE_CHANGE.json',{'file':lean_rel.as_posix(),'before_sha256':sha(BASE/lean_rel),
    'after_sha256':sha(OUT/lean_rel),'scope':'Only local htarget proof body; declaration statements and assumptions unchanged',
    'lean_sources_byte_preserved':91,'total_lean_sources':92,'native_compilation':'NOT_RUN'})
(EV/'NATIVE_RUNNER_DIFF.txt').write_text(''.join(difflib.unified_diff(old_source.splitlines(True),source.splitlines(True),
    fromfile=BASE.name+'/tools/native_runner.js',tofile=OUT.name+'/tools/native_runner.js')),encoding='utf-8')
syntax=subprocess.run(['node','--check',str(OUT/'tools/native_runner.js')],capture_output=True,text=True)
assert syntax.returncode==0,syntax.stderr
dump(WORK/'ASSEMBLY.json',{'package':OUT.name,'runner_sha256':sha(OUT/'tools/native_runner.js'),
    'changed_lean_sha256':sha(OUT/lean_rel),'runtime_snippet_sha256':sha(WORK/'shutdown_retry.js'),
    'preserved_inputs':101,'lean_sources_byte_preserved':91,'javascript_syntax':'PASS',
    'native_execution':'NOT_RUN'})
print((WORK/'ASSEMBLY.json').read_text())
