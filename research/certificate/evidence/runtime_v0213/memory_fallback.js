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
