from pathlib import Path
from datetime import datetime
from zoneinfo import ZoneInfo
import hashlib
import json
import re
import shutil
import zipfile

ROOT = Path('/workspace/scratch/f128c1434505')
WORK = ROOT / 'tmp/cancellation_v0218'
BASE = ROOT / 'output/RH_HILBERT_LIMIT_LEAN_v0_2_17_construction'
OUT = ROOT / 'output/RH_HILBERT_LIMIT_LEAN_v0_2_18_construction'
EVREL = 'evidence/cancellation_v0218'
EV = OUT / EVREL
ZIP = OUT.with_suffix('.zip')


def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def jread(p):
    return json.loads(p.read_text(encoding='utf-8'))


def dump(p, value):
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(json.dumps(value, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')


def lines(p):
    return [s.strip() for s in p.read_text(encoding='utf-8').splitlines()
            if s.strip() and not s.lstrip().startswith('#')]


assembly = jread(WORK / 'ASSEMBLY.json')
source_review = jread(WORK / 'review/INDEPENDENT_SOURCE_REVIEW.json')
integration = jread(WORK / 'review/FINAL_STATIC_INTEGRATION_REVIEW.json')
assert source_review['status'] == 'SOURCE_REVIEW_ONLY'
assert integration['status'] == 'STATIC_INTEGRATION_REVIEW_ONLY'
assert sha(OUT / 'tools/native_runner.js') == 'e27b634a8625a35d05ede552b3089232097ffdbcbb020ddb881d5b2f34904ccd'
for item in source_review['reviewed_sources']:
    actual = OUT / 'RH_HilbertLimit' / Path(item['path']).name
    assert sha(actual) == item['sha256']
for rel, h in assembly['new_source_sha256'].items():
    assert sha(OUT / rel) == h

for src, dst in [
    (WORK / 'review/INDEPENDENT_SOURCE_REVIEW.json', EV / 'SOURCE_REVIEW.json'),
    (WORK / 'review/FINAL_STATIC_INTEGRATION_REVIEW.json', EV / 'INTEGRATION_REVIEW.json'),
    (WORK / 'assemble.py', EV / 'assemble.py'),
    (Path(__file__), EV / 'package.py'),
    (WORK / 'RUN_COMMAND.txt', EV / 'RUN_COMMAND.txt'),
]:
    shutil.copyfile(src, dst)

old_lean = sorted(p.relative_to(BASE).as_posix() for p in BASE.rglob('*.lean'))
for rel in old_lean:
    assert (OUT / rel).read_bytes() == (BASE / rel).read_bytes(), rel
all_lean = sorted(p.relative_to(OUT).as_posix() for p in OUT.rglob('*.lean'))
assert len(old_lean) == 92 and len(all_lean) == 96
order = lines(OUT / 'compile-order.txt')
old_order = lines(BASE / 'compile-order.txt')
assert len(order) == 92 and order[:89] == old_order and len(set(order)) == 92
module_names = [r[:-5].replace('/', '.') for r in order]
module_pos = {m: i for i, m in enumerate(module_names)}
graph = {}
for i, rel in enumerate(order + ['CancellationAudit.lean']):
    module = rel[:-5].replace('/', '.')
    imports = re.findall(r'^import\s+(\S+)\s*$', (OUT / rel).read_text(), re.M)
    graph[module] = [m for m in imports if m in module_pos]
    for dep in graph[module]:
        assert module_pos[dep] < i, (module, dep)
    for imp in imports:
        local = OUT / (imp.replace('.', '/') + '.lean')
        assert not local.exists() or imp in module_pos, (module, 'unscheduled', imp)
reachable = set()


def visit(m):
    if m in reachable:
        return
    reachable.add(m)
    for d in graph[m]:
        visit(d)


visit('CancellationAudit')
assert reachable == set(module_names) | {'CancellationAudit'}
rows = lines(OUT / 'audit-targets.tsv')
old_rows = lines(BASE / 'audit-targets.tsv')
assert len(rows) == 394 and rows[:370] == old_rows
assert (OUT / 'audit-targets.tsv').read_bytes().startswith((BASE / 'audit-targets.tsv').read_bytes())
targets = [r.split('|')[1] for r in rows]
assert len(set(targets)) == 394
assert all(r.split('|')[0] in module_pos for r in rows)
audit_text = (OUT / 'CancellationAudit.lean').read_text()
assert re.findall(r'^#check\s+(\S+)\s*$', audit_text, re.M) == targets
assert re.findall(r'^#print axioms\s+(\S+)\s*$', audit_text, re.M) == targets
assert (OUT / 'final-audit.txt').read_text().strip() == 'CancellationAudit.lean'
inventory = jread(OUT / 'DECLARATIONS.json')
assert len(inventory) == 1129 and inventory[:1105] == jread(BASE / 'DECLARATIONS.json')
assert all(d['status'] == 'NATIVE_AUDIT_PENDING' for d in inventory[1105:])
assert {d['module'] + '|' + d['name'] for d in inventory[1105:]} == set(rows[370:])

runtime_review = {
    'schema': 'RH_HILBERT_V0218_RUNTIME_METADATA_REVIEW_V1',
    'status': 'STATIC_ONLY_NO_NEW_NATIVE_OR_RUNTIME_TEST_EXECUTION',
    'runner_sha256': sha(OUT / 'tools/native_runner.js'),
    'baseline_runner_sha256': sha(BASE / 'tools/native_runner.js'),
    'changes': 'PACKAGE_AND_VERSION_IDENTITY_AND_SEMANTIC_THEOREM_STATUS_REPORTING_ONLY',
    'node_syntax_check': 'NODE_CHECK_PASSED; DOES_NOT_EXECUTE_RUNNER_OR_WINDOWS_APIS',
    'integration_review': EVREL + '/INTEGRATION_REVIEW.json',
    'integration_review_sha256': sha(EV / 'INTEGRATION_REVIEW.json'),
    'cache_acceptance_compile_flags_scheduling_hashing_locks_and_shutdown': 'EXACT_BASELINE_LOGIC_PRESERVED',
    'run_cmd_and_native_helpers': 'EXACT_BYTES_PRESERVED',
    'native_baseline': 'USER_REPORTED_V0_2_17_PASS',
    'candidate_native_execution': 'NOT_PERFORMED',
    'lean_execution': False, 'lake_execution': False, 'ci_execution': False,
    'new_axiom_audit_execution': False,
}
dump(OUT / 'RUNNER_LOGIC_VALIDATION.json', runtime_review)

allowed_changes = {
    'STATUS.json', 'PROVENANCE.json', 'CHECKPOINT.json', 'STATIC_REVIEW.json',
    'RUNNER_LOGIC_VALIDATION.json', 'README.md', 'OPEN_OBLIGATIONS.txt',
    'RUNNER_NOTES.txt', 'SHA256SUMS.txt', 'runner-version.txt', 'compile-order.txt',
    'final-audit.txt', 'audit-targets.tsv', 'DECLARATIONS.json', 'tools/native_runner.js',
}
prior_preserved = []
for p in sorted(BASE.rglob('*')):
    if not p.is_file():
        continue
    rel = p.relative_to(BASE).as_posix()
    assert (OUT / rel).is_file()
    if rel not in allowed_changes:
        assert p.read_bytes() == (OUT / rel).read_bytes(), rel
        prior_preserved.append({'path': rel, 'sha256': sha(p), 'bytes': p.stat().st_size})
dump(EV / 'PRESERVED_PRIOR_FILES.json', {'files': prior_preserved, 'count': len(prior_preserved)})

static = {
    'schema': 'RH_HILBERT_V0218_SOURCE_AND_PACKAGE_STATIC_REVIEW_V1',
    'package': OUT.name, 'status': 'STATIC_CHECKS_ONLY_NATIVE_COMPILATION_PENDING',
    'old_lean_sources_byte_preserved': 92, 'total_lean_source_files': 96,
    'new_proof_sources': assembly['new_source_sha256'],
    'new_explicit_public_declarations': 24, 'declaration_inventory_entries': 1129,
    'prior_inventory_records_preserved': 1105,
    'ordinary_modules': 92, 'selected_aggregate': 'CancellationAudit.lean',
    'active_modules': 93, 'aggregate_reaches_all_ordinary_modules': True,
    'import_topology': 'CHECKED', 'old_audit_targets_preserved': 370,
    'new_audit_targets': 24, 'aggregate_check_and_axiom_targets': 394,
    'old_aggregate_source_preserved_unselected': 'AnalyticAudit.lean',
    'helpers_launcher_and_mathlib_requirements_preserved': True,
    'new_mathlib_direct_requirements': [],
    'source_review': EVREL + '/SOURCE_REVIEW.json',
    'source_review_sha256': sha(EV / 'SOURCE_REVIEW.json'),
    'integration_review': EVREL + '/INTEGRATION_REVIEW.json',
    'integration_review_sha256': sha(EV / 'INTEGRATION_REVIEW.json'),
    'new_semantic_forward_theorem': 'RH_HilbertLimit.nativeRH_of_exists_admissible_cancellationBudget',
    'witness_validity': 'ALL_ORDER_SEMANTIC_PREDICATE; NO_BOOL_CHECKER',
    'finite_checker_soundness': 'OPEN', 'finite_checker_equivalence': 'OPEN',
    'formal_closure': 'OPEN', 'new_native_lean_execution': False,
    'new_native_axiom_audit': False, 'new_runtime_mock_execution': False,
    'node_syntax_check_only': True,
    'changed_existing_payload_files_allowed': sorted(allowed_changes),
    'preserved_nonmetadata_parent_files': len(prior_preserved),
}
dump(OUT / 'STATIC_REVIEW.json', static)

provenance = {
    'package': OUT.name,
    'prepared_at': datetime.now(ZoneInfo('Europe/Berlin')).isoformat(),
    'mode': 'A_TIER_LEAN', 'target': 'LOCAL_COMPILER',
    'branch': 'RH_HILBERT_LIMIT / Hilbert.vector',
    'parent_package': BASE.name,
    'parent_zip_sha256': sha(ROOT / 'output' / (BASE.name + '.zip')),
    'parent_library_file_id': 'libfile_48346676be6481919f67e8f904a3bd73',
    'parent_library_version': 20,
    'user_request': 'Assume the Witness exists - show that RH follows. Make this Leaned',
    'retained_project_goal': '(exists W : FiniteWitness, check W = true) iff _root_.RiemannHypothesis',
    'new_source_endpoint': '(exists W : CancellationBudget, W.Admissible) -> _root_.RiemannHypothesis',
    'scope_limitation': 'ADMISSIBILITY_IS_UNIVERSAL; NO_TERMINATING_FINITE_CHECKER_SOUNDNESS_SUPPLIED',
    'runner_sha256': sha(OUT / 'tools/native_runner.js'),
    'native_baseline_evidence': EVREL + '/USER_REPORTED_NATIVE_PASS.json',
    'source_reviews': [EVREL + '/SOURCE_REVIEW.json', EVREL + '/INTEGRATION_REVIEW.json'],
    'new_native_or_lean_execution': False, 'direct_native_receipt_inspection': False,
    'new_runtime_tests': False, 'node_runner_syntax_check': True,
    'new_source_sha256': assembly['new_source_sha256'],
    'evidence_sha256': {p.relative_to(EV).as_posix(): sha(p)
                        for p in sorted(EV.rglob('*')) if p.is_file()},
}
dump(OUT / 'PROVENANCE.json', provenance)

files = sorted(p for p in OUT.rglob('*') if p.is_file())
assert all(not p.is_symlink() for p in files)
assert not any(p.suffix in {'.olean', '.ilean'} for p in files)
payload = [p for p in files if p.name != 'SHA256SUMS.txt' or p.parent != OUT]
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
    assert set(n.split('/')[0] for n in names) == {OUT.name}
    for p in files:
        assert z.read(OUT.name + '/' + p.relative_to(OUT).as_posix()) == p.read_bytes()
    for row in manifest.splitlines():
        h, rel = row.split('  ', 1)
        assert hashlib.sha256(z.read(OUT.name + '/' + rel)).hexdigest() == h
    assert z.read(OUT.name + '/run.cmd') == (BASE / 'run.cmd').read_bytes()

verification = {
    'archive': str(ZIP), 'filename': ZIP.name, 'sha256': sha(ZIP),
    'bytes': ZIP.stat().st_size, 'members': len(files), 'payload_hashes': len(payload),
    'zip_crc': 'VERIFIED', 'payload_sha256': 'VERIFIED', 'single_root': OUT.name,
    'all_92_prior_lean_sources_byte_preserved': True,
    'new_lean_sources': 4, 'selected_audit_declarations': 394,
    'compiled_or_axiom_audited_here': False,
    'finite_checker_soundness': 'OPEN', 'formal_closure': 'OPEN',
    'run_command': (WORK / 'RUN_COMMAND.txt').read_text().strip(),
}
dump(WORK / 'ZIP_VERIFIED.json', verification)
print(json.dumps(verification, indent=2))
