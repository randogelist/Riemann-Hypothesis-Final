from pathlib import Path
from datetime import datetime, timezone
import hashlib
import json
import re
import shutil
import zipfile

ROOT = Path('/workspace/scratch/f128c1434505')
WORK = ROOT / 'tmp/native_pass_v0221'
BASE = ROOT / 'output/RH_HILBERT_LIMIT_LEAN_v0_2_20_construction'
OUT = ROOT / 'output/RH_HILBERT_LIMIT_LEAN_v0_2_21_construction'
EVREL = 'evidence/native_pass_v0221'
EV = OUT / EVREL
ZIP = OUT.with_suffix('.zip')
OLD_RUNNER = 'RH_HILBERT_NATIVE_RUNNER_v0_2_20_ZERO_BUDGET_CAST'
NEW_RUNNER = 'RH_HILBERT_NATIVE_RUNNER_v0_2_21_SEMANTIC_PASS_CHECKPOINT'


def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def read_json(p):
    return json.loads(p.read_text(encoding='utf-8'))


def dump(p, value):
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(json.dumps(value, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')


def lines(p):
    return [s.strip() for s in p.read_text(encoding='utf-8').splitlines()
            if s.strip() and not s.lstrip().startswith('#')]


assembly = read_json(WORK / 'ASSEMBLY.json')
review = read_json(WORK / 'review/INTEGRATION_REVIEW.json')
assert review['status'] == 'STATIC_INTEGRATION_REVIEW_ONLY' and not review.get('blockers')
assert sha(OUT / 'tools/native_runner.js') == assembly['runner_sha256']
shutil.copyfile(WORK / 'review/INTEGRATION_REVIEW.json', EV / 'INTEGRATION_REVIEW.json')
shutil.copyfile(Path(__file__), EV / 'package.py')

old_lean = sorted(p.relative_to(BASE).as_posix() for p in BASE.rglob('*.lean'))
new_lean = sorted(p.relative_to(OUT).as_posix() for p in OUT.rglob('*.lean'))
assert old_lean == new_lean and len(old_lean) == 96
for rel in old_lean:
    assert (BASE / rel).read_bytes() == (OUT / rel).read_bytes(), rel
for rel in ['compile-order.txt', 'final-audit.txt', 'audit-targets.tsv', 'mathlib-imports.txt', 'run.cmd', 'lean-toolchain']:
    assert (OUT / rel).read_bytes() == (BASE / rel).read_bytes(), rel
order = lines(OUT / 'compile-order.txt')
assert len(order) == len(set(order)) == 92
assert (OUT / 'final-audit.txt').read_text().strip() == 'CancellationAudit.lean'
active_files = order + ['CancellationAudit.lean']
active_names = [r[:-5].replace('/', '.') for r in active_files]
positions = {m: i for i, m in enumerate(active_names)}
graph = {}
for i, rel in enumerate(active_files):
    module = active_names[i]
    imports = re.findall(r'^import\s+(\S+)\s*$', (OUT / rel).read_text(), re.M)
    graph[module] = [imp for imp in imports if imp in positions]
    for dep in graph[module]:
        assert positions[dep] < i, (module, dep)
    for imp in imports:
        assert not (OUT / (imp.replace('.', '/') + '.lean')).exists() or imp in positions
reachable = set()


def visit(module):
    if module not in reachable:
        reachable.add(module)
        for dep in graph[module]:
            visit(dep)


visit('CancellationAudit')
assert reachable == set(active_names)
rows = lines(OUT / 'audit-targets.tsv')
targets = [r.split('|')[1] for r in rows]
assert len(rows) == len(set(targets)) == 394
audit = (OUT / 'CancellationAudit.lean').read_text()
assert re.findall(r'^#check\s+(\S+)\s*$', audit, re.M) == targets
assert re.findall(r'^#print axioms\s+(\S+)\s*$', audit, re.M) == targets
assert all(r.split('|')[0] in positions for r in rows)

old_inventory = read_json(BASE / 'DECLARATIONS.json')
inventory = read_json(OUT / 'DECLARATIONS.json')
explicit = read_json(EV / 'EXPLICIT_USER_AXIOM_OUTPUT.json')['axioms_by_declaration']
assert len(explicit) == 14 and set(explicit) <= set(targets)
assert len(inventory) == len(old_inventory) == 1129
selected = 0
unselected = 0
explicit_count = 0
for old, new in zip(old_inventory, inventory):
    assert old['name'] == new['name'] and old['module'] == new['module']
    if new['name'] not in targets:
        assert old == new
        unselected += 1
        continue
    selected += 1
    assert old != new
    assert new['source_sha256'] == sha(OUT / new['source'])
    assert old.get('source_line') == new.get('source_line')
    allowed = {'source_sha256', 'status', 'evidence', 'receipt_validation', 'latest_audit_evidence_scope', 'latest_reported_axioms'}
    assert {k for k in old.keys() | new.keys() if old.get(k) != new.get(k)} <= allowed
    if new['name'] in explicit:
        assert new['latest_reported_axioms'] == explicit[new['name']]
        assert new['latest_audit_evidence_scope'] == 'EXPLICIT_USER_AXIOM_OUTPUT'
        explicit_count += 1
    else:
        assert new['latest_audit_evidence_scope'] == 'USER_REPORTED_SELECTED_AGGREGATE_AUDIT'
assert (selected, unselected, explicit_count) == (394, 735, 14)
for name, axioms in explicit.items():
    assert set(axioms) <= {'propext', 'Classical.choice', 'Quot.sound'}
assert (EV / 'USER_NATIVE_V0220_PASS_TAIL.txt').read_bytes() == (WORK / 'USER_NATIVE_V0220_PASS_TAIL.txt').read_bytes()

native = read_json(EV / 'USER_REPORTED_NATIVE_PASS.json')
assert native['reported_build'] == native['reported_run'] == 'PASS'
assert native['reported_counts']['COMPILED_MODULES'] == 2
assert native['reported_counts']['FROZEN_REUSED_MODULES'] == 91
assert native['reported_final_audit_declarations'] == 394
assert native['reported_sorryax'] == 'NONE'
assert native['reported_formal_closure'] == native['reported_finite_checker_soundness'] == native['reported_finite_checker_equivalence'] == 'OPEN'
status = read_json(OUT / 'STATUS.json')
assert status['formal_closure'] == status['finite_checker_equivalence'] == 'OPEN'
assert status['changed_lean_source_files'] == status['changed_proof_bodies'] == []

runner = (OUT / 'tools/native_runner.js').read_bytes()
assert runner.replace(OUT.name.encode(), BASE.name.encode(), 1).replace(NEW_RUNNER.encode(), OLD_RUNNER.encode(), 1) == (BASE / 'tools/native_runner.js').read_bytes()
assert (OUT / 'runner-version.txt').read_text().strip() == NEW_RUNNER
allowed_changes = {
    'tools/native_runner.js', 'runner-version.txt', 'STATUS.json', 'CHECKPOINT.json',
    'README.md', 'OPEN_OBLIGATIONS.txt', 'RUNNER_NOTES.txt', 'DECLARATIONS.json',
    'PROVENANCE.json', 'STATIC_REVIEW.json', 'RUNNER_LOGIC_VALIDATION.json', 'SHA256SUMS.txt',
}
preserved = []
for p in sorted(BASE.rglob('*')):
    if p.is_file():
        rel = p.relative_to(BASE).as_posix()
        assert (OUT / rel).is_file()
        if rel not in allowed_changes:
            assert p.read_bytes() == (OUT / rel).read_bytes(), rel
            preserved.append({'path': rel, 'sha256': sha(p), 'bytes': p.stat().st_size})
dump(EV / 'PRESERVED_PRIOR_FILES.json', {'count': len(preserved), 'files': preserved})

dump(OUT / 'RUNNER_LOGIC_VALIDATION.json', {
    'schema': 'RH_HILBERT_V0221_RUNTIME_IDENTITY_REVIEW_V1',
    'status': 'STATIC_ONLY_NO_NEW_NATIVE_OR_RUNTIME_EXECUTION',
    'runner_sha256': sha(OUT / 'tools/native_runner.js'),
    'baseline_runner_sha256': sha(BASE / 'tools/native_runner.js'),
    'changes': 'TWO_PACKAGE_AND_VERSION_CONSTANTS_ONLY',
    'normalized_exact_raw_byte_comparison': 'MATCH',
    'node_syntax_check': 'PASSED; NO_RUNNER_OR_WINDOWS_API_EXECUTION',
    'cache_compile_flags_scheduling_hashing_locks_shutdown': 'EXACT_BASELINE_LOGIC_PRESERVED',
    'launcher_and_native_helpers': 'EXACT_BYTES_PRESERVED',
    'prior_native_evidence': 'USER_SUPPLIED_V0_2_20_RUN_PASS',
    'candidate_native_execution': 'NOT_PERFORMED',
    'lean_execution': False, 'lake_execution': False, 'ci_execution': False,
    'new_axiom_audit_execution': False, 'new_runtime_mock_execution': False,
    'integration_review': EVREL + '/INTEGRATION_REVIEW.json',
    'integration_review_sha256': sha(EV / 'INTEGRATION_REVIEW.json'),
})
dump(OUT / 'STATIC_REVIEW.json', {
    'schema': 'RH_HILBERT_V0221_EVIDENCE_CHECKPOINT_STATIC_REVIEW_V1',
    'status': 'STATIC_SOURCE_AND_EVIDENCE_CHECKS_ONLY',
    'package': OUT.name, 'revision': 'EVIDENCE_ONLY_NOT_INIT',
    'total_lean_sources': 96, 'inherited_lean_sources_byte_preserved': 96,
    'changed_added_or_deleted_lean_sources': [], 'changed_proof_bodies': [],
    'ordinary_modules': 92, 'active_modules': 93, 'audit_targets': 394,
    'compile_and_audit_manifests': 'BYTE_PRESERVED',
    'aggregate_reaches_all_ordinary_modules': True, 'import_topology': 'CHECKED',
    'source_invalidation_cone': [],
    'expected_reuse_if_every_anchor_validates': 93,
    'expected_source_driven_compilation_tasks': 0, 'expected_counts_are_observed': False,
    'declaration_inventory_records': 1129,
    'selected_records_updated_from_reported_aggregate_pass': 394,
    'explicit_axiom_outputs_in_supplied_tail': 14, 'unselected_records_preserved': 735,
    'reported_previous_run_counts': {'compiled': 2, 'reused': 91},
    'runner_change': 'TWO_IDENTITY_CONSTANTS_ONLY',
    'source_interpretation': EVREL + '/SEMANTIC_ENDPOINT_REVIEW.json',
    'integration_review': EVREL + '/INTEGRATION_REVIEW.json',
    'integration_review_sha256': sha(EV / 'INTEGRATION_REVIEW.json'),
    'finite_checker_soundness': 'OPEN', 'finite_checker_equivalence': 'OPEN', 'formal_closure': 'OPEN',
    'native_receipt_contents_inspected': False, 'new_lean_or_native_execution': False,
    'new_native_axiom_audit': False, 'new_runtime_tests': False,
    'node_syntax_check_only': True, 'preserved_nonmetadata_parent_files': len(preserved),
})
dump(OUT / 'PROVENANCE.json', {
    'package': OUT.name, 'prepared_at_utc': datetime.now(timezone.utc).isoformat(),
    'branch': 'RH_HILBERT_LIMIT / Hilbert.vector', 'mode': 'A_TIER_LEAN', 'target': 'LOCAL_COMPILER',
    'revision_kind': 'EVIDENCE_ONLY_NOT_INIT',
    'parent_package': BASE.name, 'parent_zip_sha256': sha(BASE.with_suffix('.zip')),
    'parent_library_file_id': 'libfile_48346676be6481919f67e8f904a3bd73', 'parent_library_version': 23,
    'user_evidence': EVREL + '/USER_NATIVE_V0220_PASS_TAIL.txt',
    'evidence_interpretation': EVREL + '/USER_REPORTED_NATIVE_PASS.json',
    'all_lean_sources_byte_preserved': 96,
    'frozen_source_manifest': EVREL + '/FROZEN_SOURCE_MANIFEST.json',
    'source_interpretation': EVREL + '/SEMANTIC_ENDPOINT_REVIEW.json',
    'runner_sha256': sha(OUT / 'tools/native_runner.js'), 'runtime_policy_changes': False,
    'retained_goal': '(exists W : FiniteWitness, check W = true) iff _root_.RiemannHypothesis',
    'reported_audited_semantic_endpoint': '(exists W : CancellationBudget, W.Admissible) iff _root_.RiemannHypothesis',
    'scope_limitation': 'UNIVERSAL_ADMISSIBILITY_IS_NOT_FINITE_CHECKER_ACCEPTANCE',
    'formal_closure': 'OPEN', 'new_native_or_lean_execution': False,
    'direct_native_receipt_inspection': False, 'new_runtime_tests': False,
    'evidence_sha256': {p.relative_to(EV).as_posix(): sha(p) for p in sorted(EV.rglob('*')) if p.is_file()},
})

files = sorted(p for p in OUT.rglob('*') if p.is_file())
assert all(not p.is_symlink() for p in files)
assert not any(p.suffix in {'.olean', '.ilean'} for p in files)
payload = [p for p in files if p != OUT / 'SHA256SUMS.txt']
manifest = ''.join(sha(p) + '  ' + p.relative_to(OUT).as_posix() + '\n' for p in payload)
(OUT / 'SHA256SUMS.txt').write_text(manifest, encoding='utf-8')
files = sorted(p for p in OUT.rglob('*') if p.is_file())
assert len(files) == len(payload) + 1
with zipfile.ZipFile(ZIP, 'w', compression=zipfile.ZIP_DEFLATED, compresslevel=9) as z:
    for p in files:
        z.write(p, OUT.name + '/' + p.relative_to(OUT).as_posix())
with zipfile.ZipFile(ZIP) as z:
    assert z.testzip() is None
    names = z.namelist()
    assert len(names) == len(set(names)) == len(files)
    assert all(n.startswith(OUT.name + '/') and '..' not in Path(n).parts for n in names)
    assert {n.split('/')[0] for n in names} == {OUT.name}
    for p in files:
        assert z.read(OUT.name + '/' + p.relative_to(OUT).as_posix()) == p.read_bytes()
    for line in manifest.splitlines():
        h, rel = line.split('  ', 1)
        assert hashlib.sha256(z.read(OUT.name + '/' + rel)).hexdigest() == h
verification = {
    'archive': str(ZIP), 'filename': ZIP.name, 'sha256': sha(ZIP),
    'bytes': ZIP.stat().st_size, 'members': len(files), 'payload_hashes': len(payload),
    'zip_crc': 'VERIFIED', 'payload_sha256': 'VERIFIED', 'single_root': OUT.name,
    'lean_sources_preserved': 96, 'lean_sources_changed': [],
    'selected_audit_declarations': 394, 'explicit_user_axiom_outputs': 14,
    'compiled_or_axiom_audited_here': False,
    'reported_parent_native_run': 'PASS', 'reported_parent_counts': {'compiled': 2, 'reused': 91},
    'finite_checker_soundness': 'OPEN', 'formal_closure': 'OPEN',
    'run_command': (WORK / 'RUN_COMMAND.txt').read_text().strip(),
}
dump(WORK / 'ZIP_VERIFIED.json', verification)
print(json.dumps(verification, indent=2))
