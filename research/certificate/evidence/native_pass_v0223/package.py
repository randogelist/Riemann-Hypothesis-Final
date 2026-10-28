from pathlib import Path
from datetime import datetime, timezone
import hashlib
import json
import shutil
import zipfile

ROOT = Path('/workspace/scratch/f128c1434505')
WORK = ROOT / 'tmp/native_pass_v0223'
BASE = ROOT / 'output/RH_HILBERT_LIMIT_LEAN_v0_2_22_construction'
OUT = ROOT / 'output/RH_HILBERT_LIMIT_LEAN_v0_2_23_construction'
EVREL = 'evidence/native_pass_v0223'
EV = OUT / EVREL
ZIP = OUT.with_suffix('.zip')
OLD_RUNNER = 'RH_HILBERT_NATIVE_RUNNER_v0_2_22_RELATIVE_SHUTDOWN_RECHECK'
NEW_RUNNER = 'RH_HILBERT_NATIVE_RUNNER_v0_2_23_NATIVE_REUSE_PASS_CHECKPOINT'


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
identity = read_json(WORK / 'RUNTIME_IDENTITY_REVIEW.json')
assert not review['blockers']
assert review['runner_sha256'] == identity['runner_sha256'] == assembly['runner_sha256'] == sha(OUT / 'tools/native_runner.js')
assert identity['status'] == 'STATIC_SYNTAX_AND_NORMALIZED_BYTE_IDENTITY_PASS'
shutil.copyfile(WORK / 'review/INTEGRATION_REVIEW.json', EV / 'INTEGRATION_REVIEW.json')
shutil.copyfile(WORK / 'RUNTIME_IDENTITY_REVIEW.json', EV / 'RUNTIME_IDENTITY_REVIEW.json')
shutil.copyfile(Path(__file__), EV / 'package.py')

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
assert len(lines(OUT / 'compile-order.txt')) == 92
assert len(lines(OUT / 'audit-targets.tsv')) == 394
assert len(lines(OUT / 'mathlib-imports.txt')) == 91
assert (OUT / 'final-audit.txt').read_text().strip() == 'CancellationAudit.lean'
runner = (OUT / 'tools/native_runner.js').read_bytes()
assert runner.count(OUT.name.encode()) == runner.count(NEW_RUNNER.encode()) == 1
assert runner.replace(OUT.name.encode(), BASE.name.encode(), 1).replace(NEW_RUNNER.encode(), OLD_RUNNER.encode(), 1) == (BASE / 'tools/native_runner.js').read_bytes()
assert (OUT / 'runner-version.txt').read_text().strip() == NEW_RUNNER

native = read_json(EV / 'USER_REPORTED_NATIVE_PASS.json')
assert native['reported_build'] == native['reported_run'] == 'PASS'
assert native['reported_counts']['COMPILED_MODULES'] == 0 and native['reported_counts']['FROZEN_REUSED_MODULES'] == 93
assert native['reported_final_audit_declarations'] == 394 and native['reported_final_audit_state'] == 'FROZEN_REUSED'
assert native['explicitly_printed_axiom_declarations'] == 0
assert native['reported_sorryax'] == 'NONE'
assert native['reported_formal_closure'] == native['reported_finite_checker_equivalence'] == native['reported_finite_checker_soundness'] == 'OPEN'
assert (EV / 'USER_NATIVE_V0222_PASS_TAIL.txt').read_bytes() == (WORK / 'USER_NATIVE_V0222_PASS_TAIL.txt').read_bytes()
assert sha(EV / 'USER_NATIVE_V0222_PASS_TAIL.txt') == native['source_sha256']
status = read_json(OUT / 'STATUS.json')
checkpoint = read_json(OUT / 'CHECKPOINT.json')
for key in ['latest_user_native_evidence', 'latest_user_successful_full_native_evidence', 'latest_successful_full_run']:
    assert status[key] == native
assert checkpoint['latest_user_run'] == checkpoint['latest_successful_full_run'] == native
assert status['prior_explicit_endpoint_axiom_evidence'] == checkpoint['prior_explicit_endpoint_axiom_evidence']
assert checkpoint['prior_explicit_endpoint_axiom_evidence'] == read_json(BASE / 'CHECKPOINT.json')['latest_successful_full_run']
assert checkpoint['prior_explicit_endpoint_axiom_evidence']['explicitly_printed_axiom_declarations'] == 14
assert status['formal_closure'] == status['finite_checker_equivalence'] == 'OPEN'
assert status['changed_lean_source_files'] == status['changed_proof_bodies'] == []
assert status['selected_inventory_records_updated'] == 0
assert not status['new_runtime_mocks_run'] and not checkpoint['new_runtime_test_execution']
assert not checkpoint['changed_runtime_policy'] and not checkpoint['new_native_or_lean_execution']
assert status['shutdown_inventory_recheck'] == read_json(BASE / 'STATUS.json')['shutdown_inventory_recheck']

allowed_changes = {
    'tools/native_runner.js', 'runner-version.txt', 'STATUS.json', 'CHECKPOINT.json',
    'README.md', 'OPEN_OBLIGATIONS.txt', 'RUNNER_NOTES.txt',
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
    'schema': 'RH_HILBERT_V0223_RUNTIME_IDENTITY_REVIEW_V1',
    'status': 'STATIC_IDENTITY_CHECKS_ONLY; NO_NEW_NATIVE_OR_RUNTIME_EXECUTION',
    'runner_sha256': sha(OUT / 'tools/native_runner.js'), 'baseline_runner_sha256': sha(BASE / 'tools/native_runner.js'),
    'changes': 'TWO_PACKAGE_AND_VERSION_CONSTANTS_ONLY',
    'normalized_exact_raw_byte_comparison': 'MATCH', 'node_syntax_check': 'PASS',
    'whole_runner_entrypoint_executed': False,
    'cache_compile_audit_scheduling_memory_lock_shutdown_logic': 'EXACT_BASELINE_PRESERVED',
    'launcher_and_native_helpers': 'EXACT_BYTES_PRESERVED',
    'parent_native_evidence': EVREL + '/USER_REPORTED_NATIVE_PASS.json',
    'parent_native_evidence_scope': 'USER_REPORTED_V0222_RUN_PASS; STANDARD_AXIOM_AUDIT_FROZEN_REUSED',
    'native_runtime_paths_observed': 'INITIAL_INVENTORY; EXACT_ABSENCE_OF_TWO_UNREADABLE_CERTUTIL_ROWS; EXISTING_ADMITTED_HOST',
    'native_relative_host_exit_barrier_observed': False,
    'prior_mock_report': 'evidence/relative_shutdown_v0222/tests/mock_report.json',
    'prior_mock_report_scope': '20_PASS_0_FAIL_BOUND_TO_PARENT_V0222_RUNNER; NOT_RERUN_OR_RELABELED',
    'candidate_native_execution': 'NOT_PERFORMED',
    'lean_execution': False, 'lake_execution': False, 'ci_execution': False,
    'new_axiom_audit_execution': False, 'new_runtime_mock_execution': False,
    'integration_review': EVREL + '/INTEGRATION_REVIEW.json',
    'integration_review_sha256': sha(EV / 'INTEGRATION_REVIEW.json'),
})
dump(OUT / 'STATIC_REVIEW.json', {
    'schema': 'RH_HILBERT_V0223_REUSE_PASS_CHECKPOINT_STATIC_REVIEW_V1',
    'status': 'STATIC_SOURCE_AND_EVIDENCE_CHECKS_PASSED',
    'package': OUT.name, 'revision': 'EVIDENCE_ONLY_NOT_INIT',
    'total_lean_sources': 96, 'inherited_lean_sources_byte_preserved': 96,
    'changed_added_or_deleted_lean_sources': [], 'changed_proof_bodies': [],
    'ordinary_modules': 92, 'active_modules': 93, 'audit_targets': 394,
    'compile_and_audit_manifests': 'BYTE_PRESERVED',
    'import_topology': 'PARENT_VERIFICATION_RETAINED_WITH_EXACT_SOURCE_AND_MANIFEST_BYTES',
    'source_invalidation_cone': [], 'expected_reuse_if_every_anchor_validates': 93,
    'expected_source_driven_compilation_tasks': 0, 'expected_counts_are_observed_for_candidate': False,
    'declaration_inventory_records_byte_preserved': 1129, 'selected_records_updated': 0,
    'explicit_axiom_outputs_in_latest_tail': 0, 'prior_v0220_explicit_axiom_outputs_preserved': 14,
    'reported_latest_native_run': 'V0_2_22_PASS', 'reported_latest_counts': {'compiled': 0, 'reused': 93},
    'reported_final_audit_state': 'FROZEN_REUSED; AGGREGATE_STANDARD_AXIOMS_PASS; SORRYAX_NONE',
    'semantic_forward_and_equivalence': 'PRIOR_EXPLICIT_NATIVE_AXIOMS_AND_LATEST_REUSED_AGGREGATE_PASS_PRESERVED',
    'finite_checker_soundness': 'OPEN', 'finite_checker_equivalence': 'OPEN', 'formal_closure': 'OPEN',
    'native_receipt_contents_inspected': False, 'new_lean_or_native_execution': False,
    'new_native_axiom_audit': False, 'new_runtime_tests': False,
    'runner_changes': 'TWO_IDENTITY_CONSTANTS_ONLY', 'preserved_nonmetadata_parent_files': len(preserved),
})
dump(OUT / 'PROVENANCE.json', {
    'package': OUT.name, 'prepared_at_utc': datetime.now(timezone.utc).isoformat(),
    'branch': 'RH_HILBERT_LIMIT / Hilbert.vector', 'mode': 'A_TIER_LEAN', 'target': 'LOCAL_COMPILER',
    'revision_kind': 'EVIDENCE_ONLY_NOT_INIT',
    'parent_package': BASE.name, 'parent_zip_sha256': sha(BASE.with_suffix('.zip')),
    'parent_library_file_id': 'libfile_48346676be6481919f67e8f904a3bd73', 'parent_library_version': 25,
    'user_evidence': native['source'], 'evidence_interpretation': EVREL + '/USER_REPORTED_NATIVE_PASS.json',
    'all_lean_sources_byte_preserved': 96, 'declaration_inventory_records_byte_preserved': 1129,
    'frozen_source_manifest': EVREL + '/FROZEN_SOURCE_MANIFEST.json',
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
    'selected_audit_declarations': 394, 'declaration_inventory_preserved': 1129,
    'runner_sha256': sha(OUT / 'tools/native_runner.js'),
    'compiled_or_axiom_audited_here': False, 'new_runtime_mocks': False,
    'candidate_native_run': 'NOT_RUN', 'reported_parent_native_run': 'PASS',
    'reported_parent_module_counts': {'compiled': 0, 'reused': 93},
    'finite_checker_soundness': 'OPEN', 'formal_closure': 'OPEN',
    'run_command': (WORK / 'RUN_COMMAND.txt').read_text().strip(),
}
dump(WORK / 'ZIP_VERIFIED.json', verification)
print(json.dumps(verification, indent=2))
