#!/usr/bin/env python3
"""Assemble proof-only repairs; no Lean or native execution."""
import difflib,hashlib,json,re,shutil
from pathlib import Path
ROOT=Path('/workspace/scratch/f128c1434505')
WORK=ROOT/'tmp/lean_repair_v0215'
BASE=ROOT/'output/RH_HILBERT_LIMIT_LEAN_v0_2_14_construction'
OUT=ROOT/'output/RH_HILBERT_LIMIT_LEAN_v0_2_15_construction'
EV=OUT/'evidence/repair_v0215'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,x):
    p.parent.mkdir(parents=True,exist_ok=True)
    p.write_text(json.dumps(x,indent=2)+'\n',encoding='utf-8')
assert sha(BASE.with_suffix('.zip'))=='7c54d3341572f2e63d1853cd3a1edc86095915354752886047a506c4392535e4'
assert not OUT.exists(),'Do not overwrite an already assembled candidate'
shutil.copytree(BASE,OUT)
(EV/'baseline_v0214_metadata').mkdir(parents=True)
for name in ['README.md','STATUS.json','PROVENANCE.json','STATIC_REVIEW.json','RUNNER_LOGIC_VALIDATION.json',
             'RUNNER_NOTES.txt','SHA256SUMS.txt','runner-version.txt','OPEN_OBLIGATIONS.txt']:
    shutil.copyfile(BASE/name,EV/'baseline_v0214_metadata'/name)
old=(BASE/'tools/native_runner.js').read_text()
new=old.replace('var PACKAGE = "RH_HILBERT_LIMIT_LEAN_v0_2_14_construction";',
                'var PACKAGE = "RH_HILBERT_LIMIT_LEAN_v0_2_15_construction";').replace(
                'var RUNNER_VERSION = "RH_HILBERT_NATIVE_RUNNER_v0_2_14_CAST_AND_SHUTDOWN_RECHECK";',
                'var RUNNER_VERSION = "RH_HILBERT_NATIVE_RUNNER_v0_2_15_PROOF_REPAIR";')
assert new!=old
(OUT/'tools/native_runner.js').write_text(new,encoding='utf-8')
(OUT/'runner-version.txt').write_text('RH_HILBERT_NATIVE_RUNNER_v0_2_15_PROOF_REPAIR\n',encoding='utf-8')
files={
    'RH_HilbertLimit/CanonicalPowerSums.lean':('canonical/CanonicalPowerSums.lean','55e10b78e84bb2ec7cfbd693e5275f46b4ada256bda0530ccb4c0e80337e65de'),
    'RH_HilbertLimit/SpectralPhase.lean':('phase/SpectralPhase.lean','e5d3e26af0da7eb222dac75252480975eb4fa46150ebb342a58c42ab20063db3')}
source_changes=[]
for rel,(candidate,expected) in files.items():
    p=WORK/candidate;assert sha(p)==expected,candidate
    a=(BASE/rel).read_text();b=p.read_text()
    headers=lambda s:re.findall(r'(?ms)^((?:theorem|lemma|def|abbrev)\s+\w+.*?)(?=\s*:=)',s)
    assert headers(a)==headers(b),rel
    assert re.findall(r'^import .+$',a,re.M)==re.findall(r'^import .+$',b,re.M),rel
    shutil.copyfile(p,OUT/rel)
    source_changes.append({'path':rel,'before_sha256':sha(BASE/rel),'after_sha256':sha(OUT/rel),
        'declaration_headers_preserved':len(headers(a)),'imports_preserved':True})
canonical_rel='RH_HilbertLimit/CanonicalPowerSums.lean'
expected=(BASE/canonical_rel).read_text()
for theorem in ['hasDerivAt_resolvent','hasDerivAt_resolvent_pow']:
    before=(WORK/'canonical'/(theorem+'_before.txt')).read_text()
    after=(WORK/'canonical'/(theorem+'_after.txt')).read_text()
    assert expected.count(before)==1,theorem
    expected=expected.replace(before,after)
assert expected==(OUT/canonical_rel).read_text()
phase_rel='RH_HilbertLimit/SpectralPhase.lean'
expected=(BASE/phase_rel).read_text()
assert expected.count('  · exact affine_injective hx\n')==1
expected=expected.replace('  · exact affine_injective hx\n','  · intro hqr\n    exact affine_injective hx hqr\n')
needle='add_lt_add_left (mul_lt_mul_of_pos_right hx (norm_pos_iff.mpr hq)) _'
assert expected.count(needle)==1
expected=expected.replace(needle,'add_lt_add_right (mul_lt_mul_of_pos_right hx (norm_pos_iff.mpr hq)) _')
assert expected==(OUT/phase_rel).read_text()
ledger=(BASE/'OPEN_OBLIGATIONS.txt').read_text().split('\n',2)[2]
(OUT/'OPEN_OBLIGATIONS.txt').write_text('CURRENT PACKAGE: v0.2.15 construction, native verification pending\n'
    'Proof frontier inherited from v0.2.11; current repair changes four proofs in two modules.\n'+ledger,encoding='utf-8')
frozen=json.loads((BASE/'evidence/runtime_v0213/FROZEN_PROOF_AND_CACHE_INPUTS.json').read_text())
preserved={rel:sha(BASE/rel) for rel in frozen if rel not in set(files)|{'OPEN_OBLIGATIONS.txt'}}
assert len(preserved)==100
for rel,h in preserved.items():assert sha(OUT/rel)==h,rel
dump(EV/'PRESERVED_PROOF_AND_CACHE_INPUTS.json',preserved)
dump(EV/'SOURCE_CHANGES.json',source_changes)
(EV/'NATIVE_RUNNER_IDENTITY_DIFF.txt').write_text(''.join(difflib.unified_diff(old.splitlines(True),new.splitlines(True),
    fromfile=BASE.name+'/tools/native_runner.js',tofile=OUT.name+'/tools/native_runner.js')),encoding='utf-8')
result={'package':OUT.name,'runner_sha256':sha(OUT/'tools/native_runner.js'),'source_changes':source_changes,
    'lean_sources_total':92,'lean_sources_byte_preserved':90,'unchanged_manifest_inputs':100,
    'native_execution':'NOT_RUN','new_runtime_tests':'NOT_RUN; FUNCTIONAL_RUNTIME_UNCHANGED'}
dump(WORK/'ASSEMBLY.json',result)
print(json.dumps(result,indent=2))
