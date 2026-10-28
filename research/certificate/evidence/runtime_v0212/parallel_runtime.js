/* Dependency-aware native coordinator. Source preparation only; not run on Windows here. */
var parallelRuntime = {configured:false, workers:1, active:[], tasks:{}, states:{}, rank:{},
  orderIndex:{}, peak:0, launches:0, lastProgress:0, memory:null, memoryReadAt:0,
  workerMemoryMB:4096, reserveMB:4096, ramCapMB:0, ramMode:"AUTO", ramAttempted:false,
  ram:null, ramStatus:"NOT_NEEDED", ramExitCode:null, shutdownKeepLock:false, shutdownComplete:false, shutdownClean:false,
  memoryDenial:""};
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
  var mode=trim(env("RH_RAM_WARM")||"AUTO").toUpperCase();
  if(mode!=="AUTO"&&mode!=="ON"&&mode!=="OFF")error("RH_RAM_WARM must be AUTO, ON or OFF.");
  parallelRuntime.ramMode=mode;
  var cap=parallelIntegerSetting("RH_RAM_WARM_MB",8192,0,65536),memoryWorkers=1;
  if(memory){
    parallelRuntime.reserveMB=Math.max(parallelRuntime.reserveMB,Math.ceil(memory.totalMB/5));
    parallelRuntime.ramCapMB=mode==="OFF"?0:Math.max(0,Math.min(cap,Math.floor(memory.freeMB/4),memory.freeMB-parallelRuntime.reserveMB-parallelRuntime.workerMemoryMB));
    memoryWorkers=Math.max(1,Math.floor((memory.freeMB-parallelRuntime.reserveMB-parallelRuntime.ramCapMB)/parallelRuntime.workerMemoryMB));
  }else{parallelRuntime.ramCapMB=0;log("MEMORY_ADMISSION=UNKNOWN_SERIAL_FALLBACK");}
  parallelRuntime.workers=Math.max(1,Math.min(requested,jobs>1?jobs-1:1,memoryWorkers));
  if(jobs===1)parallelRuntime.workers=1;
  parallelRuntime.configured=true;
  log("PARALLEL_MODULE_WORKERS="+parallelRuntime.workers);
  log("LEAN_TOTAL_THREAD_BUDGET="+jobs);
  log("PARALLEL_COORDINATOR_THREAD_RESERVE="+(parallelRuntime.workers>1?1:0));
  log("WORKER_MEMORY_ADMISSION_MB="+parallelRuntime.workerMemoryMB);
  log("SYSTEM_MEMORY_RESERVE_MB="+parallelRuntime.reserveMB);
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
function parallelMemoryAllowsLaunch() {
  // Reserve every live worker's allowance, including launches not yet
  // reflected in the bounded-age WMI snapshot. Repeated denials stay throttled.
  var memory=parallelMemorySnapshot(false),live=parallelRuntime.active.length;
  if(!memory){
    parallelRuntime.memoryDenial=live?"MEMORY_UNKNOWN_WITH_ACTIVE_WORKERS":"";
    return live===0; // Preserve the original serial fallback only when RAM is unknown.
  }
  var warmReserve=0;
  if(parallelRuntime.ram){
    try{if(parallelRuntime.ram.proc.Status===0)warmReserve=parallelRuntime.ramCapMB;}
    catch(unknownWarmMemory){warmReserve=parallelRuntime.ramCapMB;}
  }
  var required=parallelRuntime.reserveMB+warmReserve+(live+1)*parallelRuntime.workerMemoryMB;
  parallelRuntime.memoryDenial=memory.freeMB>=required?"":
    "FREE_MB="+memory.freeMB+"|REQUIRED_MB="+required+"|LIVE_WORKERS="+live;
  return !parallelRuntime.memoryDenial;
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
function parallelShutdownInventory() {
  var processes=queryLockProcesses(),guarded=[];
  for(var i=0;i<processes.length;i++)if(!parallelIsReadOnlyFollower(processes[i]))guarded.push(processes[i]);
  return guarded;
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
  try{assertNoLockWorkers(parallelShutdownInventory(),{owner:null},lockSelf);}
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
    if(completed<ordered.length&&!progress&&!parallelRuntime.active.length){
      if(ready.length&&parallelRuntime.memoryDenial)error("PARALLEL_RESOURCE_BLOCKED: "+parallelRuntime.memoryDenial);
      error("PARALLEL_SCHEDULER_STALLED: no running or dependency-ready module.");
    }
    if(!progress&&parallelRuntime.active.length)WScript.Sleep(100);
  }
  log("PARALLEL_PEAK_MODULE_WORKERS="+parallelRuntime.peak);
  log("PARALLEL_NEW_OR_REAUDITED_MODULE_TASKS="+parallelRuntime.launches);
  if(!parallelRuntime.ramAttempted)log("RAM_WARM=SKIPPED_NO_ELIGIBLE_DIRTY_FRONTIER");
}
