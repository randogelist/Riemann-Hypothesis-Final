/* Native Windows Lean 4.33.0 runner. WSH JScript only; no downloads or setup.
   Cache policy: content hashes, exact dependency graph, same-target clean audit.
   This script has not been executed on Windows as part of package preparation. */
var fso = new ActiveXObject("Scripting.FileSystemObject");
var shell = new ActiveXObject("WScript.Shell");
var env = shell.Environment("PROCESS");
var root = fso.GetAbsolutePathName(".");
var PACKAGE = "RH_HILBERT_LIMIT_LEAN_v0_2_16_construction";
var RUNNER_VERSION = "RH_HILBERT_NATIVE_RUNNER_v0_2_16_PASS_CHECKPOINT";
var SCHEMA = "RH_HILBERT_LOCAL_ANCHOR_V2";
var CACHE_LAYOUT = "COMPACT_V1";
var HELPER_SCHEMA = "RH_HILBERT_SHA256_HELPER_CACHE_V1";
var helperCacheState = "NOT_USED";
var COMPILE_POLICY = "RH_HILBERT_NATIVE_COMPILE_V1";
var AUDIT_POLICY = "RH_HILBERT_STANDARD_AXIOMS_V1";
var COMPILE_FLAGS = "native-lean4.33.0;kernel-default;output-olean;resolved-LEAN_PATH;no-extra-options;threads-nonsemantic";
var LEGACY_SCHEMA = "RH_HILBERT_NATIVE_RUNNER_v0_1_0";
/* Exact files in the published v0_1_0 ZIP, not an arbitrary schema label. */
var LEGACY_RUNNER_SHA = "413a421e81441f7161af501612bf9555e4e60d588d83f162eb2fda295834d020";
var LEGACY_CMD_SHA = "3f7df94bd9fb4c8adf1c8733792c02f002f4122d681a375cf2ee6343591b6ef5";
var TARGET = "LOCAL_COMPILER";
var logPath = root + "\\run-build.log";
var auditLogPath = root + "\\run-audit.log";
var work = root + "\\.native-build";
var helpers = work + "\\runner";
var certutil = env("SystemRoot") + "\\System32\\certutil.exe";
var comspec = env("SystemRoot") + "\\System32\\cmd.exe";
var compiler = "", prefix = "", leanVersion = "", jobs = 16;
var mathlibRoot = "", cacheRoot = "", anchorRoot = "";
var packages = [], modules = {}, ordered = [], auditTargets = {};
var finalAuditRelative = "Audit.lean", finalAuditName = "Audit", finalAuditSource = root + "\\Audit.lean";
var hashFiles = {}, fileHashes = {}, moduleKeys = {}, buildStates = {};
var artifactHashes = {}, dependencyKeys = {}, globalKey = "";
var legacyGlobalKey = "", provenance = {}, anchorRoots = [], requiredMathlib = [];
var externalDirectoryFiles = {}, externalDirectoryFamilies = {}, externalPackageLocks = {}, legacyVerified = {};
var dependencyGraphState = null;
var compiled = 0, reused = 0, failed = 0, blocked = 0, audited = 0, auditOnly = 0, migrated = 0;
var workingRetained = 0, restoredArtifactFiles = 0, anchorHistoryScans = 0, compactAnchorsSaved = 0;
var anchorSerial = 0;
var runTag = stamp() + "-" + Math.floor(Math.random() * 1000000000);
var stage = "STARTUP";
var lockPath = root + "\\.native-run.lock", lockHeld = false;
var LOCK_SCHEMA = "RH_HILBERT_RUN_LOCK_V1";
var lockOwnerText = "", lockSelf = null, lockEvents = [], lockRecovered = 0;
var lockEverHeld = false;
var lockAdmittedRelativeHosts = [], lockAdmittedRelativeOwner = "";
var activeHasher = null, hashBackendMode = "AUTO", hashBatchSerial = 0, workingDigestConsumed = 0;
var HASH_BATCH_MIN_FILES = 6;
var directLaunchCounts = {certutil:0,helper:0,csc:0,lean:0,ram_warm:0,other:0,total:0};
var hashPhaseRecords = [], stagePhaseRecords = [], modulePhaseRecords = [];
var hashPhaseTotals = {sets:0,files:0,batch_sets:0,certutil_sets:0,elapsed_ms:0,failed_sets:0};
var runtimeStarted = new Date().getTime();
var persistentStorageRoot = "E:\\RH-FAST";
var persistentWorkspacesRoot = persistentStorageRoot + "\\workspaces";
var persistentProjectCache = persistentStorageRoot + "\\anchors";
var persistentWorkspace = "", persistentPriorAnchorRoot = "", persistentProfileConfigured = false;

function trim(s) { return String(s).replace(/^\s+|\s+$/g, ""); }
function norm(p) { return fso.GetAbsolutePathName(p).replace(/\\+$/g, ""); }
function keyPath(p) { return norm(p).toLowerCase(); }
function configurePersistentProfile() {
  /* Location validation precedes every lock/log write. This profile neither
     creates nor moves a workspace; the extraction command prepares it. */
  var workspace=norm(root),boundary=keyPath(persistentWorkspacesRoot)+"\\";
  if(keyPath(workspace).indexOf(boundary)!==0)error("PERSISTENT_WORKSPACE_REQUIRED: Extract the entire "+PACKAGE+
    " ZIP under "+persistentWorkspacesRoot+" and run that extracted package's run.cmd. Current package directory: "+workspace+
    ". No fallback workspace or cache writes on C: are enabled.");
  if(!persistentProfileConfigured)persistentPriorAnchorRoot=String(env("LEAN_ANCHORINGS_ROOT")||"");
  env("LEAN_ANCHORINGS_ROOT")=persistentProjectCache;
  persistentWorkspace=workspace;persistentProfileConfigured=true;
}
function compactToken(label) { return textHash(runTag+"|"+label+"|"+Math.random()).slice(0,16); }
function shortCacheGroup(kind,inputKey) { return anchorRoot+"\\"+kind+"\\"+inputKey.slice(0,24); }
function requireShortPath(path,purpose) {
  if(norm(path).length>240)error(purpose+" exceeds the conservative Windows path budget ("+norm(path).length+" > 240): "+path+". Use a shorter extraction directory or set LEAN_ANCHORINGS_ROOT to a short writable directory.");
}
function exists(p) { return fso.FileExists(p); }
function directory(p) { return fso.FolderExists(p); }
function mkdir(p) {
  if (directory(p)) return;
  var parent = fso.GetParentFolderName(p);
  if (parent && !directory(parent)) mkdir(parent);
  fso.CreateFolder(p);
}
function read(p) {
  var stream = new ActiveXObject("ADODB.Stream");
  stream.Type = 2; stream.Charset = "utf-8"; stream.Open();
  stream.LoadFromFile(p); var s = stream.ReadText(); stream.Close();
  return String(s).replace(/^\uFEFF/, "");
}
function write(p, s) {
  mkdir(fso.GetParentFolderName(p));
  var stream = new ActiveXObject("ADODB.Stream");
  stream.Type = 2; stream.Charset = "utf-8"; stream.Open();
  stream.WriteText(s); stream.SaveToFile(p, 2); stream.Close();
}
function writeAscii(p, s) {
  /* Generated Lean headers contain ASCII identifiers only. ADODB UTF-8 adds
     a BOM, which this native Lean invocation rejected before its import. */
  if(/[^\x00-\x7f]/.test(s))error("Non-ASCII text in generated Lean audit source.");
  mkdir(fso.GetParentFolderName(p));
  var stream=fso.CreateTextFile(p,true,false);
  try{stream.Write(s);}finally{stream.Close();}
}
function append(p, s) {
  /* Keep Unicode theorem types intact in the canonical logs. */
  write(p, (exists(p) ? read(p) : "") + s);
}
function log(s) { WScript.Echo(s); append(logPath, s + "\r\n"); }
function stamp() {
  var d = new Date();
  function two(n) { return n < 10 ? "0" + n : String(n); }
  return d.getUTCFullYear() + two(d.getUTCMonth()+1) + two(d.getUTCDate()) +
    "T" + two(d.getUTCHours()) + two(d.getUTCMinutes()) + two(d.getUTCSeconds()) + "Z";
}
function error(s) { throw new Error(s); }
function fatalHashError(s) { var e=new Error("HASH_INFRASTRUCTURE_FATAL: "+s);e.rhFatalHash=true;throw e; }
function isFatalHashError(e) { return !!(e&&e.rhFatalHash===true); }
function helperUnavailableError(s) { var e=new Error(s);e.rhHelperUnavailable=true;throw e; }
function elapsedSince(start) { return Math.max(0,new Date().getTime()-start); }
function diagnosticLog(s) { try{log(s);}catch(ignoredTimingLog){try{WScript.Echo(s);}catch(ignoredEcho){}} }
function timedStage(name,action) {
  stage=name;var start=new Date().getTime(),outcome="ERROR";
  diagnosticLog("STAGE_START="+name);
  try{var value=action();outcome="RETURNED";return value;}
  finally{var ms=elapsedSince(start);stagePhaseRecords.push({name:name,elapsed_ms:ms,outcome:outcome});diagnosticLog("STAGE_ELAPSED_MS="+name+"|"+ms+"|"+outcome);}
}
function keys(obj) { var a=[]; for(var k in obj) if(obj.hasOwnProperty(k)) a.push(k); return a.sort(); }
function unique(a) { var o={}, r=[]; for(var i=0;i<a.length;i++) if(!o[a[i]]) {o[a[i]]=true;r.push(a[i]);} return r; }
function quote(s) {
  s=String(s);
  if(/["\r\n%]/.test(s)) error("Unsupported command path or argument: quote, percent, or newline.");
  return '"' + s + '"';
}
function runToFile(exe, args, output) {
  var command=quote(exe), i;
  for(i=0;i<args.length;i++) command += " " + quote(args[i]);
  command += " > " + quote(output) + " 2>&1";
  return shell.Run(quote(comspec) + ' /d /v:off /s /c "' + command + '"', 0, true);
}
function invokeNative(exe,args,output) {
  var leaf=fso.GetFileName(exe).toLowerCase(),kind="other";
  if(leaf==="lean.exe")kind="lean";
  else if(leaf==="ramwarm.exe")kind="ram_warm";
  else if(leaf==="csc.exe")kind="csc";
  else if(leaf==="helper.exe"||/^sha256-.*\.exe$/.test(leaf))kind="helper";
  directLaunchCounts[kind]++;directLaunchCounts.total++;
  return runToFile(exe,args,output);
}
function lockString(value) { return value===null||typeof value==="undefined"?"":String(value); }
function validProcessCreation(value) { return /^\d{14}\.\d{6}[+-]\d{3}$/.test(value); }
function processCreationMillis(value) {
  if(!validProcessCreation(value))return NaN;
  var ms=Date.UTC(Number(value.slice(0,4)),Number(value.slice(4,6))-1,Number(value.slice(6,8)),
    Number(value.slice(8,10)),Number(value.slice(10,12)),Number(value.slice(12,14)),Number(value.slice(15,18)));
  return ms-(value.charAt(21)==="+"?1:-1)*Number(value.slice(22))*60000;
}
function queryLockProcesses() {
  try{
    var service=GetObject("winmgmts:{impersonationLevel=impersonate}!\\\\.\\root\\cimv2");
    var items=service.ExecQuery("SELECT ProcessId, ParentProcessId, CreationDate, Name, CommandLine FROM Win32_Process","WQL",48);
    var en=new Enumerator(items),out=[],seen={};
    for(;!en.atEnd();en.moveNext()){
      var p=en.item(),pid=Number(p.ProcessId),parent=Number(p.ParentProcessId),name=lockString(p.Name).toLowerCase();
      if(!(pid>=0&&Math.floor(pid)===pid)||seen[pid])error("Incomplete or inconsistent process inventory.");
      if(pid>0&&!name)error("Process inventory contains an unreadable executable name.");
      seen[pid]=true;
      out.push({pid:pid,parent:parent,created:lockString(p.CreationDate),name:name,command:lockString(p.CommandLine)});
    }
    if(!out.length)error("Empty process inventory.");
    return out;
  }catch(e){error("LOCK_STATE_UNKNOWN: Windows process ownership could not be verified. No existing lock was changed. "+e.message);}
}
function commandHasArgument(command,argument) {
  var c=String(command).replace(/\//g,"\\").toLowerCase(),a=String(argument).replace(/\//g,"\\").toLowerCase();
  return c.indexOf('"'+a+'"')>=0||(" "+c+" ").indexOf(" "+a+" ")>=0;
}
function lockLaunchToken() {
  var args=WScript.Arguments,token="";
  for(var i=0;i<args.length;i++){
    var match=/^--runner-token=([A-Za-z0-9_-]{7,128})$/.exec(String(args.Item(i)));
    if(match){if(token)error("LOCK_STATE_UNKNOWN: duplicate runner token.");token=match[1];}
  }
  if(!token)error("LOCK_STATE_UNKNOWN: launch this package through its single run.cmd so process ownership can be identified.");
  return token;
}
function identifyLockSelf(processes,token) {
  var script=keyPath(WScript.ScriptFullName),expected=keyPath(root+"\\tools\\native_runner.js"),found=[];
  if(script!==expected)error("LOCK_STATE_UNKNOWN: runner script and working package directory differ; use run.cmd.");
  for(var i=0;i<processes.length;i++){
    var p=processes[i];
    if((p.name==="cscript.exe"||p.name==="wscript.exe")&&commandHasArgument(p.command,script)&&commandHasArgument(p.command,"--runner-token="+token))found.push(p);
  }
  if(found.length!==1||!validProcessCreation(found[0].created)||!(found[0].pid>0))error("LOCK_STATE_UNKNOWN: current script process was not uniquely identified. No existing lock was changed.");
  found[0].token=token;found[0].script=script;return found[0];
}
function formatLockOwner(owner) {
  return "SCHEMA="+LOCK_SCHEMA+"\nROOT="+owner.ROOT+"\nSCRIPT="+owner.SCRIPT+"\nPID="+owner.PID+
    "\nCREATED="+owner.CREATED+"\nTOKEN="+owner.TOKEN+"\nRUN_TAG="+owner.RUN_TAG+"\n";
}
function lockSnapshotAt(path) {
  if(!directory(path)){if(exists(path))error("LOCK_STATE_UNKNOWN: lock path is a file: "+path);return null;}
  var files=listFiles(path),dirs=subfolders(path);
  if(dirs.length||files.length>1||(files.length===1&&fso.GetFileName(files[0]).toLowerCase()!=="owner.txt"))error("LOCK_STATE_UNKNOWN: unexpected files in runner lock; it was preserved.");
  var created=new Date(fso.GetFolder(path).DateCreated).getTime();
  if(!isFinite(created))error("LOCK_STATE_UNKNOWN: lock creation identity is unavailable.");
  var text=files.length?read(files[0]):"",owner=null,kind="LEGACY_EMPTY";
  if(trim(text)){
    if(/^\d{8}T\d{6}Z-\d{1,9}$/.test(trim(text)))kind="LEGACY_RUN_TAG";
    else{
      owner=parseReceipt(text);
      if(owner.SCHEMA!==LOCK_SCHEMA||owner.ROOT!==keyPath(root)||owner.SCRIPT!==keyPath(root+"\\tools\\native_runner.js")||
        !/^[1-9]\d*$/.test(owner.PID||"")||!validProcessCreation(owner.CREATED||"")||
        !/^[A-Za-z0-9_-]{7,128}$/.test(owner.TOKEN||"")||!/^\d{8}T\d{6}Z-\d{1,9}$/.test(owner.RUN_TAG||"")||
        text!==formatLockOwner(owner))error("LOCK_STATE_UNKNOWN: unrecognized or incomplete owner metadata; it was preserved.");
      kind="OWNED_V1";
    }
  }
  var generation=textHash("LOCK_GENERATION_V1\nROOT="+keyPath(root)+"\nCREATED="+created+"\nHAS_OWNER="+files.length+"\n"+text);
  return {text:text,owner:owner,kind:kind,created:created,generation:generation};
}
function lockSnapshot() { return lockSnapshotAt(lockPath); }
function processIdentity(p) { return p.pid+"|"+p.created; }
function lockAncestors(processes,self) {
  var byPid={},out={},current=self,visited={};
  for(var i=0;i<processes.length;i++)byPid[processes[i].pid]=processes[i];
  for(i=0;i<64;i++){
    if(visited[current.pid])break;visited[current.pid]=true;
    out[processIdentity(current)]=true;
    var parent=byPid[current.parent];
    if(!parent||!validProcessCreation(parent.created))break;
    var parentMillis=processCreationMillis(parent.created),childMillis=processCreationMillis(current.created);
    if(parentMillis>childMillis||(parentMillis===childMillis&&Number(parent.created.slice(18,21))>Number(current.created.slice(18,21))))break;
    current=parent;
  }
  return out;
}
function assertNoLockWorkers(processes,snapshot,self) {
  var excluded=lockAncestors(processes,self),needle=keyPath(root)+"\\";
  if(snapshot&&snapshot.owner){
    for(var oi=0;oi<processes.length;oi++)if(String(processes[oi].pid)===snapshot.owner.PID){
      if(!validProcessCreation(processes[oi].created))error("LOCK_STATE_UNKNOWN: recorded owner PID has no readable creation identity.");
      if(processes[oi].created===snapshot.owner.CREATED)error("RUNNER_ACTIVE: PID="+snapshot.owner.PID+" still owns this package lock. Let that worker finish; no lock was changed.");
    }
  }
  for(var i=0;i<processes.length;i++){
    var p=processes[i];if(excluded[processIdentity(p)])continue;
    var relevant=/^(?:cscript|wscript|cmd|lean|csc|certutil|helper|ramwarm)\.exe$/.test(p.name)||/^sha256-.*\.exe$/.test(p.name);
    if(!relevant)continue;
    if(!p.command){if(snapshot)throw unreadableLockWorkerError(p);continue;}
    var command=p.command.replace(/\//g,"\\").toLowerCase();
    /* Persistent /k shells can remain idle after run.cmd finishes; live script
       hosts and /c compiler workers are checked separately. */
    if(p.name==="cmd.exe"&&!/(?:^|\s)[\/]c(?:\s|"|$)/i.test(p.command))continue;
    if(command.indexOf(needle)>=0)error("RUNNER_ACTIVE: related worker PID="+p.pid+" ("+p.name+") is still using this package. No lock was changed.");
    if(p.name==="cscript.exe"||p.name==="wscript.exe"){
      var scriptArg=/(?:"([^"]*native_runner\.js)"|([^\s"]*native_runner\.js))(?=\s|$)/i.exec(command);
      if(scriptArg){
        var arg=scriptArg[1]||scriptArg[2];
        if(/^(?:[a-z]:\\|\\\\)/i.test(arg)){
          if(keyPath(arg)===keyPath(root+"\\tools\\native_runner.js"))error("RUNNER_ACTIVE: another script host is using this package. No lock was changed.");
        }else if(snapshot)error("LOCK_STATE_UNKNOWN: a legacy relative-path native_runner.js is active; its package cannot be distinguished. No lock was changed.");
      }
    }
  }
}
function quarantineStaleLock(snapshot) {
  var processes=queryLockProcesses(),self=identifyLockSelf(processes,lockSelf.token);
  if(processIdentity(self)!==processIdentity(lockSelf))error("LOCK_STATE_UNKNOWN: runner process identity changed.");
  assertNoLockWorkers(processes,snapshot,self);
  var latest=lockSnapshot();
  if(!latest||latest.generation!==snapshot.generation)error("RUNNER_LOCK_CHANGED: another worker changed the lock; retry after it finishes.");
  var parent=root+"\\.native-stale-locks",dest=parent+"\\"+snapshot.generation;
  requireShortPath(dest+"\\owner.txt","Retired lock path");mkdir(parent);
  if(directory(dest)||exists(dest))error("RUNNER_LOCK_RECOVERY_RACE: this lock generation already has a recovery record; the current lock was preserved.");
  /* A deterministic, permanent, non-overwriting destination prevents a second
     reclaimer from moving a newly published lock after losing the first move. */
  try{fso.MoveFolder(lockPath,dest);}catch(moveError){error("RUNNER_LOCK_RECOVERY_RACE: lock ownership changed during recovery; no replacement lock was removed. "+moveError.message);}
  var moved=lockSnapshotAt(dest);
  if(!moved||moved.generation!==snapshot.generation){
    /* Keep the tombstone even on uncertainty: removing it would allow an old
       observer to move a future lock into this generation's destination. */
    error("LOCK_STATE_UNKNOWN: recovered directory did not match the observed generation; no ownership was accepted.");
  }
  lockRecovered++;lockEvents.push("STALE_LOCK_RECOVERED="+snapshot.kind);lockEvents.push("STALE_LOCK_RECORD="+dest);
}
function acquireRunnerLock() {
  var token=lockLaunchToken(),processes=queryLockProcesses();
  lockSelf=identifyLockSelf(processes,token);
  var snapshot=lockSnapshot();assertNoLockWorkers(processes,snapshot,lockSelf);
  lockOwnerText=formatLockOwner({ROOT:keyPath(root),SCRIPT:lockSelf.script,PID:String(lockSelf.pid),CREATED:lockSelf.created,TOKEN:token,RUN_TAG:runTag});
  var pending=root+"\\.native-lock-"+textHash(lockOwnerText).slice(0,24)+".pending";
  requireShortPath(pending+"\\owner.txt","Staged lock path");
  if(directory(pending)||exists(pending))error("RUNNER_LOCK_STAGING_COLLISION: an existing staging directory was preserved.");
  mkdir(pending);write(pending+"\\owner.txt",lockOwnerText);
  try{
    if(snapshot)quarantineStaleLock(snapshot);
    /* A complete owner record is published in a single same-volume move. */
    try{fso.MoveFolder(pending,lockPath);}catch(publishError){error("RUNNER_LOCK_BUSY: another worker acquired this package; its lock was preserved. "+publishError.message);}
    var owned=lockSnapshot();
    if(!owned||owned.text!==lockOwnerText)error("LOCK_STATE_UNKNOWN: new ownership could not be verified.");
    lockHeld=true;lockEverHeld=true;lockEvents.push("RUNNER_LOCK=OWNED_PID_"+lockSelf.pid);
    captureFreshAdmittedRelativeHosts(processes,snapshot,lockSelf);
  }finally{
    if(directory(pending)&&exists(pending+"\\owner.txt")&&read(pending+"\\owner.txt")===lockOwnerText){try{fso.DeleteFolder(pending,true);}catch(stagingError){}}
  }
}
function releaseRunnerLock() {
  if(!lockHeld)return false;
  try{
    var snapshot=lockSnapshot();
    if(!snapshot||snapshot.text!==lockOwnerText){WScript.Echo("LOCK_RELEASE_SKIPPED=OWNER_CHANGED");lockHeld=false;return false;}
    fso.DeleteFolder(lockPath,true);lockHeld=false;return true;
  }catch(e){WScript.Echo("LOCK_CLEANUP_FAILED="+lockPath+" : "+e.message);lockHeld=false;return false;}
}
function textHash(s) {
  /* SHA-256 of UTF-8 for canonical manifests; file hashes retain exact bytes. */
  var bytes=unescape(encodeURIComponent(s)), w=[], len=bytes.length, i,j;
  for(i=0;i<len;i++) w[i>>2]=(w[i>>2]||0)|(bytes.charCodeAt(i)<<(24-(i%4)*8));
  w[len>>2]=(w[len>>2]||0)|(0x80<<(24-(len%4)*8));
  var size=(((len+8)>>6)+1)*16;
  for(i=0;i<size;i++) if(typeof w[i]==="undefined") w[i]=0;
  w[size-2]=Math.floor(len/0x20000000); w[size-1]=(len*8)|0;
  var K=[0x428a2f98,0x71374491,0xb5c0fbcf,0xe9b5dba5,0x3956c25b,0x59f111f1,0x923f82a4,0xab1c5ed5,
    0xd807aa98,0x12835b01,0x243185be,0x550c7dc3,0x72be5d74,0x80deb1fe,0x9bdc06a7,0xc19bf174,
    0xe49b69c1,0xefbe4786,0x0fc19dc6,0x240ca1cc,0x2de92c6f,0x4a7484aa,0x5cb0a9dc,0x76f988da,
    0x983e5152,0xa831c66d,0xb00327c8,0xbf597fc7,0xc6e00bf3,0xd5a79147,0x06ca6351,0x14292967,
    0x27b70a85,0x2e1b2138,0x4d2c6dfc,0x53380d13,0x650a7354,0x766a0abb,0x81c2c92e,0x92722c85,
    0xa2bfe8a1,0xa81a664b,0xc24b8b70,0xc76c51a3,0xd192e819,0xd6990624,0xf40e3585,0x106aa070,
    0x19a4c116,0x1e376c08,0x2748774c,0x34b0bcb5,0x391c0cb3,0x4ed8aa4a,0x5b9cca4f,0x682e6ff3,
    0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2];
  var H=[0x6a09e667,0xbb67ae85,0x3c6ef372,0xa54ff53a,0x510e527f,0x9b05688c,0x1f83d9ab,0x5be0cd19];
  function rr(x,n){return(x>>>n)|(x<<(32-n));}
  for(i=0;i<size;i+=16){
    var W=[], a=H[0],b=H[1],c=H[2],d=H[3],e=H[4],f=H[5],g=H[6],h=H[7];
    for(j=0;j<64;j++){
      if(j<16) W[j]=w[i+j];
      else {var x=W[j-15],y=W[j-2]; W[j]=(W[j-16]+(rr(x,7)^rr(x,18)^(x>>>3))+W[j-7]+(rr(y,17)^rr(y,19)^(y>>>10)))|0;}
      var t1=(h+(rr(e,6)^rr(e,11)^rr(e,25))+((e&f)^((~e)&g))+K[j]+W[j])|0;
      var t2=((rr(a,2)^rr(a,13)^rr(a,22))+((a&b)^(a&c)^(b&c)))|0;
      h=g;g=f;f=e;e=(d+t1)|0;d=c;c=b;b=a;a=(t1+t2)|0;
    }
    var v=[a,b,c,d,e,f,g,h]; for(j=0;j<8;j++)H[j]=(H[j]+v[j])|0;
  }
  var out="";for(i=0;i<8;i++)out+=("00000000"+(H[i]>>>0).toString(16)).slice(-8);return out;
}
function isCertutilInvalidFileError(output,code) {
  if(typeof code!=="number"||!isFinite(code)||code===0)return false;
  if(code===1006||(code>>>0)===0x800703ee)return true;
  return /(?:^|\r?\n)CertUtil:[^\r\n]*\b0x800703ee\b[^\r\n]*\(\s*WIN32:\s*1006\s+ERROR_FILE_INVALID\s*\)/i.test(String(output));
}
function verifiedEmptyFileHash(path) {
  /* Metadata is only a prefilter. Load actual bytes into a fresh binary
     stream; neither decoded text nor a file-size record establishes emptiness. */
  if(Number(fso.GetFile(path).Size)!==0)return "";
  var stream=new ActiveXObject("ADODB.Stream"),opened=false;
  try{
    stream.Type=1;stream.Open();opened=true;stream.LoadFromFile(path);
    if(Number(stream.Size)!==0||Number(stream.Position)!==0||stream.EOS!==true)return "";
  }finally{if(opened)stream.Close();}
  if(Number(fso.GetFile(path).Size)!==0)error("File changed while verifying an empty SHA256 input: "+path);
  diagnosticLog("SHA256_EMPTY_FILE_VERIFIED="+path+"|BYTES=0|BACKEND=ADODB_BINARY");
  return textHash("");
}
function hashOutput(output, code, path) {
  if(code!==0){
    if(isCertutilInvalidFileError(output,code)){
      var emptySHA=verifiedEmptyFileHash(path);if(emptySHA!=="")return emptySHA;
    }
    error("SHA256 command failed for " + path + " : " + output);
  }
  var lines=output.split(/\r?\n/), found=[];
  for(var i=0;i<lines.length;i++) {var x=lines[i].replace(/\s/g,"");if(/^[a-fA-F0-9]{64}$/.test(x))found.push(x.toLowerCase());}
  if(found.length!==1)error("Unrecognized certutil SHA256 result for " + path);
  return found[0];
}
function fileHash(path) {
  if(!exists(path))error("Cannot fingerprint missing file: " + path);
  try{
    var proc=launchCertutil(path),output=proc.StdOut.ReadAll()+proc.StdErr.ReadAll();
    while(proc.Status===0)WScript.Sleep(10);
    return hashOutput(output,proc.ExitCode,path);
  }catch(e){if(isFatalHashError(e))throw e;fatalHashError(e.message);}
}
function requestHash(path) { var normalized=norm(path);hashFiles[normalized.toLowerCase()]=normalized; }
function launchCertutil(path) {
  directLaunchCounts.certutil++;directLaunchCounts.total++;
  return shell.Exec(quote(certutil)+" -hashfile "+quote(path)+" SHA256");
}
function certutilHashSet(todo,requested,purpose) {
  var active=[],cursor=0,done=0,lastReport=0,out={},failure="",limit=resourceHashJobs();
  while((cursor<todo.length&&!failure)||active.length){
    while(!failure&&cursor<todo.length&&active.length<limit){
      var key=todo[cursor++],p=requested[key];
      try{active.push({key:key,path:p,proc:launchCertutil(p)});}
      catch(startError){failure=startError.message;}
    }
    for(var i=active.length-1;i>=0;i--){
      var x=active[i];if(x.proc.Status===0)continue;
      try{
        var output=x.proc.StdOut.ReadAll()+x.proc.StdErr.ReadAll();
        out[x.key]=hashOutput(output,x.proc.ExitCode,x.path);
      }catch(hashError){if(!failure)failure=hashError.message;}
      active.splice(i,1);done++;
    }
    if(purpose==="DEPENDENCIES"&&(done-lastReport>=256||done===todo.length)){
      log("DEPENDENCY_HASH_PROGRESS="+done+"/"+todo.length);lastReport=done;
    }
    if(active.length)WScript.Sleep(10);
  }
  if(failure)fatalHashError(failure);
  if(done!==todo.length)fatalHashError("Incomplete independent certutil hash set.");
  return out;
}
function certutilHashes(todo) {
  var completed=certutilHashSet(todo,hashFiles,"DEPENDENCIES");
  for(var i=0;i<todo.length;i++)fileHashes[todo[i]]=completed[todo[i]];
}
function freshHashSet(paths,purpose,forceCertutil) {
  var started=new Date().getTime(),requested={},todo=[],backend="PREFLIGHT",outcome="ERROR",out;
  purpose=String(purpose||"FILES");
  try{
    for(var i=0;i<paths.length;i++)requested[keyPath(paths[i])]=norm(paths[i]);
    todo=keys(requested);
    for(i=0;i<todo.length;i++)if(!exists(requested[todo[i]]))error("Cannot fingerprint missing file: "+requested[todo[i]]);
    if(!todo.length){backend="NONE";out={};}
    else{
      if(!forceCertutil&&hashBackendMode==="BATCH"&&!activeHasher)fatalHashError("Required validated batch helper is unavailable.");
      backend=!forceCertutil&&activeHasher&&hashBackendMode!=="CERTUTIL"&&todo.length>=HASH_BATCH_MIN_FILES?"BATCH":"CERTUTIL";
      try{
        if(backend==="BATCH")out=batchHashes(todo,activeHasher,requested,purpose);
        else out=certutilHashSet(todo,requested,purpose);
      }catch(transportError){if(isFatalHashError(transportError))throw transportError;fatalHashError(transportError.message);}
    }
    outcome="COMPLETE";return out;
  }finally{
    var ms=elapsedSince(started);
    hashPhaseTotals.sets++;hashPhaseTotals.files+=todo.length;hashPhaseTotals.elapsed_ms+=ms;
    if(backend==="BATCH")hashPhaseTotals.batch_sets++;
    if(backend==="CERTUTIL")hashPhaseTotals.certutil_sets++;
    if(outcome!=="COMPLETE")hashPhaseTotals.failed_sets++;
    hashPhaseRecords.push({name:purpose,files:todo.length,backend:backend,elapsed_ms:ms,outcome:outcome});
    diagnosticLog("HASH_PHASE="+purpose+"|FILES="+todo.length+"|BACKEND="+backend+"|ELAPSED_MS="+ms+"|"+outcome);
  }
}
function hasherInput(source,csc) {
  var dir=fso.GetParentFolderName(csc),files=[],presentPaths=[source],presence={};
  var required=[csc,dir+"\\mscorlib.dll",dir+"\\System.dll",dir+"\\System.Core.dll"];
  var optional=[dir+"\\csc.exe.config",dir+"\\cscomp.dll",dir+"\\Microsoft.CSharp.dll",
    dir+"\\clr.dll",dir+"\\clrjit.dll",dir+"\\mscoreei.dll",dir+"\\System.Security.dll",
    dir+"\\System.Configuration.dll",dir+"\\System.Xml.dll",dir+"\\Config\\machine.config",
    env("SystemRoot")+"\\System32\\mscoree.dll",env("SystemRoot")+"\\SysWOW64\\mscoree.dll"];
  var paths=required.concat(optional).sort();
  for(var i=0;i<paths.length;i++){
    var p=paths[i],present=exists(p),must=false;
    for(var j=0;j<required.length;j++)if(keyPath(p)===keyPath(required[j]))must=true;
    if(!present&&must)error("Missing installed hash-helper compiler/reference input: "+p);
    presence[keyPath(p)]=present;if(present)presentPaths.push(p);
  }
  var digests=freshHashSet(presentPaths,"HELPER_INPUTS",true),sourceSHA=digests[keyPath(source)];
  var manifest=HELPER_SCHEMA+"\nTARGET="+TARGET+"\nSOURCE_SHA256="+sourceSHA+
    "\nFLAGS=/nologo /noconfig /target:exe /optimize+ /platform:anycpu;System.dll;System.Core.dll;implicit-mscorlib\n";
  files.push({path:source,sha:sourceSHA});
  for(i=0;i<paths.length;i++){
    p=paths[i];var sha=presence[keyPath(p)]?digests[keyPath(p)]:"ABSENT";
    files.push({path:p,sha:sha});manifest+=keyPath(p)+"="+sha+"\n";
  }
  return {key:textHash(manifest),manifest:manifest,files:files,sourceSHA:sourceSHA,dir:dir};
}
function recheckHasherInput(input) {
  var presentPaths=[],i;
  for(i=0;i<input.files.length;i++){
    var f=input.files[i],present=exists(f.path);
    if(present!==(f.sha!=="ABSENT"))fatalHashError("Hash-helper input presence changed: "+f.path);
    if(present)presentPaths.push(f.path);
  }
  var digests=freshHashSet(presentPaths,"HELPER_INPUTS_RECHECK",true);
  for(i=0;i<input.files.length;i++){
    f=input.files[i];var now=f.sha==="ABSENT"?"ABSENT":digests[keyPath(f.path)];
    if(now!==f.sha)fatalHashError("Hash-helper source, compiler, reference or runtime input changed: "+f.path);
  }
}
function selfTestHasher(exe,output) {
  try{
    if(invokeNative(exe,["--self-test"],output)!==0||!exists(output)||trim(read(output))!=="BATCH_SHA256_SELF_TEST=PASS")helperUnavailableError("Native SHA256 helper self-test failed: "+exe);
  }catch(e){if(isFatalHashError(e)||e.rhHelperUnavailable)throw e;helperUnavailableError(e.message);}
}
function useHasher(exe,exeSHA,source,input,state,receipt) {
  helperCacheState=state;
  write(helpers+"\\hash-helper-provenance.txt","SCHEMA="+HELPER_SCHEMA+"\nTARGET="+TARGET+"\nSOURCE="+source+
    "\nSOURCE_SHA256="+input.sourceSHA+"\nINPUT_SHA256="+input.key+"\nHELPER="+exe+"\nHELPER_SHA256="+exeSHA+
    "\nCACHE="+state+"\nRECEIPT="+receipt+"\n");
  log("BATCH_HASH_HELPER_CACHE="+state);log("BATCH_HASH_HELPER_SOURCE_SHA256="+input.sourceSHA);log("BATCH_HASH_HELPER_EXE_SHA256="+exeSHA);
  return {exe:exe,exeSHA:exeSHA,source:source,sourceSHA:input.sourceSHA};
}
function prepareBatchHasher(strict) {
  var framework=env("SystemRoot")+"\\Microsoft.NET\\",candidates=[framework+"Framework64\\v4.0.30319\\csc.exe",framework+"Framework\\v4.0.30319\\csc.exe"],csc="";
  for(var i=0;i<candidates.length;i++)if(exists(candidates[i])){csc=candidates[i];break;}
  if(!csc){
    if(strict)error("RH_HASH_MODE=BATCH requires an existing .NET Framework v4 csc.exe.");
    log("BATCH_HASH_FALLBACK=NET_FRAMEWORK_CSC_UNAVAILABLE");return null;
  }
  var source=root+"\\tools\\NativeSha256.cs",input;
  try{input=hasherInput(source,csc);}
  catch(inputError){if(strict||isFatalHashError(inputError))throw inputError;log("BATCH_HASH_FALLBACK="+inputError.message);return null;}
  var parent=shortCacheGroup("hashers",input.key),entries=subfolders(parent).reverse();
  for(i=0;i<entries.length;i++){
    var folder=entries[i],selfTestStarted=false;if(/\.pending$/.test(folder)||!exists(folder+"\\receipt.txt"))continue;
    try{
      var r=parseReceipt(read(folder+"\\receipt.txt")),exe=folder+"\\helper.exe";
      if(r.SCHEMA!==HELPER_SCHEMA||r.TARGET!==TARGET||r.INPUT_SHA256!==input.key||r.SOURCE_SHA256!==input.sourceSHA||r.BUILD_PASS!=="1"||r.SELF_TEST_PASS!=="1")error("Hash-helper receipt identity or success fields do not match.");
      var checked=freshHashSet([folder+"\\source.cs",exe,folder+"\\build.log",folder+"\\selftest.log"],"HELPER_CACHE",true);
      if(read(folder+"\\input.txt")!==input.manifest||checked[keyPath(folder+"\\source.cs")]!==input.sourceSHA)error("Cached hash-helper inputs do not match.");
      if(checked[keyPath(exe)]!==r.EXE_SHA256||checked[keyPath(folder+"\\build.log")]!==r.BUILD_LOG_SHA256||checked[keyPath(folder+"\\selftest.log")]!==r.SELF_TEST_LOG_SHA256)error("Cached hash-helper content is corrupt.");
      if(trim(read(folder+"\\selftest.log"))!=="BATCH_SHA256_SELF_TEST=PASS")error("Cached hash-helper has no exact successful self-test.");
      selfTestStarted=true;selfTestHasher(exe,helpers+"\\hasher-selftest-"+runTag+".log");
      recheckHasherInput(input);
      if(fileHash(exe)!==r.EXE_SHA256)fatalHashError("Cached hash helper changed during validation.");
      return useHasher(exe,r.EXE_SHA256,source,input,"HIT",folder+"\\receipt.txt");
    }catch(cacheError){
      if(isFatalHashError(cacheError))throw cacheError;
      if((strict&&cacheError.rhHelperUnavailable)||(selfTestStarted&&!cacheError.rhHelperUnavailable))fatalHashError(cacheError.message);
      log("BATCH_HASH_HELPER_REJECTED="+folder+" : "+cacheError.message);
    }
  }
  var dest=parent+"\\"+compactToken("hasher"),temp=dest+".pending",builtSelfTestStarted=false;
  try{
    requireShortPath(temp+"\\selftest.log","Hash-helper cache path");
    if(directory(dest)||directory(temp))error("Unique hash-helper cache directory collision.");mkdir(temp);
    var helper=temp+"\\helper.exe",sourceCopy=temp+"\\source.cs",compileLog=temp+"\\build.log",testLog=temp+"\\selftest.log";
    fso.CopyFile(source,sourceCopy,false);
    if(fileHash(sourceCopy)!==input.sourceSHA)error("Hash-helper source copy verification failed.");
    var args=["/nologo","/noconfig","/target:exe","/optimize+","/platform:anycpu",
      "/reference:"+input.dir+"\\System.dll","/reference:"+input.dir+"\\System.Core.dll","/out:"+helper,sourceCopy];
    log("BATCH_HASH_HELPER_BUILD=EXISTING_NET_FRAMEWORK_CSC");
    var rc=invokeNative(csc,args,compileLog);
    if(rc!==0||!exists(helper)){
      if(exists(compileLog))log(read(compileLog));
      error("Native SHA256 helper compilation failed.");
    }
    var helperSHA=fileHash(helper);builtSelfTestStarted=true;selfTestHasher(helper,testLog);recheckHasherInput(input);
    if(fileHash(sourceCopy)!==input.sourceSHA||fileHash(helper)!==helperSHA)fatalHashError("Hash-helper artifacts changed during validation.");
    write(temp+"\\input.txt",input.manifest);
    write(temp+"\\receipt.txt","SCHEMA="+HELPER_SCHEMA+"\nTARGET="+TARGET+"\nINPUT_SHA256="+input.key+
      "\nSOURCE_SHA256="+input.sourceSHA+"\nEXE_SHA256="+helperSHA+"\nBUILD_LOG_SHA256="+fileHash(compileLog)+
      "\nSELF_TEST_LOG_SHA256="+fileHash(testLog)+"\nBUILD_PASS=1\nSELF_TEST_PASS=1\nTIME_UTC="+stamp()+"\n");
    fso.MoveFolder(temp,dest);
    return useHasher(dest+"\\helper.exe",helperSHA,source,input,"BUILT_AND_SAVED",dest+"\\receipt.txt");
  }catch(buildError){
    if(directory(temp)){try{fso.DeleteFolder(temp,true);}catch(ignoredCleanup){}}
    if(isFatalHashError(buildError))throw buildError;
    if((strict&&buildError.rhHelperUnavailable)||(builtSelfTestStarted&&!buildError.rhHelperUnavailable))fatalHashError(buildError.message);
    if(strict)throw buildError;
    log("BATCH_HASH_FALLBACK="+buildError.message);return null;
  }
}
function parseBatchHashes(todo,text,token,requestSHA,requested) {
  requested=requested||hashFiles;
  var lines=String(text).split(/\r?\n/),n=todo.length,out={};
  if(lines.length&&lines[lines.length-1]==="")lines.pop();
  if(lines.length!==n+2)error("Batch SHA256 result has missing or extra rows.");
  if(lines[0]!=="RH_HILBERT_SHA256_RESULT_V1|"+token+"|"+n+"|"+requestSHA)error("Batch SHA256 result schema, request token, count or request hash does not match.");
  if(lines[n+1]!=="COMPLETE|"+token+"|"+n)error("Batch SHA256 result lacks its exact completion record.");
  for(var i=0;i<n;i++){
    var pair=lines[i+1].split("|");
    if(pair.length!==2||pair[0]!==String(i)||!/^[a-f0-9]{64}$/.test(pair[1]))error("Batch SHA256 result has a duplicate, unknown, unordered or invalid row: "+i);
    if(!requested[todo[i]]||out.hasOwnProperty(todo[i]))error("Batch SHA256 request identity is inconsistent.");
    out[todo[i]]=pair[1];
  }
  return out;
}
function batchHashes(todo,helper,requested,purpose) {
  requested=requested||hashFiles;purpose=purpose||"DEPENDENCIES";
  try{
    var token=compactToken("hash-"+(++hashBatchSerial)),request=helpers+"\\sha256-"+token+".request.tsv";
    var resultFile=helpers+"\\sha256-"+token+".result.tsv",output=helpers+"\\sha256-"+token+".run.log";
    requireShortPath(resultFile+".pending","Batch SHA256 request/result path");
    if(exists(request)||exists(resultFile)||exists(resultFile+".pending"))error("Unique batch hash request/result collision.");
    var requestRows=["RH_HILBERT_SHA256_REQUEST_V1|"+token+"|"+todo.length];
    for(var i=0;i<todo.length;i++){
      var path=requested[todo[i]];
      if(!path||/[\x00-\x1f|]/.test(path))error("Unsupported or missing path in hash request.");
      requestRows.push(i+"|"+path);
    }
    write(request,requestRows.join("\n")+"\n");var requestSHA=fileHash(request),workers=resourceHashJobs();
    if(purpose==="DEPENDENCIES")log("DEPENDENCY_HASH_MODE=SHA256_CONTENT_BATCH_"+workers);
    log("HASH_PROGRESS_LOG="+purpose+"|"+output);
    /* The validated helper is reused; request/result maps are fresh for each phase. */
    var rc=invokeNative(helper.exe,[request,resultFile,String(workers),token],output);
    if(exists(output)){var contents=read(output);if(contents)log(contents);}
    if(rc!==0)fatalHashError("Native batch SHA256 helper failed; no partial hashes are accepted.");
    var guards={};guards[keyPath(helper.exe)]=helper.exe;guards[keyPath(helper.source)]=helper.source;guards[keyPath(request)]=request;
    var checked=certutilHashSet(keys(guards),guards,"BATCH_GUARDS");
    if(checked[keyPath(helper.exe)]!==helper.exeSHA||checked[keyPath(helper.source)]!==helper.sourceSHA||checked[keyPath(request)]!==requestSHA)fatalHashError("Batch hash helper, source or request changed during hashing.");
    if(!exists(resultFile))fatalHashError("Batch SHA256 helper returned without a result manifest.");
    var completed=parseBatchHashes(todo,read(resultFile),token,requestSHA,requested);
    if(purpose==="DEPENDENCIES")log("DEPENDENCY_HASH_PROGRESS="+todo.length+"/"+todo.length);
    return completed;
  }catch(e){if(isFatalHashError(e))throw e;fatalHashError(e.message);}
}
function parallelHashes() {
  var todo=keys(hashFiles),mode=trim(env("RH_HASH_MODE")||"AUTO").toUpperCase();
  if(mode!=="AUTO"&&mode!=="CERTUTIL"&&mode!=="BATCH")error("RH_HASH_MODE must be AUTO, CERTUTIL or BATCH.");
  hashBackendMode=mode;activeHasher=null;
  log("DEPENDENCY_CONTENT_FILES="+todo.length);log("RH_HASH_MODE="+mode);log("HASH_BATCH_MIN_FILES="+HASH_BATCH_MIN_FILES);
  activeHasher=mode==="CERTUTIL"?null:prepareBatchHasher(mode==="BATCH");
  var paths=[];for(var i=0;i<todo.length;i++)paths.push(hashFiles[todo[i]]);
  if(!activeHasher)log("DEPENDENCY_HASH_MODE=SHA256_CONTENT_PARALLEL_"+Math.min(jobs,16));
  var completed=freshHashSet(paths,"DEPENDENCIES",false);
  for(i=0;i<todo.length;i++)fileHashes[todo[i]]=completed[todo[i]];
}
function sourceClean(s, strict) {
  /* Preserve newlines while removing nested comments and string literals. */
  var out="",depth=0,inString=false,i=0;
  while(i<s.length){var a=s.charAt(i),b=s.charAt(i+1);
    if(depth){if(a==="/"&&b==="-"){depth++;out+="  ";i+=2;}else if(a==="-"&&b==="/"){depth--;out+="  ";i+=2;}else{out+=a==="\n"?"\n":" ";i++;}continue;}
    if(inString){if(a==="\\"){out+="  ";i+=2;}else{if(a==='"')inString=false;out+=a==="\n"?"\n":" ";i++;}continue;}
    if(a==="/"&&b==="-"){depth=1;out+="  ";i+=2;continue;}
    if(a==="-"&&b==="-"){while(i<s.length&&s.charAt(i)!=="\n"){out+=" ";i++;}continue;}
    if(a==='"'){inString=true;out+=" ";i++;continue;}
    out+=a;i++;
  }
  if(strict!==false && (depth||inString))error("Unclosed comment or string in Lean source scan.");
  return out;
}
function beginDependencyGraph() {
  /* These indexes belong only to this graph walk. No source text or digest is
     reused from the earlier requirements check or from any previous run. */
  externalDirectoryFiles={};externalDirectoryFamilies={};externalPackageLocks={};
  var now=new Date().getTime();
  dependencyGraphState={active:true,started:now,lastProgress:now,local_modules:0,external_modules:0,
    source_files:0,source_chars:0,import_prefix_chars:0,strict_scan_chars:0,
    artifact_directories:0,artifact_entries:0,package_lock_sets:0,current_module:""};
  dependencyGraphProgress("START",true);
}
function dependencyGraphProgress(status,force) {
  var g=dependencyGraphState;if(!g||!g.active)return;
  var now=new Date().getTime();if(!force&&now-g.lastProgress<5000)return;g.lastProgress=now;
  diagnosticLog("DEPENDENCY_GRAPH_PROGRESS="+status+"|elapsed_ms="+Math.max(0,now-g.started)+
    "|local_modules="+g.local_modules+"|external_modules="+g.external_modules+
    "|source_files="+g.source_files+"|source_chars="+g.source_chars+
    "|import_prefix_chars="+g.import_prefix_chars+"|strict_scan_chars="+g.strict_scan_chars+
    "|artifact_directories="+g.artifact_directories+"|artifact_entries="+g.artifact_entries+
    "|package_lock_sets="+g.package_lock_sets+"|current_module="+g.current_module);
}
function graphSourceRead(text,strict) {
  var g=dependencyGraphState;if(!g||!g.active)return;
  g.source_files++;g.source_chars+=text.length;if(strict)g.strict_scan_chars+=text.length;
  dependencyGraphProgress("RUNNING",false);
}
function graphImportScan(chars) {
  var g=dependencyGraphState;if(!g||!g.active)return;
  g.import_prefix_chars+=chars;dependencyGraphProgress("RUNNING",false);
}
function graphModuleStart(name) {
  var g=dependencyGraphState;if(!g||!g.active)return;
  g.current_module=name;dependencyGraphProgress("RUNNING",false);
}
function graphModuleAdded(local) {
  var g=dependencyGraphState;if(!g||!g.active)return;
  if(local)g.local_modules++;else g.external_modules++;
}
function importHeaderLine(header,line) {
  line=trim(line);if(!line)return true;
  if(line==="prelude"){header.prelude=true;return true;}
  if(line==="module")return true;
  var match=/^(?:(?:public|private|meta)\s+)*import\s+(.+)$/.exec(line);
  if(!match){if(/\bimport\b/.test(line))error("Unsupported import header in "+header.source+": "+line);return false;}
  var items=trim(match[1]).split(/\s+/);
  for(var j=0;j<items.length;j++){
    if(items[j]==="all")continue;
    if(!/^[A-Za-z_][A-Za-z0-9_'.]*$/.test(items[j]))error("Unsupported import name in "+header.source+": "+items[j]);
    header.imports.push(items[j]);
  }
  return true;
}
function finishImportHeader(header,scannedChars) {
  if(!header.prelude)header.imports.unshift("Init");
  return {imports:unique(header.imports),scannedChars:scannedChars};
}
function scanCleanImportHeader(source,clean) {
  var header={source:source,imports:[],prelude:false},start=0,consumed=0;
  while(true){
    var end=clean.indexOf("\n",start),next=end<0?clean.length:end+1;
    consumed=next;
    if(!importHeaderLine(header,clean.slice(start,end<0?clean.length:end))||end<0)break;
    start=next;
  }
  return finishImportHeader(header,consumed);
}
function scanImportHeader(source,text) {
  /* Match sourceClean(text,false) exactly through the first substantive cleaned
     nonheader line, including its escaped-newline behavior. The unread body
     cannot affect the old header parser, and no full-source scan is skipped
     for project proof sources (those use strict sourceClean separately). */
  var header={source:source,imports:[],prelude:false},line="",depth=0,inString=false,i=0,stopped=false;
  while(i<text.length){
    var a=text.charAt(i),b=text.charAt(i+1),emitted;
    if(depth){
      if(a==="/"&&b==="-"){depth++;emitted="  ";i+=2;}
      else if(a==="-"&&b==="/"){depth--;emitted="  ";i+=2;}
      else{emitted=a==="\n"?"\n":" ";i++;}
    }else if(inString){
      if(a==="\\"){emitted="  ";i+=2;}
      else{if(a==='"')inString=false;emitted=a==="\n"?"\n":" ";i++;}
    }else if(a==="/"&&b==="-"){depth=1;emitted="  ";i+=2;}
    else if(a==="-"&&b==="-"){
      while(i<text.length&&text.charAt(i)!=="\n"){line+=" ";i++;}continue;
    }else if(a==='"'){inString=true;emitted=" ";i++;}
    else{emitted=a;i++;}
    if(emitted==="\n"){
      if(!importHeaderLine(header,line)){stopped=true;break;}line="";
    }else line+=emitted;
  }
  if(!stopped)importHeaderLine(header,line);
  return finishImportHeader(header,Math.min(i,text.length));
}
function importsFromClean(source,clean) {
  var parsed=scanCleanImportHeader(source,clean);graphImportScan(parsed.scannedChars);return parsed.imports;
}
function importsOf(source) {
  var text=read(source);graphSourceRead(text,false);
  var parsed=scanImportHeader(source,text);graphImportScan(parsed.scannedChars);return parsed.imports;
}
function listFiles(folder) {
  var out=[];if(!directory(folder))return out;
  var en=new Enumerator(fso.GetFolder(folder).Files);
  for(;!en.atEnd();en.moveNext())out.push(String(en.item().Path));return out.sort();
}
function subfolders(folder) {
  var out=[];if(!directory(folder))return out;
  var en=new Enumerator(fso.GetFolder(folder).SubFolders);
  for(;!en.atEnd();en.moveNext())out.push(String(en.item().Path));return out.sort();
}
function addPackage(source, artifacts, label) {
  if(!directory(artifacts))return;
  var id=keyPath(artifacts);
  for(var i=0;i<packages.length;i++)if(packages[i].id===id)return;
  var locks=[],names=["lean-toolchain","lake-manifest.json","lakefile.lean","lakefile.toml"];
  for(i=0;i<names.length;i++)if(exists(source+"\\"+names[i]))locks.push(source+"\\"+names[i]);
  packages.push({id:id,source:norm(source),artifacts:norm(artifacts),label:label,locks:locks});
}
function artifactsFromList(base, files) {
  var stem=fso.GetBaseName(base),out=[];
  for(var i=0;i<files.length;i++){
    var name=fso.GetFileName(files[i]);
    if(name===stem+".olean" || name.indexOf(stem+".olean.")===0 || name===stem+".ir" || name===stem+".dll")out.push(files[i]);
  }
  return out;
}
function artifactFamily(base) {
  return artifactsFromList(base,listFiles(fso.GetParentFolderName(base)));
}
function indexArtifactFamilies(files) {
  var families={};
  function add(stem,path){var key="$"+stem;if(!families[key])families[key]=[];families[key].push(path);}
  for(var i=0;i<files.length;i++){
    var path=files[i],name=fso.GetFileName(path);
    if(name.slice(-6)===".olean")add(name.slice(0,-6),path);
    for(var at=name.indexOf(".olean.");at>=0;at=name.indexOf(".olean.",at+1))add(name.slice(0,at),path);
    if(name.slice(-3)===".ir")add(name.slice(0,-3),path);
    if(name.slice(-4)===".dll")add(name.slice(0,-4),path);
  }
  return families;
}
function externalArtifactFamily(base) {
  /* Enumerate and classify only once per graph walk, only in read-only
     dependency directories. Mutable working artifactFamily stays uncached. */
  var folder=fso.GetParentFolderName(base),key=keyPath(folder);
  if(!externalDirectoryFiles[key]){
    var files=listFiles(folder);externalDirectoryFiles[key]=files;
    externalDirectoryFamilies[key]=indexArtifactFamilies(files);
    if(dependencyGraphState&&dependencyGraphState.active){dependencyGraphState.artifact_directories++;dependencyGraphState.artifact_entries+=files.length;}
  }
  var family=externalDirectoryFamilies[key]["$"+fso.GetBaseName(base)];return family?family.slice():[];
}
function externalModule(name, visiting) {
  if(modules[name])return;
  if(visiting[name])error("Import cycle detected at "+name);
  visiting[name]=true;
  graphModuleStart(name);
  var rel=name.replace(/\./g,"\\"),matches=[],i;
  for(i=0;i<packages.length;i++)if(exists(packages[i].artifacts+"\\"+rel+".olean")){matches.push(packages[i]);break;}
  if(!matches.length)error("Missing cached artifact for "+name);
  /* The search order is exactly the LEAN_PATH order, including duplicate caches. */
  var pkg=matches[0],src=pkg.source+"\\"+rel+".lean",ole=pkg.artifacts+"\\"+rel+".olean";
  if(!exists(src))error("Source needed to fingerprint cached dependency imports is missing: "+src);
  var deps=importsOf(src),artifacts=externalArtifactFamily(ole);
  var node={name:name,local:false,source:src,imports:deps,artifacts:artifacts,package:pkg};
  modules[name]=node;graphModuleAdded(false);requestHash(src);
  for(i=0;i<artifacts.length;i++)requestHash(artifacts[i]);
  var lockKey="$"+pkg.id;
  if(!externalPackageLocks[lockKey]){
    for(i=0;i<pkg.locks.length;i++)requestHash(pkg.locks[i]);externalPackageLocks[lockKey]=true;
    if(dependencyGraphState&&dependencyGraphState.active)dependencyGraphState.package_lock_sets++;
  }
  for(i=0;i<deps.length;i++)externalModule(deps[i],visiting);
  visiting[name]=false;
}
function externalKey(name, visiting) {
  if(dependencyKeys[name])return dependencyKeys[name];
  var n=modules[name];if(!n||n.local)error("Expected external dependency: "+name);
  if(visiting[name])error("Dependency fingerprint cycle at "+name);visiting[name]=true;
  var s="EXTERNAL_MODULE_V1\n"+name+"\n"+fileHashes[keyPath(n.source)]+"\n",i;
  for(i=0;i<n.artifacts.length;i++)s+=fso.GetFileName(n.artifacts[i])+"="+fileHashes[keyPath(n.artifacts[i])]+"\n";
  for(i=0;i<n.package.locks.length;i++)s+=fso.GetFileName(n.package.locks[i])+"="+fileHashes[keyPath(n.package.locks[i])]+"\n";
  var deps=n.imports.slice().sort();for(i=0;i<deps.length;i++)s+=deps[i]+"="+externalKey(deps[i],visiting)+"\n";
  visiting[name]=false;return dependencyKeys[name]=textHash(s);
}
function selectCompiler() {
  compiler=env("AWPIRH_LEAN_EXE")||env("LEAN_EXE");
  if(!compiler){var elan=env("ELAN_HOME")||(env("USERPROFILE")+"\\.elan");compiler=elan+"\\toolchains\\leanprover--lean4---v4.33.0\\bin\\lean.exe";}
  compiler=norm(compiler);
  if(!exists(compiler)||/\\\.elan\\bin\\lean\.exe$/i.test(compiler))error("Set AWPIRH_LEAN_EXE to the native Lean 4.33.0 executable, not an elan shim: "+compiler);
  var versionFile=root+"\\lean_version.log";
  if(invokeNative(compiler,["--version"],versionFile)!==0)error("Native Lean version command failed; see lean_version.log.");
  leanVersion=trim(read(versionFile));log(leanVersion);
  if(!/version 4\.33\.0,/.test(leanVersion))error("Expected exact native Lean 4.33.0; found "+leanVersion);
  var prefixFile=root+"\\lean_prefix.log";
  if(invokeNative(compiler,["--print-prefix"],prefixFile)!==0)error("Native Lean prefix query failed.");
  prefix=norm(trim(read(prefixFile)));
  if(!exists(prefix+"\\lib\\lean\\Init.olean"))error("Native Lean prefix has no Init.olean: "+prefix);
  if(env("LEAN_JOBS")){jobs=Number(env("LEAN_JOBS"));if(!(jobs>=1&&jobs<=64&&Math.floor(jobs)===jobs))error("LEAN_JOBS must be an integer from 1 to 64.");}
}
function tryCache(candidate) {
  if(!candidate)return false;
  var base=norm(candidate),m=base+"\\.lake\\packages\\mathlib";
  if(!exists(m+"\\lean-toolchain"))m=base;
  if(!exists(m+"\\lean-toolchain")||trim(read(m+"\\lean-toolchain"))!=="leanprover/lean4:v4.33.0")return false;
  for(var i=0;i<requiredMathlib.length;i++)if(!exists(m+"\\.lake\\build\\lib\\lean\\"+requiredMathlib[i].replace(/\./g,"\\")+".olean"))return false;
  cacheRoot=base;mathlibRoot=m;return true;
}
function loadFinalAuditRoot() {
  var selector=root+"\\final-audit.txt",rel=exists(selector)?trim(read(selector)):"Audit.lean";
  rel=rel.replace(/\//g,"\\");
  if(!/^[A-Za-z_][A-Za-z0-9_]*(?:\\[A-Za-z_][A-Za-z0-9_]*)*\.lean$/.test(rel))error("final-audit.txt must contain one package-relative Lean module path.");
  finalAuditRelative=rel;finalAuditName=rel.slice(0,-5).replace(/\\/g,".");finalAuditSource=root+"\\"+rel;
  if(!exists(finalAuditSource))error("Selected final audit source is missing: "+finalAuditRelative);
  log("FINAL_AUDIT_ROOT="+finalAuditRelative);
}
function loadMathlibRequirements() {
  loadFinalAuditRoot();
  var plan=root+"\\compile-order.txt",manifest=root+"\\mathlib-imports.txt";
  if(!exists(plan)||!exists(manifest))error("compile-order.txt and mathlib-imports.txt are required.");
  var files=[finalAuditSource],lines=read(plan).split(/\r?\n/),direct={},listed={},i,j;
  for(i=0;i<lines.length;i++){
    var rel=trim(lines[i]);if(!rel||rel.charAt(0)==="#")continue;rel=rel.replace(/\//g,"\\");
    if(!/^[A-Za-z_][A-Za-z0-9_\\]*\.lean$/.test(rel))error("Invalid compile-order entry: "+rel);
    files.push(root+"\\"+rel);
  }
  for(i=0;i<files.length;i++){
    if(!exists(files[i]))error("Missing local source while checking cache requirements: "+files[i]);
    var imports=importsOf(files[i]);for(j=0;j<imports.length;j++)if(/^Mathlib(?:\.|$)/.test(imports[j]))direct[imports[j]]=true;
  }
  lines=read(manifest).split(/\r?\n/);
  for(i=0;i<lines.length;i++){
    var name=trim(lines[i]);if(!name||name.charAt(0)==="#")continue;
    if(!/^Mathlib(?:\.[A-Za-z_][A-Za-z0-9_']*)*$/.test(name)||listed[name])error("Invalid or duplicate required Mathlib module: "+name);
    listed[name]=true;
  }
  requiredMathlib=keys(direct);
  if(requiredMathlib.join("\n")!==keys(listed).join("\n"))error("mathlib-imports.txt does not exactly match the direct Mathlib imports of the supplied sources.");
  log("MATHLIB_REQUIRED_DIRECT_MODULES="+requiredMathlib.length);
  log("MATHLIB_CACHE_CHECK=REQUIRED_MODULES_ONLY");
}
function addAnchorRoot(path, explicit) {
  var candidate=norm(path),suffix="\\RH_HILBERT_LIMIT\\LOCAL_COMPILER\\lean-4.33.0";
  if(directory(candidate+suffix))candidate+=suffix;
  else if(directory(candidate+"\\LOCAL_COMPILER\\lean-4.33.0"))candidate+="\\LOCAL_COMPILER\\lean-4.33.0";
  if(!directory(candidate)){if(explicit)log("ANCHOR_IMPORT_ROOT_UNAVAILABLE="+candidate);return;}
  for(var i=0;i<anchorRoots.length;i++)if(keyPath(anchorRoots[i])===keyPath(candidate))return;
  anchorRoots.push(candidate);if(explicit)log("ANCHOR_IMPORT_ROOT="+candidate);
}
function selectCache() {
  var override=env("MATHLIB_CACHE_ROOT"),found=false,i;
  if(override){if(!tryCache(override))error("Explicit MATHLIB_CACHE_ROOT lacks a compatible complete Lean 4.33.0 Mathlib cache: "+override);found=true;}
  else{
    var candidates=[root,env("USERPROFILE")+"\\lean-native\\awpi_phi_rh_lean_sieved_v0_1_1",env("USERPROFILE")+"\\Downloads\\awpi_phi_rh_lean_sieved_v0_1_1"];
    for(i=0;i<candidates.length;i++)if(tryCache(candidates[i])){found=true;break;}
  }
  if(!found)error("Existing Mathlib cache not found. Set MATHLIB_CACHE_ROOT to a cached project or Mathlib checkout; no setup or download is attempted.");
  addPackage(mathlibRoot,mathlibRoot+"\\.lake\\build\\lib\\lean","mathlib");
  var dirs=subfolders(cacheRoot+"\\.lake\\packages").concat(subfolders(mathlibRoot+"\\.lake\\packages"));
  for(i=0;i<dirs.length;i++)addPackage(dirs[i],dirs[i]+"\\.lake\\build\\lib\\lean",fso.GetFileName(dirs[i]));
  addPackage(prefix+"\\src\\lean",prefix+"\\lib\\lean","lean-toolchain");
  log("MATHLIB_CACHE=READY");log("CACHE_ROOT="+cacheRoot);log("MATHLIB_ROOT="+mathlibRoot);
  var paths=[work];for(i=0;i<packages.length;i++)paths.push(packages[i].artifacts);
  env("LEAN_PATH")=paths.join(";");env("LEAN_SYSROOT")=prefix;
  env("PATH")=prefix+"\\bin;"+env("PATH");env("LEAN_NUM_THREADS")=String(jobs);
  var base=env("LEAN_ANCHORINGS_ROOT")||(env("LOCALAPPDATA")+"\\LEAN_ANCHORINGS");
  if(!env("LEAN_ANCHORINGS_ROOT")&&!env("LOCALAPPDATA"))error("LOCALAPPDATA or LEAN_ANCHORINGS_ROOT is required.");
  anchorRoot=norm(base)+"\\RH_HILBERT_LIMIT\\LOCAL_COMPILER\\lean-4.33.0";
  checkAnchorPathLength(anchorRoot,true);mkdir(anchorRoot);
  addAnchorRoot(anchorRoot,false);
  if(persistentPriorAnchorRoot&&keyPath(persistentPriorAnchorRoot)!==keyPath(persistentProjectCache))addAnchorRoot(persistentPriorAnchorRoot,true);
  if(env("LEAN_ANCHORINGS_ROOT")&&env("LOCALAPPDATA"))addAnchorRoot(env("LOCALAPPDATA")+"\\LEAN_ANCHORINGS",false);
  if(env("LEAN_ANCHORINGS_IMPORT_ROOT"))addAnchorRoot(env("LEAN_ANCHORINGS_IMPORT_ROOT"),true);
  if(env("LEAN_ANCHORINGS_IMPORT_ROOTS")){
    var extras=env("LEAN_ANCHORINGS_IMPORT_ROOTS").split(";");
    for(i=0;i<extras.length;i++)if(trim(extras[i]))addAnchorRoot(trim(extras[i]),true);
  }
  log("LEAN_ANCHORINGS="+anchorRoot);log("LEAN_JOBS="+jobs);
  log("PROJECT_CACHE=READ_WRITE");log("PROJECT_CACHE_LAYOUT="+CACHE_LAYOUT);
  log("PROJECT_CACHE_REUSE=VERIFIED_SAME_TARGET_SOURCE_DEPENDENCIES_TOOLCHAIN_AND_AUDIT");
}
function loadPlan() {
  beginDependencyGraph();var graphComplete=false;
  try{
  var plan=root+"\\compile-order.txt",targets=root+"\\audit-targets.tsv",i,j;
  if(!exists(plan)||!exists(targets)||!exists(finalAuditSource))error("compile-order.txt, audit-targets.tsv, and the selected final audit source are required.");
  var lines=read(plan).split(/\r?\n/),seen={};
  for(i=0;i<lines.length;i++){
    var rel=trim(lines[i]);if(!rel||rel.charAt(0)==="#")continue;
    rel=rel.replace(/\//g,"\\");
    if(!/^[A-Za-z_][A-Za-z0-9_\\]*\.lean$/.test(rel)||keyPath(root+"\\"+rel)===keyPath(finalAuditSource))error("Invalid compile-order entry or selected final audit listed twice: "+rel);
    var name=rel.slice(0,-5).replace(/\\/g,".");
    if(seen[name])error("Duplicate module in compile-order: "+name);seen[name]=true;
    var src=root+"\\"+rel;if(!exists(src))error("Missing local module source: "+rel);
    graphModuleStart(name);var sourceText=read(src);graphSourceRead(sourceText,true);
    var clean=sourceClean(sourceText);
    if(/\b(?:sorry|admit|axiom)\b/.test(clean)||/debug\.skipKernel/.test(clean))error("Prohibited proof placeholder or kernel bypass in "+rel);
    modules[name]={name:name,local:true,source:src,relative:rel,imports:importsFromClean(src,clean)};graphModuleAdded(true);
    ordered.push(name);requestHash(src);
  }
  if(!ordered.length)error("Empty compile-order.txt.");
  lines=read(targets).split(/\r?\n/);var declarations={};
  for(i=0;i<lines.length;i++){
    var line=trim(lines[i]);if(!line||line.charAt(0)==="#")continue;
    var parts=line.split("|");if(parts.length!==2)error("Audit target must be module|declaration: "+line);
    var module=trim(parts[0]),decl=trim(parts[1]);
    if(!modules[module]||!modules[module].local||!/^[A-Za-z_][A-Za-z0-9_.]*$/.test(decl))error("Invalid audit target: "+line);
    if(declarations[decl])error("Duplicate audited declaration: "+decl);declarations[decl]=true;
    if(!auditTargets[module])auditTargets[module]=[];auditTargets[module].push(decl);
  }
  seen={};
  for(i=0;i<ordered.length;i++){
    var n=modules[ordered[i]];
    if(!auditTargets[n.name]||!auditTargets[n.name].length)error("No explicit axiom-audit target for "+n.name);
    auditTargets[n.name].sort();
    for(j=0;j<n.imports.length;j++){
      var dep=n.imports[j];if(modules[dep]&&modules[dep].local&&!seen[dep])error("Compile order is not topological: "+n.name+" imports "+dep);
      if(!modules[dep])externalModule(dep,{});
    }
    seen[n.name]=true;
  }
  graphModuleStart(finalAuditName);var auditText=read(finalAuditSource);graphSourceRead(auditText,true);
  var auditClean=sourceClean(auditText);
  if(/\b(?:sorry|admit|axiom)\b/.test(auditClean)||/debug\.skipKernel/.test(auditClean))error("Prohibited proof placeholder or kernel bypass in "+finalAuditRelative);
  var auditImports=importsFromClean(finalAuditSource,auditClean);
  for(i=0;i<auditImports.length;i++)if(!modules[auditImports[i]])externalModule(auditImports[i],{});
  modules[finalAuditName]={name:finalAuditName,local:true,source:finalAuditSource,relative:finalAuditRelative,imports:auditImports};graphModuleAdded(true);
  auditTargets[finalAuditName]=[];
  for(i=0;i<ordered.length;i++)auditTargets[finalAuditName]=auditTargets[finalAuditName].concat(auditTargets[ordered[i]]);
  auditTargets[finalAuditName].sort();
  requestHash(finalAuditSource);requestHash(root+"\\compile-order.txt");requestHash(targets);requestHash(root+"\\mathlib-imports.txt");
  if(exists(root+"\\final-audit.txt"))requestHash(root+"\\final-audit.txt");
  requestHash(root+"\\tools\\native_runner.js");requestHash(root+"\\run.cmd");requestHash(compiler);
  var dllDirs=[prefix+"\\bin",prefix+"\\lib\\lean"];
  for(i=0;i<dllDirs.length;i++){var files=listFiles(dllDirs[i]);for(j=0;j<files.length;j++)if(/\.dll$/i.test(files[j]))requestHash(files[j]);}
  log("PROJECT_SOURCE_SCAN=PASS");log("PROJECT_MODULES="+ordered.length);
  graphComplete=true;
  }finally{dependencyGraphProgress(graphComplete?"COMPLETE":"INTERRUPTED",true);if(dependencyGraphState)dependencyGraphState.active=false;}
}
function makeGlobalKey() {
  var s=COMPILE_POLICY+"\nTARGET="+TARGET+"\nLEAN="+leanVersion+"\nFLAGS="+COMPILE_FLAGS+"\n";
  s+="COMPILER="+fileHashes[keyPath(compiler)]+"\n";
  var old=LEGACY_SCHEMA+"\nTARGET="+TARGET+"\nLEAN="+leanVersion+"\nRUNNER="+LEGACY_RUNNER_SHA+"\nCMD="+LEGACY_CMD_SHA+"\nCOMPILER="+fileHashes[keyPath(compiler)]+"\n";
  var files=keys(hashFiles);
  for(var i=0;i<files.length;i++)if(/\.dll$/i.test(files[i])){var line=files[i]+"="+fileHashes[files[i]]+"\n";s+=line;old+=line;}
  globalKey=textHash(s);write(helpers+"\\toolchain-fingerprint.txt",s+"FINGERPRINT="+globalKey+"\n");
  legacyGlobalKey=textHash(old);
  provenance={runner:RUNNER_VERSION,runnerSHA:fileHashes[keyPath(root+"\\tools\\native_runner.js")],cmdSHA:fileHashes[keyPath(root+"\\run.cmd")]};
  write(helpers+"\\runner-provenance.txt","RUNNER="+provenance.runner+"\nRUNNER_SHA256="+provenance.runnerSHA+"\nCMD_SHA256="+provenance.cmdSHA+"\n");
  log("TOOLCHAIN_FINGERPRINT="+globalKey);
  log("BUILD_IDENTITY=SOURCE_DEPENDENCIES_NATIVE_COMPILER_SEMANTIC_FLAGS");
  log("RUNNER_PROVENANCE_SHA256="+provenance.runnerSHA);
}
function parseReceipt(s) {
  var lines=s.split(/\r?\n/),o={};
  for(var i=0;i<lines.length;i++){var p=lines[i].indexOf("=");if(p>0){var k=lines[i].slice(0,p);if(o.hasOwnProperty(k))error("Duplicate receipt field: "+k);o[k]=lines[i].slice(p+1);}}
  return o;
}
function checkAxioms(contents, expected) {
  if(/sorryAx/.test(contents))error("sorryAx occurs in compiler/audit output.");
  var re=/'([^']+)'\s+(?:depends on axioms:\s*\[([^\]]*)\]|does not depend on any axioms)/g;
  var m,found={},allowed={"propext":true,"Classical.choice":true,"Quot.sound":true};
  while((m=re.exec(contents))!==null){
    if(found[m[1]])error("Duplicate axiom record for "+m[1]);found[m[1]]=true;
    var axioms=typeof m[2]==="string"?trim(m[2]):"";
    if(axioms){var a=axioms.split(/\s*,\s*/);for(var i=0;i<a.length;i++)if(!allowed[trim(a[i])])error("Unapproved axiom "+a[i]+" in "+m[1]);}
  }
  for(var j=0;j<expected.length;j++)if(!found[expected[j]])error("Missing exact axiom-audit record for "+expected[j]);
  return expected.length;
}
function moduleInput(name) {
  var n=modules[name],s=COMPILE_POLICY+"\nTARGET="+TARGET+"\nTOOLCHAIN="+globalKey+"\nFLAGS="+COMPILE_FLAGS+"\nMODULE="+name+"\n";
  s+="SOURCE="+fileHashes[keyPath(n.source)]+"\n";
  var deps=n.imports.slice().sort();
  for(var i=0;i<deps.length;i++){
    if(modules[deps[i]].local){if(!moduleKeys[deps[i]])error("Local dependency not verified: "+deps[i]);s+=deps[i]+"="+moduleKeys[deps[i]]+";"+artifactHashes[deps[i]]+"\n";}
    else s+=deps[i]+"="+externalKey(deps[i],{})+"\n";
  }
  return {key:textHash(s),manifest:s};
}
function clearOutputs(name) {
  var out=work+"\\"+name.replace(/\./g,"\\")+".olean",files=artifactFamily(out);
  for(var i=0;i<files.length;i++)fso.DeleteFile(files[i],true);return out;
}
function parseTargets(text) {
  if(!text)error("An anchoring must name its audited declarations.");
  var targets=text.split(","),seen={};
  for(var i=0;i<targets.length;i++){
    if(!/^[A-Za-z_][A-Za-z0-9_.]*$/.test(targets[i])||seen[targets[i]])error("Invalid anchoring audit target list.");
    seen[targets[i]]=true;
  }
  return targets;
}
function coversTargets(oldTargets,currentTargets) {
  var have={};for(var i=0;i<oldTargets.length;i++)have[oldTargets[i]]=true;
  for(i=0;i<currentTargets.length;i++)if(!have[currentTargets[i]])return false;return true;
}
function auditKey(inputKey,artifactKey,targets,policy) {
  return textHash("AUDIT_KEY_V1\nTARGET="+TARGET+"\nPOLICY="+policy+"\nALLOW=propext,Classical.choice,Quot.sound\nBUILD="+inputKey+"\nARTIFACTS="+artifactKey+"\nTARGETS="+targets.slice().sort().join(",")+"\n");
}
function compactModuleRoot(base,name) { return base+"\\c\\"+textHash(name).slice(0,16); }
function compactInputRoot(base,name,inputKey) { return compactModuleRoot(base,name)+"\\"+inputKey.slice(0,32); }
function checkAnchorPathLength(path,isDirectory) {
  var absolute=norm(path),limit=isDirectory?248:260;
  if(absolute.length>=limit)error("ANCHOR_PATH_TOO_LONG: "+(isDirectory?"directory":"file")+
    " length "+absolute.length+" must be less than "+limit+" characters: "+absolute+
    ". Choose a shorter LEAN_ANCHORINGS_ROOT before retrying.");
}
function preflightAnchorPaths(parent,dest,temp,files) {
  var folders=[parent,dest,temp,dest+"\\artifacts",temp+"\\artifacts"],i,j;
  for(i=0;i<folders.length;i++)checkAnchorPathLength(folders[i],true);
  var names=["source.lean","audit.log","input.txt","artifacts.tsv","receipt.txt"];
  for(i=0;i<names.length;i++){
    checkAnchorPathLength(dest+"\\"+names[i],false);
    checkAnchorPathLength(temp+"\\"+names[i],false);
  }
  for(j=0;j<files.length;j++){
    var name=fso.GetFileName(files[j]);
    checkAnchorPathLength(dest+"\\artifacts\\"+name,false);
    checkAnchorPathLength(temp+"\\artifacts\\"+name,false);
  }
}
function nextAnchorTag(parent,name,inputKey) {
  checkAnchorPathLength(parent,true);
  var millis=new Date().getTime(),entries=subfolders(parent),i;
  /* A newer receipt sorts first, even if two saves share a clock tick or
     the local clock moved backward. Only this exact compact input folder is read. */
  for(i=0;i<entries.length;i++){
    var old=fso.GetFileName(entries[i]);
    if(/^[a-f0-9]{16}$/.test(old))millis=Math.max(millis,parseInt(old.slice(0,12),16)+1);
  }
  var prefix=millis.toString(16);
  if(prefix.length>12)error("Compact anchoring timestamp exceeds its bounded path component.");
  prefix=("000000000000"+prefix).slice(-12);
  for(i=0;i<16;i++){
    var suffix=textHash(runTag+"\n"+name+"\n"+inputKey+"\n"+(++anchorSerial)+"\n"+Math.random()).slice(0,4);
    var tag=prefix+suffix,path=parent+"\\"+tag;
    if(!directory(path)&&!directory(path+".pending")&&!exists(path)&&!exists(path+".pending"))return tag;
  }
  error("Unique compact anchor tag collision after 16 attempts.");
}
function entryFolders(name,inputKey) {
  var out=[];
  for(var i=0;i<anchorRoots.length;i++){
    out=out.concat(subfolders(compactInputRoot(anchorRoots[i],name,inputKey)).reverse());
    out=out.concat(subfolders(anchorRoots[i]+"\\"+name+"\\"+inputKey).reverse());
  }
  return unique(out);
}
function historicalAnchorCandidates(name,seen) {
  var out=[],i,j,k,l;
  /* Only the two documented module/input directory layouts are inspected.
     Short directory components are locators; full receipt identities decide trust. */
  for(i=0;i<anchorRoots.length;i++){
    var roots=[compactModuleRoot(anchorRoots[i],name),anchorRoots[i]+"\\"+name];
    for(j=0;j<roots.length;j++){
      var groups=subfolders(roots[j]),pattern=j===0?/^[a-f0-9]{32}$/:/^[a-f0-9]{64}$/;
      for(k=0;k<groups.length;k++){
        if(!pattern.test(fso.GetFileName(groups[k])))continue;
        var entries=subfolders(groups[k]).reverse();
        for(l=0;l<entries.length;l++)if(!seen[keyPath(entries[l])]){
          seen[keyPath(entries[l])]=true;out.push(entries[l]);
        }
      }
    }
  }
  return out;
}
function anchorCandidates(name,inputKey) {
  var out=entryFolders(name,inputKey),seen={};
  for(var i=0;i<out.length;i++)seen[keyPath(out[i])]=true;
  return out.concat(historicalAnchorCandidates(name,seen));
}
function readAnchorCore(name,folder,workingOutput,scope) {
  if(/\.pending$/.test(folder))error("Uncommitted anchoring entry.");
  var receiptFile=folder+"\\receipt.txt";
  if(!exists(receiptFile))error("Missing anchoring receipt.");
  var r=parseReceipt(read(receiptFile));
  if(r.SCHEMA!==SCHEMA&&r.SCHEMA!==LEGACY_SCHEMA)error("Unsupported anchoring schema.");
  if(r.TARGET!==TARGET||r.MODULE!==name||r.BUILD_PASS!=="1"||r.AUDIT_PASS!=="1"||r.LEAN_VERSION!=="4.33.0")error("Anchoring target, module, version or PASS fields do not match.");
  if(r.SOURCE_SHA256!==fileHashes[keyPath(modules[name].source)])error("Anchoring source does not match current source.");
  var inputText=read(folder+"\\input.txt");
  if(textHash(inputText)!==r.INPUT_SHA256)error("Anchoring input manifest hash is inconsistent.");
  var inputFields=parseReceipt(inputText),targets=parseTargets(r.SCHEMA===LEGACY_SCHEMA?inputFields.AUDIT:r.AUDIT_TARGETS);
  if(r.AUDIT_TARGET_COUNT!==String(targets.length))error("Anchoring audit target count is inconsistent.");
  var auditText=read(folder+"\\audit.log");checkAxioms(auditText,targets);
  var lines=read(folder+"\\artifacts.tsv").split(/\r?\n/),verified=[],expectedHashes={},canonical="",seen={},stem=fso.GetFileName(name.replace(/\./g,"\\"));
  for(var i=0;i<lines.length;i++){
    if(!trim(lines[i]))continue;var pair=lines[i].split("|"),fn=pair[0];
    if(pair.length!==2||!/^[A-Za-z0-9_.]+$/.test(fn)||!/^[a-f0-9]{64}$/.test(pair[1])||seen[fn])error("Invalid anchoring artifact manifest.");
    if(!(fn===stem+".olean"||fn.indexOf(stem+".olean.")===0||fn===stem+".ir"||fn===stem+".dll"))error("Anchoring includes an artifact belonging to another module.");
    seen[fn]=true;
    verified.push(fn);expectedHashes[fn]=pair[1];canonical+=fn+"="+pair[1]+"\n";
  }
  if(!seen[stem+".olean"]||textHash(canonical)!==r.ARTIFACTS_SHA256)error("Anchoring output fingerprint is inconsistent.");
  var paths=[folder+"\\source.lean",folder+"\\audit.log"],workingFiles=[],workingDigest=null;
  for(i=0;i<verified.length;i++)paths.push(folder+"\\artifacts\\"+verified[i]);
  /* A current-V2 restore may request one combined snapshot. Legacy validation
     never supplies a scope, so its memoized objects cannot retain working hashes. */
  if(r.SCHEMA===SCHEMA&&workingOutput&&scope&&scope.active&&scope.module===name&&scope.outputKey===keyPath(workingOutput)){
    var candidates=artifactFamily(workingOutput),exact=candidates.length===verified.length;
    for(i=0;i<candidates.length;i++)if(!expectedHashes.hasOwnProperty(fso.GetFileName(candidates[i])))exact=false;
    if(exact){workingFiles=candidates;paths=paths.concat(workingFiles);}
  }
  var digests=freshHashSet(paths,"ANCHOR:"+name,false);
  if(digests[keyPath(folder+"\\source.lean")]!==r.SOURCE_SHA256)error("Anchoring source content was changed.");
  if(digests[keyPath(folder+"\\audit.log")]!==r.AUDIT_LOG_SHA256)error("Anchoring audit log content was changed.");
  for(i=0;i<verified.length;i++)if(digests[keyPath(folder+"\\artifacts\\"+verified[i])]!==expectedHashes[verified[i]])error("Anchoring artifact content hash mismatch.");
  if(workingFiles.length){
    var workingHashes={},workingNames=[];
    for(i=0;i<workingFiles.length;i++){
      workingNames.push(fso.GetFileName(workingFiles[i]));workingHashes[keyPath(workingFiles[i])]=digests[keyPath(workingFiles[i])];
    }
    workingDigest={scope:scope,outputKey:keyPath(workingOutput),files:workingNames,digests:workingHashes,consumed:false};
  }
  return {r:r,folder:folder,receipt:receiptFile,inputText:inputText,inputFields:inputFields,targets:targets,auditText:auditText,files:verified,expectedHashes:expectedHashes,artifactKey:r.ARTIFACTS_SHA256,workingDigest:workingDigest};
}
function verifyLegacy(name,folder,stack) {
  var cacheKey=keyPath(folder);if(legacyVerified[cacheKey])return legacyVerified[cacheKey];
  if(stack[cacheKey])error("Legacy anchoring dependency cycle.");stack[cacheKey]=true;
  var c=readAnchorCore(name,folder),r=c.r,n=modules[name];
  if(r.SCHEMA!==LEGACY_SCHEMA)error("Expected the pinned v0_1_0 receipt schema.");
  var s=LEGACY_SCHEMA+"\nTARGET="+TARGET+"\nTOOLCHAIN="+legacyGlobalKey+"\nMODULE="+name+"\nSOURCE="+fileHashes[keyPath(n.source)]+"\nAUDIT="+c.targets.join(",")+"\n";
  var deps=n.imports.slice().sort();
  for(var i=0;i<deps.length;i++){
    var dep=deps[i];
    if(modules[dep].local){
      var raw=c.inputFields[dep]||"",parts=raw.split(";");
      if(parts.length!==2||!/^[a-f0-9]{64}$/.test(parts[0])||parts[1]!==artifactHashes[dep])error("Legacy local dependency artifact does not match the verified current dependency: "+dep);
      var candidates=entryFolders(dep,parts[0]),found=false;
      for(var j=0;j<candidates.length;j++){
        try{var dc=verifyLegacy(dep,candidates[j],stack);if(dc.r.INPUT_SHA256===parts[0]&&dc.artifactKey===parts[1]){found=true;break;}}
        catch(ignoredDependency){if(isFatalHashError(ignoredDependency))throw ignoredDependency;/* A different candidate may be valid. */}
      }
      if(!found)error("No verified same-target legacy dependency receipt for "+dep);
      s+=dep+"="+parts[0]+";"+parts[1]+"\n";
    }else s+=dep+"="+externalKey(dep,{})+"\n";
  }
  if(c.inputText!==s||r.INPUT_SHA256!==textHash(s))error("Legacy native compiler, flags, source, dependencies or pinned runner provenance do not match.");
  stack[cacheKey]=false;legacyVerified[cacheKey]=c;return c;
}
function verifyCurrent(name,folder,input,workingOutput,scope) {
  var c=readAnchorCore(name,folder,workingOutput,scope),r=c.r;
  if(r.SCHEMA!==SCHEMA||r.COMPILE_POLICY!==COMPILE_POLICY||r.INPUT_SHA256!==input.key||c.inputText!==input.manifest)error("Current build identity does not match.");
  /* Only this documented policy is recognized; unknown audit formats are never imported. */
  if(r.AUDIT_POLICY!=="RH_HILBERT_STANDARD_AXIOMS_V1")error("Unsupported prior audit policy.");
  if(r.AUDIT_KEY!==auditKey(input.key,c.artifactKey,c.targets,r.AUDIT_POLICY))error("Prior audit identity is inconsistent.");
  return c;
}
function workingArtifactsMatch(name,output,c,scope) {
  var snapshot=c.workingDigest,eligible=!!(snapshot&&!snapshot.consumed&&scope&&scope.active&&snapshot.scope===scope&&
    scope.module===name&&scope.outputKey===keyPath(output)&&snapshot.outputKey===keyPath(output));
  /* Consume before any early return or mutation. No subsequent call may reuse it. */
  c.workingDigest=null;if(snapshot)snapshot.consumed=true;if(scope)scope.active=false;
  var files=artifactFamily(output);
  if(files.length!==c.files.length)return false;
  for(var i=0;i<files.length;i++)if(!c.expectedHashes.hasOwnProperty(fso.GetFileName(files[i])))return false;
  if(eligible){
    if(snapshot.files.length!==files.length)eligible=false;
    else for(i=0;i<files.length;i++)if(snapshot.files[i]!==fso.GetFileName(files[i]))eligible=false;
  }
  try{
    var digests=eligible?snapshot.digests:freshHashSet(files,"WORKING:"+name,false);
    if(eligible)workingDigestConsumed++;
    for(i=0;i<files.length;i++)if(digests[keyPath(files[i])]!==c.expectedHashes[fso.GetFileName(files[i])])return false;
  }catch(e){if(isFatalHashError(e))throw e;log("WORKING_ARTIFACT_RECHECK_FAILED="+name+" : "+e.message);return false;}
  return true;
}
function restoreAnchor(name,input) {
  var entries=entryFolders(name,input.key),seen={};
  for(var phase=0;phase<2;phase++){
    if(phase===1){anchorHistoryScans++;entries=historicalAnchorCandidates(name,seen);}
    for(var i=0;i<entries.length;i++){
      var folder=entries[i],copyStarted=false,scope=null;seen[keyPath(folder)]=true;
      if(/\.pending$/.test(folder)||!exists(folder+"\\receipt.txt"))continue;
      try{
        var summary=parseReceipt(read(folder+"\\receipt.txt"));
        if(summary.SOURCE_SHA256!==fileHashes[keyPath(modules[name].source)])continue;
        if(summary.SCHEMA===SCHEMA&&summary.INPUT_SHA256!==input.key)continue;
        var legacy=summary.SCHEMA===LEGACY_SCHEMA;
        var output=work+"\\"+name.replace(/\./g,"\\")+".olean";
        scope={module:name,outputKey:keyPath(output),active:true};
        var c=legacy?verifyLegacy(name,folder,{}):verifyCurrent(name,folder,input,output,scope);
        var retained=workingArtifactsMatch(name,output,c,scope),outputDir=fso.GetParentFolderName(output);
        if(retained){workingRetained++;log("WORKING_ARTIFACTS_RETAINED="+name);}
        else{
          clearOutputs(name);mkdir(outputDir);copyStarted=true;
          var destinations=[];
          for(var j=0;j<c.files.length;j++){
            var destination=outputDir+"\\"+c.files[j];
            fso.CopyFile(folder+"\\artifacts\\"+c.files[j],destination,false);
            destinations.push(destination);
          }
          var copied=freshHashSet(destinations,"RESTORE_DESTINATIONS:"+name,false);
          for(j=0;j<destinations.length;j++)if(copied[keyPath(destinations[j])]!==c.expectedHashes[c.files[j]])error("Restored working artifact does not match its verified anchoring hash.");
          restoredArtifactFiles+=c.files.length;log("BUILD_ARTIFACT_RESTORED="+name);
        }
        var imported=keyPath(folder).indexOf(keyPath(anchorRoot)+"\\")!==0;
        var policy=legacy?"RH_HILBERT_STANDARD_AXIOMS_V1":c.r.AUDIT_POLICY;
        log("SOURCE_ANCHOR_RECEIPT="+c.receipt);
        return {restored:true,retained:retained,needsAudit:policy!==AUDIT_POLICY||!coversTargets(c.targets,auditTargets[name]),legacy:legacy,imported:imported,receipt:c.receipt,folder:folder,artifactKey:c.artifactKey,auditText:c.auditText,auditLog:folder+"\\audit.log",output:output};
      }catch(e){
        if(scope)scope.active=false;
        if(copyStarted){try{clearOutputs(name);}catch(cleanupError){if(!isFatalHashError(e))throw cleanupError;}}
        if(isFatalHashError(e))throw e;
        log("ANCHOR_REJECTED="+folder+" : "+e.message);
      }
    }
  }
  return null;
}
function saveAnchor(name,input,auditLog,output,origin) {
  var previousStage=stage;stage="CACHE_SAVE:"+name;
  var parent=compactInputRoot(anchorRoot,name,input.key);
  var tag=nextAnchorTag(parent,name,input.key);
  var dest=parent+"\\"+tag,temp=dest+".pending";
  var files=artifactFamily(output),manifest="",canonical="";
  if(!exists(output))error("Compiler did not create "+output);
  preflightAnchorPaths(parent,dest,temp,files);
  var originalHashes=freshHashSet(files,"SAVE_ORIGINALS:"+name,false);
  if(directory(dest)||directory(temp))error("Unique anchor directory collision.");mkdir(temp+"\\artifacts");
  var stagedPaths=[];
  for(var i=0;i<files.length;i++){
    var fileName=fso.GetFileName(files[i]),hash=originalHashes[keyPath(files[i])];
    fso.CopyFile(files[i],temp+"\\artifacts\\"+fileName,false);
    stagedPaths.push(temp+"\\artifacts\\"+fileName);
    manifest+=fileName+"|"+hash+"\n";canonical+=fileName+"="+hash+"\n";
  }
  fso.CopyFile(modules[name].source,temp+"\\source.lean",false);fso.CopyFile(auditLog,temp+"\\audit.log",false);
  stagedPaths.push(temp+"\\source.lean");stagedPaths.push(temp+"\\audit.log");
  var stagedHashes=freshHashSet(stagedPaths,"SAVE_STAGED:"+name,false);
  for(i=0;i<files.length;i++)if(stagedHashes[keyPath(temp+"\\artifacts\\"+fso.GetFileName(files[i]))]!==originalHashes[keyPath(files[i])])error("Anchor output copy verification failed.");
  if(stagedHashes[keyPath(temp+"\\source.lean")]!==fileHashes[keyPath(modules[name].source)])error("Source changed during compilation; no anchor is accepted.");
  checkAxioms(read(temp+"\\audit.log"),auditTargets[name]);
  write(temp+"\\input.txt",input.manifest);write(temp+"\\artifacts.tsv",manifest);
  var artifactKey=textHash(canonical),auditHash=stagedHashes[keyPath(temp+"\\audit.log")];
  var receipt="SCHEMA="+SCHEMA+"\nCACHE_LAYOUT="+CACHE_LAYOUT+"\nTARGET="+TARGET+"\nLEAN_VERSION=4.33.0\nCOMPILE_POLICY="+COMPILE_POLICY+"\nMODULE="+name+"\nINPUT_SHA256="+input.key+
    "\nSOURCE_SHA256="+fileHashes[keyPath(modules[name].source)]+"\nARTIFACTS_SHA256="+artifactKey+"\nAUDIT_LOG_SHA256="+auditHash+
    "\nBUILD_PASS=1\nAUDIT_PASS=1\nAUDIT_POLICY="+AUDIT_POLICY+"\nAUDIT_TARGETS="+auditTargets[name].join(",")+
    "\nAUDIT_KEY="+auditKey(input.key,artifactKey,auditTargets[name],AUDIT_POLICY)+"\nAUDIT_TARGET_COUNT="+auditTargets[name].length+
    "\nRUNNER="+provenance.runner+"\nRUNNER_SHA256="+provenance.runnerSHA+"\nCMD_SHA256="+provenance.cmdSHA+"\nORIGIN_RECEIPT="+(origin||"")+"\nTIME_UTC="+stamp()+"\n";
  write(temp+"\\receipt.txt",receipt);fso.MoveFolder(temp,dest);
  moduleKeys[name]=input.key;artifactHashes[name]=artifactKey;
  compactAnchorsSaved++;log("ANCHOR_SAVE_LAYOUT=COMPACT_V1");
  log("ANCHOR_SAVED="+dest+"\\receipt.txt");
  stage=previousStage;
}
function acceptRestored(name,input,restored) {
  if(restored.legacy||restored.imported){
    saveAnchor(name,input,restored.auditLog,restored.output,restored.receipt);
    if(restored.legacy){migrated++;log("LEGACY_ANCHOR_MIGRATED="+name);}
  }else{moduleKeys[name]=input.key;artifactHashes[name]=restored.artifactKey;}
  buildStates[name]=restored.legacy?"LEGACY_VERIFIED_MIGRATED":"FROZEN_REUSED";
  append(auditLogPath,"FROZEN_AUDIT="+name+"\r\n"+restored.auditText+"\r\n");
  reused++;audited+=auditTargets[name].length;log("FROZEN_REUSE="+name);
}
/* Dependency-aware native coordinator. Source preparation only; not run on Windows here. */
var parallelRuntime = {configured:false, workers:1, active:[], tasks:{}, states:{}, rank:{},
  orderIndex:{}, peak:0, launches:0, lastProgress:0, memory:null, memoryReadAt:0,
  workerMemoryMB:4096, reserveMB:4096, ramCapMB:0, ramMode:"AUTO", ramAttempted:false,
  ram:null, ramStatus:"NOT_NEEDED", ramExitCode:null, shutdownKeepLock:false, shutdownComplete:false, shutdownClean:false,
  memoryDenial:"", preferredReserveMB:4096, minimumReserveMB:1024, memoryPressureSeen:false,
  memoryFallback:false, ramDisabledForMemory:false, shutdownInventoryAttempts:0};
var RAM_HELPER_SCHEMA = "RH_HILBERT_RAM_HELPER_CACHE_V1";

function parallelIntegerSetting(name,fallback,min,max) {
  var raw=trim(env(name)||"");if(!raw)return fallback;
  if(!/^[0-9]+$/.test(raw))error(name+" must be an integer.");
  var value=Number(raw);if(!(value>=min&&value<=max&&Math.floor(value)===value))error(name+" must be between "+min+" and "+max+".");
  return value;
}
function parallelMemorySnapshot(force) {
  var now=new Date().getTime();
  if(!force&&parallelRuntime.memoryReadAt&&now-parallelRuntime.memoryReadAt<2000)return parallelRuntime.memory;
  parallelRuntime.memoryReadAt=now;
  try{
    var service=GetObject("winmgmts:{impersonationLevel=impersonate}!\\\\.\\root\\cimv2");
    var records=new Enumerator(service.ExecQuery("SELECT TotalVisibleMemorySize, FreePhysicalMemory FROM Win32_OperatingSystem","WQL",48));
    if(records.atEnd())throw new Error("No operating-system memory record.");
    var record=records.item(),total=Math.floor(Number(record.TotalVisibleMemorySize)/1024),free=Math.floor(Number(record.FreePhysicalMemory)/1024);
    if(!(total>0&&free>=0&&free<=total&&isFinite(total)))throw new Error("Invalid memory counters.");
    parallelRuntime.memory={totalMB:total,freeMB:free};
  }catch(memoryError){parallelRuntime.memory=null;}
  return parallelRuntime.memory;
}
function configureParallelRuntime() {
  var memory=parallelMemorySnapshot(true),requested=parallelIntegerSetting("RH_MODULE_WORKERS",4,1,16);
  parallelRuntime.workerMemoryMB=parallelIntegerSetting("RH_WORKER_MEMORY_MB",4096,512,131072);
  parallelRuntime.reserveMB=parallelIntegerSetting("RH_SYSTEM_RESERVE_MB",4096,1024,131072);
  parallelRuntime.minimumReserveMB=trim(env("RH_SYSTEM_RESERVE_MB")||"")?parallelRuntime.reserveMB:1024;
  var mode=trim(env("RH_RAM_WARM")||"AUTO").toUpperCase();
  if(mode!=="AUTO"&&mode!=="ON"&&mode!=="OFF")error("RH_RAM_WARM must be AUTO, ON or OFF.");
  parallelRuntime.ramMode=mode;
  var cap=parallelIntegerSetting("RH_RAM_WARM_MB",8192,0,65536),memoryWorkers=1;
  if(memory){
    parallelRuntime.reserveMB=Math.max(parallelRuntime.reserveMB,Math.ceil(memory.totalMB/5));
    parallelRuntime.ramCapMB=mode==="OFF"?0:Math.max(0,Math.min(cap,Math.floor(memory.freeMB/4),memory.freeMB-parallelRuntime.reserveMB-parallelRuntime.workerMemoryMB));
    memoryWorkers=Math.max(1,Math.floor((memory.freeMB-parallelRuntime.reserveMB-parallelRuntime.ramCapMB)/parallelRuntime.workerMemoryMB));
  }else{parallelRuntime.ramCapMB=0;log("MEMORY_ADMISSION=UNKNOWN_SERIAL_FALLBACK");}
  parallelRuntime.preferredReserveMB=parallelRuntime.reserveMB;
  parallelRuntime.workers=Math.max(1,Math.min(requested,jobs>1?jobs-1:1,memoryWorkers));
  if(jobs===1)parallelRuntime.workers=1;
  parallelRuntime.configured=true;
  log("PARALLEL_MODULE_WORKERS="+parallelRuntime.workers);
  log("LEAN_TOTAL_THREAD_BUDGET="+jobs);
  log("PARALLEL_COORDINATOR_THREAD_RESERVE="+(parallelRuntime.workers>1?1:0));
  log("WORKER_MEMORY_ADMISSION_MB="+parallelRuntime.workerMemoryMB);
  log("SYSTEM_MEMORY_RESERVE_MB="+parallelRuntime.reserveMB);
  log("SERIAL_MEMORY_MINIMUM_RESERVE_MB="+parallelRuntime.minimumReserveMB);
  log("RAM_WARM_MODE="+mode);log("RAM_WARM_BUDGET_MB="+parallelRuntime.ramCapMB);
  log("RAM_WARM_RESIDENCY=OS_MANAGED_NOT_GUARANTEED");
  if(memory)log("MEMORY_SNAPSHOT_MB=TOTAL:"+memory.totalMB+"|FREE:"+memory.freeMB);
  var pathOwners={};
  for(var i=0;i<ordered.length;i++){
    var name=ordered[i];parallelRuntime.states[name]="PENDING";parallelRuntime.orderIndex[name]=i;parallelRuntime.rank[name]=1;
    var owned=[work+"\\"+name.replace(/\./g,"\\")+".olean",helpers+"\\"+name+".compile.log",
      helpers+"\\"+name+".audit.log",root+"\\RunnerAudit\\"+name.replace(/\./g,"_")+".lean"];
    for(var pi=0;pi<owned.length;pi++){
      var pathKey=keyPath(owned[pi]);
      if(pathOwners.hasOwnProperty(pathKey)&&pathOwners[pathKey]!==name)
        error("PARALLEL_OUTPUT_PATH_COLLISION: "+name+" and "+pathOwners[pathKey]+" share "+owned[pi]);
      pathOwners[pathKey]=name;
    }
  }
  // Every selected audit dependency lies behind the ordinary-module barrier.
  for(i=ordered.length-1;i>=0;i--){
    name=ordered[i];var deps=modules[name].imports;
    for(var j=0;j<deps.length;j++)if(modules[deps[j]].local&&parallelRuntime.rank.hasOwnProperty(deps[j]))
      parallelRuntime.rank[deps[j]]=Math.max(parallelRuntime.rank[deps[j]],parallelRuntime.rank[name]+1);
  }
  var rows=[];
  for(i=0;i<ordered.length;i++){
    name=ordered[i];var local=[];deps=modules[name].imports;
    for(j=0;j<deps.length;j++)if(modules[deps[j]].local)local.push(deps[j]);
    var quoted=[];for(j=0;j<local.length;j++)quoted.push(quoteJSON(local[j]));
    rows.push('{"module":'+quoteJSON(name)+',"priority_depth":'+parallelRuntime.rank[name]+',"local_imports":['+quoted.join(",")+']}');
  }
  write(root+"\\run-parallel-plan.json",'{"schema":"RH_PARALLEL_PLAN_V1","workers":'+parallelRuntime.workers+
    ',"total_thread_budget":'+jobs+',"worker_memory_admission_mb":'+parallelRuntime.workerMemoryMB+
    ',"ram_warm_budget_mb":'+parallelRuntime.ramCapMB+',"final_audit_barrier":'+quoteJSON(finalAuditName)+',"modules":['+rows.join(",")+']}\n');
}
function parallelActiveThreads() {
  var used=0;for(var i=0;i<parallelRuntime.active.length;i++)used+=parallelRuntime.active[i].threads;return used;
}
function resourceHashJobs() {
  return Math.max(1,Math.min(16,jobs-parallelActiveThreads()));
}
function parallelDependencyState(name) {
  var deps=modules[name].imports,waiting=false;
  for(var i=0;i<deps.length;i++)if(modules[deps[i]].local){
    var state=parallelRuntime.states[deps[i]];
    if(state==="FAILED"||state==="BLOCKED")return {ready:false,failed:deps[i]};
    if(state!=="DONE"||!moduleKeys[deps[i]]||!artifactHashes[deps[i]])waiting=true;
  }
  return {ready:!waiting,failed:""};
}
function parallelRecord(name,started,outcome) {
  var ms=elapsedSince(started);modulePhaseRecords.push({name:name,elapsed_ms:ms,outcome:outcome});
  diagnosticLog("MODULE_ELAPSED_MS="+name+"|"+ms+"|"+outcome);
}
function parallelPrepare(name) {
  var started=new Date().getTime(),n=modules[name],input=moduleInput(name),restored=restoreAnchor(name,input);
  if(restored&&!restored.needsAudit){
    acceptRestored(name,input,restored);parallelRuntime.states[name]="DONE";
    parallelRecord(name,started,buildStates[name]);return null;
  }
  var output=restored?restored.output:clearOutputs(name);mkdir(fso.GetParentFolderName(output));
  var task={name:name,started:started,input:input,restored:restored,output:output,threads:0,proc:null,
    phase:restored?"AUDIT":"COMPILE",compileLog:helpers+"\\"+name+".compile.log",
    auditSource:root+"\\RunnerAudit\\"+name.replace(/\./g,"_")+".lean",auditLog:helpers+"\\"+name+".audit.log"};
  requireShortPath(output,"Working Lean artifact path");requireShortPath(task.compileLog,"Compile log path");
  requireShortPath(task.auditSource,"Generated audit source path");requireShortPath(task.auditLog,"Audit log path");
  parallelRuntime.tasks[name]=task;parallelRuntime.states[name]="READY";
  if(restored){auditOnly++;log("AUDIT_ONLY_START="+name);}
  return task;
}
function startNativeAsync(exe,args,output,threads,kind) {
  var command=quote(exe);for(var i=0;i<args.length;i++)command+=" "+quote(args[i]);
  command+=" > "+quote(output)+" 2>&1";
  var previousThreads=String(env("LEAN_NUM_THREADS")||"");
  if(threads)env("LEAN_NUM_THREADS")=String(threads);
  try{
    var process=shell.Exec(quote(comspec)+' /d /v:off /s /c "'+command+'"');
    if(!directLaunchCounts.hasOwnProperty(kind))directLaunchCounts[kind]=0;
    directLaunchCounts[kind]++;directLaunchCounts.total++;return process;
  }finally{if(threads)env("LEAN_NUM_THREADS")=previousThreads;}
}
function parallelStartPhase(task) {
  stage="MODULE:"+task.name;
  var args;
  if(task.phase==="COMPILE"){
    log("COMPILE_START="+task.name);
    args=["-j"+task.threads,"-o",task.output,modules[task.name].source];
    task.proc=startNativeAsync(compiler,args,task.compileLog,task.threads,"lean");
  }else{
    var audit="import "+task.name+"\n";
    for(var i=0;i<auditTargets[task.name].length;i++)audit+="#check "+auditTargets[task.name][i]+"\n#print axioms "+auditTargets[task.name][i]+"\n";
    writeAscii(task.auditSource,audit);log("AXIOM_AUDIT_START="+task.name);
    task.proc=startNativeAsync(compiler,["-j"+task.threads,task.auditSource],task.auditLog,task.threads,"lean");
  }
  log("PARALLEL_WORKER="+task.name+"|PHASE="+task.phase+"|THREADS="+task.threads+"|SHELL_PID="+task.proc.ProcessID);
}
function parallelFail(task,state,message) {
  clearOutputs(task.name);buildStates[task.name]=state;parallelRuntime.states[task.name]="FAILED";failed++;
  if(message)log(message);
  parallelRecord(task.name,task.started,state);
}
function parallelAdvance(task) {
  if(task.proc.Status===0)return false;
  stage="MODULE:"+task.name;
  var rc=task.proc.ExitCode;
  if(task.phase==="COMPILE"){
    var compileContents=exists(task.compileLog)?read(task.compileLog):"";
    if(compileContents)log(compileContents);
    if(rc!==0){parallelFail(task,"COMPILE_FAILED","COMPILE_FAIL="+task.name);return true;}
    if(/sorryAx/.test(compileContents)){parallelFail(task,"AUDIT_FAILED","AXIOM_AUDIT_FAIL="+task.name+" : Compiler reported sorryAx.");return true;}
    if(!exists(task.output)){parallelFail(task,"COMPILE_FAILED","COMPILE_FAIL="+task.name+" : Missing output artifact.");return true;}
    task.phase="AUDIT";parallelStartPhase(task);return false;
  }
  var auditText=exists(task.auditLog)?read(task.auditLog):"";
  if(rc!==0){if(auditText)log(auditText);parallelFail(task,"AUDIT_COMPILE_FAILED","AXIOM_AUDIT_FAIL="+task.name);return true;}
  try{checkAxioms(auditText,auditTargets[task.name]);}
  catch(auditError){parallelFail(task,"AUDIT_FAILED","AXIOM_AUDIT_FAIL="+task.name+" : "+auditError.message);return true;}
  // The coordinator alone can accept an audit, publish an anchor, and release dependents.
  append(auditLogPath,"MODULE="+task.name+"\r\n"+auditText+"\r\n");
  saveAnchor(task.name,task.input,task.auditLog,task.output,task.restored?task.restored.receipt:"");
  audited+=auditTargets[task.name].length;
  if(task.restored){
    reused++;buildStates[task.name]="FROZEN_REUSED_REAUDITED";
    if(task.restored.legacy){migrated++;log("LEGACY_ANCHOR_MIGRATED="+task.name);}
    log("AUDIT_ONLY_PASS="+task.name);
  }else{compiled++;buildStates[task.name]="COMPILED_AUDITED";log("COMPILE_AND_AXIOM_AUDIT_PASS="+task.name);}
  parallelRuntime.states[task.name]="DONE";parallelRecord(task.name,task.started,buildStates[task.name]);return true;
}
function parallelReadyTasks() {
  var ready=[];
  for(var i=0;i<ordered.length;i++)if(parallelRuntime.states[ordered[i]]==="READY")ready.push(parallelRuntime.tasks[ordered[i]]);
  ready.sort(function(a,b){return parallelRuntime.rank[b.name]-parallelRuntime.rank[a.name]||parallelRuntime.orderIndex[a.name]-parallelRuntime.orderIndex[b.name];});
  return ready;
}
/* Adaptive admission affects scheduling only, never proof/cache acceptance. */
function parallelStopRamForMemory() {
  var ram=parallelRuntime.ram;
  if(!ram)return true;
  try{
    if(ram.proc.Status!==0){parallelReportRamCompletion();return true;}
    log("RAM_WARM_RELEASE_FOR_MEMORY=REQUESTED");
    write(ram.stop,ram.token+"\n");
    var started=new Date().getTime();
    while(ram.proc.Status===0&&elapsedSince(started)<5000)WScript.Sleep(100);
    if(ram.proc.Status===0){
      parallelRuntime.memoryDenial="RAM_WARM_RELEASE_UNCONFIRMED|WAIT_MS=5000";
      return false;
    }
    parallelReportRamCompletion();
    log("RAM_WARM_RELEASE_FOR_MEMORY=EXIT_CONFIRMED");
    return true;
  }catch(ramReleaseError){
    parallelRuntime.memoryDenial="RAM_WARM_RELEASE_UNCERTAIN : "+ramReleaseError.message;
    return false;
  }
}
function parallelTrySerialFallback() {
  // Only an idle coordinator may change the active invocation to serial mode.
  if(parallelRuntime.active.length)return false;
  parallelRuntime.memoryPressureSeen=true;
  if(!parallelStopRamForMemory())return false;
  // Do not credit mapped bytes as newly free RAM. Observe the OS after exit.
  var memory=parallelMemorySnapshot(true);
  if(!memory){parallelRuntime.memoryDenial="MEMORY_REFRESH_UNKNOWN_AFTER_PRESSURE";return false;}
  var required=parallelRuntime.minimumReserveMB+parallelRuntime.workerMemoryMB;
  if(memory.freeMB<required){
    parallelRuntime.memoryDenial="FREE_MB="+memory.freeMB+"|REQUIRED_MB="+required+
      "|LIVE_WORKERS=0|POLICY=SERIAL_MINIMUM";
    return false;
  }
  parallelRuntime.workers=1;
  parallelRuntime.reserveMB=parallelRuntime.minimumReserveMB;
  parallelRuntime.ramCapMB=0;
  parallelRuntime.ramDisabledForMemory=true;
  if(!parallelRuntime.ram)parallelRuntime.ramStatus="DISABLED_FOR_MEMORY_ADMISSION";
  if(!parallelRuntime.memoryFallback){
    log("PARALLEL_MEMORY_FALLBACK=SERIAL_UNTIL_EXIT");
    log("PARALLEL_MODULE_WORKERS_EFFECTIVE=1");
    log("SYSTEM_MEMORY_RESERVE_EFFECTIVE_MB="+parallelRuntime.reserveMB);
    log("SERIAL_ADMISSION_MB=FREE:"+memory.freeMB+"|REQUIRED:"+required+
      "|WORKER:"+parallelRuntime.workerMemoryMB+"|RESERVE:"+parallelRuntime.reserveMB);
    log("RAM_WARM_FUTURE_BUDGET_MB=0");
  }
  parallelRuntime.memoryFallback=true;
  parallelRuntime.memoryDenial="";
  return true;
}
function parallelMemoryAllowsLaunch() {
  // Live-worker accounting remains conservative, including recent launches
  // whose allocations may not yet appear in the bounded-age WMI snapshot.
  var memory=parallelMemorySnapshot(false),live=parallelRuntime.active.length;
  if(!memory){
    if(parallelRuntime.memoryPressureSeen){
      parallelRuntime.memoryDenial="MEMORY_UNKNOWN_AFTER_KNOWN_PRESSURE";return false;
    }
    parallelRuntime.memoryDenial=live?"MEMORY_UNKNOWN_WITH_ACTIVE_WORKERS":"";
    return live===0;
  }
  var warmReserve=0;
  if(parallelRuntime.ram){
    try{if(parallelRuntime.ram.proc.Status===0)warmReserve=parallelRuntime.ramCapMB;}
    catch(unknownWarmMemory){warmReserve=parallelRuntime.ramCapMB;}
  }
  var required=parallelRuntime.reserveMB+warmReserve+(live+1)*parallelRuntime.workerMemoryMB;
  if(memory.freeMB>=required){parallelRuntime.memoryDenial="";return true;}
  parallelRuntime.memoryPressureSeen=true;
  parallelRuntime.memoryDenial="FREE_MB="+memory.freeMB+"|REQUIRED_MB="+required+"|LIVE_WORKERS="+live;
  if(live)return false;
  return parallelTrySerialFallback();
}
function parallelRequireFinalAuditMemory() {
  if(parallelRuntime.active.length)error("FINAL_AUDIT_BARRIER_BROKEN: ordinary workers remain active.");
  if(!parallelMemoryAllowsLaunch()){
    stage="RESOURCE_ADMISSION:FINAL_AUDIT";
    error("PARALLEL_RESOURCE_BLOCKED: "+parallelRuntime.memoryDenial);
  }
}

function parallelThreadShare(readyCount) {
  var reserve=parallelRuntime.workers>1?1:0,remaining=jobs-reserve-parallelActiveThreads();
  var slots=Math.min(parallelRuntime.workers-parallelRuntime.active.length,readyCount);
  if(slots<=0||remaining<1)return 0;
  return Math.max(1,Math.floor(remaining/slots));
}
function parallelLiveProcesses() {
  var live=[];
  for(var i=0;i<parallelRuntime.active.length;i++){
    var t=parallelRuntime.active[i];
    try{if(t.proc&&t.proc.Status===0)live.push(t.name+":"+t.phase+":"+t.proc.ProcessID);}
    catch(unknownWorker){live.push(t.name+":STATUS_UNKNOWN");}
  }
  if(parallelRuntime.ram){
    try{if(parallelRuntime.ram.proc.Status===0)live.push("RAM_WARM:"+parallelRuntime.ram.proc.ProcessID);}
    catch(unknownRam){live.push("RAM_WARM:STATUS_UNKNOWN");}
  }
  return live;
}
function parallelIsReadOnlyFollower(process) {
  if((process.name!=="cscript.exe"&&process.name!=="wscript.exe")||!process.command)return false;
  // Recognize the script argument itself, not an arbitrary later argument
  // that happens to contain the observer's path. Unknown commands stay guarded.
  var tokens=String(process.command).match(/"[^"\r\n]*"|[^\s"]+/g);
  if(!tokens||tokens.length<2)return false;
  var index=1;
  while(index<tokens.length&&/^\/\//.test(tokens[index]))index++;
  if(index>=tokens.length)return false;
  var script=tokens[index];
  if(script.charAt(0)==='"'&&script.charAt(script.length-1)==='"')script=script.slice(1,-1);
  if(!/^(?:[A-Za-z]:[\\/]|\\\\)/.test(script))return false;
  return keyPath(script)===keyPath(root+"\\tools\\follow_active.js");
}
/* Same-owner fresh-lock admission snapshot. Not used for stale recovery. */
function lockActualRelativeRunner(process) {
  if((process.name!=="cscript.exe"&&process.name!=="wscript.exe")||!process.command)return false;
  var tokens=String(process.command).match(/"[^"\r\n]*"|[^\s"]+/g);
  if(!tokens||tokens.length<2)return false;
  var index=1;
  while(index<tokens.length&&/^\/\//.test(tokens[index]))index++;
  if(index>=tokens.length)return false;
  var script=tokens[index];
  if(script.charAt(0)==='"'&&script.charAt(script.length-1)==='"')script=script.slice(1,-1);
  if(/^(?:[A-Za-z]:[\\/]|\\\\)/.test(script))return false;
  return /(?:^|[\\/])native_runner\.js$/i.test(script);
}
function lockCreatedNoLater(process,owner) {
  if(!validProcessCreation(process.created)||!validProcessCreation(owner.created))return false;
  var a=processCreationMillis(process.created),b=processCreationMillis(owner.created);
  return a<b||(a===b&&Number(process.created.slice(18,21))<=Number(owner.created.slice(18,21)));
}
function captureFreshAdmittedRelativeHosts(processes,snapshot,self) {
  lockAdmittedRelativeHosts=[];
  lockAdmittedRelativeOwner="";
  if(snapshot||!lockHeld)return;
  var needle=keyPath(root)+"\\";
  for(var i=0;i<processes.length;i++){
    var p=processes[i];
    if(p.pid===self.pid||p.parent===self.pid||!lockActualRelativeRunner(p)||!lockCreatedNoLater(p,self))continue;
    // An absolute workspace reference is never covered by this exception.
    if(p.command.replace(/\//g,"\\").toLowerCase().indexOf(needle)>=0)continue;
    lockAdmittedRelativeHosts.push({pid:p.pid,created:p.created,command:p.command});
  }
  lockAdmittedRelativeOwner=lockOwnerText;
  lockEvents.push("RUNNER_PREEXISTING_ADMITTED_UNRESOLVED_HOSTS="+lockAdmittedRelativeHosts.length);
}
function parallelIsFreshAdmittedRelativeHost(process) {
  if(!lockHeld||!lockAdmittedRelativeOwner||lockAdmittedRelativeOwner!==lockOwnerText)return false;
  if(process.pid===lockSelf.pid||process.parent===lockSelf.pid||!lockActualRelativeRunner(process))return false;
  // This same absolute-root guard also remains in assertNoLockWorkers.
  var command=process.command.replace(/\//g,"\\").toLowerCase();
  if(command.indexOf(keyPath(root)+"\\")>=0)return false;
  for(var i=0;i<lockAdmittedRelativeHosts.length;i++){
    var admitted=lockAdmittedRelativeHosts[i];
    if(process.pid===admitted.pid&&process.created===admitted.created&&process.command===admitted.command){
      diagnosticLog("SHUTDOWN_PREEXISTING_ADMITTED_UNRESOLVED_HOST=PID:"+process.pid);
      return true;
    }
  }
  return false;
}

function parallelShutdownInventory() {
  var processes=queryLockProcesses(),guarded=[];
  for(var i=0;i<processes.length;i++)if(!parallelIsReadOnlyFollower(processes[i])&&!parallelIsFreshAdmittedRelativeHost(processes[i]))guarded.push(processes[i]);
  return guarded;
}
/* A fresh complete inventory can resolve a transient unreadable process row.
   No process is omitted because it was previously unreadable or has exited by
   assumption. Existing stale-lock recovery does not call this retry wrapper. */
function unreadableLockWorkerError(process) {
  var e=new Error("LOCK_STATE_UNKNOWN: cannot exclude an active "+process.name+" worker with unreadable command line. No lock was changed.");
  e.rhUnreadableLockWorker=true;
  e.rhWorker={pid:process.pid,parent:process.parent,created:process.created,name:process.name};
  return e;
}
function parallelAssertShutdownInventory() {
  var ownerText=lockOwnerText,self=lockSelf,maxAttempts=6;
  if(!lockHeld||!ownerText||!self)error("LOCK_STATE_UNKNOWN: owned shutdown has no verified lock owner.");
  var selfIdentity=processIdentity(self),token=self.token;
  for(var attempt=1;attempt<=maxAttempts;attempt++){
    parallelRuntime.shutdownInventoryAttempts=attempt;
    if(!lockHeld||lockOwnerText!==ownerText)error("RUNNER_LOCK_CHANGED: shutdown ownership changed; the lock was preserved.");
    var snapshot=lockSnapshot();
    if(!snapshot||snapshot.text!==ownerText)error("RUNNER_LOCK_CHANGED: shutdown lock metadata changed; the lock was preserved.");
    var live=parallelLiveProcesses();
    if(live.length)error("LOCK_STATE_UNKNOWN: owned workers became live or uncertain during inventory recheck: "+live.join(","));
    var processes=parallelShutdownInventory(),current=identifyLockSelf(processes,token);
    if(processIdentity(current)!==selfIdentity)error("LOCK_STATE_UNKNOWN: runner process identity changed during shutdown recheck.");
    try{
      assertNoLockWorkers(processes,{owner:null},current);
    }catch(inventoryError){
      if(!inventoryError||inventoryError.rhUnreadableLockWorker!==true)throw inventoryError;
      var p=inventoryError.rhWorker;
      diagnosticLog("SHUTDOWN_UNREADABLE_WORKER=PID:"+p.pid+"|PARENT:"+p.parent+"|CREATED:"+p.created+"|NAME:"+p.name+"|ATTEMPT:"+attempt);
      if(attempt===maxAttempts)throw inventoryError;
      diagnosticLog("WORKER_INVENTORY_RECHECK=NEXT:"+(attempt+1)+"|MAX:"+maxAttempts+"|WAIT_MS:200");
      WScript.Sleep(200);
      continue;
    }
    live=parallelLiveProcesses();
    if(live.length)error("LOCK_STATE_UNKNOWN: owned workers became live or uncertain after inventory recheck: "+live.join(","));
    if(attempt>1)diagnosticLog("WORKER_INVENTORY_RECHECK=CLEAR|ATTEMPTS:"+attempt);
    return;
  }
  error("LOCK_STATE_UNKNOWN: shutdown inventory recheck exhausted without a verified result.");
}

function parallelReportRamCompletion() {
  var ram=parallelRuntime.ram;if(!ram)return;
  var exited=false,known=false,status=null,statusError="";
  try{
    exited=ram.proc.Status!==0;known=true;
    if(exited){
      var code=Number(ram.proc.ExitCode);
      if(!isFinite(code)||Math.floor(code)!==code)error("Invalid RAM helper shell exit code.");
      parallelRuntime.ramExitCode=code;
    }
  }catch(processError){known=false;statusError=processError.message;}
  try{status=readRamWarmStatus(ram);}
  catch(readStatusError){statusError=readStatusError.message;}
  if(!known)parallelRuntime.ramStatus="PROCESS_STATUS_UNKNOWN";
  else if(!exited)parallelRuntime.ramStatus=status?"ACTIVE_"+status.STATE:"ACTIVE_WITHOUT_VERIFIED_STATUS";
  else if(parallelRuntime.ramExitCode===3)parallelRuntime.ramStatus="EXITED_LEASE_TIMEOUT";
  else if(parallelRuntime.ramExitCode!==0)parallelRuntime.ramStatus="EXITED_NONZERO";
  else if(!status)parallelRuntime.ramStatus=statusError?"EXITED_WITH_UNVERIFIED_STATUS":"EXITED_WITHOUT_STATUS";
  else if(status.TERMINAL!=="1")parallelRuntime.ramStatus="EXITED_WITH_STALE_NONTERMINAL_STATUS";
  else parallelRuntime.ramStatus="EXITED_"+status.STATE;
  diagnosticLog("RAM_WARM_FINAL_STATE="+parallelRuntime.ramStatus);
  if(parallelRuntime.ramExitCode!==null)diagnosticLog("RAM_WARM_EXIT_CODE="+parallelRuntime.ramExitCode);
  if(status)diagnosticLog("RAM_WARM_LAST_VERIFIED_STATUS="+status.STATE+"|TERMINAL="+status.TERMINAL+
    "|HELD_BYTES_AT_STATUS="+status.HELD_BYTES+"|CURRENT_RESIDENCY=NOT_INFERRED");
  if(statusError)diagnosticLog("RAM_WARM_FINAL_STATUS_DETAIL="+statusError);
}
function parallelShutdown() {
  if(parallelRuntime.shutdownComplete)return parallelRuntime.shutdownClean;
  if(!lockHeld){parallelRuntime.shutdownComplete=true;parallelRuntime.shutdownClean=true;return true;}
  if(parallelRuntime.ram){
    try{write(parallelRuntime.ram.stop,parallelRuntime.ram.token+"\n");}
    catch(stopError){diagnosticLog("RAM_WARM_STOP_REQUEST_FAILED="+stopError.message);}
  }
  var started=new Date().getTime(),last=0,live=parallelLiveProcesses();
  while(live.length&&elapsedSince(started)<30000){
    if(elapsedSince(started)-last>=5000){last=elapsedSince(started);diagnosticLog("WORKER_DRAIN="+live.join(","));}
    WScript.Sleep(100);live=parallelLiveProcesses();
  }
  parallelReportRamCompletion();
  if(live.length){
    parallelRuntime.shutdownKeepLock=true;
    parallelRuntime.shutdownComplete=true;parallelRuntime.shutdownClean=false;
    diagnosticLog("RUNNER_LOCK_RETAINED=LIVE_OR_UNCERTAIN_OWNED_WORKERS");
    diagnosticLog("WORKERS_STILL_ACTIVE="+live.join(","));
    return false;
  }
  try{parallelAssertShutdownInventory();}
  catch(workerInventoryError){
    parallelRuntime.shutdownKeepLock=true;
    parallelRuntime.shutdownComplete=true;parallelRuntime.shutdownClean=false;
    diagnosticLog("RUNNER_LOCK_RETAINED=WORKER_INVENTORY_UNCERTAIN : "+workerInventoryError.message);return false;
  }
  parallelRuntime.shutdownComplete=true;parallelRuntime.shutdownClean=true;return true;
}
function processModulesParallel() {
  configureParallelRuntime();
  var completed=0;
  while(completed<ordered.length){
    var progress=false;
    for(var ai=parallelRuntime.active.length-1;ai>=0;ai--){
      if(parallelAdvance(parallelRuntime.active[ai])){parallelRuntime.active.splice(ai,1);progress=true;}
    }
    // Topological iteration permits any frozen descendants to become ready immediately.
    for(var i=0;i<ordered.length;i++){
      var name=ordered[i];if(parallelRuntime.states[name]!=="PENDING")continue;
      var dep=parallelDependencyState(name);
      if(dep.failed){
        clearOutputs(name);buildStates[name]="BLOCKED_DEPENDENCY";parallelRuntime.states[name]="BLOCKED";blocked++;
        log("MODULE_BLOCKED="+name+" DEPENDENCY="+dep.failed);progress=true;
      }else if(dep.ready){stage="MODULE:"+name;parallelPrepare(name);progress=true;}
    }
    var ready=parallelReadyTasks();
    maybeStartRamWarm(ready);
    while(ready.length&&parallelRuntime.active.length<parallelRuntime.workers&&parallelMemoryAllowsLaunch()){
      var threads=parallelThreadShare(ready.length);if(!threads)break;
      var task=ready.shift();task.threads=threads;parallelRuntime.states[task.name]="RUNNING";
      // Track before launch so a partial failure cannot release the package lock prematurely.
      parallelRuntime.active.push(task);parallelStartPhase(task);
      parallelRuntime.launches++;parallelRuntime.peak=Math.max(parallelRuntime.peak,parallelRuntime.active.length);progress=true;
    }
    completed=0;
    for(i=0;i<ordered.length;i++){
      var state=parallelRuntime.states[ordered[i]];
      if(state==="DONE"||state==="FAILED"||state==="BLOCKED")completed++;
    }
    var now=new Date().getTime();
    if(now-parallelRuntime.lastProgress>=5000||completed===ordered.length){
      log("PARALLEL_PROGRESS="+completed+"/"+ordered.length+"|ACTIVE="+parallelRuntime.active.length+"|READY="+ready.length+"|LEAN_THREADS="+parallelActiveThreads());
      parallelRuntime.lastProgress=now;
    }
    if(completed<ordered.length&&!parallelRuntime.active.length){
      if(ready.length&&parallelRuntime.memoryDenial){stage="RESOURCE_ADMISSION";error("PARALLEL_RESOURCE_BLOCKED: "+parallelRuntime.memoryDenial);}
      if(!progress)error("PARALLEL_SCHEDULER_STALLED: no running or dependency-ready module.");
    }
    if(!progress&&parallelRuntime.active.length)WScript.Sleep(100);
  }
  log("PARALLEL_PEAK_MODULE_WORKERS="+parallelRuntime.peak);
  log("PARALLEL_NEW_OR_REAUDITED_MODULE_TASKS="+parallelRuntime.launches);
  if(!parallelRuntime.ramAttempted)log("RAM_WARM=SKIPPED_NO_ELIGIBLE_DIRTY_FRONTIER");
}

/* Optional read-only compiled-import warmer. It is never a proof-validation cache. */
function ramHelperInput(source,csc) {
  var input=hasherInput(source,csc);
  input.manifest=input.manifest.replace(HELPER_SCHEMA,RAM_HELPER_SCHEMA).replace("/platform:anycpu","/platform:x64");
  input.key=textHash(input.manifest);return input;
}
function ramSelfTest(exe,output) {
  if(invokeNative(exe,["--self-test"],output)!==0||!exists(output)||trim(read(output))!=="RAM_WARM_SELF_TEST=PASS")
    error("RAM warmer self-test failed.");
}
function prepareRamWarmer() {
  var framework=env("SystemRoot")+"\\Microsoft.NET\\",candidates=[framework+"Framework64\\v4.0.30319\\csc.exe",framework+"Framework\\v4.0.30319\\csc.exe"],csc="";
  for(var i=0;i<candidates.length;i++)if(exists(candidates[i])){csc=candidates[i];break;}
  if(!csc){log("RAM_WARM_FALLBACK=EXISTING_NET_FRAMEWORK_CSC_UNAVAILABLE");return null;}
  var source=root+"\\tools\\NativeRamWarm.cs",input=ramHelperInput(source,csc);
  var parent=shortCacheGroup("ramwarmers",input.key),entries=subfolders(parent).reverse();
  for(i=0;i<entries.length;i++){
    var folder=entries[i];if(/\.pending$/.test(folder)||!exists(folder+"\\receipt.txt"))continue;
    try{
      var r=parseReceipt(read(folder+"\\receipt.txt")),exe=folder+"\\ramwarm.exe";
      if(r.SCHEMA!==RAM_HELPER_SCHEMA||r.TARGET!==TARGET||r.INPUT_SHA256!==input.key||r.SOURCE_SHA256!==input.sourceSHA||r.BUILD_PASS!=="1"||r.SELF_TEST_PASS!=="1")error("RAM helper cache identity mismatch.");
      var checked=freshHashSet([folder+"\\source.cs",exe,folder+"\\build.log",folder+"\\selftest.log"],"RAM_HELPER_CACHE",true);
      if(read(folder+"\\input.txt")!==input.manifest||checked[keyPath(folder+"\\source.cs")]!==input.sourceSHA||
        checked[keyPath(exe)]!==r.EXE_SHA256||checked[keyPath(folder+"\\build.log")]!==r.BUILD_LOG_SHA256||
        checked[keyPath(folder+"\\selftest.log")]!==r.SELF_TEST_LOG_SHA256||trim(read(folder+"\\selftest.log"))!=="RAM_WARM_SELF_TEST=PASS")error("RAM helper cached content mismatch.");
      ramSelfTest(exe,helpers+"\\ram-selftest-"+runTag+".log");recheckHasherInput(input);
      if(fileHash(exe)!==r.EXE_SHA256)fatalHashError("RAM helper changed during validation.");
      log("RAM_WARM_HELPER_CACHE=HIT");return {exe:exe,exeSHA:r.EXE_SHA256,source:source,sourceSHA:input.sourceSHA};
    }catch(cacheError){if(isFatalHashError(cacheError))throw cacheError;log("RAM_WARM_HELPER_REJECTED="+folder+" : "+cacheError.message);}
  }
  var dest=parent+"\\"+compactToken("ram-helper"),temp=dest+".pending";
  try{
    requireShortPath(temp+"\\selftest.log","RAM helper cache path");
    if(directory(dest)||directory(temp))error("RAM helper cache collision.");mkdir(temp);
    var helper=temp+"\\ramwarm.exe",sourceCopy=temp+"\\source.cs",compileLog=temp+"\\build.log",testLog=temp+"\\selftest.log";
    fso.CopyFile(source,sourceCopy,false);
    if(fileHash(sourceCopy)!==input.sourceSHA)error("RAM helper source copy mismatch.");
    var args=["/nologo","/noconfig","/target:exe","/optimize+","/platform:x64",
      "/reference:"+input.dir+"\\System.dll","/reference:"+input.dir+"\\System.Core.dll","/out:"+helper,sourceCopy];
    log("RAM_WARM_HELPER_BUILD=EXISTING_NET_FRAMEWORK_CSC");
    if(invokeNative(csc,args,compileLog)!==0||!exists(helper)){
      if(exists(compileLog))log(read(compileLog));error("RAM helper compilation failed.");
    }
    var helperSHA=fileHash(helper);ramSelfTest(helper,testLog);recheckHasherInput(input);
    if(fileHash(sourceCopy)!==input.sourceSHA||fileHash(helper)!==helperSHA)fatalHashError("RAM helper content changed during validation.");
    write(temp+"\\input.txt",input.manifest);
    write(temp+"\\receipt.txt","SCHEMA="+RAM_HELPER_SCHEMA+"\nTARGET="+TARGET+"\nINPUT_SHA256="+input.key+
      "\nSOURCE_SHA256="+input.sourceSHA+"\nEXE_SHA256="+helperSHA+"\nBUILD_LOG_SHA256="+fileHash(compileLog)+
      "\nSELF_TEST_LOG_SHA256="+fileHash(testLog)+"\nBUILD_PASS=1\nSELF_TEST_PASS=1\nTIME_UTC="+stamp()+"\n");
    fso.MoveFolder(temp,dest);log("RAM_WARM_HELPER_CACHE=BUILT_AND_SAVED");
    return {exe:dest+"\\ramwarm.exe",exeSHA:helperSHA,source:source,sourceSHA:input.sourceSHA};
  }catch(buildError){
    if(directory(temp)){try{fso.DeleteFolder(temp,true);}catch(cleanupError){}}
    if(isFatalHashError(buildError))throw buildError;
    log("RAM_WARM_FALLBACK="+buildError.message);return null;
  }
}
function ramCandidatePlan(ready) {
  var frequency={},visited={},rootIndex=0;
  function visit(name) {
    var key="$"+name;
    if(visited[key]===rootIndex)return;visited[key]=rootIndex;
    frequency[name]=(frequency[name]||0)+1;
    var n=modules[name];
    for(var j=0;j<n.imports.length;j++)visit(n.imports[j]);
  }
  for(var i=0;i<ready.length;i++){
    rootIndex=i+1;var deps=modules[ready[i].name].imports;
    for(var j=0;j<deps.length;j++)visit(deps[j]);
  }
  var names=keys(frequency),files=[],seen={};
  for(i=0;i<names.length;i++){
    var name=names[i],n=modules[name],family;
    // Only accepted local dependencies are mapped. No queued/running module output can enter.
    if(n.local){if(!moduleKeys[name]||parallelRuntime.states[name]!=="DONE")continue;family=artifactFamily(work+"\\"+name.replace(/\./g,"\\")+".olean");}
    else family=n.artifacts;
    for(j=0;j<family.length;j++){
      var path=family[j],key=keyPath(path);
      if(seen[key]||!/(?:\.olean(?:\..*)?|\.ir)$/i.test(path))continue;
      seen[key]=true;
      var size=Number(fso.GetFile(path).Size);if(!(size>0&&isFinite(size)))continue;
      files.push({module:name,path:norm(path),bytes:size,frequency:frequency[name],local:n.local});
    }
  }
  files.sort(function(a,b){return (b.local?1:0)-(a.local?1:0)||b.frequency-a.frequency||(a.module<b.module?-1:a.module>b.module?1:a.path<b.path?-1:a.path>b.path?1:0);});
  var selected=[],charged=0,budget=parallelRuntime.ramCapMB*1048576;
  for(i=0;i<files.length&&selected.length<4096;i++){
    var charge=Math.ceil(files[i].bytes/4096)*4096;
    if(charge>budget-charged)continue;
    selected.push(files[i]);charged+=charge;
  }
  var rows=["module|shared_ready_jobs|bytes|source_kind|path"];
  for(i=0;i<selected.length;i++)rows.push(selected[i].module+"|"+selected[i].frequency+"|"+selected[i].bytes+"|"+(selected[i].local?"AUDITED_LOCAL_IMPORT":"FINGERPRINTED_EXTERNAL_IMPORT")+"|"+selected[i].path);
  write(root+"\\run-ram-plan.tsv",rows.join("\n")+"\n");
  log("RAM_WARM_CANDIDATE_FILES="+files.length);log("RAM_WARM_SELECTED_FILES="+selected.length);
  log("RAM_WARM_SELECTED_CHARGED_BYTES="+charged);
  return selected;
}
function ramStatusInteger(status,name,maximum) {
  var raw=status[name];
  if(typeof raw!=="string"||!/^(?:0|[1-9][0-9]*)$/.test(raw))error("Invalid RAM status integer: "+name);
  var value=Number(raw);
  if(!isFinite(value)||Math.floor(value)!==value||value>maximum)error("Out-of-range RAM status integer: "+name);
  return value;
}
function readRamWarmStatus(ram) {
  if(!exists(ram.status))return null;
  var status=parseReceipt(read(ram.status));
  if(status.SCHEMA!=="RH_HILBERT_RAM_STATUS_V1"||status.TOKEN!==ram.token||status.REQUEST_SHA256!==ram.requestSHA||
    status.OWNER_PID!==String(lockSelf.pid)||status.OWNER_START_UNIX_MS!==String(processCreationMillis(lockSelf.created)))
    error("RAM warmer status does not match this exact request and owner.");
  if(!/^(INITIALIZING|READY|PARTIAL|STOPPED)$/.test(status.STATE||"")||!/^[01]$/.test(status.TERMINAL||""))error("Malformed RAM warmer status.");
  var count=ramStatusInteger(status,"REQUEST_FILES",ram.requestCount);
  if(count!==ram.requestCount)error("RAM warmer request count does not match.");
  var countFields=["PROCESSED_FILES","MAPPED_FILES","WARMED_FILES","SKIPPED_FILES","HELD_FILES"];
  for(var i=0;i<countFields.length;i++)ramStatusInteger(status,countFields[i],count);
  var budget=ramStatusInteger(status,"BUDGET_BYTES",ram.budgetBytes);
  var charged=ramStatusInteger(status,"CHARGED_BYTES",budget);
  var mapped=ramStatusInteger(status,"MAPPED_BYTES",charged);
  var held=ramStatusInteger(status,"HELD_BYTES",mapped);
  if(Number(status.HELD_FILES)>Number(status.MAPPED_FILES)||Number(status.WARMED_FILES)>Number(status.MAPPED_FILES))
    error("Inconsistent RAM warmer file counts.");
  if((status.STATE==="INITIALIZING"&&status.TERMINAL!=="0")||
    (status.STATE==="STOPPED"&&status.TERMINAL!=="1")||
    (status.TERMINAL==="1"&&(held!==0||Number(status.HELD_FILES)!==0)))
    error("Inconsistent RAM warmer lifecycle status.");
  if(status.MODE!=="WARM_MAPPED_FILE_CACHE"||status.RESIDENCY!=="NOT_GUARANTEED"||status.LEAN_ENVIRONMENT!=="NOT_SHARED")
    error("Unsupported RAM warmer status semantics.");
  return status;
}
function maybeStartRamWarm(ready) {
  if(parallelRuntime.ramAttempted||parallelRuntime.ramMode==="OFF"||parallelRuntime.ramCapMB<=0||!ready.length)return;
  if(parallelRuntime.ramMode==="AUTO"&&ready.length<2)return;
  // Prepare once, before any Lean workers: no hidden C# build competing with Lean.
  if(parallelRuntime.active.length)return;
  parallelRuntime.ramAttempted=true;
  try{
    var selected=ramCandidatePlan(ready);if(!selected.length){parallelRuntime.ramStatus="NO_ELIGIBLE_IMPORTS";return;}
    var helper=prepareRamWarmer();if(!helper){parallelRuntime.ramStatus="HELPER_UNAVAILABLE";return;}
    var token=compactToken("ram-warm"),base=helpers+"\\ram-"+token;
    var ram={token:token,request:base+".request.tsv",status:base+".status.txt",stop:base+".stop",log:base+".log",proc:null,
      requestCount:selected.length,budgetBytes:parallelRuntime.ramCapMB*1048576};
    requireShortPath(ram.status+".pending","RAM status path");
    if(exists(ram.request)||exists(ram.status)||exists(ram.stop))error("RAM request path collision.");
    var rows=["RH_HILBERT_RAM_REQUEST_V1|"+token+"|"+selected.length];
    for(var i=0;i<selected.length;i++){
      if(/[\x00-\x1f|]/.test(selected[i].path))error("Unsupported RAM path.");
      rows.push(i+"|"+selected[i].path);
    }
    write(ram.request,rows.join("\n")+"\n");ram.requestSHA=fileHash(ram.request);
    if(fileHash(helper.exe)!==helper.exeSHA||fileHash(helper.source)!==helper.sourceSHA)fatalHashError("RAM helper source or executable changed before launch.");
    var args=["--warm",ram.request,ram.status,ram.stop,String(lockSelf.pid),String(processCreationMillis(lockSelf.created)),token,String(parallelRuntime.ramCapMB)];
    ram.proc=startNativeAsync(helper.exe,args,ram.log,0,"ram_warm");parallelRuntime.ram=ram;parallelRuntime.ramStatus="STARTED";
    log("RAM_WARM_LOG="+ram.log);log("RAM_WARM_STATUS_FILE="+ram.status);
    var started=new Date().getTime(),status=null;
    while(elapsedSince(started)<5000){
      status=readRamWarmStatus(ram);
      if(status&&(status.STATE==="READY"||status.STATE==="PARTIAL"||status.STATE==="STOPPED"))break;
      if(ram.proc.Status!==0)break;WScript.Sleep(50);
    }
    status=readRamWarmStatus(ram);
    if(status){
      parallelRuntime.ramStatus=status.STATE;
      log("RAM_WARM_STATE="+status.STATE+"|MAPPED_FILES="+(status.MAPPED_FILES||"0")+"|HELD_BYTES="+(status.HELD_BYTES||"0"));
    }else{parallelRuntime.ramStatus=ram.proc.Status===0?"BACKGROUND_INITIALIZING":"EXITED_WITHOUT_STATUS";log("RAM_WARM_STATE="+parallelRuntime.ramStatus);}
    if(ram.proc.Status!==0&&ram.proc.ExitCode!==0){
      log("RAM_WARM_FALLBACK=HELPER_RUNTIME_UNAVAILABLE");if(exists(ram.log))log(read(ram.log));
    }
  }catch(warmError){
    if(isFatalHashError(warmError))throw warmError;
    parallelRuntime.ramStatus="DISABLED_AFTER_ERROR";log("RAM_WARM_FALLBACK="+warmError.message);
    if(parallelRuntime.ram){try{write(parallelRuntime.ram.stop,parallelRuntime.ram.token+"\n");}catch(stopError){}}
  }
}


function processModuleBody(name,isFinalAudit) {
  var n=modules[name],i;
  for(i=0;i<n.imports.length;i++)if(modules[n.imports[i]].local&&!moduleKeys[n.imports[i]]){
    clearOutputs(name);buildStates[name]="BLOCKED_DEPENDENCY";blocked++;log("MODULE_BLOCKED="+name+" DEPENDENCY="+n.imports[i]);return;
  }
  var input=moduleInput(name),restored=restoreAnchor(name,input);
  if(restored&&!restored.needsAudit){acceptRestored(name,input,restored);return;}
  if(isFinalAudit)parallelRequireFinalAuditMemory();
  var output=restored?restored.output:clearOutputs(name);mkdir(fso.GetParentFolderName(output));
  var compileLog=helpers+"\\"+name+".compile.log",auditSource=root+"\\RunnerAudit\\"+name.replace(/\./g,"_")+".lean",auditLog=helpers+"\\"+name+".audit.log";
  requireShortPath(output,"Working Lean artifact path");requireShortPath(compileLog,"Compile log path");
  requireShortPath(auditSource,"Generated audit source path");requireShortPath(auditLog,"Audit log path");
  if(!restored){
    log("COMPILE_START="+name);
    if(invokeNative(compiler,["-j"+jobs,"-o",output,n.source],compileLog)!==0){log(read(compileLog));clearOutputs(name);buildStates[name]="COMPILE_FAILED";failed++;log("COMPILE_FAIL="+name);return;}
    var compileContents=read(compileLog);if(compileContents)log(compileContents);
    if(/sorryAx/.test(compileContents))error("Compiler reported sorryAx in "+name);
  }else{auditOnly++;log("AUDIT_ONLY_START="+name);}
  if(isFinalAudit&&!restored){auditLog=compileLog;}
  else{
    var audit="import "+name+"\n";
    for(i=0;i<auditTargets[name].length;i++)audit+="#check "+auditTargets[name][i]+"\n#print axioms "+auditTargets[name][i]+"\n";
    writeAscii(auditSource,audit);log("AXIOM_AUDIT_START="+name);
    if(invokeNative(compiler,["-j"+jobs,auditSource],auditLog)!==0){log(read(auditLog));clearOutputs(name);buildStates[name]="AUDIT_COMPILE_FAILED";failed++;return;}
  }
  try{audited+=checkAxioms(read(auditLog),auditTargets[name]);}
  catch(e){clearOutputs(name);buildStates[name]="AUDIT_FAILED";failed++;log("AXIOM_AUDIT_FAIL="+name+" : "+e.message);return;}
  append(auditLogPath,"MODULE="+name+"\r\n"+read(auditLog)+"\r\n");
  saveAnchor(name,input,auditLog,output,restored?restored.receipt:"");
  if(restored){reused++;buildStates[name]="FROZEN_REUSED_REAUDITED";if(restored.legacy){migrated++;log("LEGACY_ANCHOR_MIGRATED="+name);}log("AUDIT_ONLY_PASS="+name);}
  else{compiled++;buildStates[name]="COMPILED_AUDITED";log("COMPILE_AND_AXIOM_AUDIT_PASS="+name);}
}
function processModule(name,isFinalAudit) {
  var started=new Date().getTime(),outcome="ERROR";
  try{var value=processModuleBody(name,isFinalAudit);outcome=buildStates[name]||"RETURNED";return value;}
  finally{
    var ms=elapsedSince(started);modulePhaseRecords.push({name:name,elapsed_ms:ms,outcome:outcome});
    diagnosticLog("MODULE_ELAPSED_MS="+name+"|"+ms+"|"+outcome);
  }
}
function finalAudit() {
  log("FINAL_AUDIT_START="+finalAuditRelative);processModule(finalAuditName,true);
  if(!moduleKeys[finalAuditName])error("Final "+finalAuditRelative+" was not successfully compiled/reused and audited.");
  log("FINAL_AUDIT_DECLARATIONS="+auditTargets[finalAuditName].length);
}
function quoteJSON(s) {return '"'+String(s).replace(/\\/g,"\\\\").replace(/"/g,'\\"').replace(/\r/g,"\\r").replace(/\n/g,"\\n").replace(/\t/g,"\\t")+'"';}
function numericMapJSON(values) {
  var out=[],names=keys(values);for(var i=0;i<names.length;i++)out.push(quoteJSON(names[i])+":"+values[names[i]]);
  return "{"+out.join(",")+"}";
}
function phaseRecordsJSON(records) {
  var out=[];
  for(var i=0;i<records.length;i++){
    var r=records[i],s="{\"name\":"+quoteJSON(r.name)+",\"elapsed_ms\":"+r.elapsed_ms+",\"outcome\":"+quoteJSON(r.outcome);
    if(typeof r.files==="number")s+=",\"files\":"+r.files;
    if(typeof r.backend==="string")s+=",\"backend\":"+quoteJSON(r.backend);
    out.push(s+"}");
  }
  return "["+out.join(",")+"]";
}
function result(pass,message) {
  var lines=["{",'  "package": '+quoteJSON(PACKAGE)+",",'  "target": "LOCAL_COMPILER",',
    '  "lean_version": '+quoteJSON(leanVersion)+",",'  "build": '+quoteJSON(pass?"PASS":"FAIL")+",",
    '  "axiom_audit": '+quoteJSON(pass?"PASS":"INCOMPLETE_OR_FAILED")+",",
    '  "mathematical_status": '+quoteJSON(pass?"ANALYTIC_CRITERIA_AUDITED_FINITE_CHECKER_OPEN":"NEW_ANALYTIC_SOURCE_NATIVE_AUDIT_PENDING")+",",
    '  "canonical_power_sums": '+quoteJSON(pass?"EXACT_CONSTRUCTION_AUDITED":"NEW_SOURCE_NATIVE_AUDIT_PENDING")+",",
    '  "actual_spectral_calibration": '+quoteJSON(pass?"EXACT_CONSTRUCTION_AUDITED":"NEW_SOURCE_NATIVE_AUDIT_PENDING")+",",
    '  "dominant_extraction": '+quoteJSON(pass?"EXACT_CONSTRUCTION_AUDITED":"NEW_SOURCE_NATIVE_AUDIT_PENDING")+",",
    '  "unconditional_actual_limit": '+quoteJSON(pass?"ROOT_SCALE_LIMIT_DECLARATION_AUDITED":"NOT_CERTIFIED")+",",
    '  "ordinary_limit_sequence": "rootScale actualVariation",',
    '  "actual_subexponential_bound": "OPEN",','  "unconditional_rh": "NOT_ESTABLISHED",',
    '  "finite_accepted_witness": "NOT_ESTABLISHED",','  "finite_checker_equivalence": "OPEN",','  "formal_closure": "OPEN",',
    '  "final_audit_source": '+quoteJSON(finalAuditRelative)+",",
    '  "project_cache": "READ_WRITE",','  "cache_root": '+quoteJSON(anchorRoot)+",",
    '  "persistent_storage_root": '+quoteJSON(persistentStorageRoot)+",",'  "persistent_workspace": '+quoteJSON(persistentWorkspace)+",",
    '  "persistent_project_cache": '+quoteJSON(persistentProjectCache)+",",'  "cache_retention": "VALID_ANCHORS_NO_QUOTA_NO_AUTOMATIC_EVICTION",',
    '  "hash_helper_cache": '+quoteJSON(helperCacheState)+",",
    '  "lock_policy": "PID_CREATION_AND_PERMANENT_QUARANTINE_V1",','  "stale_locks_recovered": '+lockRecovered+",",
    '  "compiled": '+compiled+",",'  "frozen_reused": '+reused+",",'  "audit_only": '+auditOnly+",",'  "legacy_migrated": '+migrated+",",'  "failed": '+failed+",",'  "blocked": '+blocked+",",
    '  "runner_profile": "LOCAL_FAST_CACHED_RAM_PARALLEL",','  "cache_validation": "FRESH_CONTENT_HASHES_SAME_TARGET_AUDIT",','  "anchor_write_layout": "COMPACT_V1",',
    '  "working_artifact_modules_retained": '+workingRetained+",",'  "restored_artifact_files": '+restoredArtifactFiles+",",'  "anchor_history_scans": '+anchorHistoryScans+",",'  "compact_anchors_saved": '+compactAnchorsSaved+",",
    '  "combined_working_digests_consumed": '+workingDigestConsumed+",",'  "runtime_elapsed_ms": '+elapsedSince(runtimeStarted)+",",
    '  "parallel_module_workers": '+parallelRuntime.workers+",",'  "parallel_peak_module_workers": '+parallelRuntime.peak+",",
    '  "lean_total_thread_budget": '+jobs+",",'  "ram_warm_status": '+quoteJSON(parallelRuntime.ramStatus)+",",
    '  "memory_serial_fallback": '+(parallelRuntime.memoryFallback?"true":"false")+",",
    '  "memory_preferred_reserve_mib": '+parallelRuntime.preferredReserveMB+",",'  "memory_effective_reserve_mib": '+parallelRuntime.reserveMB+",",
    '  "ram_disabled_for_memory": '+(parallelRuntime.ramDisabledForMemory?"true":"false")+",",
    '  "preexisting_admitted_unresolved_hosts": '+lockAdmittedRelativeHosts.length+",",
    '  "shutdown_inventory_attempts": '+parallelRuntime.shutdownInventoryAttempts+",",
    '  "ram_warm_exit_code": '+(parallelRuntime.ramExitCode===null?"null":String(parallelRuntime.ramExitCode))+",",
    '  "ram_warm_residency": "OS_MANAGED_NOT_GUARANTEED",','  "owned_worker_shutdown_complete": '+(parallelRuntime.shutdownClean?"true":"false")+",",
    '  "logical_tool_launches": '+numericMapJSON(directLaunchCounts)+",",'  "hash_phase_totals": '+numericMapJSON(hashPhaseTotals)+",",
    '  "stage_timings": '+phaseRecordsJSON(stagePhaseRecords)+",",'  "module_timings": '+phaseRecordsJSON(modulePhaseRecords)+",",'  "hash_timings": '+phaseRecordsJSON(hashPhaseRecords)+",",
    '  "audited_declarations_with_module_multiplicity": '+audited+",",'  "time_utc": '+quoteJSON(stamp())+",",'  "message": '+quoteJSON(message)+",",'  "modules": {'];
  var names=keys(buildStates);for(var i=0;i<names.length;i++)lines.push("    "+quoteJSON(names[i])+": "+quoteJSON(buildStates[names[i]])+(i+1<names.length?",":""));
  lines.push("  }","}");write(root+"\\run-result.json",lines.join("\r\n")+"\r\n");
}
var exitCode=1, runFailureMessage="";
try{
  stage="PERSISTENT_PROFILE";configurePersistentProfile();
  stage="RUNNER_LOCK";acquireRunnerLock();
  write(logPath,"");write(auditLogPath,"");mkdir(helpers);
  for(var li=0;li<lockEvents.length;li++)log(lockEvents[li]);
  if(!exists(certutil))error("Native certutil.exe is required for SHA256 fingerprints.");
  if(textHash("")!=="e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"||textHash("abc")!=="ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad")error("Manifest SHA256 self-check failed.");
  log("PACKAGE="+PACKAGE);log("RUNNER="+RUNNER_VERSION);log("ANCHOR_SCHEMA="+SCHEMA);log("TARGET="+TARGET);
  log("PERSISTENT_STORAGE_ROOT="+persistentStorageRoot);log("PERSISTENT_WORKSPACE="+persistentWorkspace);
  log("PERSISTENT_PROJECT_CACHE="+persistentProjectCache);log("CACHE_RETENTION=VALID_ANCHORS_NO_QUOTA_NO_AUTOMATIC_EVICTION");
  log("RUNNER_LOCK_POLICY=PID_CREATION_AND_PERMANENT_QUARANTINE_V1");
  log("RUNNER_PROFILE=LOCAL_FAST_CACHED_RAM_PARALLEL");log("CACHE_VALIDATION=FRESH_CONTENT_HASHES_SAME_TARGET_AUDIT");log("ANCHOR_WRITE_LAYOUT=COMPACT_V1");
  log("NETWORK=NOT_USED");log("LAKE=NOT_USED");log("PYTHON=NOT_USED");log("POWERSHELL=NOT_USED");log("WSL=NOT_USED");
  timedStage("COMPILER",selectCompiler);timedStage("MATHLIB_REQUIREMENTS",loadMathlibRequirements);
  timedStage("MATHLIB_CACHE",selectCache);timedStage("DEPENDENCY_GRAPH",loadPlan);
  timedStage("CONTENT_FINGERPRINTS",function(){parallelHashes();makeGlobalKey();});
  timedStage("PROJECT_MODULES",processModulesParallel);
  if(failed||blocked)error("Some modules failed or were blocked. Independent modules were still attempted.");
  timedStage("FINAL_AUDIT",finalAudit);
  if(!timedStage("WORKER_SHUTDOWN",parallelShutdown))error("Owned workers remain live or uncertain; the workspace lock is preserved until they finish.");
  log("AXIOM_AUDIT=PASS_STANDARD_LOGICAL_AXIOMS_ONLY");log("SORRYAX=NONE");
  log("MATHEMATICAL_STATUS=ANALYTIC_CRITERIA_AUDITED_FINITE_CHECKER_OPEN");
  log("CANONICAL_POWER_SUMS=EXACT_CONSTRUCTION_AUDITED");log("ACTUAL_SPECTRAL_CALIBRATION=EXACT_CONSTRUCTION_AUDITED");
  log("DOMINANT_EXTRACTION=EXACT_CONSTRUCTION_AUDITED");log("UNCONDITIONAL_ACTUAL_LIMIT=ROOT_SCALE_LIMIT_DECLARATION_AUDITED");
  log("ORDINARY_LIMIT_SEQUENCE=rootScale actualVariation");log("ACTUAL_SUBEXPONENTIAL_BOUND=OPEN");
  log("UNCONDITIONAL_RH=NOT_ESTABLISHED");log("FINITE_ACCEPTED_WITNESS=NOT_ESTABLISHED");
  log("FINITE_CHECKER_EQUIVALENCE=OPEN");log("FORMAL_CLOSURE=OPEN");
  log("COMPILED_MODULES="+compiled);log("FROZEN_REUSED_MODULES="+reused);log("AUDIT_ONLY_MODULES="+auditOnly);log("LEGACY_MIGRATED_MODULES="+migrated);log("PROJECT_BUILD=PASS");log("RUN=PASS");
  log("WORKING_ARTIFACT_MODULES_RETAINED="+workingRetained);log("RESTORED_ARTIFACT_FILES="+restoredArtifactFiles);log("ANCHOR_HISTORY_SCANS="+anchorHistoryScans);log("COMPACT_ANCHORS_SAVED="+compactAnchorsSaved);
  log("COMBINED_WORKING_DIGESTS_CONSUMED="+workingDigestConsumed);log("LOGICAL_TOOL_LAUNCHES="+numericMapJSON(directLaunchCounts));log("HASH_PHASE_TOTALS="+numericMapJSON(hashPhaseTotals));
  result(true,"Exact supplied declarations compiled and passed their recorded axiom audits; theorem hypotheses remain explicit.");exitCode=0;
}catch(e){
  runFailureMessage=e.message;
  if(lockHeld){try{log("PROJECT_BUILD=FAIL");log("FAILED_STAGE="+stage);log("REASON="+e.message);log("RUN=FAIL");}catch(ignore){WScript.Echo("RUN=FAIL : "+e.message);}}
  else WScript.Echo("RUN=FAIL : "+e.message);
}
if(lockHeld){
  var shutdownClean=false;
  try{shutdownClean=parallelShutdown();}catch(shutdownError){diagnosticLog("RUNNER_LOCK_RETAINED=SHUTDOWN_UNCERTAIN : "+shutdownError.message);}
  if(exitCode!==0){try{result(false,runFailureMessage||"Native run failed.");}catch(resultError){WScript.Echo("RESULT_WRITE_FAILED="+resultError.message);}}
  if(shutdownClean)releaseRunnerLock();
}
WScript.Echo((lockEverHeld?"Logs: ":"Existing logs were not overwritten: ")+logPath+" and "+auditLogPath);
WScript.Quit(exitCode);
