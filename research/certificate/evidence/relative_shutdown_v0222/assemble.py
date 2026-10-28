from pathlib import Path
import difflib
import hashlib
import json
import re
import shutil

ROOT = Path('/workspace/scratch/f128c1434505')
WORK = ROOT / 'tmp/relative_shutdown_v0222'
BASE = ROOT / 'output/RH_HILBERT_LIMIT_LEAN_v0_2_21_construction'
OUT = ROOT / 'output/RH_HILBERT_LIMIT_LEAN_v0_2_22_construction'
EVREL = 'evidence/relative_shutdown_v0222'
EV = OUT / EVREL
RUNNER_SHA = '8fc5a81e3802a52e3ec12fa2c94177a42b59b202a83b66c9609ea1356889e907'
NEW_RUNNER = 'RH_HILBERT_NATIVE_RUNNER_v0_2_22_RELATIVE_SHUTDOWN_RECHECK'


def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def read_json(p):
    return json.loads(p.read_text(encoding='utf-8'))


def dump(p, value):
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(json.dumps(value, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')


assert sha(BASE.with_suffix('.zip')) == '4bde59b2e1dd110a8659ca9569900492fcc963190f05a85a8b6e75e08982e508'
assert sha(OUT / 'tools/native_runner.js') == RUNNER_SHA
archive = EV / 'baseline_v0221_metadata'
archive.mkdir(parents=True, exist_ok=True)
for rel in [
    'STATUS.json', 'CHECKPOINT.json', 'README.md', 'OPEN_OBLIGATIONS.txt',
    'RUNNER_NOTES.txt', 'runner-version.txt', 'DECLARATIONS.json',
    'PROVENANCE.json', 'STATIC_REVIEW.json', 'RUNNER_LOGIC_VALIDATION.json', 'SHA256SUMS.txt',
]:
    shutil.copyfile(BASE / rel, archive / rel)

log_name = 'USER_NATIVE_V0221_SHUTDOWN_FAIL_EXCERPT.txt'
shutil.copyfile(WORK / log_name, EV / log_name)
log = (EV / log_name).read_text()
assert 'FAILED_STAGE=WORKER_SHUTDOWN\n' in log and 'RUN=FAIL\n' in log
assert 'FINAL_AUDIT_DECLARATIONS=394\n' in log
assert 'FROZEN_REUSE=CancellationAudit\n' in log
assert 'FROZEN_REUSED_MODULES=' not in log and 'AXIOM_AUDIT=PASS' not in log
native = {
    'evidence_kind': 'SELECTED_FINAL_STAGES_FROM_USER_MESSAGE_UTF8_LF_TRANSCRIPTION_NOT_ORIGINAL_LOG_BYTES',
    'reported_package': BASE.name, 'reported_build': 'FAIL', 'reported_run': 'FAIL',
    'reported_failed_stage': 'WORKER_SHUTDOWN',
    'reported_reason': 'Owned workers remain live or uncertain; the workspace lock is preserved until they finish.',
    'ordinary_module_progress': {'completed': 92, 'total': 92, 'active': 0, 'ready': 0, 'lean_threads': 0},
    'reported_new_or_reaudited_module_tasks': 0, 'reported_peak_module_workers': 0,
    'reported_ram_warm': 'SKIPPED_NO_ELIGIBLE_DIRTY_FRONTIER',
    'reported_final_audit': 'CancellationAudit.lean',
    'reported_final_audit_state': 'FROZEN_REUSED',
    'reported_final_audit_declarations': 394,
    'reported_stages_ms': {'PROJECT_MODULES': 58644, 'FINAL_AUDIT': 427, 'WORKER_SHUTDOWN': 548},
    'reported_final_audit_module_elapsed_ms': 343,
    'reported_shutdown': {'launch_inventory_sealed': True, 'launch_records': 417,
        'snapshot_rows': 717, 'queued_unreadable_rows': 0, 'lock_retained': True,
        'reason': 'LEGACY_RELATIVE_RUNNER_WORKSPACE_UNKNOWN', 'offending_process_identity': None},
    'aggregate_module_summary_counts': None,
    'aggregate_module_summary_note': 'Not emitted in the supplied failed run; do not infer final aggregate counters.',
    'explicit_per_declaration_axiom_output_in_excerpt': 0,
    'final_audit_anchor_receipt_path': re.search(r'^SOURCE_ANCHOR_RECEIPT=(.*)$', log, re.M).group(1),
    'receipt_contents_inspected': False, 'independent_native_verification': False,
    'source': EVREL + '/' + log_name, 'source_sha256': sha(EV / log_name),
    'scope': 'Selected exact final-stage excerpt; preceding per-module reuse lines remain in the user message.',
    'cause_limit': 'The old log does not identify the host, its actual script argument, or whether it exited; the two repaired cases are source-level findings, not a proven diagnosis of that process.',
}
dump(EV / 'USER_REPORTED_NATIVE_FAILURE.json', native)

policy = {
    'strategy': 'INITIAL_COMPLETE_INVENTORY_WITH_BOUNDED_EXACT_RECHECK; ONE_FRESH_BARRIER_AFTER_UNRESOLVED_RELATIVE_HOST_ABSENCE',
    'script_classifier': 'RESTRICTED_FULLY_CONSUMED_WSH_SCRIPT_ARGUMENT_PARSER; OLD_BROAD_MATCHER_FOR_UNSUPPORTED_SYNTAX',
    'current_workspace_guard': 'ABSOLUTE_ROOT_ANYWHERE_CHECK_PRECEDES_SCRIPT_CLASSIFICATION; EVERY_INITIAL_ROW_CHECKED_BEFORE_ABSENCE_QUERIES',
    'absence_rule': 'ONLY_COMPLETE_SUCCESSFUL_EXACT_PID_QUERY_WITH_NO_ROW',
    'identity_rule': 'EXACT_PID_FULL_CREATION_NAME_PARENT; KNOWN_RELATIVE_COMMAND_MUST_REMAIN_IDENTICAL',
    'unreadable_to_relative': 'REMAINS_PENDING_AND_BINDS_FIRST_READABLE_COMMAND',
    'post_exit_barrier': 'ONE_FRESH_COMPLETE_INVENTORY; NEW_UNRESOLVED_RELATIVE_HOST_FAILS_IMMEDIATELY; UNREADABLE_ROWS_SHARE_EXISTING_BUDGET',
    'contradictory_reappearance': 'RETAIN_LOCK',
    'persistent_uncertainty_or_identity_change': 'RETAIN_LOCK',
    'preexisting_parent_exemption_extended_to_children': False,
    'existing_admission_and_follower_exceptions': 'EXACT_FUNCTION_BYTES_PRESERVED',
    'own_launch_boundary': 'EXACT_EXISTING_SEAL_AND_COMPLETION_CHECKS_PRESERVED',
    'owner_and_self_checks': 'EXACT_BEFORE_AND_AFTER_EACH_INVENTORY_ITERATION',
    'stale_lock_acquisition_and_recovery': 'CONTROL_FLOW_UNCHANGED; SHARED_SCRIPT_CLASSIFIER_CORRECTED; NO_RETRY_OR_NEW_EXEMPTION',
    'scope': 'COOPERATIVE_WORKSPACE_LOCK_AND_POINT_IN_TIME_PROCESS_OBSERVATIONS; NOT_ATOMIC_OS_PROCESS_TREE_CLOSURE',
    'query_and_wait_limits': {
        'complete_machine_inventory_queries_max': 2,
        'queued_rows_across_both_inventories_max': 64, 'rounds_max': 6,
        'targeted_worker_queries_per_round_max': 64, 'targeted_worker_queries_total_max': 384,
        'targeted_self_queries_total_max': 14, 'scheduled_sleep_between_rounds_ms': 200,
        'scheduled_sleep_total_max_ms': 1000, 'existing_owned_worker_drain_ms': 30000,
        'hard_wall_clock_bound': False,
        'runtime_note': 'WMI/COM enumeration and status calls retain their existing lack of a wrapper-imposed hard deadline.',
    },
}
dump(EV / 'SHUTDOWN_POLICY.json', policy)

old_status = read_json(BASE / 'STATUS.json')
old_checkpoint = read_json(BASE / 'CHECKPOINT.json')
last_pass = old_checkpoint['latest_successful_full_run']
status = dict(old_status)
status.update({
    'package': OUT.name, 'version': '0.2.22',
    'revision_scope': 'RUNTIME_ONLY_RELATIVE_RUNNER_SHUTDOWN_REPAIR; ALL_PROOF_SOURCES_FROZEN',
    'latest_user_native_evidence': native, 'previous_user_native_evidence': old_status['latest_user_native_evidence'],
    'latest_successful_full_run': last_pass,
    'working_artifact_retention_next_run': 'A new v0.2.22 workspace may restore validated shared anchors; later runs may retain validated working artifacts.',
    'runtime_logic_change': 'CONSERVATIVE_SCRIPT_CLASSIFICATION_AND_BOUNDED_RELATIVE_HOST_SHUTDOWN_REVALIDATION',
    'new_runtime_mocks_run': True,
    'native_validation': 'V0_2_21_SHUTDOWN_FAIL_AFTER_REUSED_AUDIT; LAST_COMPLETE_PASS_V0_2_20; V0_2_22_NOT_RUN_NATIVELY',
    'delivery_filename': OUT.name + '.zip', 'canonical_archive_root': OUT.name,
    'new_version_workspace': 'E:\\RH-FAST\\workspaces\\' + OUT.name,
    'earlier_status_archive': EVREL + '/baseline_v0221_metadata/STATUS.json',
    'shutdown_inventory_recheck': policy,
    'selected_inventory_records_updated': 0, 'declaration_inventory_records_byte_preserved': 1129,
    'explicit_axiom_outputs_in_latest_tail': 0,
    'explicit_axiom_outputs_in_last_successful_full_run': 14,
})
dump(OUT / 'STATUS.json', status)
checkpoint = dict(old_checkpoint)
checkpoint.update({
    'schema': 'RH_HILBERT_V0222_RELATIVE_RUNNER_RUNTIME_REPAIR_V1',
    'source_package': BASE.name, 'source_zip_sha256': sha(BASE.with_suffix('.zip')),
    'checkpoint_package': OUT.name,
    'evidence_class': 'USER_SUPPLIED_SHUTDOWN_FAILURE_AFTER_REUSED_AUDIT; SOURCE_BOUND_SIMULATED_RUNTIME_TESTS; LEAN_SOURCES_FROZEN',
    'latest_user_run': native, 'changed_runtime_policy': True,
    'runner_changes': status['runtime_logic_change'],
    'source_manifest': EVREL + '/FROZEN_SOURCE_MANIFEST.json',
    'new_runtime_test_execution': True,
    'previous_checkpoint': EVREL + '/baseline_v0221_metadata/CHECKPOINT.json',
    'delivery_filename': OUT.name + '.zip', 'canonical_archive_root': OUT.name,
    'shutdown_policy': policy,
})
dump(OUT / 'CHECKPOINT.json', checkpoint)

command = ('cd /d "%USERPROFILE%\\Downloads" && (if not exist "E:\\RH-FAST\\workspaces" mkdir "E:\\RH-FAST\\workspaces")'
    ' && tar -xf "' + OUT.name + '.zip" -C "E:\\RH-FAST\\workspaces"'
    ' && cmd /k call "E:\\RH-FAST\\workspaces\\' + OUT.name + '\\run.cmd"')
(WORK / 'RUN_COMMAND.txt').write_text(command + '\n', encoding='utf-8')
(OUT / 'README.md').write_text('''# RH Hilbert Limit v0.2.22 construction

This revision repairs the shutdown handling of legacy script hosts. It preserves
all 96 Lean source files, all 394 selected audit targets, the 92-module ordinary
compile order and the `CancellationAudit.lean` endpoint. The mode remains
`A_TIER_LEAN`, the target remains `LOCAL_COMPILER`, and the branch remains
`RH_HILBERT_LIMIT / Hilbert.vector`.

## Reported failure and repair

The supplied v0.2.21 log reaches 92/92 ordinary modules with zero new or
reaudited tasks. It restores `CancellationAudit` and reports 394 audit targets.
The run then fails at `WORKER_SHUTDOWN`: a readable legacy relative runner has
an unknown workspace. The old diagnostic does not identify that process or
its actual script argument. This revision does not claim to have established
which process caused that native failure.

The guard now identifies the actual WSH script argument for a deliberately
restricted, fully consumed command syntax. A later argument containing
`native_runner.js` no longer classifies an unrelated script as the runner.
Unsupported quoting or host switches retain the previous conservative
matcher. Absolute references to the current workspace still trigger the
existing guard before script classification.

An unresolved relative runner receives bounded exact process checks during
owned shutdown. A still-live host remains a blocker. Only a complete exact
query reporting absence retires that identity. PID reuse, changed creation
time, parent, executable or known relative command, incomplete queries and
query failures preserve the lock. An unreadable host that becomes a relative
runner remains pending and binds its first readable command.

After such a relative host exits, one fresh complete inventory checks for
workers it may have left behind. A new unresolved relative host in that final
inventory blocks release immediately. A current-workspace worker blocks
release as before. These are cooperative lock and point-in-time process
checks, not an atomic operating-system process-tree guarantee.

The recheck has one shared budget: 64 queued rows, six rounds, at most two
complete inventories and five scheduled 200 ms waits. WMI calls have no new
hard wall-clock deadline. Existing exact fresh-admission and read-only
follower exceptions are unchanged. No foreign process is terminated, no old
workspace lock is deleted, and no forced stale recovery is added.

If a genuinely unresolved legacy runner remains active, the lock is still
retained. The diagnostic now identifies its PID, parent, creation timestamp,
host, parser mode, relative script and command hash without printing arbitrary
script arguments. This is a conservative repair, not a guarantee that every
legacy-host conflict will become a successful run.

## Preserved mathematical endpoint

The last complete user-supplied native pass is v0.2.20. Its printed standard
axiom audits include:

```lean
RH_HilbertLimit.nativeRH_of_exists_admissible_cancellationBudget
  (hWitness : ∃ W, W.Admissible) : RiemannHypothesis

RH_HilbertLimit.exists_admissible_cancellationBudget_iff_nativeRH :
  (∃ W, W.Admissible) ↔ RiemannHypothesis
```

Thus the recorded semantic endpoint is retained: assuming an admissible
cancellation budget exists, RH follows, and the converse is also recorded.
The budget contains two natural numbers; admissibility is a universal
condition after the cutoff. This is not a terminating finite Bool checker.
The requested finite-checker soundness and equivalence remain **OPEN**, and
the runner retains `FORMAL_CLOSURE=OPEN`. No unconditional admissible witness,
accepted finite-checker witness or unconditional RH is obtained here.

## Cache and validation

All 93 active modules, including the final audit, remain eligible for reuse
when the existing same-target source, dependency, toolchain, artifact and
audit checks succeed. Zero compilation tasks are induced by source changes.
These are conditional expectations, not aggregate counters from the failed
v0.2.21 log. Missing or invalid cache evidence still causes a rebuild or failure.

The launcher, cache keys, content hashing, helper sources, compiler/audit
flags, scheduling and RAM admission code are preserved. This revision has
no measured runtime-speedup claim. The latest run had no dirty frontier, so
it did not need parallel compilation or RAM warming.

Twenty focused tests execute the assembled runner functions in a Node VM
with synthetic process, WMI, shell, clock and file boundaries. All pass and
the report binds the candidate SHA256. No Windows/WSH/native runner, Lean,
Lake, C# compiler, Wine or CI was executed during preparation. Native receipt
contents were not supplied for independent inspection. The new package
still needs its native run on the user's machine.

## Run

Save the ZIP in Downloads and run this one CMD command:

```cmd
''' + command + '''
```

This uses a new workspace under `E:\\RH-FAST\\workspaces` and the established
shared cache under `E:\\RH-FAST\\anchors`. The earlier retained lock remains
under its own workspace. The runner uses installed native Lean 4.33.0 and
compatible cached Mathlib. It adds no Lake, Python, PowerShell, WSL or network
setup requirement.

## Evidence

The new evidence directory contains a selected exact transcription of the
reported final stages, the runtime diff, frozen source manifest, protected
function comparison, focused simulated-host report and independent source
review. Earlier evidence and declaration metadata remain intact. No new
compiled artifacts, native PASS receipts or mathematical audits are created.
`SHA256SUMS.txt` covers every other payload file.

Primary API references used for the narrow runtime design:

- [Microsoft cscript command documentation](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/cscript) separates the script filename from its arguments.
- [Microsoft Win32_Process documentation](https://learn.microsoft.com/en-us/windows/win32/cimwin32prov/win32-process) describes the command, process identity, parent and creation fields used by the existing queries.
''', encoding='utf-8')

obligations = (BASE / 'OPEN_OBLIGATIONS.txt').read_text()
obligations = obligations.replace('PACKAGE=v0.2.21 construction', 'PACKAGE=v0.2.22 construction', 1)
obligations = obligations.replace('No mathematical edit is made in this checkpoint.', 'No mathematical edit is made in this runtime repair.', 1)
obligations += '''\n7. v0.2.21 completed its reused proof/audit stages but failed at shutdown.
   v0.2.22 changes only runtime classification and bounded revalidation.
   Twenty simulated-host tests pass; native Windows validation is still
   required. Persistent unresolved relative hosts continue to retain locks.
'''
(OUT / 'OPEN_OBLIGATIONS.txt').write_text(obligations, encoding='utf-8')
(OUT / 'RUNNER_NOTES.txt').write_text('''PACKAGE=''' + OUT.name + '''
RUNNER=''' + NEW_RUNNER + '''
MODE=A_TIER_LEAN
TARGET=LOCAL_COMPILER
REVISION=RUNTIME_ONLY_NOT_INIT
LATEST_USER_RUN=V0_2_21_FAIL_AT_WORKER_SHUTDOWN_AFTER_REUSED_FINAL_AUDIT
LAST_COMPLETE_NATIVE_PASS=V0_2_20_USER_SUPPLIED
LATEST_AGGREGATE_MODULE_COUNTS=NOT_EMITTED
LEAN_SOURCES_BYTE_PRESERVED=96
CHANGED_LEAN_SOURCES=0
AUDIT_TARGETS_PRESERVED=394
ACTIVE_MODULES=93
DECLARATION_INVENTORY_RECORDS_PRESERVED=1129
EXPECTED_REUSE_IF_ALL_IDENTITIES_VALIDATE=93
EXPECTED_SOURCE_DRIVEN_COMPILE_AND_AUDIT=0
EXPECTED_COUNTS_ARE_OBSERVED=FALSE
SCRIPT_CLASSIFICATION=LIMITED_ACTUAL_ARGUMENT_PARSE_WITH_CONSERVATIVE_FALLBACK
RELATIVE_HOST_RECHECK=EXACT_IDENTITY_AND_COMMAND; ABSENCE_ONLY
POST_RELATIVE_EXIT_BARRIER=ONE_FRESH_COMPLETE_INVENTORY
PERSISTENT_OR_NEW_FINAL_BARRIER_AMBIGUITY=RETAIN_LOCK
ACQUISITION_ADMISSION_AND_FOLLOWER_CONTROL_FLOW=BYTE_PRESERVED
CACHE_HASHING_COMPILE_AUDIT_SCHEDULING_RAM_ADMISSION=BYTE_PRESERVED
SHARED_RECHECK_ROWS_MAX=64
RECHECK_ROUNDS_MAX=6
COMPLETE_INVENTORIES_MAX=2
WORKER_QUERIES_MAX=384
SELF_QUERIES_MAX=14
SCHEDULED_RECHECK_SLEEP_TOTAL_MAX_MS=1000
WMI_HARD_DEADLINE=NOT_ADDED
NATIVE_EXECUTION_BY_ASSISTANT=NOT_RUN
SIMULATED_HOST_FOCUSED_TESTS=20_PASS_0_FAIL
RUNTIME_SPEEDUP_CLAIMED=FALSE
SEMANTIC_CANCELLATION_FORWARD=PRIOR_USER_NATIVE_AXIOM_PASS_PRESERVED
SEMANTIC_CANCELLATION_EQUIVALENCE=PRIOR_USER_NATIVE_AXIOM_PASS_PRESERVED
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
before = (BASE / 'tools/native_runner.js').read_text()
after = (OUT / 'tools/native_runner.js').read_text()
(EV / 'RUNNER_PATCH.diff').write_text(''.join(difflib.unified_diff(
    before.splitlines(keepends=True), after.splitlines(keepends=True),
    fromfile=BASE.name + '/tools/native_runner.js', tofile=OUT.name + '/tools/native_runner.js')), encoding='utf-8')
shutil.copytree(WORK / 'tests', EV / 'tests', dirs_exist_ok=True)
shutil.copyfile(Path(__file__), EV / 'assemble.py')
shutil.copyfile(WORK / 'RUN_COMMAND.txt', EV / 'RUN_COMMAND.txt')
dump(WORK / 'ASSEMBLY.json', {
    'package': OUT.name, 'parent_package': BASE.name, 'runner_sha256': RUNNER_SHA,
    'changed_lean_sources': [], 'lean_sources_byte_preserved': 96,
    'active_modules': 93, 'audit_targets': 394, 'declaration_inventory_byte_preserved': 1129,
    'new_native_or_lean_execution': False, 'simulated_tests': 20,
})
shutil.copyfile(WORK / 'ASSEMBLY.json', EV / 'ASSEMBLY.json')
print(json.dumps(read_json(WORK / 'ASSEMBLY.json'), indent=2))
