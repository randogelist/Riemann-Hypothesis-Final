from pathlib import Path
from datetime import datetime, timezone
import hashlib
import json
import re
import shutil
import zipfile

ROOT = Path('/workspace/scratch/f128c1434505')
WORK = ROOT / 'tmp/cancellation_fix_v0219'
BASE = ROOT / 'output/RH_HILBERT_LIMIT_LEAN_v0_2_18_construction'
OUT = ROOT / 'output/RH_HILBERT_LIMIT_LEAN_v0_2_19_construction'
EVREL = 'evidence/cancellation_fix_v0219'
EV = OUT / EVREL
ZIP = OUT.with_suffix('.zip')
SOURCE = 'RH_HilbertLimit/Cancellation.lean'
OLD_RUNNER = 'RH_HILBERT_NATIVE_RUNNER_v0_2_18_SEMANTIC_CANCELLATION'
NEW_RUNNER = 'RH_HILBERT_NATIVE_RUNNER_v0_2_19_ROW_VARIATION_UNFOLD'


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
assert review['status'] == 'STATIC_INTEGRATION_REVIEW_ONLY', review
assert not review.get('blockers'), review
assert sha(OUT / SOURCE) == assembly['new_source_sha256']
assert sha(OUT / 'tools/native_runner.js') == assembly['runner_sha256']
shutil.copyfile(WORK / 'review/INTEGRATION_REVIEW.json', EV / 'INTEGRATION_REVIEW.json')
shutil.copyfile(Path(__file__), EV / 'package.py')

old_lean = sorted(p.relative_to(BASE).as_posix() for p in BASE.rglob('*.lean'))
new_lean = sorted(p.relative_to(OUT).as_posix() for p in OUT.rglob('*.lean'))
assert old_lean == new_lean and len(old_lean) == 96
changed = [rel for rel in old_lean if (OUT / rel).read_bytes() != (BASE / rel).read_bytes()]
assert changed == [SOURCE]
old_rewrite = '      rw [Finset.sum_add_distrib, ← Finset.mul_sum, sum_forward_differences]'
new_rewrite = '      rw [rowVariation, Finset.sum_add_distrib, ← Finset.mul_sum,\n        sum_forward_differences]'
assert (BASE / SOURCE).read_bytes().replace(old_rewrite.encode(), new_rewrite.encode(), 1) == (OUT / SOURCE).read_bytes()
assert sha(OUT / 'RH_HilbertLimit/EventualGrowth.lean') == 'f846d1a1b897542c460783a9ab5702ff1b713e5788fe149034d1ead5f0d178c0'

fixed_manifests = ['compile-order.txt', 'final-audit.txt', 'audit-targets.tsv', 'mathlib-imports.txt']
for rel in fixed_manifests:
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
        local = OUT / (imp.replace('.', '/') + '.lean')
        assert not local.exists() or imp in positions, (module, imp)
reachable = set()


def visit(module):
    if module not in reachable:
        reachable.add(module)
        for dep in graph[module]:
            visit(dep)


visit('CancellationAudit')
assert reachable == set(active_names)
dirty = {'RH_HilbertLimit.Cancellation'}
for module in active_names:
    if set(graph[module]) & dirty:
        dirty.add(module)
expected_dirty = {'RH_HilbertLimit.Cancellation', 'RH_HilbertLimit.ActualCancellationWitness', 'CancellationAudit'}
assert dirty == expected_dirty

rows = lines(OUT / 'audit-targets.tsv')
targets = [r.split('|')[1] for r in rows]
assert len(rows) == len(set(targets)) == 394
audit_text = (OUT / 'CancellationAudit.lean').read_text()
assert re.findall(r'^#check\s+(\S+)\s*$', audit_text, re.M) == targets
assert re.findall(r'^#print axioms\s+(\S+)\s*$', audit_text, re.M) == targets
assert all(r.split('|')[0] in positions for r in rows)

prior_inventory = read_json(BASE / 'DECLARATIONS.json')
inventory = read_json(OUT / 'DECLARATIONS.json')
assert len(inventory) == len(prior_inventory) == 1129
changed_records = []
counts = {'RH_HilbertLimit.Cancellation': 0, 'RH_HilbertLimit.EventualGrowth': 0}
for old, new in zip(prior_inventory, inventory):
    assert old['name'] == new['name']
    if old != new:
        module = new['module']
        assert module in counts
        counts[module] += 1
        changed_records.append(new['name'])
        assert new['source_sha256'] == sha(OUT / new['source'])
        assert old['source_line'] == new['source_line']
        allowed = {'status', 'evidence', 'receipt_validation'}
        if module == 'RH_HilbertLimit.Cancellation':
            allowed.add('source_sha256')
        assert {k for k in old.keys() | new.keys() if old.get(k) != new.get(k)} <= allowed
assert counts == {'RH_HilbertLimit.Cancellation': 9, 'RH_HilbertLimit.EventualGrowth': 3}

runner_bytes = (OUT / 'tools/native_runner.js').read_bytes()
assert runner_bytes.replace(OUT.name.encode(), BASE.name.encode(), 1).replace(NEW_RUNNER.encode(), OLD_RUNNER.encode(), 1) == (BASE / 'tools/native_runner.js').read_bytes()
assert (OUT / 'runner-version.txt').read_text().strip() == NEW_RUNNER
assert (OUT / 'run.cmd').read_bytes() == (BASE / 'run.cmd').read_bytes()

allowed_changes = {
    SOURCE, 'tools/native_runner.js', 'runner-version.txt', 'STATUS.json',
    'CHECKPOINT.json', 'README.md', 'OPEN_OBLIGATIONS.txt', 'RUNNER_NOTES.txt',
    'DECLARATIONS.json', 'PROVENANCE.json', 'STATIC_REVIEW.json',
    'RUNNER_LOGIC_VALIDATION.json', 'SHA256SUMS.txt',
}
preserved = []
for p in sorted(BASE.rglob('*')):
    if p.is_file():
        rel = p.relative_to(BASE).as_posix()
        assert (OUT / rel).is_file(), rel
        if rel not in allowed_changes:
            assert p.read_bytes() == (OUT / rel).read_bytes(), rel
            preserved.append({'path': rel, 'sha256': sha(p), 'bytes': p.stat().st_size})
dump(EV / 'PRESERVED_PRIOR_FILES.json', {'count': len(preserved), 'files': preserved})

runtime_review = {
    'schema': 'RH_HILBERT_V0219_RUNTIME_IDENTITY_REVIEW_V1',
    'status': 'STATIC_ONLY_NO_NATIVE_OR_RUNTIME_EXECUTION',
    'runner_sha256': sha(OUT / 'tools/native_runner.js'),
    'baseline_runner_sha256': sha(BASE / 'tools/native_runner.js'),
    'changes': 'TWO_PACKAGE_AND_VERSION_CONSTANTS_ONLY',
    'normalized_exact_raw_byte_comparison': 'MATCH',
    'node_syntax_check': 'PASSED; NO_RUNNER_OR_WINDOWS_API_EXECUTION',
    'cache_acceptance_compile_flags_scheduling_hashing_locks_shutdown': 'EXACT_BASELINE_LOGIC_PRESERVED',
    'launcher_and_native_helpers': 'EXACT_BYTES_PRESERVED',
    'candidate_native_execution': 'NOT_PERFORMED',
    'lean_execution': False, 'lake_execution': False, 'ci_execution': False,
    'new_axiom_audit_execution': False, 'new_runtime_mock_execution': False,
    'integration_review': EVREL + '/INTEGRATION_REVIEW.json',
    'integration_review_sha256': sha(EV / 'INTEGRATION_REVIEW.json'),
}
dump(OUT / 'RUNNER_LOGIC_VALIDATION.json', runtime_review)

static = {
    'schema': 'RH_HILBERT_V0219_STATIC_PACKAGE_REVIEW_V1',
    'status': 'STATIC_CHECKS_ONLY_NATIVE_COMPILATION_PENDING',
    'package': OUT.name,
    'total_lean_source_files': 96, 'inherited_lean_files_byte_preserved': 95,
    'changed_lean_source_files': changed, 'added_or_deleted_lean_source_files': [],
    'source_change': 'ONE_REWRITE_LIST_IN_ONE_PROOF_BODY',
    'definitions_theorem_statements_hypotheses': 'UNCHANGED',
    'eventual_growth_source_byte_preserved': True,
    'ordinary_modules': 92, 'active_modules': 93,
    'audit_targets': 394, 'all_audit_and_compile_manifests_byte_preserved': True,
    'aggregate_reaches_all_ordinary_modules': True, 'import_topology': 'CHECKED',
    'source_invalidation_cone': sorted(dirty),
    'expected_reused_modules_if_all_other_anchors_validate': 90,
    'expected_compiled_modules_if_all_other_anchors_validate': 3,
    'expected_counts_are_observed': False,
    'declaration_inventory_records': 1129,
    'changed_declaration_inventory_records': changed_records,
    'preserved_declaration_inventory_records': 1117,
    'runner_changes': 'TWO_PACKAGE_AND_VERSION_CONSTANTS_ONLY',
    'source_review': EVREL + '/SOURCE_REPAIR_REVIEW.json',
    'integration_review': EVREL + '/INTEGRATION_REVIEW.json',
    'integration_review_sha256': sha(EV / 'INTEGRATION_REVIEW.json'),
    'witness_admissibility': 'EXPLICIT_ALL_ORDER_PREDICATE; NO_BOOL_CHECKER',
    'finite_checker_soundness': 'OPEN', 'finite_checker_equivalence': 'OPEN',
    'formal_closure': 'OPEN',
    'native_or_lean_execution': False, 'new_native_axiom_audit': False,
    'runtime_mock_execution': False, 'node_syntax_check_only': True,
    'preserved_nonmetadata_parent_files': len(preserved),
}
dump(OUT / 'STATIC_REVIEW.json', static)

provenance = {
    'package': OUT.name, 'prepared_at_utc': datetime.now(timezone.utc).isoformat(),
    'branch': 'RH_HILBERT_LIMIT / Hilbert.vector', 'mode': 'A_TIER_LEAN', 'target': 'LOCAL_COMPILER',
    'parent_package': BASE.name, 'parent_zip_sha256': sha(BASE.with_suffix('.zip')),
    'parent_library_file_id': 'libfile_48346676be6481919f67e8f904a3bd73', 'parent_library_version': 21,
    'user_evidence': EVREL + '/USER_NATIVE_V0218_FAIL_TAIL.txt',
    'evidence_interpretation': EVREL + '/USER_REPORTED_NATIVE_RESULT.json',
    'user_request_scope': 'REPAIR_REPORTED_CANCELLATION_COMPILE_FAILURE_AND_PRESERVE_PASSED_MODULES',
    'changed_source': SOURCE, 'source_sha256': sha(OUT / SOURCE),
    'old_source_sha256': sha(BASE / SOURCE),
    'eventual_growth_source_sha256': sha(OUT / 'RH_HilbertLimit/EventualGrowth.lean'),
    'runner_sha256': sha(OUT / 'tools/native_runner.js'),
    'runtime_policy_changes': False,
    'retained_goal': '(exists W : FiniteWitness, check W = true) iff _root_.RiemannHypothesis',
    'prepared_semantic_source_endpoint': '(exists W : CancellationBudget, W.Admissible) -> _root_.RiemannHypothesis',
    'scope_limitation': 'UNIVERSAL_ADMISSIBILITY_IS_NOT_FINITE_CHECKER_ACCEPTANCE',
    'formal_closure': 'OPEN', 'new_native_or_lean_execution': False,
    'direct_native_receipt_inspection': False, 'new_runtime_tests': False,
    'evidence_sha256': {p.relative_to(EV).as_posix(): sha(p) for p in sorted(EV.rglob('*')) if p.is_file()},
}
dump(OUT / 'PROVENANCE.json', provenance)

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
    'lean_sources_preserved': 95, 'lean_sources_changed': [SOURCE],
    'selected_audit_declarations': 394,
    'compiled_or_axiom_audited_here': False,
    'finite_checker_soundness': 'OPEN', 'formal_closure': 'OPEN',
    'run_command': (WORK / 'RUN_COMMAND.txt').read_text().strip(),
}
dump(WORK / 'ZIP_VERIFIED.json', verification)
print(json.dumps(verification, indent=2))
