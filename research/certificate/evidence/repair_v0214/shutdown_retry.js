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
