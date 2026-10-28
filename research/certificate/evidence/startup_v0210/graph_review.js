'use strict';
// Node-only review: every Windows operation and compiler response is simulated.
const fs = require('fs');
const path = require('path');
const assert = require('assert');
const {MemoryWindowsFS, createHost, populateFixture, buildAll, sha256} = require('./mock_host');
const candidate = path.resolve(process.argv[2] || path.join(__dirname, '../native_runner.js'));
const baseline = path.resolve(process.argv[3] || path.join(__dirname, 'fixtures/baseline_native_runner.js.txt'));
const project = process.argv[4] ? path.resolve(process.argv[4]) : null;
const reportPath = path.resolve(process.argv[5] || path.join(__dirname, 'graph_results.json'));
const root = 'E:\\RH-FAST\\workspaces\\RH_HILBERT_REVIEW';
const mathlib = 'C:\\cache\\.lake\\packages\\mathlib';
const art = mathlib + '\\.lake\\build\\lib\\lean';
const launcher = fs.readFileSync(path.join(__dirname, 'fixtures/baseline_run.cmd.txt'));
const results = [], measurements = {};
const plain = value => JSON.parse(JSON.stringify(value));
function test(name, fn) {
  try { const details=fn(); results.push({name,status:'PASS',details:details||null}); process.stdout.write('PASS '+name+'\n'); }
  catch(e) { results.push({name,status:'FAIL',error:e.message,stack:e.stack}); process.stdout.write('FAIL '+name+': '+e.message+'\n'); }
}
function host(file, memory) {
  memory = memory || new MemoryWindowsFS(root);
  for(const drive of ['C:\\','E:\\']) memory.mkdir(drive);
  const h=createHost(file,{memory,env:{RH_HASH_MODE:'CERTUTIL',LEAN_JOBS:'7'}});
  populateFixture(h);
  h.memory.put(root+'\\run.cmd',launcher);
  return h;
}
function ready(h) {
  const c=h.context;
  c.configurePersistentProfile(); c.mkdir(c.helpers); c.write(c.logPath,''); c.write(c.auditLogPath,'');
  c.selectCompiler(); c.loadMathlibRequirements(); c.selectCache(); return h;
}
function counts(h) {
  const c=h.context,out={GetAbsolutePathName:0,FileExists:0,FolderExists:0,GetFolder:0,GetFileName:0,GetBaseName:0,
    leanReads:0,leanReadChars:0,sourceCleanCalls:0,sourceCleanChars:0,requestHashCalls:0};
  for(const name of ['GetAbsolutePathName','FileExists','FolderExists','GetFolder','GetFileName','GetBaseName']) {
    const old=c.fso[name]; c.fso[name]=function(){out[name]++;return old.apply(c.fso,arguments);};
  }
  const read=c.read,clean=c.sourceClean,request=c.requestHash;
  c.read=function(p){const value=read(p);if(/\.lean$/i.test(p)){out.leanReads++;out.leanReadChars+=value.length;}return value;};
  c.sourceClean=function(s,strict){out.sourceCleanCalls++;out.sourceCleanChars+=s.length;return clean(s,strict);};
  c.requestHash=function(p){out.requestHashCalls++;return request(p);};
  return out;
}
function graph(h) {
  const c=h.context;
  return plain({ordered:c.ordered,packages:c.packages,modules:Object.keys(c.modules).sort().map(n=>[n,c.modules[n]]),
    targets:c.auditTargets,final:[c.finalAuditName,c.finalAuditSource,c.finalAuditRelative],
    required:c.requiredMathlib,hashes:Object.keys(c.hashFiles).sort().map(k=>[k,c.hashFiles[k]])});
}
function outcome(fn) {try{return {value:plain(fn())};}catch(e){return {error:e.message};}}
function parser(h,s) {const p=root+'\\Parser.lean';h.memory.put(p,s);return outcome(()=>h.context.importsOf(p));}
function wide(h,n=48) {
  const names=[];
  for(let i=0;i<n;i++){
    const name='Mathlib.Wide.M'+String(i).padStart(3,'0');names.push(name);
    h.memory.put(mathlib+'\\'+name.replace(/\./g,'\\')+'.lean',
      'import Mathlib.ReviewBase\nnamespace Synthetic\n'+('-- body text "import Broken" /- inert -/\n').repeat(300)+'end Synthetic\n');
    const base=art+'\\'+name.replace(/\./g,'\\');
    for(const suffix of ['.olean','.olean.private','.olean.server','.ir','.dll'])h.memory.put(base+suffix,'SYNTHETIC '+name+suffix);
  }
  h.memory.put(mathlib+'\\Mathlib\\Review.lean','import '+names.join(' ')+'\nnamespace Synthetic\nend Synthetic\n');
  for(let i=0;i<48;i++)h.memory.put(art+'\\Mathlib\\Wide\\Unrelated'+i+'.ilean','not an artifact family member');
}
function keysAfterBuild(h) {
  const c=h.context; c.parallelHashes();c.makeGlobalKey();buildAll(h);
  assert.strictEqual(c.failed,0);assert.strictEqual(c.blocked,0);
  return plain({global:c.globalKey,legacy:c.legacyGlobalKey,
    external:Object.keys(c.modules).filter(n=>!c.modules[n].local).sort().map(n=>[n,c.externalKey(n,{})]),
    modules:Array.from(c.ordered).map(n=>[n,c.moduleInput(n).key,c.moduleKeys[n],c.artifactHashes[n],
      c.auditKey(c.moduleKeys[n],c.artifactHashes[n],c.auditTargets[n],c.AUDIT_POLICY)])});
}
function packageFixture(h,label,options={}) {
  const source='C:\\cache\\.lake\\packages\\'+label, artifacts=source+'\\.lake\\build\\lib\\lean';
  h.memory.mkdir(artifacts); h.memory.put(source+'\\lake-manifest.json','{"fixture":"'+label+'"}');
  if(options.source!==false)h.memory.put(source+'\\Duplicate\\Node.lean','prelude\n');
  if(options.artifact!==false)h.memory.put(artifacts+'\\Duplicate\\Node.olean','SYNTHETIC '+label);
  if(options.companion)h.memory.put(artifacts+'\\Duplicate\\Node.olean.private','SYNTHETIC companion');
  return {source,artifacts};
}
function needDuplicate(h){h.memory.put(mathlib+'\\Mathlib\\Review.lean','import Duplicate.Node\n');}

test('header_parser_equivalence_edge_matrix',()=>{
  const b=host(baseline),c=host(candidate);
  const cases=[
    ['', 'empty'],['\n \r\n','whitespace'],['prelude\n','prelude'],['module\nimport A.B\n','module'],
    ['import A B A\n','duplicates'],['public private meta import all A all B\n','modifiers_all'],
    ["import A.foo' _Private.B\n",'apostrophes'],['import A\r\nimport B\r\n','crlf'],
    ['/- outer\n /- nested -/\n-/\nimport A\n','nested_comments'],
    ['import /- between -/ A\n','comment_between'],['import A -- ignored import B\nimport C','line_comment'],
    ['"import Bogus"\nimport Real\n','masked_string'],['"escaped \\\n still string"\nimport Real\n','escaped_lf'],
    ['"\\\" /- -- "\nimport Real\n','escaped_quotes'],['/- " -- /- x -/ -/ import A\n','mixed_comment'],
    ['import A\nnamespace X\nimport Invalid!\n','later_body_ignored'],
    ['def import := 1\n','first_body_import_rejected'],['import\nimport A\n','bare_import'],
    ['import A!\n','malformed_name'],['import «A»\n','unicode_name'],['import A;\n','semicolon'],
    ['public\nimport A\n','modifier_without_import'],['prelude\nmodule\nprivate import A\nprelude\n','repeated_header'],
    ['/- unfinished','open_comment'],['"unfinished','open_string'],['"trailing \\','trailing_escape'],
    ['import A /-\n nested -/ import B\n','comment_line_split'],['import A\n#check A\n/- unclosed','body_then_unclosed'],
    ['import all\n','all_only'],['module import A\n','unsupported_module_import'],['-- import A','comment_eof'],
    ['\uFEFFimport A\n','bom'],['import A\rimport B','bare_cr'],['prelude\n"x" import A\n','masked_prefix']
  ];
  for(const [text,label] of cases){
    const expected=parser(b,text),actual=parser(c,text);assert.deepStrictEqual(actual,expected,label);
    const source=root+'\\Parser.lean';const cleaned=c.context.sourceClean(text,false);
    assert.deepStrictEqual(outcome(()=>c.context.scanCleanImportHeader(source,cleaned).imports),expected,label+' clean');
  }
  return {fixtures:cases.length,compared:['importsOf','scanCleanImportHeader'],errors_compared_exactly:true};
});
test('all_86_frozen_project_sources_import_equivalence',()=>{
  assert(project,'Pass project source root as CLI argument 4.');
  const manifest=JSON.parse(fs.readFileSync(path.join(__dirname,'fixtures/project_sources.json'),'utf8'));
  const b=host(baseline),c=host(candidate);let chars=0,scanned=0;
  assert.strictEqual(manifest.lean_file_count,86);
  for(const file of manifest.files){
    const bytes=fs.readFileSync(path.join(project,file.path));assert.strictEqual(sha256(bytes),file.sha256,file.path);
    const text=bytes.toString('utf8'),expected=parser(b,text);assert.deepStrictEqual(parser(c,text),expected,file.path);
    const parsed=c.context.scanImportHeader(root+'\\Parser.lean',text);chars+=text.length;scanned+=parsed.scannedChars;
    assert.deepStrictEqual(outcome(()=>c.context.importsFromClean(root+'\\Parser.lean',c.context.sourceClean(text,false))),expected,file.path+' clean');
  }
  return {sources:manifest.files.length,sha256_verified:true,source_characters:chars,header_characters:scanned};
});
test('artifact_index_preserves_exact_case_delimiters_companions_and_sorted_order',()=>{
  const b=host(baseline),c=host(candidate),folder='C:\\cache\\artifacts\\';
  const leaves=['A.olean','A.olean.private','A.olean.server','A.ir','A.dll','A.ilean','A.c','A.oleanx',
    'A.OLEAN','a.olean','A.olean.B.olean.private','A.olean.B.olean','A.olean.ir','A.olean.dll',
    'A.olean.olean','A.olean.','__proto__.olean','constructor.olean','X.ir','Z.olean'];
  const files=leaves.map(n=>folder+n).sort(),index=c.context.indexArtifactFamilies(files);
  const stems=['A','a','A.olean','A.olean.B','A.olean.B.olean','__proto__','constructor','Missing'];
  for(const stem of stems)assert.deepStrictEqual(plain(index['$'+stem]||[]),plain(b.context.artifactsFromList(folder+stem+'.olean',files)),stem);
  return {files:files.length,queried_stems:stems.length};
});
test('wide_graph_manifest_and_build_audit_identity_equal_with_operation_counts',()=>{
  const b=host(baseline),c=host(candidate);wide(b);wide(c);ready(b);ready(c);
  const bc=counts(b),cc=counts(c);b.context.loadPlan();c.context.loadPlan();
  const before=plain(bc),after=plain(cc),g=plain(c.context.dependencyGraphState);
  assert.deepStrictEqual(graph(c),graph(b));
  assert(after.GetAbsolutePathName<before.GetAbsolutePathName);
  assert(after.GetFileName<before.GetFileName);
  assert(after.leanReads<before.leanReads);
  assert(after.sourceCleanChars+g.import_prefix_chars<before.sourceCleanChars);
  assert.strictEqual(g.active,false);
  assert(c.messages.some(x=>x.startsWith('DEPENDENCY_GRAPH_PROGRESS=START|')));
  assert(c.messages.some(x=>x.startsWith('DEPENDENCY_GRAPH_PROGRESS=COMPLETE|')));
  assert.deepStrictEqual(keysAfterBuild(c),keysAfterBuild(b));
  const runnerKey=c.context.keyPath(root+'\\tools\\native_runner.js');
  const bh=plain(b.context.fileHashes),ch=plain(c.context.fileHashes);delete bh[runnerKey];delete ch[runnerKey];
  assert.deepStrictEqual(ch,bh);
  measurements.synthetic_wide_graph={local_modules:3,external_wide_modules:48,before,after,candidate_graph_counters:g,
    all_requested_hash_paths_equal:true,all_content_hashes_equal_except_runner_provenance:true,
    global_legacy_external_module_audit_keys_equal:true,native_timing_claim:false};
  return measurements.synthetic_wide_graph;
});
test('first_olean_shadow_wins_in_lean_path_order',()=>{
  const outputs=[];for(const f of [baseline,candidate]){const h=host(f);needDuplicate(h);const first=packageFixture(h,'aaa');packageFixture(h,'zzz');ready(h);h.context.loadPlan();
    assert.strictEqual(h.context.modules['Duplicate.Node'].source,first.source+'\\Duplicate\\Node.lean');outputs.push(graph(h));}
  assert.deepStrictEqual(outputs[1],outputs[0]);return {first_eligible_package:'aaa'};
});
test('first_olean_shadow_missing_source_fails_without_later_fallback',()=>{
  const outputs=[];for(const f of [baseline,candidate]){const h=host(f);needDuplicate(h);packageFixture(h,'aaa',{source:false});packageFixture(h,'zzz');ready(h);outputs.push(outcome(()=>h.context.loadPlan()));
    if(f===candidate){assert.strictEqual(h.context.dependencyGraphState.active,false);assert(h.messages.some(x=>x.startsWith('DEPENDENCY_GRAPH_PROGRESS=INTERRUPTED|')));}}
  assert.deepStrictEqual(outputs[1],outputs[0]);assert.match(outputs[0].error,/source.*missing/i);return {error:outputs[0].error};
});
test('source_only_or_companion_only_package_does_not_shadow_later_olean',()=>{
  for(const variant of [{artifact:false},{source:false,artifact:false,companion:true}]){
    const outputs=[];for(const f of [baseline,candidate]){const h=host(f);needDuplicate(h);packageFixture(h,'aaa',variant);const later=packageFixture(h,'zzz');ready(h);h.context.loadPlan();
      assert.strictEqual(h.context.modules['Duplicate.Node'].source,later.source+'\\Duplicate\\Node.lean');outputs.push(graph(h));}assert.deepStrictEqual(outputs[1],outputs[0]);
  }return {variants:2};
});
test('registered_local_module_precedes_external_namesake',()=>{
  const outputs=[];for(const f of [baseline,candidate]){const h=host(f);h.memory.put(mathlib+'\\Review\\Base.lean','prelude\n');h.memory.put(art+'\\Review\\Base.olean','SHADOW');
    ready(h);h.context.loadPlan();assert.strictEqual(h.context.modules['Review.Base'].local,true);assert(!Object.values(h.context.hashFiles).includes(art+'\\Review\\Base.olean'));outputs.push(graph(h));}
  assert.deepStrictEqual(outputs[1],outputs[0]);return {local_winner:true};
});
test('requirements_phase_does_not_cache_source_imports_for_graph',()=>{
  const outputs=[];for(const f of [baseline,candidate]){const h=host(f);ready(h);h.memory.put(mathlib+'\\Mathlib\\Late.lean','prelude\n');h.memory.put(art+'\\Mathlib\\Late.olean','LATE');
    h.memory.put(root+'\\Review\\Base.lean',h.memory.text(root+'\\Review\\Base.lean').replace('import Mathlib.Review','import Mathlib.Review Mathlib.Late'));
    h.context.loadPlan();assert(h.context.modules['Mathlib.Late']);outputs.push(graph(h));}assert.deepStrictEqual(outputs[1],outputs[0]);return {late_import_seen:true};
});
test('strict_full_project_scan_still_rejects_late_body_placeholder',()=>{
  const outputs=[];for(const f of [baseline,candidate]){const h=host(f);ready(h);h.memory.put(root+'\\Review\\Base.lean',h.memory.text(root+'\\Review\\Base.lean')+'\ntheorem bad : False := by sorry\n');outputs.push(outcome(()=>h.context.loadPlan()));}
  assert.deepStrictEqual(outputs[1],outputs[0]);assert.match(outputs[0].error,/Prohibited proof placeholder/);return {full_body_rejection_preserved:true};
});
test('fresh_invocation_observes_external_source_edit_and_new_companion',()=>{
  const result=[];
  for(const file of [baseline,candidate]){
    const first=host(file);ready(first);first.context.loadPlan();const old=keysAfterBuild(first);
    first.memory.put(mathlib+'\\Mathlib\\ReviewBase.lean','prelude\n-- modified dependency content\n');
    first.memory.put(art+'\\Mathlib\\Review.olean.extra','NEW COMPANION');
    const second=createHost(file,{memory:first.memory,env:Object.assign({},first.values,{RH_HASH_MODE:'CERTUTIL'})});
    ready(second);second.context.loadPlan();const fresh=keysAfterBuild(second);
    assert(second.context.modules['Mathlib.Review'].artifacts.includes(art+'\\Mathlib\\Review.olean.extra'));
    assert.notStrictEqual(fresh.modules[0][1],old.modules[0][1]);result.push({graph:graph(second),keys:fresh});
  }
  assert.deepStrictEqual(result[1],result[0]);return {source_and_new_artifact_seen:true,dependent_module_key_changed:true};
});
test('profile_lock_and_build_identity_functions_preserved_byte_for_byte',()=>{
  const b=host(baseline),c=host(candidate);
  const names=['configurePersistentProfile','acquireRunnerLock','releaseRunnerLock','lockSnapshot','selectCache',
    'makeGlobalKey','moduleInput','verifyLegacy','auditKey','readAnchorCore','verifyCurrent','restoreAnchor',
    'workingArtifactsMatch','processModule','prepareBatchHasher','parseBatchHashes','batchHashes'];
  for(const name of names){assert.strictEqual(typeof b.context[name],'function',name);assert.strictEqual(String(c.context[name]),String(b.context[name]),name);}
  return {functions:names,identity_and_lock_no_change:true};
});
const report={schema:'RH_GRAPH_STARTUP_NODE_REVIEW_V1',scope:'Node VM and in-memory Windows host only; no Lean or native execution',
  runner_sha256:sha256(fs.readFileSync(candidate)),baseline_sha256:sha256(fs.readFileSync(baseline)),
  passed:results.filter(x=>x.status==='PASS').length,failed:results.filter(x=>x.status==='FAIL').length,measurements,tests:results};
fs.writeFileSync(reportPath,JSON.stringify(report,null,2)+'\n');
process.exitCode=report.failed?1:0;
