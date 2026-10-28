from pathlib import Path
from datetime import datetime
from zoneinfo import ZoneInfo
import hashlib
import json
import re
import shutil
import zipfile

ROOT = Path('/workspace/scratch/f128c1434505')
WORK = ROOT / 'tmp/shutdown_fix_v0217'
BASE = ROOT / 'output/reuse_record_v0216/RH_HILBERT_LIMIT_LEAN_v0_2_16_construction'
BASE_ZIP = ROOT / 'output/RH_HILBERT_LIMIT_LEAN_v0_2_16_REUSE_RECORD_construction.zip'
OUT = ROOT / 'output/RH_HILBERT_LIMIT_LEAN_v0_2_17_construction'
EV = OUT / 'evidence/shutdown_fix_v0217'
ARCHIVE = OUT.with_suffix('.zip')
RUNNER_SHA = '3d9233a9dd98ecd6549860716c338d11f5aedb44d9146b0835941d3b171e030c'

def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()

def js(p):
    return json.loads(p.read_text(encoding='utf-8'))

def dump(p, value):
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(json.dumps(value, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')

def function_text(source, name):
    match = re.search(r'^function ' + re.escape(name) + r'\(', source, re.M)
    assert match, name
    first_line = source[match.start():source.index('\n', match.start())].rstrip()
    if first_line.endswith('}'):
        return first_line
    end = source.index('\n}', match.start()) + 2
    return source[match.start():end]

for folder in ['evidence', 'review', 'tests']:
    shutil.copytree(WORK / folder, EV / folder, dirs_exist_ok=True)
for name in ['assemble_metadata.py', 'package.py', 'ASSEMBLY.json']:
    shutil.copyfile(WORK / name, EV / name)

runner = OUT / 'tools/native_runner.js'
assert sha(runner) == RUNNER_SHA
assert sha(BASE_ZIP) == '03c16d7cd2cdfb9e6fa5081d7084a667e2f27f34bb313c8993d55f379b24074d'
old_source = (BASE / 'tools/native_runner.js').read_text()
source = runner.read_text()
assert 'var PACKAGE = "' + OUT.name + '";' in source
assert 'var RUNNER_VERSION = "' + (OUT / 'runner-version.txt').read_text().strip() + '";' in source
mock = js(EV / 'tests/candidate/mock_report.json')
assert mock['status'] == 'PASS' and mock['passed'] == 16 and mock['failed'] == 0
assert mock['runner_sha256'] == RUNNER_SHA
assert sha(EV / 'tests/candidate/mock_report.json') == 'f62d97084c6f7daa4266f3c2d4d9442af8f906bed1ce1158547f22a0abdab134'
assert len(mock['cases']) == 16 and all(x['outcome'] == 'PASS' for x in mock['cases'])
test_files = js(EV / 'tests/copy_inventory.json')['files']
for item in test_files:
    p = EV / 'tests' / item['path']
    assert sha(p) == item['sha256'] and p.stat().st_size == item['bytes'], item['path']
assert len(test_files) + 1 == len([p for p in (EV / 'tests').rglob('*') if p.is_file()]) == 12
implementation = js(EV / 'review/EXACT_PROCESS_IMPLEMENTATION.json')
assert implementation['candidate_runner_sha256'] == RUNNER_SHA
assert implementation['status'] == 'STATIC_CHECKS_PASS_NATIVE_PENDING'
assert js(EV / 'review/ROOT_RUNNER_REVIEW.json')['candidate_runner_sha256'] == RUNNER_SHA
protected = js(EV / 'review/PROTECTED_FUNCTIONS.json')
assert protected['candidate_runner_sha256'] == RUNNER_SHA
for name, retained in protected['exact_function_text_preserved'].items():
    assert retained and function_text(source, name) == function_text(old_source, name), name
old_names = set(re.findall(r'^function (\w+)\(', old_source, re.M))
new_names = set(re.findall(r'^function (\w+)\(', source, re.M))
assert old_names <= new_names
changed_functions = sorted(n for n in old_names if function_text(source, n) != function_text(old_source, n))
assert set(changed_functions) == {'runToFile', 'launchCertutil', 'startNativeAsync', 'parallelLiveProcesses',
    'parallelShutdownInventory', 'parallelAssertShutdownInventory', 'parallelShutdown', 'result'}
assert new_names - old_names == {'nativeBeginLaunch', 'nativeTrackedRun', 'nativeTrackedExec', 'sealNativeLaunches',
    'ownedNativeLaunchOutstanding', 'queryShutdownProcess', 'guardShutdownOwner'}
for name in ['SCHEMA', 'CACHE_LAYOUT', 'HELPER_SCHEMA', 'COMPILE_POLICY', 'AUDIT_POLICY', 'COMPILE_FLAGS', 'TARGET', 'HASH_BATCH_MIN_FILES']:
    pattern = r'^var ' + name + r' = .*;$'
    assert re.search(pattern, old_source, re.M).group() == re.search(pattern, source, re.M).group(), name
assert len(re.findall(r'\bshell\.Run\(', source)) == 1
assert len(re.findall(r'\bshell\.Exec\(', source)) == 1

lean = {p.relative_to(BASE).as_posix(): sha(p) for p in BASE.rglob('*.lean')}
assert len(lean) == 92
assert lean == {p.relative_to(OUT).as_posix(): sha(p) for p in OUT.rglob('*.lean')}
inputs = ['DECLARATIONS.json', 'run.cmd', 'tools/NativeSha256.cs', 'tools/NativeRamWarm.cs', 'tools/follow_active.js',
          'compile-order.txt', 'audit-targets.tsv', 'mathlib-imports.txt', 'lean-toolchain', 'final-audit.txt']
for rel in inputs:
    assert (OUT / rel).read_bytes() == (BASE / rel).read_bytes(), rel
assert len(js(OUT / 'DECLARATIONS.json')) == 1105
targets = re.findall(r'^#print axioms (\S+)', (OUT / 'AnalyticAudit.lean').read_text(), re.M)
assert len(targets) == len(set(targets)) == 370
assert js(OUT / 'CHECKPOINT.json')['exact_endpoint_declarations'] == js(BASE / 'CHECKPOINT.json')['exact_endpoint_declarations']
prior_evidence = {p.relative_to(BASE).as_posix(): sha(p) for p in (BASE / 'evidence').rglob('*') if p.is_file()}
for rel, h in prior_evidence.items():
    assert sha(OUT / rel) == h, rel
dump(EV / 'PRESERVED_PRIOR_EVIDENCE.json', prior_evidence)
dump(EV / 'FROZEN_PROOF_AND_EXECUTION_INPUTS.json', dict(lean, **{rel: sha(BASE / rel) for rel in inputs}))

status = js(OUT / 'STATUS.json')
assert status['package'] == OUT.name and status['version'] == '0.2.17'
assert status['mode'] == 'A_TIER_LEAN' and status['target'] == 'LOCAL_COMPILER'
assert status['formal_closure'] == 'OPEN' and status['unconditional_rh'] == 'NOT_ESTABLISHED'
assert status['latest_user_native_evidence']['reported_run'] == 'FAIL'
assert status['latest_user_native_evidence']['failed_stage'] == 'WORKER_SHUTDOWN'
assert status['latest_user_successful_native_evidence']['reported_run'] == 'PASS'
assert status['new_runtime_mocks_run'] is True and status['local_lean_executed'] is False
status['runtime_mock_validation'] = {
    'status': 'PASS', 'scope': mock['scope'], 'passed': 16, 'failed': 0,
    'runner_sha256': RUNNER_SHA,
    'report': 'evidence/shutdown_fix_v0217/tests/candidate/mock_report.json',
    'report_sha256': sha(EV / 'tests/candidate/mock_report.json'),
    'native_execution': False,
}
dump(OUT / 'STATUS.json', status)

dump(OUT / 'RUNNER_LOGIC_VALIDATION.json', {
    'schema': 'RH_HILBERT_V0217_SHUTDOWN_RUNTIME_REVIEW_V1',
    'status': 'STATIC_AND_16_FOCUSED_NODE_MOCK_CASES_PASS; NATIVE_WINDOWS_PENDING',
    'runner_sha256': RUNNER_SHA,
    'baseline_runner_sha256': sha(BASE / 'tools/native_runner.js'),
    'changed_existing_functions': changed_functions,
    'new_functions': sorted(new_names - old_names),
    'exact_preserved_protected_functions': list(protected['exact_function_text_preserved']),
    'mock_report': 'evidence/shutdown_fix_v0217/tests/candidate/mock_report.json',
    'mock_report_sha256': sha(EV / 'tests/candidate/mock_report.json'),
    'mock_cases_passed': 16, 'mock_cases_failed': 0,
    'raw_shell_calls_mocked': True, 'whole_WSH_entry_point_executed': False,
    'native_execution_here': False, 'new_lean_execution_here': False,
    'cache_and_axiom_acceptance_changed': False,
    'shutdown_limits': implementation['shutdown_query_limits'],
    'independent_native_audit_or_receipt_inspection': False,
})
allowed = set(js(WORK / 'ASSEMBLY.json')['metadata_changed']) | {'tools/native_runner.js'}
dump(OUT / 'STATIC_REVIEW.json', {
    'schema': 'RH_HILBERT_V0217_FROZEN_PROOF_RUNNER_REPAIR_REVIEW_V1',
    'package': OUT.name, 'status': 'EXACT_PROOF_PRESERVATION_AND_BOUNDED_RUNTIME_REPAIR_REVIEWED',
    'lean_sources_byte_preserved': 92, 'changed_lean_sources': [],
    'declaration_inventory_byte_preserved': 1105, 'selected_axiom_targets_preserved': 370,
    'exact_endpoint_types_preserved': 10,
    'helpers_and_launcher_byte_preserved': True,
    'runner_changed_functions': changed_functions,
    'new_runner_functions': sorted(new_names - old_names),
    'all_other_existing_runner_function_bodies_unchanged': len(old_names) - len(changed_functions),
    'cache_criteria_and_compile_semantic_flags_unchanged': True,
    'prior_evidence_files_byte_preserved': len(prior_evidence),
    'runtime_tests': '16 TARGETED NODE VM MOCK CASES PASS; NO NATIVE EXECUTION',
    'allowed_changed_parent_files': sorted(allowed),
    'formal_closure': 'OPEN',
})
dump(OUT / 'PROVENANCE.json', {
    'package': OUT.name, 'prepared_at': datetime.now(ZoneInfo('Europe/Berlin')).isoformat(),
    'mode': 'A_TIER_LEAN', 'target': 'LOCAL_COMPILER',
    'parent_package': BASE.name, 'parent_delivery_filename': BASE_ZIP.name,
    'parent_zip_sha256': sha(BASE_ZIP),
    'parent_library_file_id': 'libfile_48346676be6481919f67e8f904a3bd73', 'parent_library_version': 19,
    'scope': 'Repair exact process shutdown revalidation and own launch accounting; preserve reported-pass proof/audit sources and cache criteria.',
    'runner_sha256': RUNNER_SHA, 'lean_sources_byte_preserved': 92,
    'user_failure_transcript_sha256': sha(EV / 'evidence/USER_NATIVE_SHUTDOWN_FAIL_TAIL.txt'),
    'new_native_or_lean_execution': False, 'new_runtime_tests': '16_FOCUSED_NODE_VM_MOCK_CASES_PASS',
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
            assert rel in allowed, rel
            changed.append(rel)
for p in OUT.rglob('*'):
    if p.is_file():
        rel = p.relative_to(OUT)
        assert p.suffix.lower() not in {'.exe', '.dll', '.olean', '.ilean', '.pyc'}, rel
        assert not any(x in rel.parts for x in ['.native-build', '.native-run.lock']), rel
        if not (BASE / rel).exists():
            assert rel.parts[:2] == ('evidence', 'shutdown_fix_v0217'), rel

payload = [p for p in sorted(OUT.rglob('*')) if p.is_file() and p != OUT / 'SHA256SUMS.txt']
(OUT / 'SHA256SUMS.txt').write_text(''.join(sha(p) + '  ' + p.relative_to(OUT).as_posix() + '\n' for p in payload), encoding='utf-8')
with zipfile.ZipFile(ARCHIVE, 'w', zipfile.ZIP_DEFLATED, compresslevel=9) as z:
    for p in sorted(OUT.rglob('*')):
        if p.is_file():
            z.write(p, (Path(OUT.name) / p.relative_to(OUT)).as_posix())
with zipfile.ZipFile(ARCHIVE) as z:
    assert z.testzip() is None
    names = z.namelist()
    assert len(names) == len(set(names)) and {n.split('/')[0] for n in names} == {OUT.name}
    assert all('..' not in Path(n).parts and not n.startswith('/') for n in names)
    sums = z.read(OUT.name + '/SHA256SUMS.txt').decode().splitlines()
    assert len(sums) == len(payload) == len(names) - 1
    for line in sums:
        digest, rel = line.split('  ', 1)
        assert hashlib.sha256(z.read(OUT.name + '/' + rel)).hexdigest() == digest == sha(OUT / rel)
    assert z.read(OUT.name + '/run.cmd') == (BASE / 'run.cmd').read_bytes()
    assert hashlib.sha256(z.read(OUT.name + '/tools/native_runner.js')).hexdigest() == RUNNER_SHA

verified = {
    'archive': str(ARCHIVE), 'bytes': ARCHIVE.stat().st_size, 'sha256': sha(ARCHIVE),
    'members': len(names), 'hashed_payload_files': len(payload), 'crc': 'PASS', 'single_root': OUT.name,
    'lean_sources_preserved': 92, 'changed_lean_sources': [], 'declaration_inventory_preserved': 1105,
    'runner_sha256': RUNNER_SHA, 'runtime_tests': '16_FOCUSED_NODE_MOCK_CASES_PASS',
    'native_execution': 'NOT_RUN', 'native_run_status': 'USER_VALIDATION_PENDING',
    'old_workspace_lock': 'UNTOUCHED', 'shared_anchor_acceptance': 'UNCHANGED_FULL_VALIDATION',
    'changed_parent_files': sorted(set(changed) | {'SHA256SUMS.txt'}),
    'formal_closure': 'OPEN',
}
dump(WORK / 'ZIP_VERIFIED.json', verified)
print(json.dumps(verified, indent=2))
