from pathlib import Path
from datetime import datetime
from zoneinfo import ZoneInfo
import hashlib
import json
import re
import shutil
import zipfile

ROOT = Path('/workspace/scratch/f128c1434505')
WORK = ROOT / 'tmp/reuse_record_v0216'
BASE = ROOT / 'output/RH_HILBERT_LIMIT_LEAN_v0_2_16_construction'
OUT = ROOT / 'output/reuse_record_v0216' / BASE.name
ARCHIVE = ROOT / 'output/RH_HILBERT_LIMIT_LEAN_v0_2_16_REUSE_RECORD_construction.zip'
EV = OUT / 'evidence/reuse_record_v0216'

def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()

def js(p):
    return json.loads(p.read_text(encoding='utf-8'))

def dump(p, value):
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(json.dumps(value, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')

for folder in ['evidence', 'review']:
    shutil.copytree(WORK / folder, EV / folder, dirs_exist_ok=True)
for name in ['assemble.py', 'package.py', 'ASSEMBLY.json']:
    shutil.copyfile(WORK / name, EV / name)

runtime = js(EV / 'evidence/UNCHANGED_EXECUTION_INPUTS_REVIEW.json')
native = js(EV / 'evidence/NATIVE_REUSE_TAIL_REVIEW.json')
endpoint = js(EV / 'review/ENDPOINT_REUSE_EVIDENCE.json')
assert runtime['status'] == 'PASS_STATIC_BYTE_COMPARISON'
assert runtime['candidate_runner_sha256'] == sha(OUT / 'tools/native_runner.js') == sha(BASE / 'tools/native_runner.js')
assert native['transcript_sha256'] == sha(EV / 'evidence/USER_NATIVE_REUSE_TAIL.txt') == 'd4c7ca9f9d6b20e4d0085f7c3cbdd2105957263746b2bb0bb6668bdb81d07f15'
assert native['reported']['compiled_modules'] == 0 and native['reported']['frozen_reused_modules'] == 90
assert native['reported_final_aggregate']['declarations'] == 370
assert endpoint['warm_counts_are_now_user_reported_observed'] is True

lean = {p.relative_to(BASE).as_posix(): sha(p) for p in BASE.rglob('*.lean')}
assert len(lean) == 92
assert lean == {p.relative_to(OUT).as_posix(): sha(p) for p in OUT.rglob('*.lean')}
for item in runtime['unchanged_runtime_and_execution_inputs']:
    assert sha(OUT / item['path']) == sha(BASE / item['path']) == item['sha256']
prior_evidence = {p.relative_to(BASE).as_posix(): sha(p) for p in (BASE / 'evidence').rglob('*') if p.is_file()}
for rel, h in prior_evidence.items():
    assert sha(OUT / rel) == h, rel
dump(EV / 'PRESERVED_PRIOR_EVIDENCE.json', prior_evidence)

checkpoint = js(OUT / 'CHECKPOINT.json')
assert checkpoint['exact_endpoint_declarations'] == js(BASE / 'CHECKPOINT.json')['exact_endpoint_declarations']
targets = re.findall(r'^#print axioms (\S+)', (OUT / 'AnalyticAudit.lean').read_text(), re.M)
assert len(targets) == len(set(targets)) == 370
delta = js(EV / 'DECLARATION_EVIDENCE_DELTA.json')
assert len(delta) == 67 and {item['name'] for item in delta} <= set(targets)
old_declarations, declarations = js(BASE / 'DECLARATIONS.json'), js(OUT / 'DECLARATIONS.json')
assert len(old_declarations) == len(declarations) == 1105
updated = {item['name'] for item in delta}
for old, new in zip(old_declarations, declarations):
    if new['name'] not in updated:
        assert old == new
    else:
        for key in ['name', 'kind', 'module', 'source', 'source_line', 'source_sha256']:
            assert old.get(key) == new.get(key)
        assert new['source_sha256'] == sha(OUT / new['source'])
        assert new['status'] == 'USER_REPORTED_V0_2_16_STANDARD_AXIOM_AUDIT_PASS_REUSED'

status = js(OUT / 'STATUS.json')
assert status['formal_closure'] == checkpoint['formal_closure'] == 'OPEN'
assert status['finite_checker_equivalence'] == 'OPEN_NOT_IMPLEMENTED_AS_A_PROVED_DECLARATION'
assert status['unconditional_rh'] == checkpoint['unconditional_rh'] == 'NOT_ESTABLISHED'
assert status['expected_warm_counts_are_observed'] is True
assert status['mode'] == checkpoint['mode'] == 'A_TIER_LEAN'
assert status['target'] == checkpoint['target'] == 'LOCAL_COMPILER'

dump(OUT / 'RUNNER_LOGIC_VALIDATION.json', {
    'schema': 'RH_HILBERT_V0216_REUSE_RUNTIME_PRESERVATION_V1',
    'status': 'EXACT_ALL_RUNTIME_BYTES_AND_IDENTITIES_PRESERVED',
    'runner_sha256': sha(OUT / 'tools/native_runner.js'),
    'baseline_runner_sha256': sha(BASE / 'tools/native_runner.js'),
    'runtime_or_identity_revision': False,
    'runtime_review': 'evidence/reuse_record_v0216/evidence/UNCHANGED_EXECUTION_INPUTS_REVIEW.json',
    'runtime_review_sha256': sha(EV / 'evidence/UNCHANGED_EXECUTION_INPUTS_REVIEW.json'),
    'new_runtime_tests': False, 'native_execution_here': False,
    'user_reported_run': 'PASS; 0 compiled, 90 frozen reused; explicit standard-axiom audit summary with no sorryAx',
    'independent_native_audit_or_receipt_inspection': False,
})
allowed_changes = set(js(WORK / 'ASSEMBLY.json')['metadata_changed'])
dump(OUT / 'STATIC_REVIEW.json', {
    'schema': 'RH_HILBERT_V0216_REUSE_RECORD_STATIC_REVIEW_V1',
    'package': BASE.name, 'delivery_filename': ARCHIVE.name,
    'status': 'SOURCE_RUNTIME_AND_IDENTITY_PRESERVATION_CHECKED',
    'lean_sources_preserved': 92, 'changed_proof_inputs': [],
    'selected_axiom_targets_preserved': 370,
    'exact_endpoint_declarations_preserved': 10,
    'analytic_declaration_evidence_entries_updated': 67,
    'older_metadata_entries_unchanged': 1038,
    'all_runtime_bytes_unchanged': True, 'package_and_runner_identity_unchanged': True,
    'new_tests_or_native_execution': False, 'formal_closure': 'OPEN',
    'allowed_changed_parent_files': sorted(allowed_changes),
    'prior_evidence_files_preserved': len(prior_evidence),
})
dump(OUT / 'PROVENANCE.json', {
    'package': BASE.name, 'delivery_filename': ARCHIVE.name,
    'prepared_at': datetime.now(ZoneInfo('Europe/Berlin')).isoformat(),
    'mode': 'A_TIER_LEAN', 'target': 'LOCAL_COMPILER',
    'parent_package': BASE.name, 'parent_zip_sha256': sha(BASE.with_suffix('.zip')),
    'parent_library_file_id': 'libfile_48346676be6481919f67e8f904a3bd73',
    'parent_library_version': 18,
    'scope': 'Record explicit user-reported warm reuse/audit PASS while preserving all source/runtime bytes and the same canonical workspace.',
    'runner_sha256': sha(OUT / 'tools/native_runner.js'), 'lean_sources_byte_preserved': 92,
    'user_reuse_transcript_sha256': native['transcript_sha256'],
    'new_native_or_lean_execution': False, 'new_runtime_tests': False,
    'direct_native_receipt_inspection': False,
    'evidence_sha256': {p.relative_to(EV).as_posix(): sha(p) for p in sorted(EV.rglob('*'))
                       if p.is_file() and 'baseline_v0216_metadata' not in p.parts},
})

changed = []
for p in BASE.rglob('*'):
    if p.is_file():
        rel = p.relative_to(BASE).as_posix()
        assert (OUT / rel).is_file(), rel
        if sha(p) != sha(OUT / rel):
            assert rel in allowed_changes, rel
            changed.append(rel)
for p in OUT.rglob('*'):
    if p.is_file():
        rel = p.relative_to(OUT)
        assert p.suffix.lower() not in {'.exe', '.dll', '.olean', '.ilean', '.pyc'}, rel
        assert '.native-build' not in rel.parts, rel
        if not (BASE / rel).exists():
            assert rel.parts[:2] == ('evidence', 'reuse_record_v0216'), rel

payload = [p for p in sorted(OUT.rglob('*')) if p.is_file() and p != OUT / 'SHA256SUMS.txt']
(OUT / 'SHA256SUMS.txt').write_text(''.join(sha(p) + '  ' + p.relative_to(OUT).as_posix() + '\n' for p in payload), encoding='utf-8')
with zipfile.ZipFile(ARCHIVE, 'w', zipfile.ZIP_DEFLATED, compresslevel=9) as z:
    for p in sorted(OUT.rglob('*')):
        if p.is_file():
            z.write(p, (Path(OUT.name) / p.relative_to(OUT)).as_posix())
with zipfile.ZipFile(ARCHIVE) as z:
    assert z.testzip() is None
    names = z.namelist()
    assert len(names) == len(set(names))
    assert {n.split('/')[0] for n in names} == {BASE.name}
    assert all('..' not in Path(n).parts and not n.startswith('/') for n in names)
    sums = z.read(BASE.name + '/SHA256SUMS.txt').decode().splitlines()
    assert len(sums) == len(payload) == len(names) - 1
    for line in sums:
        digest, rel = line.split('  ', 1)
        assert hashlib.sha256(z.read(BASE.name + '/' + rel)).hexdigest() == digest
        assert sha(OUT / rel) == digest
    assert z.read(BASE.name + '/run.cmd') == (BASE / 'run.cmd').read_bytes()
    assert z.read(BASE.name + '/tools/native_runner.js') == (BASE / 'tools/native_runner.js').read_bytes()

verified = {
    'archive': str(ARCHIVE), 'bytes': ARCHIVE.stat().st_size, 'sha256': sha(ARCHIVE),
    'members': len(names), 'hashed_payload_files': len(payload), 'crc': 'PASS',
    'single_root': BASE.name, 'same_canonical_workspace': True,
    'lean_sources_preserved': 92, 'changed_lean_sources': [],
    'runner_sha256': sha(OUT / 'tools/native_runner.js'),
    'all_runtime_bytes_and_identities': 'UNCHANGED',
    'native_evidence': 'USER_REPORTED_V0_2_16_REUSE_AND_STANDARD_AXIOM_AUDIT_PASS',
    'native_execution': 'NOT_RUN_BY_ASSISTANT', 'new_tests': 'NOT_RUN',
    'changed_metadata_files': sorted(set(changed) | {'SHA256SUMS.txt'}),
    'formal_closure': 'OPEN',
}
dump(WORK / 'ZIP_VERIFIED.json', verified)
print(json.dumps(verified, indent=2))
