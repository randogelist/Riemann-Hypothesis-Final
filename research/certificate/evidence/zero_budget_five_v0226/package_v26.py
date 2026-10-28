"""Verify and seal source-only package. Never execute Lean or native runner."""
from pathlib import Path
import json, re, zipfile, hashlib
from prepare_v26 import ROOT, BASE, OUT, EV, NEW, FINAL, sha, lines, clean

old_sources=sorted(p.relative_to(BASE).as_posix() for p in BASE.rglob('*.lean'))
assert len(old_sources)==102
for rel in old_sources:
    assert (BASE/rel).read_bytes()==(OUT/rel).read_bytes(),rel
assert len(list(OUT.rglob('*.lean')))==106
for rel in ['run.cmd','lean-toolchain','tools/follow_active.js','tools/NativeSha256.cs','tools/NativeRamWarm.cs']:
    assert (BASE/rel).read_bytes()==(OUT/rel).read_bytes(),rel
assert lines(OUT/'compile-order.txt')==lines(BASE/'compile-order.txt')+NEW
assert lines(OUT/'final-audit.txt')==[FINAL]
rows=lines(OUT/'audit-targets.tsv')
old_rows=lines(BASE/'audit-targets.tsv')
assert rows[:len(old_rows)]==old_rows
targets=[r.split('|')[1] for r in rows]
assert len(targets)==len(set(targets))==463
audit=clean((OUT/FINAL).read_text())
assert re.findall(r'^#check (\S+)$',audit,re.M)==targets
assert re.findall(r'^#print axioms (\S+)$',audit,re.M)==targets
decls=json.loads((OUT/'DECLARATIONS.json').read_text())
old_decls=json.loads((BASE/'DECLARATIONS.json').read_text())
assert decls[:len(old_decls)]==old_decls
assert len(decls)==len(old_decls)+15
for d in decls[len(old_decls):]:
    assert sha(OUT/d['source'])==d['source_sha256']
    assert d['status']=='NATIVE_AUDIT_PENDING'
    assert d['module']+'|'+d['name'] in rows
for rel in NEW:
    src=clean((OUT/rel).read_text())
    assert not re.search(r'\b(sorry|admit|axiom|unsafe|native_decide)\b',src)
    assert 'debug.skipKernel' not in src
edits=json.loads((EV/'RUNNER_REPORTING_EDITS.json').read_text())
runner=(OUT/'tools/native_runner.js').read_bytes()
assert sha(OUT/'tools/native_runner.js')==edits['runner_sha256']
normalized=runner.replace(edits['json_addition'].encode(),b'',1).replace(edits['log_addition'].encode(),b'',1)
for old,new,count in reversed(edits['replacements']):
    assert normalized.count(new.encode())==count
    normalized=normalized.replace(new.encode(),old.encode())
assert normalized==(BASE/'tools/native_runner.js').read_bytes()
status=json.loads((OUT/'STATUS.json').read_text())
assert status['first_batch_indices']==list(range(5))
assert status['next_batch_indices']==list(range(5,10))
assert status['next_batch_status']=='NOT_INCLUDED_NOT_VERIFIED'
assert status['selected_candidate_admissibility']==status['universal_propagation']=='OPEN'
assert status['unconditional_rh']=='NOT_ESTABLISHED'
assert status['accepted_finite_witness'] is None
assert status['assistant_lean_native_or_ci_execution'] is False
for rel in NEW+[FINAL]: assert sha(OUT/rel)==status['new_source_sha256'][rel]
review=json.loads((EV/'FINAL_SOURCE_REVIEW.json').read_text())
assert review['blockers']==[]
assert not review['lean_compiled'] and not review['native_axiom_audit_executed']
for rel,h in review['source_sha256'].items(): assert sha(OUT/rel)==h
evidence=EV/'package_v26.py'
evidence.write_bytes(Path(__file__).read_bytes())
files=sorted(p for p in OUT.rglob('*') if p.is_file())
assert all(not p.is_symlink() and p.suffix not in {'.olean','.ilean'} for p in files)
manifest=''.join(sha(p)+'  '+p.relative_to(OUT).as_posix()+'\n' for p in files if p!=OUT/'SHA256SUMS.txt')
(OUT/'SHA256SUMS.txt').write_text(manifest)
archive=ROOT/'output'/(OUT.name+'.zip')
archive.parent.mkdir(exist_ok=True)
with zipfile.ZipFile(archive,'w',zipfile.ZIP_DEFLATED,compresslevel=9) as z:
    for p in files: z.write(p,OUT.name+'/'+p.relative_to(OUT).as_posix())
with zipfile.ZipFile(archive) as z:
    assert z.testzip() is None
    names=z.namelist()
    assert len(names)==len(set(names))==len(files)
    assert all(n.startswith(OUT.name+'/') and '..' not in Path(n).parts for n in names)
    assert sum(n.endswith('/run.cmd') for n in names)==1
    for p in files: assert z.read(OUT.name+'/'+p.relative_to(OUT).as_posix())==p.read_bytes()
    for line in manifest.splitlines():
        h,rel=line.split('  ',1)
        assert hashlib.sha256(z.read(OUT.name+'/'+rel)).hexdigest()==h
result={'archive':str(archive),'sha256':sha(archive),'bytes':archive.stat().st_size,
    'members':len(files),'archive_integrity':'VERIFIED','old_lean_files_preserved':102,
    'new_lean_files':4,'new_public_declarations':15,'selected_audit_targets':463,
    'source_review':'NO_STATIC_BLOCKERS','native_compilation':'NOT_RUN','native_axiom_audit':'PENDING',
    'first_batch_indices':list(range(5)),'next_batch':'5..9 AFTER USER NATIVE PASS; NOT INCLUDED',
    'universal_admissibility':'OPEN'}
(archive.parent/'verification_v26.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(result,indent=2))
