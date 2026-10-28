#!/usr/bin/env python3
"""Freeze reported-pass source bytes and update checkpoint metadata only."""
import difflib,hashlib,json,re,shutil
from pathlib import Path
ROOT=Path('/workspace/scratch/f128c1434505')
WORK=ROOT/'tmp/checkpoint_v0216'
BASE=ROOT/'output/RH_HILBERT_LIMIT_LEAN_v0_2_15_construction'
OUT=ROOT/'output/RH_HILBERT_LIMIT_LEAN_v0_2_16_construction'
EV=OUT/'evidence/checkpoint_v0216'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def js(p):return json.loads(p.read_text())
def dump(p,x):
    p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(x,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
assert sha(BASE.with_suffix('.zip'))=='746214590251c079eca33d5b66a4257c136b86ad497a321ef143c83d2a116a0d'
assert not OUT.exists(),'Do not overwrite an assembled checkpoint'
shutil.copytree(BASE,OUT)
(EV/'baseline_v0215_metadata').mkdir(parents=True)
for name in ['README.md','STATUS.json','PROVENANCE.json','STATIC_REVIEW.json','RUNNER_LOGIC_VALIDATION.json',
             'RUNNER_NOTES.txt','SHA256SUMS.txt','runner-version.txt','OPEN_OBLIGATIONS.txt','DECLARATIONS.json']:
    shutil.copyfile(BASE/name,EV/'baseline_v0215_metadata'/name)
old=(BASE/'tools/native_runner.js').read_text()
new=old.replace('var PACKAGE = "RH_HILBERT_LIMIT_LEAN_v0_2_15_construction";',
                'var PACKAGE = "RH_HILBERT_LIMIT_LEAN_v0_2_16_construction";').replace(
                'var RUNNER_VERSION = "RH_HILBERT_NATIVE_RUNNER_v0_2_15_PROOF_REPAIR";',
                'var RUNNER_VERSION = "RH_HILBERT_NATIVE_RUNNER_v0_2_16_PASS_CHECKPOINT";')
assert new!=old
(OUT/'tools/native_runner.js').write_text(new,encoding='utf-8')
(OUT/'runner-version.txt').write_text('RH_HILBERT_NATIVE_RUNNER_v0_2_16_PASS_CHECKPOINT\n',encoding='utf-8')
(EV/'NATIVE_RUNNER_IDENTITY_DIFF.txt').write_text(''.join(difflib.unified_diff(old.splitlines(True),new.splitlines(True),
    fromfile=BASE.name+'/tools/native_runner.js',tofile=OUT.name+'/tools/native_runner.js')),encoding='utf-8')
lean={p.relative_to(BASE).as_posix():sha(p) for p in BASE.rglob('*.lean')}
assert len(lean)==92
for rel,h in lean.items():assert sha(OUT/rel)==h,rel
dump(EV/'FROZEN_LEAN_SOURCE_HASHES_V0215.json',lean)

# Correct source-location/hash metadata for the five analytic modules while
# recording only the aggregate PASS the user supplied, never an invented audit.
analytic=set(js(BASE/'STATUS.json')['inherited_unverified_proof_modules'])
def declaration_lines(path):
    namespaces=[];out={}
    for line_no,line in enumerate(path.read_text().splitlines(),1):
        m=re.match(r'^namespace\s+(\S+)',line)
        if m:namespaces.append(m.group(1));continue
        m=re.match(r'^end(?:\s+(\S+))?\s*$',line)
        if m and namespaces:
            if m.group(1) is None or m.group(1)==namespaces[-1]:namespaces.pop()
            continue
        m=re.match(r'^(?:(?:private|protected|noncomputable)\s+)*(?:theorem|lemma|def|abbrev)\s+([\w.]+)',line)
        if m:
            name='.'.join(namespaces+[m.group(1)])
            assert name not in out,name
            out[name]=line_no
    return out
locations={rel:declaration_lines(OUT/rel) for rel in analytic}
inventory=js(BASE/'DECLARATIONS.json');deltas=[]
for item in inventory:
    rel=item.get('source')
    if rel not in analytic:continue
    before=dict(item);assert item['name'] in locations[rel],item['name']
    item.update({'source_line':locations[rel][item['name']],'source_sha256':sha(OUT/rel),
        'status':'USER_REPORTED_V0_2_15_AGGREGATE_RUN_PASS',
        'evidence':'evidence/checkpoint_v0216/evidence/NATIVE_PASS_TAIL_REVIEW.json',
        'evidence_scope':'Aggregate PASS summary only; expected selected audit coverage verified in source. Direct native declaration/audit/receipt/hash records not supplied.',
        'source_hash_origin':'LOCAL_PACKAGE_BYTES; NOT_A_NATIVE_HASH_FROM_THE_PASTED_TAIL',
        'receipt_validation':'REQUIRED_ON_USER_MACHINE_FOR_REUSE'})
    deltas.append({'name':item['name'],'before':before,'after':dict(item)})
assert len(deltas)==67 and len(inventory)==1105
dump(OUT/'DECLARATIONS.json',inventory)
dump(EV/'DECLARATION_METADATA_DELTA.json',deltas)
frozen=js(BASE/'evidence/runtime_v0213/FROZEN_PROOF_AND_CACHE_INPUTS.json')
preserved={rel:sha(BASE/rel) for rel in frozen if rel not in {'DECLARATIONS.json','OPEN_OBLIGATIONS.txt'}}
assert len(preserved)==101
for rel,h in preserved.items():assert sha(OUT/rel)==h,rel
dump(EV/'PRESERVED_PROOF_AND_CACHE_INPUTS.json',preserved)
result={'package':OUT.name,'runner_sha256':sha(OUT/'tools/native_runner.js'),'lean_source_files_preserved':92,
    'unchanged_manifest_inputs':101,'changed_lean_sources':[],'declaration_metadata_entries_updated':67,
    'native_execution':'NOT_RUN','new_tests':'NOT_RUN; NO_FUNCTIONAL_CODE_CHANGE'}
dump(WORK/'ASSEMBLY.json',result)
print(json.dumps(result,indent=2))
