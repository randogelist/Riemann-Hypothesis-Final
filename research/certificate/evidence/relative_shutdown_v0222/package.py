from pathlib import Path
from datetime import datetime, timezone
import hashlib
import json
import re
import shutil
import zipfile

ROOT = Path('/workspace/scratch/f128c1434505')
WORK = ROOT / 'tmp/relative_shutdown_v0222'
BASE = ROOT / 'output/RH_HILBERT_LIMIT_LEAN_v0_2_21_construction'
OUT = ROOT / 'output/RH_HILBERT_LIMIT_LEAN_v0_2_22_construction'
EVREL = 'evidence/relative_shutdown_v0222'
EV = OUT / EVREL
ZIP = OUT.with_suffix('.zip')
RUNNER_SHA = '8fc5a81e3802a52e3ec12fa2c94177a42b59b202a83b66c9609ea1356889e907'


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


assert sha(OUT / 'tools/native_runner.js') == RUNNER_SHA
assert (OUT / 'runner-version.txt').read_text().strip() == 'RH_HILBERT_NATIVE_RUNNER_v0_2_22_RELATIVE_SHUTDOWN_RECHECK'
review = read_json(WORK / 'review/INDEPENDENT_SAFETY_REVIEW.json')
protected = read_json(WORK / 'review/INDEPENDENT_PROTECTED_FUNCTIONS.json')
integration = read_json(WORK / 'review/INTEGRATION_REVIEW.json')
assert review['candidate_sha256'] == protected['candidate_sha256'] == RUNNER_SHA
assert review['verdict'] == 'STATIC_REVIEW_NO_BLOCKER_FOUND' and not review['blocking_findings']
assert not integration['blockers'] and integration['runner_sha256'] == RUNNER_SHA
assert protected['unchanged_existing_function_count'] == 163
assert set(protected['changed_existing_functions']) == {'assertNoLockWorkers', 'parallelAssertShutdownInventory'}
assert set(protected['added_functions']) == {'lockSimpleWshScriptArgument', 'relativeLockWorkerDetails', 'relativeLockWorkerError'}
assert not protected['removed_functions']
for p in sorted((WORK / 'review').iterdir()):
    if p.is_file():
        shutil.copyfile(p, EV / p.name)
shutil.copyfile(Path(__file__), EV / 'package.py')

mock = read_json(EV / 'tests/mock_report.json')
assert mock['runner_sha256'] == RUNNER_SHA and mock['status'] == 'PASS'
assert mock['passed'] == 20 and mock['failed'] == 0
assert len(mock['cases']) == 20 and all(c['outcome'] == 'PASS' for c in mock['cases'])
assert sha(EV / 'tests/mock_report.json') == '490d5a79124ca558eadb229b14ee77a5cdbad47c21bcb74b427f71d0ba83b0ee'
for p in (WORK / 'tests').iterdir():
    if p.is_file():
        assert p.read_bytes() == (EV / 'tests' / p.name).read_bytes()

old_lean = sorted(p.relative_to(BASE).as_posix() for p in BASE.rglob('*.lean'))
new_lean = sorted(p.relative_to(OUT).as_posix() for p in OUT.rglob('*.lean'))
assert old_lean == new_lean and len(old_lean) == 96
for rel in old_lean:
    assert (BASE / rel).read_bytes() == (OUT / rel).read_bytes(), rel
for rel in ['compile-order.txt', 'final-audit.txt', 'audit-targets.tsv', 'mathlib-imports.txt',
            'run.cmd', 'lean-toolchain', 'DECLARATIONS.json', 'tools/follow_active.js',
            'tools/NativeSha256.cs', 'tools/NativeRamWarm.cs']:
    assert (OUT / rel).read_bytes() == (BASE / rel).read_bytes(), rel
assert len(read_json(OUT / 'DECLARATIONS.json')) == 1129
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
assert len(lines(OUT / 'mathlib-imports.txt')) == 91

status = read_json(OUT / 'STATUS.json')
checkpoint = read_json(OUT / 'CHECKPOINT.json')
native = read_json(EV / 'USER_REPORTED_NATIVE_FAILURE.json')
assert native['reported_build'] == native['reported_run'] == 'FAIL'
assert native['reported_failed_stage'] == 'WORKER_SHUTDOWN'
assert native['aggregate_module_summary_counts'] is None
assert status['latest_user_native_evidence'] == checkpoint['latest_user_run'] == native
assert checkpoint['latest_successful_full_run'] == read_json(BASE / 'CHECKPOINT.json')['latest_successful_full_run']
assert status['formal_closure'] == status['finite_checker_equivalence'] == 'OPEN'
assert status['changed_lean_source_files'] == status['changed_proof_bodies'] == []
assert status['selected_inventory_records_updated'] == 0
assert checkpoint['new_native_or_lean_execution'] is False
assert status['local_lean_executed'] is status['native_windows_execution_by_assistant'] is False
assert status['new_runtime_mocks_run'] is True

allowed_changes = {
    'tools/native_runner.js', 'runner-version.txt', 'STATUS.json', 'CHECKPOINT.json',
    'README.md', 'OPEN_OBLIGATIONS.txt', 'RUNNER_NOTES.txt',
    'PROVENANCE.json', 'STATIC_REVIEW.json', 'RUNNER_LOGIC_VALIDATION.json', 'SHA256SUMS.txt',
}
preserved = []
changed = []
for p in sorted(BASE.rglob('*')):
    if p.is_file():
        rel = p.relative_to(BASE).as_posix()
        assert (OUT / rel).is_file()
        if rel not in allowed_changes:
            assert p.read_bytes() == (OUT / rel).read_bytes(), rel
            preserved.append({'path': rel, 'sha256': sha(p), 'bytes': p.stat().st_size})
        elif p.read_bytes() != (OUT / rel).read_bytes():
            changed.append(rel)
dump(EV / 'PRESERVED_PRIOR_FILES.json', {'count': len(preserved), 'files': preserved})

dump(OUT / 'RUNNER_LOGIC_VALIDATION.json', {
    'schema': 'RH_HILBERT_V0222_SOURCE_BOUND_SIMULATED_RUNTIME_VALIDATION_V1',
    'status': '20_FOCUSED_NODE_VM_TESTS_PASS; INDEPENDENT_STATIC_REVIEW_NO_BLOCKERS; NATIVE_NOT_RUN',
    'runner_sha256': RUNNER_SHA, 'baseline_runner_sha256': sha(BASE / 'tools/native_runner.js'),
    'modified_existing_functions': protected['changed_existing_functions'],
    'added_functions': protected['added_functions'], 'unchanged_existing_functions': 163,
    'launcher_and_native_helpers': 'EXACT_BYTES_PRESERVED',
    'cache_hashing_compiler_audit_memory_and_admission_functions': 'EXACT_BYTES_PRESERVED',
    'node_syntax_check': 'PASSED; NO_RUNNER_ENTRYPOINT_EXECUTION',
    'focused_test_report': EVREL + '/tests/mock_report.json',
    'focused_test_report_sha256': sha(EV / 'tests/mock_report.json'),
    'focused_tests_passed': 20, 'focused_tests_failed': 0,
    'test_scope': 'ACTUAL_FUNCTIONS_IN_NODE_VM_WITH_SYNTHETIC_WMI_SHELL_FILES_AND_CLOCK',
    'candidate_native_execution': 'NOT_PERFORMED',
    'lean_execution': False, 'lake_execution': False, 'ci_execution': False,
    'new_axiom_audit_execution': False, 'csharp_execution_or_compilation': False,
    'independent_source_review': EVREL + '/INDEPENDENT_SAFETY_REVIEW.json',
    'independent_source_review_sha256': sha(EV / 'INDEPENDENT_SAFETY_REVIEW.json'),
    'integration_review': EVREL + '/INTEGRATION_REVIEW.json',
    'integration_review_sha256': sha(EV / 'INTEGRATION_REVIEW.json'),
    'limitations': mock['limitations'],
})
dump(OUT / 'STATIC_REVIEW.json', {
    'schema': 'RH_HILBERT_V0222_RUNTIME_REPAIR_STATIC_REVIEW_V1',
    'status': 'SOURCE_PRESERVATION_AND_EVIDENCE_CHECKS_PASSED',
    'package': OUT.name, 'revision': 'RUNTIME_ONLY_NOT_INIT',
    'total_lean_sources': 96, 'inherited_lean_sources_byte_preserved': 96,
    'changed_added_or_deleted_lean_sources': [], 'changed_proof_bodies': [],
    'ordinary_modules': 92, 'active_modules': 93, 'audit_targets': 394,
    'compile_and_audit_manifests': 'BYTE_PRESERVED',
    'aggregate_reaches_all_ordinary_modules': True, 'import_topology': 'CHECKED',
    'source_invalidation_cone': [], 'expected_reuse_if_every_anchor_validates': 93,
    'expected_source_driven_compilation_tasks': 0, 'expected_counts_are_observed': False,
    'declaration_inventory_records_byte_preserved': 1129,
    'selected_records_updated': 0, 'explicit_axiom_outputs_in_latest_excerpt': 0,
    'reported_latest_run': 'FAIL_AT_WORKER_SHUTDOWN_AFTER_REUSED_FINAL_AUDIT',
    'reported_latest_aggregate_module_counts': None,
    'reported_last_complete_run': 'V0_2_20_PASS',
    'semantic_forward_and_equivalence': 'PRIOR_USER_NATIVE_AXIOM_AUDIT_PASS_PRESERVED',
    'finite_checker_soundness': 'OPEN', 'finite_checker_equivalence': 'OPEN', 'formal_closure': 'OPEN',
    'native_receipt_contents_inspected': False, 'new_lean_or_native_execution': False,
    'new_native_axiom_audit': False, 'new_runtime_tests': '20_PASS_0_FAIL_NODE_VM_SYNTHETIC_HOST_ONLY',
    'preserved_nonmetadata_parent_files': len(preserved),
})
dump(OUT / 'PROVENANCE.json', {
    'package': OUT.name, 'prepared_at_utc': datetime.now(timezone.utc).isoformat(),
    'branch': 'RH_HILBERT_LIMIT / Hilbert.vector', 'mode': 'A_TIER_LEAN', 'target': 'LOCAL_COMPILER',
    'revision_kind': 'RUNTIME_ONLY_NOT_INIT',
    'parent_package': BASE.name, 'parent_zip_sha256': sha(BASE.with_suffix('.zip')),
    'parent_library_file_id': 'libfile_48346676be6481919f67e8f904a3bd73', 'parent_library_version': 24,
    'user_evidence': native['source'], 'evidence_interpretation': EVREL + '/USER_REPORTED_NATIVE_FAILURE.json',
    'all_lean_sources_byte_preserved': 96,
    'frozen_source_manifest': EVREL + '/FROZEN_SOURCE_MANIFEST.json',
    'runner_sha256': RUNNER_SHA, 'runtime_policy_changes': True,
    'retained_goal': '(exists W : FiniteWitness, check W = true) iff _root_.RiemannHypothesis',
    'reported_audited_semantic_endpoint': '(exists W : CancellationBudget, W.Admissible) iff _root_.RiemannHypothesis',
    'scope_limitation': 'UNIVERSAL_ADMISSIBILITY_IS_NOT_FINITE_CHECKER_ACCEPTANCE',
    'formal_closure': 'OPEN', 'new_native_or_lean_execution': False,
    'direct_native_receipt_inspection': False,
    'new_runtime_tests': '20_PASS_0_FAIL_NODE_VM_SYNTHETIC_HOST_ONLY',
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
    'selected_audit_declarations': 394, 'declaration_inventory_preserved': 1129,
    'runner_sha256': RUNNER_SHA, 'simulated_runtime_tests': {'passed': 20, 'failed': 0},
    'compiled_or_axiom_audited_here': False, 'candidate_native_run': 'NOT_RUN',
    'reported_parent_native_run': 'FAIL_AT_WORKER_SHUTDOWN_AFTER_REUSED_AUDIT',
    'reported_latest_aggregate_module_counts': None,
    'finite_checker_soundness': 'OPEN', 'formal_closure': 'OPEN',
    'run_command': (WORK / 'RUN_COMMAND.txt').read_text().strip(),
}
dump(WORK / 'ZIP_VERIFIED.json', verification)
print(json.dumps(verification, indent=2))
