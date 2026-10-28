/* Read-only observer for an existing native Windows Hilbert runner.
   This script never acquires/recovers/releases a lock, starts a compiler,
   terminates a process, writes target files, or reads run-result.json.
   Observed log text is not a build or mathematical certification. */
var followFSO = new ActiveXObject("Scripting.FileSystemObject");
var FOLLOW_OWNER_SCHEMA = "RH_HILBERT_RUN_LOCK_V1";

function followError(message) { throw new Error(message); }
function followString(value) { return value===null||typeof value==="undefined"?"":String(value); }
function followPath(path) {
  var value=followFSO.GetAbsolutePathName(path).replace(/\//g,"\\");
  return /^[A-Za-z]:\\$/.test(value)?value:value.replace(/\\+$/g,"");
}
function followPathKey(path) { return followPath(path).toLowerCase(); }
function followRead(path) {
  var stream=new ActiveXObject("ADODB.Stream");
  stream.Type=2;stream.Charset="utf-8";stream.Open();
  try{stream.LoadFromFile(path);return String(stream.ReadText()).replace(/^\uFEFF/,"");}
  finally{stream.Close();}
}
function followValidCreation(value) { return /^\d{14}\.\d{6}[+-]\d{3}$/.test(value); }
function followArgument(command,argument) {
  var c=String(command).replace(/\//g,"\\").toLowerCase(),a=String(argument).replace(/\//g,"\\").toLowerCase();
  return c.indexOf('"'+a+'"')>=0||(" "+c+" ").indexOf(" "+a+" ")>=0;
}
function followOwnerText(owner) {
  return "SCHEMA="+FOLLOW_OWNER_SCHEMA+"\nROOT="+owner.ROOT+"\nSCRIPT="+owner.SCRIPT+"\nPID="+owner.PID+
    "\nCREATED="+owner.CREATED+"\nTOKEN="+owner.TOKEN+"\nRUN_TAG="+owner.RUN_TAG+"\n";
}
function followSnapshot(target) {
  var lock=target+"\\.native-run.lock";
  try{
  if(!followFSO.FolderExists(lock)){
    if(followFSO.FileExists(lock))followError("The lock path is a file; ownership is uncertain.");
    return null;
  }
  var folder=followFSO.GetFolder(lock),dirs=new Enumerator(folder.SubFolders),files=new Enumerator(folder.Files),count=0,ownerPath="";
  if(!dirs.atEnd())followError("Unexpected directory inside the owner record.");
  for(;!files.atEnd();files.moveNext()){
    var file=files.item();count++;
    if(followFSO.GetFileName(file.Path).toLowerCase()!=="owner.txt")followError("Unexpected file inside the owner record.");
    ownerPath=file.Path;
  }
  if(count!==1)followError("No complete identifiable owner record is available.");
  var text=followRead(ownerPath),lines=text.split(/\r?\n/),owner={};
  for(var i=0;i<lines.length;i++){
    if(!lines[i])continue;
    var equals=lines[i].indexOf("=");
    if(equals<=0)followError("Malformed owner metadata.");
    var key=lines[i].slice(0,equals);
    if(owner.hasOwnProperty(key))followError("Duplicate owner metadata.");
    owner[key]=lines[i].slice(equals+1);
  }
  if(owner.SCHEMA!==FOLLOW_OWNER_SCHEMA||owner.ROOT!==followPathKey(target)||
    owner.SCRIPT!==followPathKey(target+"\\tools\\native_runner.js")||
    !/^[1-9]\d*$/.test(owner.PID||"")||Number(owner.PID)>4294967295||
    !followValidCreation(owner.CREATED||"")||!/^[A-Za-z0-9_-]{7,128}$/.test(owner.TOKEN||"")||
    !/^\d{8}T\d{6}Z-\d{1,9}$/.test(owner.RUN_TAG||"")||text!==followOwnerText(owner))
    followError("Owner metadata does not identify this target directory exactly.");
  var created=new Date(folder.DateCreated).getTime();
  if(!isFinite(created))followError("Lock-directory creation identity is unreadable.");
  return {owner:owner,text:text,created:created};
  }catch(snapshotError){
    /* Normal owner cleanup may remove the directory between these reads. */
    if(!followFSO.FolderExists(lock)&&!followFSO.FileExists(lock))return null;
    throw snapshotError;
  }
}
function followSameOwner(a,b) { return !!a&&!!b&&a.text===b.text&&a.created===b.created; }
function followProcessState(owner) {
  var service=GetObject("winmgmts:{impersonationLevel=impersonate}!\\\\.\\root\\cimv2");
  var rows=service.ExecQuery("SELECT ProcessId, CreationDate, Name, CommandLine FROM Win32_Process WHERE ProcessId="+owner.PID,"WQL",48);
  var en=new Enumerator(rows),found=[];
  for(;!en.atEnd();en.moveNext())found.push(en.item());
  if(!found.length)return "OWNER_EXITED";
  if(found.length!==1||String(Number(found[0].ProcessId))!==owner.PID)followError("Process inventory is inconsistent.");
  var process=found[0],created=followString(process.CreationDate);
  if(!followValidCreation(created))followError("The recorded PID has no readable creation identity.");
  if(created!==owner.CREATED)return "OWNER_PID_REUSED";
  var name=followString(process.Name).toLowerCase(),command=followString(process.CommandLine);
  if((name!=="cscript.exe"&&name!=="wscript.exe")||!command||
    !followArgument(command,owner.SCRIPT)||!followArgument(command,"--runner-token="+owner.TOKEN))
    followError("The live process command does not match the recorded script and token.");
  return "OWNER_ALIVE";
}
function followLogSample(path) {
  /* The compiler runner rewrites this UTF-8 file on each append. Sharing or
     truncation during one sample is transient; the next poll retries it. */
  try{return followFSO.FileExists(path)?followRead(path):null;}catch(transientRead){return null;}
}
function followCompleteText(text) {
  var end=text.lastIndexOf("\n");return end<0?"":text.slice(0,end+1);
}
function followEmitLines(text,prefix,tailLimit) {
  var lines=text.split("\n");
  if(lines.length&&lines[lines.length-1]==="")lines.pop();
  var start=tailLimit?Math.max(0,lines.length-tailLimit):0;
  for(var i=start;i<lines.length;i++)WScript.Echo(prefix+lines[i].replace(/\r$/, ""));
}
function followAdvanceLog(state,sample,owner) {
  if(sample===null)return;
  var complete=followCompleteText(sample);
  if(!state.initialized){
    /* This is only an observation filter. A PID-only header is not a receipt
       binding this log to the complete owner identity. */
    var header="RUNNER_LOCK=OWNED_PID_"+owner.PID;
    var lines=complete.split(/\r?\n/),matching=false;
    for(var i=0;i<lines.length;i++)if(lines[i]===header){matching=true;break;}
    if(!matching)return;
    followEmitLines(complete,"[FOLLOW_LOG_SNAPSHOT] ",25);
    state.prefix=complete;state.initialized=true;return;
  }
  if(complete.length<state.prefix.length||complete.slice(0,state.prefix.length)!==state.prefix)return;
  var added=complete.slice(state.prefix.length);
  if(added)followEmitLines(added,"[FOLLOW_LOG_NEW] ",0);
  state.prefix=complete;
}
function followGuardedLog(target,captured) {
  var before=followSnapshot(target);
  if(before&&!followSameOwner(captured,before))return {changed:true,sample:null};
  var sample=followLogSample(target+"\\run-build.log"),after=followSnapshot(target);
  if(after&&!followSameOwner(captured,after))return {changed:true,sample:null};
  return {changed:false,sample:sample};
}
function followExistingLog(target,captured) {
  var result=followGuardedLog(target,captured);
  if(!result.changed&&result.sample!==null)
    followEmitLines(followCompleteText(result.sample),"[EXISTING_LOG_UNBOUND] ",25);
  return !result.changed;
}
function followFinished(status,target,captured,state) {
  if(captured&&state&&(status==="OWNER_EXITED"||status==="OWNER_PID_REUSED"||status==="OWNER_LOCK_REMOVED")){
    try{
      var last=followGuardedLog(target,captured);
      if(last.changed)status="OWNER_CHANGED";
      else if(state.initialized)followAdvanceLog(state,last.sample,captured.owner);
      else if(last.sample!==null)followEmitLines(followCompleteText(last.sample),"[EXISTING_LOG_UNBOUND] ",25);
    }catch(finalReadError){WScript.Echo("FOLLOW_LOG_STATUS=FINAL_SAMPLE_UNAVAILABLE");}
  }
  WScript.Echo("FOLLOW_STATUS="+status);
  WScript.Echo("FOLLOW_BUILD_RESULT=NOT_CERTIFIED");
  if(status==="OWNER_EXITED"||status==="OWNER_PID_REUSED"||status==="OWNER_LOCK_REMOVED")
    WScript.Echo("FOLLOW_NOTE=Owner exit or lock removal does not confirm that child work completed.");
  WScript.Echo("FOLLOW_LOG_PATH="+target+"\\run-build.log");
  WScript.Echo("FOLLOW_NEXT_ACTION=Review the existing log. Run "+target+"\\run.cmd only if you want another compilation; this observer will not start it.");
  return 0;
}
function followChangedOrRemoved(target,captured,current,state) {
  if(current)return followFinished("OWNER_CHANGED",target);
  var status=followProcessState(captured.owner);
  return followFinished(status==="OWNER_ALIVE"?"OWNER_LOCK_REMOVED":status,target,captured,state);
}
function followMain() {
  WScript.Echo("FOLLOW_BUILD_RESULT=NOT_CERTIFIED");
  var args=WScript.Arguments;
  if(args.length!==1||!/^(?:[A-Za-z]:[\\/]|\\\\[^\\/]+[\\/][^\\/]+)/.test(String(args.Item(0)))){
    WScript.Echo("FOLLOW_STATUS=INVALID_ARGUMENTS");
    WScript.Echo("FOLLOW_USAGE=follow_active.js ABSOLUTE_TARGET_ROOT");return 2;
  }
  var target=followPath(String(args.Item(0)));
  WScript.Echo("FOLLOW_TARGET_ROOT="+target);
  if(!followFSO.FolderExists(target)){WScript.Echo("FOLLOW_STATUS=TARGET_NOT_FOUND");return 2;}
  var captured=followSnapshot(target);
  if(!captured)return followFinished(followExistingLog(target,null)?"NO_ACTIVE_OWNER":"OWNER_CHANGED",target);
  var firstState=followProcessState(captured.owner);
  if(firstState!=="OWNER_ALIVE")return followFinished(followExistingLog(target,captured)?firstState:"OWNER_CHANGED",target);
  WScript.Echo("FOLLOW_STATUS=ATTACHED");WScript.Echo("FOLLOW_OWNER_PID="+captured.owner.PID);
  WScript.Echo("FOLLOW_OWNER_CREATED="+captured.owner.CREATED);WScript.Echo("FOLLOW_RUN_TAG="+captured.owner.RUN_TAG);
  WScript.Echo("FOLLOW_LOG_SCOPE=Observed text only; no build verdict is inferred from log lines.");
  var state={initialized:false,prefix:""},polls=0,logPath=target+"\\run-build.log";
  while(true){
    var before=followSnapshot(target);
    if(!followSameOwner(captured,before))return followChangedOrRemoved(target,captured,before,state);
    var processState=followProcessState(captured.owner);
    if(processState!=="OWNER_ALIVE")return followFinished(processState,target,captured,state);
    var sample=followLogSample(logPath),after=followSnapshot(target);
    if(!followSameOwner(captured,after))return followChangedOrRemoved(target,captured,after,state);
    followAdvanceLog(state,sample,captured.owner);
    if(polls>0&&polls%10===0)WScript.Echo("FOLLOW_HEARTBEAT=OWNER_ALIVE PID="+captured.owner.PID+" POLL="+polls);
    WScript.Sleep(1000);polls++;
  }
}

// FOLLOW_MAIN_ENTRY
var followExit=2;
try{followExit=followMain();}
catch(followFailure){WScript.Echo("FOLLOW_STATUS=UNCERTAIN");WScript.Echo("FOLLOW_REASON="+followFailure.message);WScript.Echo("FOLLOW_BUILD_RESULT=NOT_CERTIFIED");}
WScript.Quit(followExit);
