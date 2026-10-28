'use strict';

// Focused Node VM review. Actual runner functions run with simulated host
// boundaries; no native processes or whole WSH entry point are executed.
const fs=require('fs'),path=require('path'),assert=require('assert');
const {makeHost,sha256}=require('./runtime_host');
const args={};
for(let i=2;i<process.argv.length;i+=2){
 assert(['--package-root','--report','--expected-runner-sha256'].includes(process.argv[i]),'unknown argument');
 assert(process.argv[i+1],'missing argument');args[process.argv[i].slice(2)]=process.argv[i+1];
}
assert(args['package-root']&&args.report&&/^[a-f0-9]{64}$/.test(args['expected-runner-sha256']||''),'missing arguments');
const runner=path.join(path.resolve(args['package-root']),'tools','native_runner.js'),bytes=fs.readFileSync(runner),runnerSHA=sha256(bytes);
assert.strictEqual(runnerSHA,args['expected-runner-sha256'],'unexpected candidate bytes');
const setterCount=[...bytes.toString('utf8').matchAll(/env\("([A-Z_]+)"\)\s*=(?!=)/g)].length;
assert.strictEqual(setterCount,7,'COM setter adaptation count changed');
const results=[];
function test(name,action){try{results.push({name,outcome:'PASS',evidence:action()||{}});}catch(e){results.push({name,outcome:'FAIL',error:e.message,stack:e.stack});}}
const graph={'Review.Single':[]};
function relative(){return {ProcessId:34008,ParentProcessId:55,CreationDate:'20261027095000.001234+000',Name:'cscript.exe',CommandLine:'"C:\\Windows\\System32\\cscript.exe" //nologo tools\\native_runner.js'};}
function unknown(changes={}){return Object.assign({ProcessId:8001,ParentProcessId:34008,CreationDate:'20261027100000.123456+000',Name:'certutil.exe',CommandLine:''},changes);}
function fixture(options={},withRelative=false,sourceGraph=graph){
 const h=makeHost({runner},options).installFixture(sourceGraph);
 if(withRelative)h.extraInventory=[relative()];
 h.context.acquireRunnerLock();h.startup();
 assert.strictEqual(h.context.runToFile,h.actualRunToFile,'actual runToFile must not be overridden');
 return h;
}
function owner(h){return h.memory.text(h.context.lockPath+'\\owner.txt');}
function shutdown(h){return h.shutdownAndConditionalRelease();}
function oneInitial(h,row){h.extraInventory.push(row);}
function targeted(h,callback){h.inventoryProvider=event=>event.pid===8001?callback(event):event.rows;}
function noNewLaunches(h,action){const c=h.context,before={certutil:c.directLaunchCounts.certutil,total:c.directLaunchCounts.total,records:c.ownedNativeLaunches.length};const value=action();assert.strictEqual(c.directLaunchCounts.certutil,before.certutil);assert.strictEqual(c.directLaunchCounts.total,before.total);assert.strictEqual(c.ownedNativeLaunches.length,before.records);return value;}

test('expired_initial_row_does_not_chase_new_unreadable_children',()=>{
 const h=fixture({},true),c=h.context;oneInitial(h,unknown());
 targeted(h,()=>{h.extraInventory=[relative(),unknown({ProcessId:8002,CreationDate:'20261027100001.654321+000'})];return [];});
 const before={clock:h.clock,full:h.fullInventoryQueries};
 assert.strictEqual(noNewLaunches(h,()=>shutdown(h)),true);
 assert.strictEqual(h.fullInventoryQueries-before.full,1);
 assert.strictEqual(c.parallelRuntime.shutdownFullInventoryQueries,1);
 assert.strictEqual(c.parallelRuntime.shutdownTargetedWorkerQueries,1);
 assert.strictEqual(c.parallelRuntime.shutdownExpiredRows,1);
 assert(!h.targetInventoryQueries.includes(8002));assert.strictEqual(h.clock-before.clock,0);
 assert.strictEqual(c.lockHeld,false);assert.strictEqual(c.nativeLaunchesSealed,true);
 return {full_inventories:1,exact_initial_worker_queries:1,new_worker_pid_chased:false,expired_rows:1,added_native_launches:0,fake_wait_ms:0};
});

test('absence_resolution_does_not_require_an_admitted_parent',()=>{
 const h=fixture(),c=h.context;oneInitial(h,unknown({ParentProcessId:7777}));targeted(h,()=>[]);
 assert.strictEqual(shutdown(h),true);assert.strictEqual(c.lockAdmittedRelativeHosts.length,0);
 assert.strictEqual(c.parallelRuntime.shutdownExpiredRows,1);
 return {unrelated_parent_not_used_as_evidence:true,absence_from_successful_exact_query_required:true};
});

test('matching_readable_row_reenters_original_guard',()=>{
 const outcomes=[];
 for(const binding of ['current_root','outside_root']){
  const h=fixture({},true),c=h.context,p=unknown();oneInitial(h,p);
  const command='certutil.exe -hashfile "'+(binding==='current_root'?c.root:'E:\\OTHER')+'\\input.bin" SHA256';
  targeted(h,()=>[Object.assign({},p,{CommandLine:command})]);
  const clean=shutdown(h);assert.strictEqual(clean,binding==='outside_root');
  assert.strictEqual(c.parallelRuntime.shutdownReadableRows,1);
  assert.strictEqual(c.lockHeld,binding==='current_root');
  assert.strictEqual(h.sleeps.length,0);
  outcomes.push({binding,clean,readable_rows:1});
 }
 return {outcomes};
});

test('persistent_unreadable_same_identity_retains_lock_with_finite_budget',()=>{
 const h=fixture({},true),c=h.context;oneInitial(h,unknown());
 const before={clock:h.clock,full:h.fullInventoryQueries},text=owner(h);
 assert.strictEqual(shutdown(h),false);
 assert.strictEqual(h.clock-before.clock,1000);assert.strictEqual(h.fullInventoryQueries-before.full,1);
 assert.strictEqual(c.parallelRuntime.shutdownInventoryAttempts,6);
 assert.strictEqual(c.parallelRuntime.shutdownTargetedWorkerQueries,6);
 assert.strictEqual(c.parallelRuntime.shutdownTargetedSelfQueries,12);
 assert.strictEqual(c.parallelRuntime.shutdownExpiredRows,0);
 assert(c.lockHeld);assert.strictEqual(owner(h),text);
 return {full_inventories:1,worker_queries:6,self_queries:12,fake_scheduled_sleep_ms:1000,parent_admission_exempted_child:false,lock_retained:true};
});

test('targeted_failure_malformed_rows_and_identity_reuse_never_mean_absent',()=>{
 const variants=[
  ['query_throws',()=>{throw new Error('SIMULATED WMI failure');}],
  ['duplicate_rows',()=>[unknown(),unknown()]],
  ['partial_enumeration_throws',()=>{const rows=[unknown(),unknown()];Object.defineProperty(rows,1,{get(){throw new Error('SIMULATED partial enumeration failure');}});return rows;}],
  ['wrong_pid',()=>[unknown({ProcessId:8002})]],
  ['new_creation_same_pid',()=>[unknown({CreationDate:'20261027100000.123457+000'})]],
  ['changed_name',()=>[unknown({Name:'lean.exe'})]],
  ['changed_parent',()=>[unknown({ParentProcessId:1234})]],
  ['missing_creation',()=>[unknown({CreationDate:''})]],
  ['invalid_parent',()=>[unknown({ParentProcessId:-1})]],
 ];
 for(const [name,reply] of variants){
  const h=fixture({},true),c=h.context;oneInitial(h,unknown());const text=owner(h);targeted(h,reply);
  assert.strictEqual(shutdown(h),false,name);assert(c.lockHeld,name);assert.strictEqual(owner(h),text,name);
  assert.strictEqual(c.parallelRuntime.shutdownExpiredRows,0,name);assert.strictEqual(h.sleeps.length,0,name);
 }
 return {retained_cases:variants.map(x=>x[0]),assumed_absences:0};
});

test('invalid_initial_identity_and_more_than_64_rows_fail_closed',()=>{
 const variants=[
  ['missing_creation',[unknown({CreationDate:''})]],
  ['invalid_parent',[unknown({ParentProcessId:-1})]],
  ['row_budget_65',Array.from({length:65},(_,i)=>unknown({ProcessId:8001+i}))],
 ];
 for(const [name,rows] of variants){
  const h=fixture(),c=h.context;h.extraInventory=rows;
  assert.strictEqual(shutdown(h),false,name);assert(c.lockHeld,name);
  assert.strictEqual(c.parallelRuntime.shutdownTargetedWorkerQueries,0,name);
  assert.strictEqual(h.sleeps.length,0,name);
 }
 return {retained_cases:variants.map(x=>x[0]),worker_queries_before_rejection:0};
});

test('64_persistent_rows_bound_exact_worker_queries_to_384',()=>{
 const h=fixture(),c=h.context;h.extraInventory=Array.from({length:64},(_,i)=>unknown({ProcessId:8001+i}));
 const before=h.clock;assert.strictEqual(shutdown(h),false);
 assert.strictEqual(c.parallelRuntime.shutdownFullInventoryQueries,1);
 assert.strictEqual(c.parallelRuntime.shutdownTargetedWorkerQueries,384);
 assert.strictEqual(c.parallelRuntime.shutdownTargetedSelfQueries,12);
 assert.strictEqual(h.clock-before,1000);assert(c.lockHeld);
 return {full_inventories:1,worker_queries:384,self_queries:12,fake_scheduled_sleep_ms:1000};
});

test('initial_full_inventory_failure_is_not_a_successful_empty_census',()=>{
 const h=fixture(),c=h.context;h.inventoryProvider=e=>{if(e.full)throw new Error('SIMULATED full query failure');return e.rows;};
 assert.strictEqual(shutdown(h),false);assert(c.lockHeld);assert.strictEqual(h.sleeps.length,0);
 assert.strictEqual(c.parallelRuntime.shutdownExpiredRows,0);
 return {full_inventory_failed:true,lock_retained:true};
});

test('lock_text_and_generation_changes_during_revalidation_are_preserved',()=>{
 const cases=[];
 for(const mode of ['owner_text','generation_same_text']){
  const h=fixture(),c=h.context;oneInitial(h,unknown());const old=owner(h);
  let changed=false;const priorFolder=c.fso.GetFolder;
  c.fso.GetFolder=p=>{const value=priorFolder(p);if(changed&&h.memory.key(p)===h.memory.key(c.lockPath))value.DateCreated=new Date(h.epoch+1);return value;};
  targeted(h,()=>{changed=true;if(mode==='owner_text')h.memory.put(c.lockPath+'\\owner.txt',old.replace('TOKEN=mock-owner-token-123456','TOKEN=mock-new-owner-654321'));return [];});
  assert.strictEqual(shutdown(h),false,mode);assert(c.lockHeld,mode);
  assert.strictEqual(owner(h),mode==='owner_text'?old.replace('TOKEN=mock-owner-token-123456','TOKEN=mock-new-owner-654321'):old);
  cases.push({mode,lock_retained:true});
 }
 return {cases};
});

test('self_target_query_requires_exact_identity_before_and_after_workers',()=>{
 const variants=[
  ['absent_initial',false,()=>[]],
  ['creation_changed_initial',false,rows=>rows.map(r=>Object.assign({},r,{CreationDate:'20261027095959.000001+000'}))],
  ['parent_changed_post',true,rows=>rows.map(r=>Object.assign({},r,{ParentProcessId:1234}))],
  ['command_unreadable_post',true,rows=>rows.map(r=>Object.assign({},r,{CommandLine:''}))],
 ];
 for(const [name,post,mutate] of variants){
  const h=fixture(),c=h.context;let workerResolved=false;oneInitial(h,unknown());
  h.inventoryProvider=e=>{if(e.pid===8001){workerResolved=true;return [];}if(e.pid===c.lockSelf.pid&&(!post||workerResolved))return mutate(e.rows);return e.rows;};
  assert.strictEqual(shutdown(h),false,name);assert(c.lockHeld,name);assert.strictEqual(h.sleeps.length,0,name);
 }
 const full=fixture(),fc=full.context;
 full.inventoryProvider=e=>e.full?e.rows.map(r=>r.ProcessId===fc.lockSelf.pid?Object.assign({},r,{CreationDate:'20261027095959.000001+000'}):r):e.rows;
 assert.strictEqual(shutdown(full),false);assert(fc.lockHeld);
 return {retained_identity_variants:variants.map(x=>x[0]).concat(['complete_inventory_changed_self'])};
});

test('new_owned_worker_during_exact_query_blocks_cleanup',()=>{
 const h=fixture(),c=h.context;oneInitial(h,unknown());
 targeted(h,()=>{c.parallelRuntime.active=[{name:'Review.Single',phase:'COMPILE',threads:16,proc:{ProcessID:9009,Status:0}}];return [];});
 assert.strictEqual(shutdown(h),false);assert(c.lockHeld);
 assert.strictEqual(h.sleeps.length,0);
 return {post_query_owned_worker_guard:true,lock_retained:true};
});

test('all_three_actual_launch_routes_register_before_call_and_obey_seal',()=>{
 const h=fixture(),c=h.context;
 const oldRun=c.shell.Run,oldExec=c.shell.Exec,seen=[];
 c.shell.Run=(...callArgs)=>{const r=c.ownedNativeLaunches[c.ownedNativeLaunches.length-1];assert.strictEqual(r.state,'LAUNCH_UNCERTAIN');assert.strictEqual(r.owner,c.lockOwnerText);seen.push('SYNC_RUN');return oldRun(...callArgs);};
 c.shell.Exec=command=>{const r=c.ownedNativeLaunches[c.ownedNativeLaunches.length-1];assert.strictEqual(r.state,'LAUNCH_UNCERTAIN');assert.strictEqual(r.owner,c.lockOwnerText);seen.push(r.kind);return {Status:1,ExitCode:0,ProcessID:9876,StdOut:{ReadAll:()=>''},StdErr:{ReadAll:()=>''}};};
 c.runToFile(c.compiler,['--version'],c.root+'\\test-version.log');
 c.launchCertutil(c.root+'\\compile-order.txt');
 c.startNativeAsync(c.compiler,['--version'],c.root+'\\test-async.log',1,'lean');
 assert.strictEqual(seen.length,3);assert.strictEqual(c.ownedNativeLaunchOutstanding().length,0);
 c.sealNativeLaunches();const count=c.ownedNativeLaunches.length,beforeCalls=seen.length;
 assert.throws(()=>c.runToFile(c.compiler,['--version'],c.root+'\\post-seal.log'),/NATIVE_LAUNCH_CLOSED/);
 assert.throws(()=>c.launchCertutil(c.root+'\\compile-order.txt'),/NATIVE_LAUNCH_CLOSED/);
 assert.throws(()=>c.startNativeAsync(c.compiler,['--version'],c.root+'\\post-seal-async.log',1,'lean'),/NATIVE_LAUNCH_CLOSED/);
 assert.strictEqual(seen.length,beforeCalls);assert.strictEqual(c.ownedNativeLaunches.length,count);
 return {actual_launch_routes_exercised:seen,registered_before_raw_call:true,post_seal_raw_calls:0};
});

test('throwing_or_invalid_launches_remain_in_owned_uncertainty_ledger',()=>{
 const variants=[
  ['run_throws','run',()=>{throw new Error('SIMULATED launch failure');}],
  ['run_invalid_code','run',()=>undefined],
  ['exec_throws','exec',()=>{throw new Error('SIMULATED launch failure');}],
  ['exec_missing_handle','exec',()=>null],
 ];
 for(const [name,route,boundary] of variants){
  const h=fixture(),c=h.context;
  if(route==='run')c.shell.Run=boundary;else c.shell.Exec=boundary;
  assert.throws(()=>route==='run'?c.runToFile(c.compiler,['--version'],c.root+'\\fail.log'):c.launchCertutil(c.root+'\\compile-order.txt'));
  const record=c.ownedNativeLaunches[c.ownedNativeLaunches.length-1];assert.strictEqual(record.state,'LAUNCH_UNCERTAIN',name);
  assert(c.ownedNativeLaunchOutstanding().some(x=>x.includes('LAUNCH_UNCERTAIN')),name);
  const before=h.clock,queries=h.inventoryQueries;assert.strictEqual(shutdown(h),false,name);
  assert.strictEqual(h.clock-before,30000,name);assert.strictEqual(h.inventoryQueries,queries,name);assert(c.lockHeld,name);
 }
 return {uncertain_launch_cases:variants.map(x=>x[0]),fake_owned_drain_ms_per_case:30000,inventory_not_reached:true};
});

test('retained_handle_status_is_conservative_and_owner_bound',()=>{
 const variants=[['running',0],['invalid',2],['throwing','throws']];
 for(const [name,status] of variants){
  const h=fixture(),c=h.context,proc={ProcessID:9877};
  Object.defineProperty(proc,'Status',{get(){if(status==='throws')throw new Error('SIMULATED status unknown');return status;}});
  c.shell.Exec=()=>proc;c.launchCertutil(c.root+'\\compile-order.txt');
  assert(c.ownedNativeLaunchOutstanding().length>0,name);
  const before=h.clock;assert.strictEqual(shutdown(h),false,name);assert.strictEqual(h.clock-before,30000,name);assert(c.lockHeld,name);
 }
 const h=fixture(),c=h.context;assert.strictEqual(c.ownedNativeLaunchOutstanding().length,0);
 const record=c.ownedNativeLaunches[0];record.owner+='changed';
 assert(c.ownedNativeLaunchOutstanding().some(x=>x.includes('OWNER_UNKNOWN')));
 return {uncertain_status_cases:variants.map(x=>x[0]),only_numeric_status_1_finishes_async:true,changed_owner_record_blocked:true};
});

test('stale_and_legacy_lock_acquisition_do_not_use_targeted_shutdown_resolution',()=>{
 for(const schema of ['owned','legacy_empty']){
  const h=makeHost({runner}).installFixture(graph),c=h.context;
  const text=schema==='owned'?c.formatLockOwner({ROOT:c.keyPath(c.root),SCRIPT:c.keyPath(c.root+'\\tools\\native_runner.js'),PID:'4321',CREATED:'20261027090000.000000+000',TOKEN:'mock-stale-owner-12345',RUN_TAG:c.runTag}):'';
  if(schema==='owned')h.memory.put(c.lockPath+'\\owner.txt',text);else h.memory.mkdir(c.lockPath);
  h.extraInventory=[unknown()];h.inventoryProvider=e=>e.pid===8001?[]:e.rows;
  assert.throws(()=>c.acquireRunnerLock(),/unreadable command line/);
  assert.strictEqual(h.targetInventoryQueries.length,0);assert.strictEqual(c.lockRecovered,0);assert.strictEqual(c.lockHeld,false);
  assert(h.memory.directory(c.lockPath));if(schema==='owned')assert.strictEqual(owner(h),text);
 }
 return {stale_recovery_targeted_queries:0,old_locks_preserved:true};
});

test('mock_cached_pipeline_and_final_audit_reuse_complete_before_sealed_cleanup',()=>{
 const seed=fixture();seed.run();seed.context.finalAudit();assert.strictEqual(shutdown(seed),true);
 const h=makeHost({runner},{memory:seed.memory}).installFixture(graph),c=h.context;
 c.acquireRunnerLock();h.startup();h.run();
 const before=c.directLaunchCounts.lean;c.finalAudit();
 assert.strictEqual(c.compiled,0);assert.strictEqual(c.reused,2);assert.strictEqual(c.directLaunchCounts.lean,before);
 assert.strictEqual(c.ownedNativeLaunchOutstanding().length,0);
 assert.strictEqual(noNewLaunches(h,()=>shutdown(h)),true);
 assert.strictEqual(c.parallelRuntime.shutdownFullInventoryQueries,1);
 assert.strictEqual(c.parallelRuntime.shutdownTargetedWorkerQueries,0);assert.strictEqual(c.lockHeld,false);
 return {simulated_ordinary_plus_aggregate_reused:2,extra_final_compiler_calls:0,cleanup_extra_native_launches:0,all_launch_records_finished:true};
});

assert.strictEqual(sha256(fs.readFileSync(runner)),runnerSHA,'runner changed during testing');
const report={schema:'RH_V0217_FOCUSED_NODE_VM_REVIEW_V1',status:results.every(x=>x.outcome==='PASS')?'PASS':'FAIL',scope:'NODE_VM_SYNTHETIC_HOST_ONLY',runner_sha256:runnerSHA,
 passed:results.filter(x=>x.outcome==='PASS').length,failed:results.filter(x=>x.outcome==='FAIL').length,cases:results,
 host:{actual_runner_function_definitions:true,actual_runToFile_restored:true,raw_shell_Run_Exec_substituted:true,whole_wsh_entry_point_executed:false,COM_setter_adaptations:setterCount},
 limitations:['No native Windows, WSH/COM, WMI, Lean/Lake, C#, Wine or CI execution occurred.','All process identities, WMI responses, compiler/audit outcomes, files, receipts, hashes and time are simulated in memory.','Only rows from the initial complete census are revisited. These tests do not assert a global stop-the-world Windows process census or identify unreadable processes as foreign.','Six rounds/64 rows bound targeted worker queries and scheduled sleeps; no hard wall-clock bound is implied for WMI calls.','The current native user failure remains evidence; these mocked cases do not certify the new runner on Windows or promote the mathematical endpoint.']};
fs.mkdirSync(path.dirname(path.resolve(args.report)),{recursive:true});fs.writeFileSync(path.resolve(args.report),JSON.stringify(report,null,2)+'\n');
console.log(JSON.stringify({status:report.status,passed:report.passed,failed:report.failed,runner_sha256:runnerSHA,failures:results.filter(x=>x.outcome==='FAIL').map(x=>({name:x.name,error:x.error})),report:path.resolve(args.report)},null,2));
process.exitCode=report.failed?1:0;
