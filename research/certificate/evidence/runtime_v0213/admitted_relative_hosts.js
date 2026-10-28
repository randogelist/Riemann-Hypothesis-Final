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
