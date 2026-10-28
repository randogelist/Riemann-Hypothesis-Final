from pathlib import Path
from datetime import datetime
from zoneinfo import ZoneInfo
import hashlib
import json
import re
import shutil
import zipfile

from assemble import (ROOT, WORK, BASE, OUT, EVREL, EV, NEW, FINAL,
                      OLD_RUNNER, NEW_RUNNER, OLD_MATH, NEW_MATH,
                      sha, write, dump, read_json, lines, clean_source)

ZIP = OUT.with_suffix('.zip')

assembly = read_json(WORK / 'ASSEMBLY.json')
source_review = read_json(WORK / 'review/PROOF_SOURCE_REVIEW.json')
integration_review = read_json(WORK / 'review/INTEGRATION_REVIEW.json')
syntax = read_json(WORK / 'NODE_SYNTAX_CHECK.json')
report_edits = read_json(WORK / 'RUNNER_REPORTING_EDITS.json')
assert not source_review.get('blockers')
assert not integration_review.get('blockers')
assert syntax['exit_code'] == 0
assert syntax['runner_sha256'] == report_edits['runner_sha256'] == assembly['runner_sha256'] == sha(OUT / 'tools/native_runner.js')
assert sha(OUT / 'tools/native_runner.js') in json.dumps(integration_review)
for rel in NEW:
    assert sha(OUT / rel) in json.dumps(source_review), rel
    assert sha(OUT / rel) == assembly['new_source_sha256'][rel]
    assert (OUT / rel).read_bytes() == (WORK / 'proof' / Path(rel).name).read_bytes()

shutil.copyfile(WORK / 'review/PROOF_SOURCE_REVIEW.json', EV / 'SOURCE_REVIEW.json')
shutil.copyfile(WORK / 'review/INTEGRATION_REVIEW.json', EV / 'INTEGRATION_REVIEW.json')
shutil.copyfile(WORK / 'NODE_SYNTAX_CHECK.json', EV / 'NODE_SYNTAX_CHECK.json')
shutil.copyfile(WORK / 'RUNNER_REPORTING_EDITS.json', EV / 'RUNNER_REPORTING_EDITS.json')
if (WORK / 'proof/FIRST_MOMENT_SOURCE_REVIEW.json').is_file():
    shutil.copyfile(WORK / 'proof/FIRST_MOMENT_SOURCE_REVIEW.json', EV / 'AUTHOR_SOURCE_REVIEW.json')
shutil.copyfile(Path(__file__), EV / 'package.py')

old_lean = sorted(p.relative_to(BASE).as_posix() for p in BASE.rglob('*.lean'))
new_lean = sorted(p.relative_to(OUT).as_posix() for p in OUT.rglob('*.lean'))
assert len(old_lean) == 96 and len(new_lean) == 99
assert sorted(set(new_lean) - set(old_lean)) == sorted(NEW + [FINAL])
for rel in old_lean:
    assert (BASE / rel).read_bytes() == (OUT / rel).read_bytes(), rel
for rel in ['run.cmd', 'lean-toolchain', 'mathlib-imports.txt',
            'tools/follow_active.js', 'tools/NativeSha256.cs', 'tools/NativeRamWarm.cs']:
    assert (OUT / rel).read_bytes() == (BASE / rel).read_bytes(), rel
old_decls = read_json(BASE / 'DECLARATIONS.json')
new_decls = read_json(OUT / 'DECLARATIONS.json')
assert len(new_decls) == 1163 and len(old_decls) == 1129
assert new_decls[:1129] == old_decls
assert len(lines(OUT / 'compile-order.txt')) == 94
assert lines(OUT / 'compile-order.txt') == lines(BASE / 'compile-order.txt') + NEW
assert len(lines(OUT / 'audit-targets.tsv')) == 428
assert lines(OUT / 'audit-targets.tsv')[:394] == lines(BASE / 'audit-targets.tsv')
assert (OUT / 'final-audit.txt').read_text().strip() == FINAL
assert len(lines(OUT / 'mathlib-imports.txt')) == 91
targets = [row.split('|')[1] for row in lines(OUT / 'audit-targets.tsv')]
audit = clean_source((OUT / FINAL).read_text())
assert re.findall(r'^#check ([A-Za-z_][A-Za-z0-9_.]*)$', audit, re.M) == targets
assert re.findall(r'^#print axioms ([A-Za-z_][A-Za-z0-9_.]*)$', audit, re.M) == targets
assert len(targets) == len(set(targets))
for d in new_decls[1129:]:
    assert d['status'] == 'NATIVE_AUDIT_PENDING'
    assert d['source_sha256'] == sha(OUT / d['source'])
    assert d['module'] + '|' + d['name'] in lines(OUT / 'audit-targets.tsv')

runner = (OUT / 'tools/native_runner.js').read_bytes()
normalized = runner.replace(OUT.name.encode(), BASE.name.encode(), 1).replace(NEW_RUNNER.encode(), OLD_RUNNER.encode(), 1)
normalized = normalized.replace(NEW_MATH.encode(), OLD_MATH.encode())
normalized = normalized.replace(report_edits['json_addition'].encode(), b'', 1)
normalized = normalized.replace(report_edits['log_addition'].encode(), b'', 1)
assert normalized == (BASE / 'tools/native_runner.js').read_bytes()
assert (OUT / 'runner-version.txt').read_text().strip() == NEW_RUNNER

status = read_json(OUT / 'STATUS.json')
checkpoint = read_json(OUT / 'CHECKPOINT.json')
native = read_json(EV / 'USER_REPORTED_NATIVE_PASS.json')
assert native['reported_package'] == BASE.name
assert native['reported_run'] == native['reported_build'] == 'PASS'
assert native['reported_counts']['COMPILED_MODULES'] == 0
assert native['reported_counts']['FROZEN_REUSED_MODULES'] == 93
assert native['reported_final_audit_declarations'] == 394
assert native['explicitly_printed_axiom_declarations'] == 0
assert native['reported_sorryax'] == 'NONE'
assert sha(EV / 'USER_NATIVE_V0223_PASS_EXCERPT.txt') == native['source_sha256']
assert status['latest_user_native_evidence'] == status['latest_successful_full_run'] == native
assert checkpoint['latest_user_run'] == native
assert status['selected_candidate_admissibility'] == status['formal_closure'] == status['finite_checker_equivalence'] == 'OPEN'
assert not status['first_refinement_verified_here']
assert status['unconditional_rh'] == 'NOT_ESTABLISHED'
assert status['accepted_finite_witness'] is None
assert not status['assistant_lean_native_or_ci_execution']
assert checkpoint['current_native_execution'] == 'NOT_RUN'
assert status['prior_explicit_endpoint_axiom_evidence'] == read_json(BASE / 'STATUS.json')['prior_explicit_endpoint_axiom_evidence']

allowed_changes = {
    'tools/native_runner.js', 'runner-version.txt', 'STATUS.json', 'CHECKPOINT.json',
    'README.md', 'OPEN_OBLIGATIONS.txt', 'RUNNER_NOTES.txt', 'DECLARATIONS.json',
    'compile-order.txt', 'audit-targets.tsv', 'final-audit.txt',
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
    'schema': 'RH_HILBERT_V0224_REPORTING_ONLY_REVIEW_V1',
    'status': 'STATIC_SYNTAX_AND_NORMALIZED_EXECUTION_LOGIC_IDENTITY_VERIFIED',
    'runner_sha256': sha(OUT / 'tools/native_runner.js'),
    'baseline_runner_sha256': sha(BASE / 'tools/native_runner.js'),
    'changes': report_edits['changes'], 'normalized_exact_raw_bytes_match': True,
    'node_syntax_check': 'PASS', 'whole_runner_entrypoint_executed': False,
    'compile_cache_audit_scheduling_memory_lock_shutdown_decisions': 'BYTE_PRESERVED',
    'launcher_and_native_helpers': 'BYTE_PRESERVED',
    'new_runtime_mocks_run': False, 'native_or_lean_execution': False,
    'historical_mock_report': 'evidence/relative_shutdown_v0222/tests/mock_report.json',
    'historical_mock_scope': 'V0222_SYNTHETIC_HOST_20_PASS_0_FAIL; NOT_NEW_V0224_TESTS',
    'integration_review': EVREL + '/INTEGRATION_REVIEW.json',
    'integration_review_sha256': sha(EV / 'INTEGRATION_REVIEW.json'),
})
dump(OUT / 'STATIC_REVIEW.json', {
    'schema': 'RH_HILBERT_V0224_ZERO_BUDGET_STATIC_REVIEW_V1',
    'status': 'STATIC_SOURCE_REVIEW_AND_PACKAGE_INVARIANTS_VERIFIED; NATIVE_AUDIT_PENDING',
    'package': OUT.name, 'revision_kind': 'ADDITIVE_PROOF_SOURCE_NOT_INIT',
    'all_old_lean_sources_byte_preserved': 96, 'new_lean_sources': NEW + [FINAL],
    'old_declaration_records_preserved': 1129, 'new_public_declarations_selected_for_audit': 34,
    'new_source_sha256': {rel: sha(OUT / rel) for rel in NEW + [FINAL]},
    'ordinary_modules': 94, 'active_modules': 95, 'audit_targets': 428,
    'declaration_inventory_records': 1163, 'direct_mathlib_requirements': 91,
    'import_topology': 'VERIFIED_FROM_COMMENT_STRIPPED_ACTIVE_SOURCES',
    'final_audit_exact_type_and_axiom_output_coverage': '428_SELECTED_TARGETS_EXACTLY_ONCE',
    'expected_frozen_ordinary_reuse_if_valid': 92, 'expected_new_source_driven_tasks': 3,
    'expected_counts_are_observed': False,
    'selected_candidate': {'cutoff': 0, 'coefficient': 0},
    'first_check': 'SOURCE_PROOF_WITHOUT_RH_HYPOTHESIS; NATIVE_AUDIT_PENDING',
    'first_check_is_full_admissibility': False,
    'universal_propagation': 'OPEN', 'universal_admissibility': 'OPEN',
    'finite_checker_soundness': 'OPEN', 'finite_checker_equivalence': 'OPEN', 'formal_closure': 'OPEN',
    'source_review': EVREL + '/SOURCE_REVIEW.json',
    'source_review_sha256': sha(EV / 'SOURCE_REVIEW.json'),
    'latest_reported_native_package': BASE.name, 'latest_reported_native_run': 'PASS',
    'current_native_run': 'NOT_RUN', 'assistant_native_lean_lake_or_ci_execution': False,
    'native_receipt_contents_independently_inspected': False,
    'new_runtime_tests': False,
})
dump(OUT / 'PROVENANCE.json', {
    'package': OUT.name, 'prepared_at': datetime.now(ZoneInfo('Europe/Berlin')).isoformat(),
    'branch': 'RH_HILBERT_LIMIT / Hilbert.vector', 'mode': 'A_TIER_LEAN', 'target': 'LOCAL_COMPILER',
    'revision_kind': 'ADDITIVE_PROOF_SOURCE_NOT_INIT',
    'parent_package': BASE.name, 'parent_zip_sha256': sha(BASE.with_suffix('.zip')),
    'parent_library_file_id': 'libfile_48346676be6481919f67e8f904a3bd73', 'parent_library_version': 26,
    'user_evidence': native['source'], 'user_evidence_scope': native['aggregate_coverage_scope'],
    'all_old_lean_sources_byte_preserved': 96, 'old_declaration_records_preserved': 1129,
    'new_lean_sources': NEW + [FINAL], 'new_public_declarations': 34,
    'runner_sha256': sha(OUT / 'tools/native_runner.js'),
    'retained_goal': '(exists W : FiniteWitness, check W = true) iff _root_.RiemannHypothesis',
    'candidate': {'cutoff': 0, 'coefficient': 0},
    'new_proof_scope': 'EXPLICIT_CANDIDATE_AND_INDEPENDENT_FIRST_CANCELLATION_ROW; SOURCE_ONLY',
    'universal_admissibility': 'OPEN', 'finite_checker_equivalence': 'OPEN', 'formal_closure': 'OPEN',
    'current_native_or_lean_execution': False, 'runtime_policy_changes': False,
    'evidence_sha256': {p.relative_to(EV).as_posix(): sha(p) for p in sorted(EV.rglob('*')) if p.is_file()},
})

files = sorted(p for p in OUT.rglob('*') if p.is_file())
assert all(not p.is_symlink() for p in files)
assert not any(p.suffix in {'.olean', '.ilean'} for p in files)
payload = [p for p in files if p != OUT / 'SHA256SUMS.txt']
manifest = ''.join(sha(p) + '  ' + p.relative_to(OUT).as_posix() + '\n' for p in payload)
write(OUT / 'SHA256SUMS.txt', manifest)
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
    'lean_sources_preserved': 96, 'lean_sources_added': NEW + [FINAL],
    'selected_audit_declarations': 428, 'new_public_declarations': 34,
    'declaration_inventory': 1163, 'runner_sha256': sha(OUT / 'tools/native_runner.js'),
    'compiled_or_axiom_audited_here': False, 'new_runtime_mocks': False,
    'candidate_native_run': 'NOT_RUN', 'reported_parent_native_run': 'PASS',
    'first_cancellation_check': 'SOURCE_PROOF_PREPARED_WITHOUT_RH; NATIVE_AUDIT_PENDING',
    'universal_admissibility': 'OPEN', 'finite_checker_equivalence': 'OPEN', 'formal_closure': 'OPEN',
    'run_command': (WORK / 'RUN_COMMAND.txt').read_text().strip(),
}
dump(WORK / 'ZIP_VERIFIED.json', verification)
print(json.dumps(verification, indent=2))
