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
