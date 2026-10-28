from pathlib import Path
import hashlib
import json
import re
import shutil

ROOT = Path('/workspace/scratch/f128c1434505')
WORK = ROOT / 'tmp/native_pass_v0223'
BASE = ROOT / 'output/RH_HILBERT_LIMIT_LEAN_v0_2_22_construction'
OUT = ROOT / 'output/RH_HILBERT_LIMIT_LEAN_v0_2_23_construction'
EVREL = 'evidence/native_pass_v0223'
EV = OUT / EVREL
OLD_RUNNER = 'RH_HILBERT_NATIVE_RUNNER_v0_2_22_RELATIVE_SHUTDOWN_RECHECK'
NEW_RUNNER = 'RH_HILBERT_NATIVE_RUNNER_v0_2_23_NATIVE_REUSE_PASS_CHECKPOINT'


def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def read_json(p):
    return json.loads(p.read_text(encoding='utf-8'))


def dump(p, value):
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(json.dumps(value, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')


assert sha(BASE.with_suffix('.zip')) == '01bc75fefa135b43d264b3322cbcfc029ca2969ac657b7e4332de384dad21a3f'
assert not OUT.exists()
shutil.copytree(BASE, OUT)
archive = EV / 'baseline_v0222_metadata'
archive.mkdir(parents=True)
for rel in ['STATUS.json', 'CHECKPOINT.json', 'README.md', 'OPEN_OBLIGATIONS.txt',
            'RUNNER_NOTES.txt', 'runner-version.txt', 'DECLARATIONS.json',
            'PROVENANCE.json', 'STATIC_REVIEW.json', 'RUNNER_LOGIC_VALIDATION.json', 'SHA256SUMS.txt']:
    shutil.copyfile(BASE / rel, archive / rel)

runner = (BASE / 'tools/native_runner.js').read_bytes()
assert runner.count(BASE.name.encode()) == runner.count(OLD_RUNNER.encode()) == 1
runner = runner.replace(BASE.name.encode(), OUT.name.encode(), 1).replace(OLD_RUNNER.encode(), NEW_RUNNER.encode(), 1)
(OUT / 'tools/native_runner.js').write_bytes(runner)
(OUT / 'runner-version.txt').write_text(NEW_RUNNER + '\n', encoding='utf-8')

log_name = 'USER_NATIVE_V0222_PASS_TAIL.txt'
shutil.copyfile(WORK / log_name, EV / log_name)
log = (EV / log_name).read_text()


def scalar(key):
    matches = re.findall(r'^' + re.escape(key) + r'=(.*)$', log, re.M)
    assert len(matches) == 1, (key, matches)
    return matches[0]


assert scalar('RUN') == scalar('PROJECT_BUILD') == 'PASS'
assert scalar('AXIOM_AUDIT') == 'PASS_STANDARD_LOGICAL_AXIOMS_ONLY'
assert scalar('SORRYAX') == 'NONE'
assert scalar('FINAL_AUDIT_DECLARATIONS') == '394'
counts = {key: int(scalar(key)) for key in [
    'COMPILED_MODULES', 'FROZEN_REUSED_MODULES', 'AUDIT_ONLY_MODULES', 'LEGACY_MIGRATED_MODULES',
    'WORKING_ARTIFACT_MODULES_RETAINED', 'RESTORED_ARTIFACT_FILES', 'ANCHOR_HISTORY_SCANS',
    'COMPACT_ANCHORS_SAVED', 'COMBINED_WORKING_DIGESTS_CONSUMED']}
assert counts['COMPILED_MODULES'] == 0 and counts['FROZEN_REUSED_MODULES'] == 93
assert scalar('FORMAL_CLOSURE') == scalar('FINITE_CHECKER_SOUNDNESS') == scalar('FINITE_CHECKER_EQUIVALENCE') == 'OPEN'
assert scalar('SEMANTIC_CANCELLATION_WITNESS_FORWARD') == scalar('SEMANTIC_CANCELLATION_WITNESS_EQUIVALENCE') == 'DECLARATION_AUDITED'
assert 'WORKER_INVENTORY_RECHECK=CLEAR|ATTEMPTS:1|FULL_INVENTORIES:1|EXACT_WORKER_QUERIES:2' in log
native = {
    'evidence_kind': 'USER_MESSAGE_UTF8_LF_TRANSCRIPTION_NOT_ORIGINAL_NATIVE_LOG_BYTES',
    'reported_package': BASE.name, 'reported_build': 'PASS', 'reported_run': 'PASS',
    'reported_final_audit': 'CancellationAudit.lean', 'reported_final_audit_state': 'FROZEN_REUSED',
    'reported_final_audit_declarations': 394, 'explicitly_printed_axiom_declarations': 0,
    'reported_axiom_audit': scalar('AXIOM_AUDIT'), 'reported_sorryax': scalar('SORRYAX'),
    'reported_final_audit_module_elapsed_ms': 376,
    'reported_stages_ms': {'FINAL_AUDIT': 478, 'WORKER_SHUTDOWN': 1422},
    'reported_counts': counts,
    'reported_logical_tool_launches': json.loads(scalar('LOGICAL_TOOL_LAUNCHES')),
    'reported_hash_phase_totals': json.loads(scalar('HASH_PHASE_TOTALS')),
    'reported_shutdown': {
        'clear': True, 'attempts': 1, 'full_inventories': 1, 'exact_worker_queries': 2,
        'launch_inventory_sealed': True, 'launch_records': 417, 'snapshot_rows': 748,
        'initial_unreadable_rows': 2, 'initial_unresolved_relative_runners': 0,
        'preexisting_admitted_host_pid': 45652,
        'absent_workers': [
            {'pid': 41244, 'created': '20261027234922.167689+060', 'name': 'certutil.exe'},
            {'pid': 44548, 'created': '20261027234922.181459+060', 'name': 'certutil.exe'},
        ],
        'admitted_host_termination_claimed': False,
        'relative_runner_absence_and_second_inventory_branch_exercised': False,
    },
    'reported_mathematical_status': scalar('MATHEMATICAL_STATUS'),
    'reported_semantic_forward': scalar('SEMANTIC_CANCELLATION_WITNESS_FORWARD'),
    'reported_semantic_equivalence': scalar('SEMANTIC_CANCELLATION_WITNESS_EQUIVALENCE'),
    'reported_witness_admissibility': scalar('WITNESS_ADMISSIBILITY'),
    'reported_formal_closure': scalar('FORMAL_CLOSURE'),
    'reported_finite_checker_soundness': scalar('FINITE_CHECKER_SOUNDNESS'),
    'reported_finite_checker_equivalence': scalar('FINITE_CHECKER_EQUIVALENCE'),
    'reported_accepted_finite_witness': scalar('FINITE_ACCEPTED_WITNESS'),
    'reported_unconditional_rh': scalar('UNCONDITIONAL_RH'),
    'reported_anchor_receipt_path': scalar('SOURCE_ANCHOR_RECEIPT'),
    'source': EVREL + '/' + log_name, 'source_sha256': sha(EV / log_name), 'source_bytes': (EV / log_name).stat().st_size,
    'first_marker': 'BUILD_ARTIFACT_RESTORED=CancellationAudit',
    'direct_native_receipt_contents': 'NOT_SUPPLIED; PATH_ONLY',
    'native_source_dependency_toolchain_and_artifact_fingerprints': 'NOT_SUPPLIED_IN_EXCERPT',
    'independent_native_verification': 'NOT_PERFORMED',
    'aggregate_coverage_scope': '394_SELECTED_TARGETS_REUSED_PRIOR_AUDIT; NO_FRESH_PER_DECLARATION_PRINTS_IN_THIS_TAIL',
    'reuse_requirement': 'EXACT_SAME_TARGET_SOURCE_DEPENDENCIES_TOOLCHAIN_ARTIFACTS_AND_PRIOR_AUDIT_PASS_VALIDATION',
    'timing_scope': 'REPORTED_STAGES_AND_HASH_AGGREGATES_ONLY; NO_WHOLE_RUN_WALL_TIME',
}
dump(EV / 'USER_REPORTED_NATIVE_PASS.json', native)

old_status = read_json(BASE / 'STATUS.json')
old_checkpoint = read_json(BASE / 'CHECKPOINT.json')
prior_explicit = old_checkpoint['latest_successful_full_run']
assert prior_explicit['reported_package'] == 'RH_HILBERT_LIMIT_LEAN_v0_2_20_construction'
status = dict(old_status)
status.update({
    'package': OUT.name, 'version': '0.2.23',
    'revision_scope': 'EVIDENCE_ONLY_NATIVE_REUSE_PASS_CHECKPOINT; ALL_PROOF_SOURCES_AND_RUNTIME_LOGIC_FROZEN',
    'latest_user_native_evidence': native, 'latest_user_successful_full_native_evidence': native,
    'latest_successful_full_run': native, 'previous_user_native_evidence': old_status['latest_user_native_evidence'],
    'prior_explicit_endpoint_axiom_evidence': prior_explicit,
    'semantic_cancellation_witness_forward': 'USER_REPORTED_V0220_EXPLICIT_AXIOMS_AND_V0222_FROZEN_AGGREGATE_AUDIT_PASS_SOURCE_UNCHANGED',
    'semantic_cancellation_witness_equivalence': 'USER_REPORTED_V0220_EXPLICIT_AXIOMS_AND_V0222_FROZEN_AGGREGATE_AUDIT_PASS_SOURCE_UNCHANGED',
    'working_artifact_retention_next_run': 'A new v0.2.23 workspace may restore validated shared anchors; later runs may retain validated working artifacts.',
    'runtime_logic_change': 'NONE; TWO_PACKAGE_AND_VERSION_CONSTANTS_ONLY',
    'new_runtime_mocks_run': False,
    'native_validation': 'USER_SUPPLIED_V0_2_22_FULL_REUSE_RUN_AND_AGGREGATE_AUDIT_PASS; V0_2_23_NOT_RUN',
    'delivery_filename': OUT.name + '.zip', 'canonical_archive_root': OUT.name,
    'new_version_workspace': 'E:\\RH-FAST\\workspaces\\' + OUT.name,
    'earlier_status_archive': EVREL + '/baseline_v0222_metadata/STATUS.json',
    'selected_inventory_records_updated': 0, 'declaration_inventory_records_byte_preserved': 1129,
    'explicit_axiom_outputs_in_latest_tail': 0, 'explicit_axiom_outputs_in_last_successful_full_run': 0,
    'explicit_axiom_outputs_in_prior_v0220_evidence': 14,
})
dump(OUT / 'STATUS.json', status)
checkpoint = dict(old_checkpoint)
checkpoint.update({
    'schema': 'RH_HILBERT_V0223_NATIVE_REUSE_PASS_CHECKPOINT_V1',
    'source_package': BASE.name, 'source_zip_sha256': sha(BASE.with_suffix('.zip')),
    'checkpoint_package': OUT.name,
    'evidence_class': 'USER_SUPPLIED_NATIVE_REUSE_RUN_AND_AGGREGATE_AUDIT_PASS; SOURCES_AND_RUNTIME_LOGIC_FROZEN',
    'latest_user_run': native, 'latest_successful_full_run': native,
    'prior_explicit_endpoint_axiom_evidence': prior_explicit,
    'changed_runtime_policy': False, 'runner_changes': 'TWO_PACKAGE_AND_VERSION_CONSTANTS_ONLY',
    'source_manifest': EVREL + '/FROZEN_SOURCE_MANIFEST.json', 'new_runtime_test_execution': False,
    'previous_checkpoint': EVREL + '/baseline_v0222_metadata/CHECKPOINT.json',
    'delivery_filename': OUT.name + '.zip', 'canonical_archive_root': OUT.name,
})
dump(OUT / 'CHECKPOINT.json', checkpoint)

command = ('cd /d "%USERPROFILE%\\Downloads" && (if not exist "E:\\RH-FAST\\workspaces" mkdir "E:\\RH-FAST\\workspaces")'
    ' && tar -xf "' + OUT.name + '.zip" -C "E:\\RH-FAST\\workspaces"'
    ' && cmd /k call "E:\\RH-FAST\\workspaces\\' + OUT.name + '\\run.cmd"')
(WORK / 'RUN_COMMAND.txt').write_text(command + '\n', encoding='utf-8')
(OUT / 'README.md').write_text('''# RH Hilbert Limit v0.2.23 construction

This evidence checkpoint records the user-supplied native v0.2.22 **RUN PASS**.
All 96 Lean files, the 92-module ordinary compile order, the 394 audit targets,
the 1129 declaration-inventory records and the runner logic are preserved.
Only the runner's package/version constants and checkpoint metadata change.
The mode remains `A_TIER_LEAN`; the target remains `LOCAL_COMPILER`; the branch
remains `RH_HILBERT_LIMIT / Hilbert.vector`. This is not an Init.

## Native result recorded

The supplied v0.2.22 tail reports:

```text
COMPILED_MODULES=0
FROZEN_REUSED_MODULES=93
FINAL_AUDIT_DECLARATIONS=394
AXIOM_AUDIT=PASS_STANDARD_LOGICAL_AXIOMS_ONLY
SORRYAX=NONE
PROJECT_BUILD=PASS
RUN=PASS
```

This is a successful cached run, including reuse of `CancellationAudit`.
It reports no new module compilation. The tail gives an aggregate audit
status; it does not print new per-declaration axiom lists or include the
contents of the native receipts. The previous v0.2.20 explicit endpoint
axiom output remains preserved as separate evidence.

Shutdown cleared in one round, using one complete process inventory and two
exact worker queries. Both unreadable `certutil.exe` rows were confirmed
absent. A preexisting admitted host was handled by the existing exact
admission rule; its termination is not asserted. The initial unresolved
relative-runner count was zero, so this run did not exercise the separate
relative-host disappearance and second-inventory branch. The parent package's
20 simulated-host tests remain historical evidence for those runtime paths.

## Preserved witness-to-RH endpoint

The prior explicit native audit reports:

```lean
RH_HilbertLimit.nativeRH_of_exists_admissible_cancellationBudget
  (hWitness : ∃ W, W.Admissible) : RiemannHypothesis

RH_HilbertLimit.exists_admissible_cancellationBudget_iff_nativeRH :
  (∃ W, W.Admissible) ↔ RiemannHypothesis
```

The latest successful run retains these exact source declarations and reports
their selected aggregate audit as passed through frozen reuse. Assuming an
admissible cancellation budget exists, RH follows. The reverse implication
is also retained. No witness must be obtained to state or prove these
conditional transfers.

The finite data in a `CancellationBudget` are two natural numbers, its cutoff
and coefficient. Its `Admissible` property requires the cancellation bound
at every index after that cutoff. The data pair alone does not establish
admissibility. A terminating finite Bool checker with proved soundness and
completeness for actual xi/zeta remains **OPEN**. The ultimate requested goal
is `(∃ W : FiniteWitness, check W = true) ↔ RiemannHypothesis`.

The native status therefore remains `FINITE_CHECKER_SOUNDNESS=OPEN`,
`FINITE_CHECKER_EQUIVALENCE=OPEN` and `FORMAL_CLOSURE=OPEN`. No accepted finite
checker witness, unconditional admissible budget, actual subexponential bound
or unconditional RH is obtained by this checkpoint.

## Frozen reuse and verification boundaries

All 93 active modules remain eligible for reuse if their same-target source,
dependency, toolchain, artifact and prior audit identities validate. Source
changes induce zero compilation tasks in v0.2.23. These are conditional
expectations for the new package; the observed 0 compiled / 93 reused counts
belong to v0.2.22. Missing or invalid cache evidence still rebuilds or fails.

The launcher, helpers, cache and hashing decisions, compile/audit flags,
parallel/RAM admission, process ownership and shutdown algorithm retain their
parent bytes. The normalized runner comparison removes only the two identity
constant changes. No runtime speedup is claimed. Reported hash-stage timing
does not establish whole-run elapsed time.

No Lean, Lake, Windows/WSH/native runner, C# compiler, Wine or CI was executed
here. No new runtime mock tests were run, and no compiled artifacts or native
PASS receipts were fabricated. The v0.2.23 package itself has not been run
on the user's native compiler. The successful result recorded here belongs
to the user-supplied v0.2.22 run.

## Run

Save the ZIP in Downloads, then run:

```cmd
''' + command + '''
```

The command opens the new package under `E:\\RH-FAST\\workspaces`, reuses the
established `E:\\RH-FAST\\anchors` cache and keeps the CMD window open. The
runner uses installed native Lean 4.33.0 and compatible cached Mathlib;
no Lake, Python, PowerShell, WSL or network setup is added.

## Evidence

`evidence/native_pass_v0223` preserves the supplied log tail as a UTF-8/LF
transcription, its interpretation, frozen source hashes, the independent
integration review and prior checkpoint metadata. Earlier source, audit and
runtime evidence remains intact. `DECLARATIONS.json` is byte-preserved;
the new aggregate reuse evidence is recorded separately. `SHA256SUMS.txt`
covers every other payload file.
''', encoding='utf-8')
(OUT / 'OPEN_OBLIGATIONS.txt').write_text('''PACKAGE=v0.2.23 construction
MODE=A_TIER_LEAN
TARGET=LOCAL_COMPILER

RECORDED_NATIVE_RESULT:
User-supplied v0.2.22 RUN PASS: zero compiled, 93 frozen reused, 394 selected
audit targets, standard logical axioms only, no sorryAx; shutdown CLEAR.
Prior v0.2.20 explicit semantic witness implication/equivalence evidence is
preserved. All96 Lean files and all1129 declaration records are unchanged.

1. Construct an effectively checkable finite certificate that implies the
   universally quantified cancellation budget for the actual mathematical
   source. The current local-flux adapter still has all-order hypotheses.
2. Implement a terminating finite raw checker and prove its soundness for
   actual xi/zeta. Admissible is not a Bool checker.
3. Prove completeness for the full scoped goal:
   (exists W : FiniteWitness, check W = true) iff RiemannHypothesis.
   Obtaining an accepted witness is not required to prove that equivalence.
4. Finite-checker soundness/equivalence and formal closure remain OPEN.
   No unconditional admissible budget, accepted finite witness, actual
   subexponential bound or unconditional RH is established.
5. Reuse requires exact same-target source/dependency/toolchain/artifact
   fingerprints and prior audit validation. Native receipt contents were
   not supplied for independent inspection.
6. v0.2.23 is an evidence-only checkpoint, not a newly executed native run.
   No Lean/native/compiler/CI execution or new runtime mocks occurred here.
''', encoding='utf-8')
(OUT / 'RUNNER_NOTES.txt').write_text('''PACKAGE=''' + OUT.name + '''
RUNNER=''' + NEW_RUNNER + '''
MODE=A_TIER_LEAN
TARGET=LOCAL_COMPILER
REVISION=EVIDENCE_ONLY_NOT_INIT
LATEST_USER_RUN=V0_2_22_RUN_AND_AGGREGATE_AUDIT_PASS
LATEST_REPORTED_COMPILED_MODULES=0
LATEST_REPORTED_FROZEN_REUSED_MODULES=93
LATEST_REPORTED_AUDIT_TARGETS=394
LATEST_REPORTED_SHUTDOWN=CLEAR;ONE_INVENTORY;TWO_EXACT_WORKER_QUERIES
LATEST_EXPLICIT_PER_DECLARATION_AXIOM_OUTPUTS=0
PRIOR_EXPLICIT_AXIOM_OUTPUTS_V0_2_20=14
LEAN_SOURCES_BYTE_PRESERVED=96
CHANGED_LEAN_SOURCES=0
ACTIVE_MODULES=93
DECLARATION_INVENTORY_RECORDS_PRESERVED=1129
EXPECTED_REUSE_IF_ALL_IDENTITIES_VALIDATE=93
EXPECTED_SOURCE_DRIVEN_COMPILE_AND_AUDIT=0
EXPECTED_COUNTS_ARE_OBSERVED_FOR_THIS_VERSION=FALSE
RUNNER_CHANGE=TWO_PACKAGE_AND_VERSION_CONSTANTS_ONLY
CACHE_HASHING_COMPILE_AUDIT_SCHEDULING_RAM_OWNERSHIP_SHUTDOWN_LOGIC=UNCHANGED
NEW_NATIVE_EXECUTION_BY_ASSISTANT=NOT_RUN
NEW_RUNTIME_MOCKS=NOT_RUN
PRIOR_V0_2_22_RUNTIME_MOCKS=20_PASS_0_FAIL;PARENT_SOURCE_DIGEST_ONLY
RUNTIME_SPEEDUP_CLAIMED=FALSE
SEMANTIC_CANCELLATION_FORWARD=PRIOR_EXPLICIT_AXIOMS_AND_LATEST_FROZEN_AGGREGATE_PASS
SEMANTIC_CANCELLATION_EQUIVALENCE=PRIOR_EXPLICIT_AXIOMS_AND_LATEST_FROZEN_AGGREGATE_PASS
WITNESS_ADMISSIBILITY=EXPLICIT_ALL_ORDER_PREDICATE
FINITE_CHECKER_SOUNDNESS=OPEN
FINITE_CHECKER_EQUIVALENCE=OPEN
FORMAL_CLOSURE=OPEN
UNCONDITIONAL_RH=NOT_ESTABLISHED
''', encoding='utf-8')

frozen = []
for p in sorted(BASE.rglob('*.lean')):
    rel = p.relative_to(BASE).as_posix()
    assert (OUT / rel).read_bytes() == p.read_bytes(), rel
    frozen.append({'path': rel, 'sha256': sha(p), 'bytes': p.stat().st_size})
assert len(frozen) == 96
dump(EV / 'FROZEN_SOURCE_MANIFEST.json', {'count': 96, 'files': frozen})
assert (OUT / 'DECLARATIONS.json').read_bytes() == (BASE / 'DECLARATIONS.json').read_bytes()
assembly = {
    'package': OUT.name, 'parent_package': BASE.name, 'revision_kind': 'EVIDENCE_ONLY_NOT_INIT',
    'runner_sha256': sha(OUT / 'tools/native_runner.js'),
    'baseline_runner_sha256': sha(BASE / 'tools/native_runner.js'),
    'changed_lean_sources': [], 'lean_sources_byte_preserved': 96,
    'active_modules': 93, 'audit_targets': 394, 'declaration_inventory_byte_preserved': 1129,
    'reported_parent_native_counts': counts,
    'runtime_algorithm_changes': False, 'new_native_or_lean_execution': False, 'new_runtime_mock_tests': False,
}
dump(WORK / 'ASSEMBLY.json', assembly)
dump(EV / 'ASSEMBLY.json', assembly)
shutil.copyfile(Path(__file__), EV / 'assemble.py')
shutil.copyfile(WORK / 'RUN_COMMAND.txt', EV / 'RUN_COMMAND.txt')
print(json.dumps(assembly, indent=2))
