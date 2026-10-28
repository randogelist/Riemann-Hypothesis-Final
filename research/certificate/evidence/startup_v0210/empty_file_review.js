'use strict';
// Node VM, in-memory Windows filesystem, and synthetic native responses only.
const fs=require('fs'),path=require('path'),assert=require('assert');
const {MemoryWindowsFS,createHost,populateFixture,sha256}=require('./mock_host');
const {instrument}=require('./runtime_host');
const {installBinaryHost}=require('./binary_host_adapter');
const candidate=path.resolve(process.argv[2]||path.join(__dirname,'../native_runner.js'));
const baseline=path.resolve(process.argv[3]||path.join(__dirname,'fixtures/baseline_native_runner.js.txt'));
const reportPath=path.resolve(process.argv[4]||path.join(__dirname,'empty_file_results.json'));
const root='E:\\RH-FAST\\workspaces\\RH_HILBERT_EMPTY_REVIEW';
const helper=fs.readFileSync(path.join(__dirname,'fixtures/NativeSha256.cs.txt'));
const emptySHA=sha256(Buffer.alloc(0));
const fixture=root+'\\empty.log';
const diag='CertUtil: -hashfile command FAILED: 0x800703ee (WIN32: 1006 ERROR_FILE_INVALID)\r\n';
const tests=[];
function test(name,fn){try{const details=fn();tests.push({name,status:'PASS',details:details||null});process.stdout.write('PASS '+name+'\n');}
  catch(e){tests.push({name,status:'FAIL',error:e.message,stack:e.stack});process.stdout.write('FAIL '+name+': '+e.message+'\n');}}
function setup(options={}){
  const memory=options.memory||new MemoryWindowsFS(root);for(const drive of ['C:\\','E:\\'])memory.mkdir(drive);
  const h=instrument(createHost(options.runner||candidate,{memory,env:{RH_HASH_MODE:'AUTO',LEAN_JOBS:'7'}}),{});
  if(!options.memory)populateFixture(h);
  memory.put(root+'\\tools\\native_runner.js',h.fullSource);memory.put(root+'\\tools\\NativeSha256.cs',helper);
  const c=h.context;c.configurePersistentProfile();c.mkdir(c.helpers);c.write(c.logPath,'');c.write(c.auditLogPath,'');
  c.selectCompiler();c.loadMathlibRequirements();c.selectCache();installBinaryHost(h);
  if(options.csc){
    for(const leaf of ['csc.exe','mscorlib.dll','System.dll','System.Core.dll','clr.dll'])
      memory.put(path.win32.dirname(h.csc)+'\\'+leaf,'SYNTHETIC FRAMEWORK '+leaf);
    const oldRun=c.runToFile;
    c.runToFile=function(exe,args,output){const rc=oldRun(exe,args,output);if(exe===h.csc)memory.put(output,options.compileLog===undefined?Buffer.alloc(0):options.compileLog);return rc;};
  }
  return h;
}
function failCertutil(h,predicate=()=>true,code=1006,output=diag){
  const old=h.context.shell.Exec;
  h.context.shell.Exec=function(command){
    const match=/^"[^"]+certutil\.exe"\s+-hashfile\s+"([^"]+)"\s+SHA256$/i.exec(command);
    if(match&&predicate(match[1])){h.hashes.push(match[1]);return {Status:1,ExitCode:code,StdOut:{ReadAll(){return output;}},StdErr:{ReadAll(){return '';}}};}
    return old(command);
  };
}
function fatal(fn,pattern){let thrown;try{fn();}catch(e){thrown=e;}assert(thrown,'Expected failure');assert.strictEqual(thrown.rhFatalHash,true,'Expected fatal hash marker');if(pattern)assert.match(thrown.message,pattern);return thrown.message;}
function receiptPaths(h){return [...h.memory.entries.values()].filter(e=>!e.directory&&/\\receipt\.txt$/.test(e.path)&&/HELPER/.test(h.memory.text(e.path))).map(e=>e.path);}

test('recognition_requires_nonzero_finite_numeric_code_or_exact_certutil_diagnostic',()=>{
  const c=setup().context;
  for(const code of [1006,0x800703ee,0x800703ee-0x100000000])assert.strictEqual(c.isCertutilInvalidFileError('',code),true,String(code));
  for(const code of [1,2,0x80070005])assert.strictEqual(c.isCertutilInvalidFileError(diag,code),true,String(code));
  assert.strictEqual(c.isCertutilInvalidFileError('CertUtil: localisée 0x800703ee ( WIN32:1006 ERROR_FILE_INVALID )',7),true);
  for(const code of [0,'1006',NaN,Infinity,-Infinity,null,undefined])assert.strictEqual(c.isCertutilInvalidFileError(diag,code),false,String(code));
  for(const output of ['filename C:\\1006.log', 'ERROR_FILE_INVALID 1006', '0x800703ee',
    'CertUtil: 0x800703ee (WIN32: 1006)', 'Other: 0x800703ee (WIN32: 1006 ERROR_FILE_INVALID)',
    'filenameCertUtil: 0x800703ee (WIN32: 1006 ERROR_FILE_INVALID)', 'CertUtil: 0x800703ef (WIN32: 1006 ERROR_FILE_INVALID)'])
    assert.strictEqual(c.isCertutilInvalidFileError(output,1),false,output);
  return {accepted_numeric_forms:3,diagnostic_label_and_tokens_required_for_other_nonzero_codes:true};
});
test('fileHash_recovers_only_after_binary_empty_read_and_pre_post_size_checks',()=>{
  for(const code of [1006,0x800703ee,0x800703ee-0x100000000]){
    const h=setup();h.memory.put(fixture,Buffer.alloc(0));failCertutil(h,()=>true,code,'injected native invalid-file result');
    assert.strictEqual(h.context.fileHash(fixture),emptySHA);
    assert.deepStrictEqual(h.binary.binaryLoads,[fixture]);assert.strictEqual(h.binary.fileSizeReads.length,2);
    assert.strictEqual(h.binary.binaryCloses.length,1);assert.strictEqual(h.binary.binaryEOS.length,1);
    assert(h.messages.some(x=>x.includes('SHA256_EMPTY_FILE_VERIFIED=')&&x.includes('|BYTES=0|BACKEND=ADODB_BINARY')));
  }return {numeric_exit_forms:3,expected_sha256:emptySHA};
});
test('certutilHashSet_mixed_empty_and_nonempty_results_complete_exactly',()=>{
  const h=setup(),c=h.context,files=[fixture,root+'\\normal.bin',root+'\\other-empty.log'];
  h.memory.put(files[0],Buffer.alloc(0));h.memory.put(files[1],Buffer.from([0,1,2,255]));h.memory.put(files[2],Buffer.alloc(0));
  failCertutil(h,p=>p!==files[1]);const requested={};for(const p of files)requested[c.keyPath(p)]=p;
  const result=c.certutilHashSet(Object.keys(requested).sort(),requested,'REVIEW');
  assert.strictEqual(Object.keys(result).length,3);
  for(const p of files)assert.strictEqual(result[c.keyPath(p)],sha256(h.memory.read(p)));
  assert.strictEqual(h.binary.binaryLoads.length,2);return {files:3,independently_verified_empty_files:2};
});
test('BOM_only_whitespace_and_nonempty_files_never_recover',()=>{
  const inputs=[Buffer.from([0xef,0xbb,0xbf]),Buffer.from([0xff,0xfe]),Buffer.from(' \r\n\t'),Buffer.from('x'),Buffer.from([0])];
  for(const data of inputs){const h=setup();h.memory.put(fixture,data);failCertutil(h);fatal(()=>h.context.fileHash(fixture),/SHA256 command failed/);assert.strictEqual(h.binary.binaryLoads.length,0);}
  return {rejected_nonempty_byte_patterns:inputs.length};
});
test('false_zero_metadata_cannot_hide_nonempty_binary_bytes',()=>{
  const h=setup();h.memory.put(fixture,'REAL BYTES');failCertutil(h);h.binary.afterGetFile=(p,n,f)=>{f.Size=0;};
  fatal(()=>h.context.fileHash(fixture),/SHA256 command failed/);assert.strictEqual(h.binary.binaryLoads.length,1);assert.strictEqual(h.binary.binaryCloses.length,1);
  return {metadata_was_zero:true,actual_binary_nonempty_rejected:true};
});
test('unreadable_binary_stream_fails_and_closes',()=>{
  const h=setup();h.memory.put(fixture,'');failCertutil(h);h.binary.beforeBinaryLoad=()=>{throw new Error('SYNTHETIC_BINARY_ACCESS_DENIED');};
  fatal(()=>h.context.fileHash(fixture),/SYNTHETIC_BINARY_ACCESS_DENIED/);assert.strictEqual(h.binary.binaryCloses.length,1);return {close_after_load_failure:true};
});
test('growth_after_binary_snapshot_is_rejected_by_second_metadata_read',()=>{
  const h=setup();h.memory.put(fixture,'');failCertutil(h);h.binary.afterBinaryLoad=p=>h.memory.put(p,'CHANGED AFTER SNAPSHOT');
  fatal(()=>h.context.fileHash(fixture),/File changed while verifying an empty/);assert.strictEqual(h.binary.fileSizeReads.length,2);assert.strictEqual(h.binary.binaryCloses.length,1);
  return {post_read_growth_rejected:true};
});
test('nonzero_or_invalid_binary_Size_Position_or_EOS_rejected',()=>{
  const cases=[['binarySizeOverride',1],['binarySizeOverride',0x100000000],['binarySizeOverride',NaN],
    ['binaryPositionOverride',1],['binaryPositionOverride',NaN],['binaryEOSOverride',false],['binaryEOSOverride',1]];
  for(const [field,value] of cases){const h=setup();h.memory.put(fixture,'');failCertutil(h);h.binary[field]=value;
    fatal(()=>h.context.fileHash(fixture),/SHA256 command failed/);assert.strictEqual(h.binary.binaryCloses.length,1);}
  return {rejected_stream_states:cases.length};
});
test('unrecognized_errors_and_malformed_success_never_probe_empty_file',()=>{
  const cases=[{code:5,text:'access denied'},{code:1,text:'file C:\\1006.log'},
    {code:0,text:diag},{code:0,text:'no digest'},{code:0,text:emptySHA+'\n'+emptySHA}];
  for(const item of cases){const h=setup();h.memory.put(fixture,'');failCertutil(h,()=>true,item.code,item.text);fatal(()=>h.context.fileHash(fixture));assert.strictEqual(h.binary.binaryLoads.length,0);}
  return {rejected_error_or_output_forms:cases.length};
});
test('missing_file_and_metadata_access_failure_are_fatal',()=>{
  const h=setup();failCertutil(h);assert.throws(()=>h.context.fileHash(fixture),/missing file/);
  h.memory.put(fixture,'');h.binary.beforeGetFile=()=>{throw new Error('SYNTHETIC_METADATA_ACCESS_DENIED');};
  fatal(()=>h.context.fileHash(fixture),/SYNTHETIC_METADATA_ACCESS_DENIED/);assert.strictEqual(h.binary.binaryLoads.length,0);return {missing_and_inaccessible_rejected:true};
});
test('fresh_calls_never_reuse_an_old_empty_digest',()=>{
  const h=setup();h.memory.put(fixture,'');failCertutil(h);assert.strictEqual(h.context.fileHash(fixture),emptySHA);
  h.memory.put(fixture,'changed');fatal(()=>h.context.fileHash(fixture),/SHA256 command failed/);
  h.memory.put(fixture,'');assert.strictEqual(h.context.fileHash(fixture),emptySHA);assert.strictEqual(h.binary.binaryLoads.length,2);
  return {three_calls:true,new_binary_stream_for_each_empty_recovery:true};
});
test('certutil_hash_set_failure_does_not_commit_partial_global_hashes',()=>{
  const h=setup(),c=h.context,p2=root+'\\second.log';h.memory.put(fixture,'');h.memory.put(p2,'not empty');
  c.hashFiles={};c.requestHash(fixture);c.requestHash(p2);c.fileHashes={sentinel:'unchanged'};failCertutil(h);
  fatal(()=>c.certutilHashes(Object.keys(c.hashFiles).sort()));assert.deepStrictEqual(JSON.parse(JSON.stringify(c.fileHashes)),{sentinel:'unchanged'});
  return {no_partial_commit:true};
});
test('actual_prepareBatchHasher_empty_build_log_saves_and_warm_reuses',()=>{
  const first=setup({csc:true});failCertutil(first,p=>/\\build\.log$/.test(p));
  const built=first.context.prepareBatchHasher(false);assert(built);assert.strictEqual(first.context.helperCacheState,'BUILT_AND_SAVED');assert.strictEqual(first.io.cscCalls,1);
  const receipt=receiptPaths(first);assert.strictEqual(receipt.length,1);assert.match(first.memory.text(receipt[0]),new RegExp('BUILD_LOG_SHA256='+emptySHA));
  const second=setup({memory:first.memory,csc:true});failCertutil(second,p=>/\\build\.log$/.test(p));
  const reused=second.context.prepareBatchHasher(false);assert(reused);assert.strictEqual(second.context.helperCacheState,'HIT');assert.strictEqual(second.io.cscCalls,0);
  assert.strictEqual(reused.exe,built.exe);assert.strictEqual(reused.exeSHA,built.exeSHA);
  assert(first.binary.binaryLoads.some(p=>/\.pending\\build\.log$/.test(p)));assert(second.binary.binaryLoads.some(p=>/\\build\.log$/.test(p)));
  return {cold_synthetic_csc_calls:1,warm_synthetic_csc_calls:0,cold_state:'BUILT_AND_SAVED',warm_state:'HIT',empty_log_receipt_sha256:emptySHA};
});
test('baseline_reproduces_empty_build_log_failure_at_receipt_hash',()=>{
  const h=setup({runner:baseline,csc:true});failCertutil(h,p=>/\\build\.log$/.test(p));
  fatal(()=>h.context.prepareBatchHasher(false),/SHA256 command failed/);assert.strictEqual(h.io.cscCalls,1);assert.strictEqual(receiptPaths(h).length,0);
  return {baseline_failed_after_synthetic_helper_build:true,committed_receipts:0};
});
test('helper_build_nonempty_log_invalid_file_error_fails_without_receipt',()=>{
  const h=setup({csc:true,compileLog:'compiler output exists'});failCertutil(h,p=>/\\build\.log$/.test(p));
  fatal(()=>h.context.prepareBatchHasher(false),/SHA256 command failed/);assert.strictEqual(receiptPaths(h).length,0);
  assert.strictEqual(h.binary.binaryLoads.length,0);return {no_false_empty_receipt:true};
});
test('warm_helper_cache_nonempty_tampering_stays_fatal',()=>{
  const h=setup({csc:true});failCertutil(h,p=>/\\build\.log$/.test(p));const built=h.context.prepareBatchHasher(false);assert(built);
  const log=path.win32.dirname(built.exe)+'\\build.log';h.memory.put(log,'tampered');
  const warm=setup({memory:h.memory,csc:true});failCertutil(warm,p=>/\\build\.log$/.test(p));
  fatal(()=>warm.context.prepareBatchHasher(false),/SHA256 command failed/);assert.strictEqual(warm.io.cscCalls,0);
  assert.strictEqual(warm.binary.binaryLoads.length,0);return {tampered_nonempty_log_rejected_before_rebuild:true};
});
const report={schema:'RH_EMPTY_FILE_HASH_NODE_REVIEW_V1',scope:'Node VM and in-memory Windows host only; all certutil, csc and helper responses simulated',
  runner_sha256:sha256(fs.readFileSync(candidate)),baseline_sha256:sha256(fs.readFileSync(baseline)),
  passed:tests.filter(x=>x.status==='PASS').length,failed:tests.filter(x=>x.status==='FAIL').length,tests};
fs.writeFileSync(reportPath,JSON.stringify(report,null,2)+'\n');process.exitCode=report.failed?1:0;
