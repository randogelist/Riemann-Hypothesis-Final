'use strict';

// Narrow Node VM baseline observation. No native process is ever executed.
const fs=require('fs'),path=require('path'),assert=require('assert');
const {makeHost,sha256}=require('./baseline_host/runtime_host');
const args={};
for(let i=2;i<process.argv.length;i+=2){assert(['--package-root','--report'].includes(process.argv[i])&&process.argv[i+1]);args[process.argv[i].slice(2)]=process.argv[i+1];}
assert(args['package-root']&&args.report,'Use --package-root BASELINE --report FILE');
const runner=path.join(path.resolve(args['package-root']),'tools','native_runner.js');
const bytes=fs.readFileSync(runner);
assert.strictEqual(sha256(bytes),'d5eb2c1f33b4fafcd0b1d366850cc860c7e73552dd739ee9cdd238559e679c86');
const results=[];
function observe(name,action) {
 try {results.push({name,status:'PASS_EXPECTED_BASELINE_BEHAVIOR',evidence:action()});}
 catch(e){results.push({name,status:'FAIL',error:e.message,stack:e.stack});}
}
function setup() {
 const h=makeHost({runner}).installFixture({'Review.Single':[]}).startup(),c=h.context;
 h.extraInventory=[{ProcessId:34008,ParentProcessId:55,CreationDate:'20261027095000.001234+000',Name:'cscript.exe',
  CommandLine:'"C:\\Windows\\System32\\cscript.exe" //nologo tools\\native_runner.js'}];
 c.acquireRunnerLock();
 assert.strictEqual(c.lockAdmittedRelativeHosts.length,1);
 return h;
}
function unknown(pid,attempt) {
 return {ProcessId:pid,ParentProcessId:34008,CreationDate:'2026102710000'+attempt+'.123456+000',Name:'certutil.exe',CommandLine:''};
}
observe('six_unreadable_rows_from_same_admitted_parent_need_no_self_hash_launch',()=>{
 const h=setup(),c=h.context;
 let sequence=1;h.extraInventory.push(unknown(8001,sequence));
 h.onSleep=()=>{sequence++;h.extraInventory[1]=unknown(8000+sequence,sequence);};
 const before={hashes:h.hashes.length,certutil:c.directLaunchCounts.certutil,total:c.directLaunchCounts.total,clock:h.clock,inventory:h.inventoryQueries};
 const owner=h.memory.text(c.lockPath+'\\owner.txt');
 assert.strictEqual(h.shutdownAndConditionalRelease(),false);
 assert.strictEqual(h.inventoryQueries-before.inventory,6);
 assert.strictEqual(h.clock-before.clock,1000);
 assert.strictEqual(h.hashes.length,before.hashes);
 assert.strictEqual(c.directLaunchCounts.certutil,before.certutil);
 assert.strictEqual(c.directLaunchCounts.total,before.total);
 assert(c.lockHeld);assert.strictEqual(h.memory.text(c.lockPath+'\\owner.txt'),owner);
 return {fresh_inventories:6,different_unreadable_rows:sequence,common_parent_pid:34008,
  fake_scheduled_wait_ms:1000,certutil_launched_during_shutdown:0,total_tools_launched_during_shutdown:0,
  lock_retained:true,exemption_did_not_extend_from_parent_to_child:true};
});
observe('diagnostic_logging_and_owner_snapshot_do_not_launch_hash_processes',()=>{
 const h=setup(),c=h.context;
 const before={hashes:h.hashes.length,certutil:c.directLaunchCounts.certutil,total:c.directLaunchCounts.total};
 c.diagnosticLog('SIMULATED_LOG_OBSERVATION');
 const snapshot=c.lockSnapshot();
 assert(snapshot && snapshot.text===c.lockOwnerText);
 assert.strictEqual(h.hashes.length,before.hashes);
 assert.strictEqual(c.directLaunchCounts.certutil,before.certutil);
 assert.strictEqual(c.directLaunchCounts.total,before.total);
 return {diagnostic_logged:true,owner_snapshot_read:true,added_hashes:0,added_native_launches:0};
});
assert.strictEqual(sha256(fs.readFileSync(runner)),sha256(bytes));
const report={schema:'RH_V0217_BASELINE_SHUTDOWN_OBSERVATION_V1',runner_sha256:sha256(bytes),scope:'NODE_VM_SYNTHETIC_HOST_ONLY',
 status:results.every(x=>x.status==='PASS_EXPECTED_BASELINE_BEHAVIOR')?'PASS_EXPECTED_BASELINE_BEHAVIOR':'FAIL',cases:results,
 limitations:['These are baseline behavior checks, not candidate-fix tests.','No Windows, WSH/COM, WMI, Lean/Lake, C# or CI execution occurred.',
 'All process rows, parent identities, hashes, receipts, files and time are simulated in memory.',
 'Synthetic parent34008 and rotating children reproduce the structural reported pattern only, not exact native process identities.',
 'The observation rules out certutil launches in this simulated shutdown call path; it does not determine the actual native unreadable workers\' commands or workspace.']};
const out=path.resolve(args.report);
fs.mkdirSync(path.dirname(out),{recursive:true});
fs.writeFileSync(out,JSON.stringify(report,null,2)+'\n');
console.log(JSON.stringify({status:report.status,case_count:results.length,report:out,report_sha256:sha256(fs.readFileSync(out)),failures:results.filter(x=>x.status==='FAIL')},null,2));
process.exitCode=report.status==='FAIL'?1:0;
