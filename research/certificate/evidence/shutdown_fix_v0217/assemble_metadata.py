from pathlib import Path
from datetime import datetime
from zoneinfo import ZoneInfo
import hashlib
import json
import shutil

ROOT = Path('/workspace/scratch/f128c1434505')
WORK = ROOT / 'tmp/shutdown_fix_v0217'
BASE = ROOT / 'output/reuse_record_v0216/RH_HILBERT_LIMIT_LEAN_v0_2_16_construction'
BASE_ZIP = ROOT / 'output/RH_HILBERT_LIMIT_LEAN_v0_2_16_REUSE_RECORD_construction.zip'
OUT = ROOT / 'output/RH_HILBERT_LIMIT_LEAN_v0_2_17_construction'
EVREL = 'evidence/shutdown_fix_v0217'
EV = OUT / EVREL
RUNNER_VERSION = 'RH_HILBERT_NATIVE_RUNNER_v0_2_17_EXACT_PROCESS_RECHECK'

def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()

def js(p):
    return json.loads(p.read_text(encoding='utf-8'))

def write(p, text):
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(text, encoding='utf-8')

def dump(p, value):
    write(p, json.dumps(value, indent=2, ensure_ascii=False) + '\n')

assert sha(BASE_ZIP) == '03c16d7cd2cdfb9e6fa5081d7084a667e2f27f34bb313c8993d55f379b24074d'
metadata = ['STATUS.json', 'CHECKPOINT.json', 'README.md', 'OPEN_OBLIGATIONS.txt',
            'PROVENANCE.json', 'STATIC_REVIEW.json', 'RUNNER_LOGIC_VALIDATION.json',
            'RUNNER_NOTES.txt', 'SHA256SUMS.txt', 'runner-version.txt']
for rel in metadata + ['tools/native_runner.js']:
    dest = EV / 'baseline_v0216_metadata' / rel
    assert not dest.exists(), 'Do not overwrite preserved baseline metadata.'
    dest.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(BASE / rel, dest)

review = js(WORK / 'evidence/NATIVE_SHUTDOWN_FAIL_REVIEW.json')
transcript = WORK / 'evidence/USER_NATIVE_SHUTDOWN_FAIL_TAIL.txt'
assert sha(transcript) == review['transcript']['sha256'] == 'd5d0f7e509bbf1eec992b010752aaf76a57422472e2f228cd70cc1424e427d6f'
report = {
    'evidence_kind': 'USER_MESSAGE_UTF8_LF_TRANSCRIPTION_NOT_ORIGINAL_NATIVE_LOG_BYTES',
    'reported_package': BASE.name,
    'reported_build': 'FAIL', 'reported_run': 'FAIL', 'failed_stage': 'WORKER_SHUTDOWN',
    'reported_parallel_peak_module_workers': 0, 'reported_new_or_reaudited_tasks': 0,
    'reported_selected_final_audit': 'AnalyticAudit.lean', 'reported_final_audit_declarations': 370,
    'reported_retained_and_reused_final_module': 'AnalyticAudit',
    'reported_stage_elapsed_ms': review['stage_timings_ms'],
    'reported_shutdown_inventory': review['shutdown_inventory'],
    'source': EVREL + '/evidence/USER_NATIVE_SHUTDOWN_FAIL_TAIL.txt',
    'source_sha256': sha(transcript), 'source_bytes': transcript.stat().st_size,
    'review': EVREL + '/evidence/NATIVE_SHUTDOWN_FAIL_REVIEW.json',
    'final_overall_axiom_summary': 'NOT_EMITTED_IN_FAILED_EXCERPT',
    'aggregate_compiled_and_reused_module_counts': 'NOT_SUPPLIED_IN_FAILED_EXCERPT',
    'all_90_working_artifacts_retained': 'NOT_INFERRED_FROM_FINAL_AUDIT_RETENTION_LINE',
    'native_receipt_contents_or_exact_fingerprints': 'NOT_SUPPLIED',
    'independent_native_verification': 'NOT_PERFORMED',
    'first_marker': 'CLIPPED_PREFIX_PRESERVED_VERBATIM',
}
dump(EV / 'USER_REPORTED_SHUTDOWN_FAILURE.json', report)

status = js(BASE / 'STATUS.json')
status['previous_user_native_evidence'] = status['latest_user_native_evidence']
status['latest_user_native_evidence'] = report
status.update({
    'package': OUT.name, 'version': '0.2.17', 'delivery_filename': OUT.name + '.zip',
    'canonical_archive_root': OUT.name,
    'revision_scope': 'SHUTDOWN_PROCESS_REVALIDATION_AND_OWN_LAUNCH_ACCOUNTING; NO_LEAN_SOURCE_CHANGE',
    'runtime_logic_change': 'SEAL_AND_ACCOUNT_OWN_LAUNCHES; REVALIDATE_UNREADABLE_ROWS_FROM_ONE_COMPLETE_SHUTDOWN_INVENTORY_BY_EXACT_PROCESS_IDENTITY',
    'runtime_native_verification': 'V0_2_17_NOT_RUN; LATEST_V0_2_16_REPORT_FAILED_AT_WORKER_SHUTDOWN_AFTER_FINAL_AUDIT_REUSE',
    'native_validation': 'NO_ASSISTANT_NATIVE_EXECUTION; PREVIOUS_V0_2_16_REPORTED_PROOF_AUDIT_PASS_PRESERVED',
    'source_review_scope': 'EXACT_PROOF_INPUT_PRESERVATION_PLUS_TARGETED_RUNNER_LOGIC_REVIEW',
    'prior_declaration_metadata': 'All 1105 declaration inventory entries are byte-preserved from the successful v0.2.16 reuse record.',
    'new_runtime_mocks_run': True,
    'runtime_mock_scope': 'NODE_VM_SYNTHETIC_BOUNDARY_ONLY; NOT_WINDOWS_WSH_WMI_OR_LEAN',
    'earlier_status_archive': EVREL + '/baseline_v0216_metadata/STATUS.json',
    'expected_warm_counts_are_observed': False,
    'warm_count_observation_scope': '0_COMPILED_90_REUSED_WAS_USER_REPORTED_FOR_V0_2_16_ONLY; V0_2_17_PENDING',
    'working_artifact_retention_next_run': 'NEW_V0_2_17_WORKSPACE_MAY_RESTORE_VALID_SHARED_ANCHORS; LATER_SAME_WORKSPACE_RUNS_MAY_RETAIN_VALIDATED_FILES',
    'new_version_workspace': 'E:' + chr(92) + 'RH-FAST' + chr(92) + 'workspaces' + chr(92) + OUT.name,
    'old_retained_lock_policy': 'PRESERVED_IN_V0_2_16_WORKSPACE; NO_DELETE_OR_FORCED_RECOVERY',
    'first_run_expected_new_compilation': 'None from source changes; missing, changed or invalid source/dependency/toolchain/artifact/audit identities still rebuild or fail.',
    'shutdown_inventory_recheck': {
        'strategy': 'ONE_COMPLETE_INVENTORY_PLUS_BOUNDED_TARGETED_REVALIDATION_OF_ITS_UNREADABLE_ROWS',
        'absence_rule': 'COMPLETE_SUCCESSFUL_TARGETED_QUERY_RETURNS_NO_ROW',
        'readable_row_rule': 'MATCH_PID_FULL_CREATION_NAME_AND_PARENT_THEN_REENTER_EXISTING_WORKSPACE_GUARD',
        'persistent_uncertainty_or_identity_change': 'RETAIN_LOCK',
        'preexisting_parent_exemption_extended_to_children': False,
        'own_launch_boundary': 'SEALED_BEFORE_SHUTDOWN; EVERY_NATIVE_LAUNCH_RECORDED_AND_COMPLETION_CHECKED',
        'owner_and_self_checks': 'EXACT_BEFORE_AND_AFTER; NO_BROAD_SECOND_CENSUS',
        'stale_lock_acquisition_and_recovery': 'UNCHANGED',
        'scope': 'COOPERATIVE_WORKSPACE_LOCK_AND_PROCESS_OBSERVATIONS; NOT_AN_ATOMIC_OS_PROCESS_SNAPSHOT',
        'query_and_wait_limits': js(WORK / 'review/EXACT_PROCESS_IMPLEMENTATION.json')['shutdown_query_limits'],
    },
})
status.pop('same_workspace_reused', None)
dump(OUT / 'STATUS.json', status)

checkpoint = js(BASE / 'CHECKPOINT.json')
checkpoint.update({
    'schema': 'RH_HILBERT_V0217_RUNTIME_REPAIR_FROZEN_PROOF_CHECKPOINT_V1',
    'source_package': BASE.name, 'source_zip_sha256': sha(BASE_ZIP),
    'checkpoint_package': OUT.name, 'delivery_filename': OUT.name + '.zip',
    'canonical_archive_root': OUT.name,
    'evidence_class': 'V0_2_16_REPORTED_STANDARD_AXIOM_AUDIT_PASS_PRESERVED; V0_2_17_RUNTIME_REPAIR_NOT_NATIVELY_RUN',
    'latest_user_run': report,
    'reported_run_scope': 'Historical successful v0.2.16 report, preserved separately from latest shutdown failure.',
    'warm_counts_are_observed': False, 'warm_count_observation_scope': 'NOT_OBSERVED_FOR_V0_2_17',
    'changed_runtime_policy': True, 'package_and_runner_identity_changed': True,
    'all_runner_and_helper_bytes_preserved': False,
    'helper_and_launcher_bytes_preserved': True,
    'runtime_change_scope': 'Process lifetime accounting and shutdown-only exact-row revalidation; source/cache/audit policies preserved.',
    'previous_checkpoint': EVREL + '/baseline_v0216_metadata/CHECKPOINT.json',
    'new_native_or_test_execution': True,
    'new_native_execution': False,
    'new_runtime_test_scope': 'TARGETED_NODE_VM_MOCKS_ONLY',
})
dump(OUT / 'CHECKPOINT.json', checkpoint)
write(OUT / 'runner-version.txt', RUNNER_VERSION + '\n')

command = ('cd /d "%USERPROFILE%\\Downloads" && (if not exist "E:\\RH-FAST\\workspaces" mkdir "E:\\RH-FAST\\workspaces")'
           ' && tar -xf "' + OUT.name + '.zip" -C "E:\\RH-FAST\\workspaces" && cmd /k call "E:\\RH-FAST\\workspaces\\' + OUT.name + '\\run.cmd"')
base_readme = (BASE / 'README.md').read_text(encoding='utf-8')
endpoint_and_runtime = base_readme.split('## Exact analytic endpoint retained\n', 1)[1].split('## Preservation and evidence files\n', 1)[0]
write(OUT / 'README.md', '''# RH Hilbert Limit v0.2.17 — exact-process shutdown repair

Mode **A_TIER_LEAN**; target **LOCAL_COMPILER**; native Windows Lean **4.33.0**.

This package repairs the shutdown check following the latest reported v0.2.16 failure. All **92 Lean sources**, **370 selected audit targets**, theorem definitions and hypotheses, declaration inventory, native helpers and launcher are preserved. The changed JavaScript runner is **prepared for the user's native run**; its static and synthetic checks do not establish a Windows or Lean PASS.

## Run

Download the ZIP to Downloads and run this in Windows CMD:

```cmd
''' + command + '''
```

The new workspace is `E:\\RH-FAST\\workspaces\\RH_HILBERT_LIMIT_LEAN_v0_2_17_construction`. The existing v0.2.16 workspace and its retained lock remain untouched. The new runner uses the same shared `E:\\RH-FAST\\anchors` cache, subject to all existing source, dependency, toolchain, artifact and audit checks. It may restore the 90 valid active module artifacts into the new workspace; later runs in that same workspace can retain validated working files. A package version change does not by itself require proof recompilation.

The command leaves CMD open. Native execution uses the already installed compatible compiler and cached Mathlib. The runner does not use Lake setup, Python, PowerShell, WSL or network setup.

## What the latest log establishes

The visible clipped progress line ends at 89/89 with no active worker, and the full lines report zero new or reaudited tasks. `AnalyticAudit` is explicitly retained and frozen-reused with 370 declarations. Shutdown then observes six different unreadable `certutil.exe` process rows, all bearing numeric parent 34008, and reports `PROJECT_BUILD=FAIL`, `FAILED_STAGE=WORKER_SHUTDOWN`, `RUN=FAIL`.

The supplied tail does not include a final overall axiom-PASS summary or aggregate compiled/reused module counts. It establishes retention of the final audit artifact, not retention of all 90 artifacts. The previous v0.2.16 successful run remains separately recorded evidence for all 90 reused modules and the standard-axiom audit with no `sorryAx`. No mathematical result is promoted from this failed run.

Source inspection and a focused synthetic reproduction show that shutdown logging and lock metadata reads do not themselves launch `certutil`. The changing rows are consistent with another process's continuing hashing, but their unreadable commands do not identify a foreign workspace or prove that the workers have exited.

## The repair

1. **Close the runner's own launch set.** Every direct native launch is recorded before it starts. Shutdown seals that set and checks the retained process handles or completed synchronous waits. A live, uncertain or incompletely recorded owned launch prevents lock release.
2. **Keep one complete shutdown inventory.** Each unreadable relevant row is rechecked by a targeted process query. A row is retired only after a successfully completed query returns no process. A readable row with the same PID, full creation identity, name and parent goes through the existing workspace guard.
3. **Preserve uncertainty.** A still-unreadable worker, changed identity, reused PID, inconsistent response or query failure retains the lock. A preexisting parent's admission grants no exemption to its children. Exact lock-owner and self-process checks surround the revalidation.

The retries now resolve the identities that actually caused uncertainty, instead of repeatedly replacing the entire inventory and encountering another hash process. Rechecks are bounded. This remains a process-observation protocol under the workspace lock; it is not an atomic operating-system snapshot. Existing acquisition, stale-lock recovery, permanent quarantine and release rules are preserved.

The PID/creation and query-result handling follows Microsoft's [Win32_Process documentation](https://learn.microsoft.com/en-us/windows/win32/cimwin32prov/win32-process) and [SWbemServices.ExecQuery documentation](https://learn.microsoft.com/en-us/windows/win32/wmisdk/swbemservices-execquery). Source links and the precise design inference are recorded in the evidence directory.

## Exact analytic endpoint retained
''' + endpoint_and_runtime + '''## Evidence and validation

`STATUS.json` separates the latest failed run, the earlier successful proof-audit evidence, and the unexecuted native repair. `CHECKPOINT.json` preserves all ten exact endpoint types. `DECLARATIONS.json` is byte-identical to the previous delivery. Formal closure and the finite raw terminating-checker equivalence remain **OPEN**.

`evidence/shutdown_fix_v0217` contains the exact clipped-log transcription, a bounded review, the runner change review, targeted Node VM tests and the archived baseline metadata. Test processes, files and WMI replies are simulated. No Lean, Lake, Windows/WSH/WMI execution, C# compilation, Wine or CI was performed during preparation. The tests cover the new shutdown behavior and failure boundaries; historical test records retain their original source bindings.

`RUNNER_LOGIC_VALIDATION.json` and `STATIC_REVIEW.json` state the exact checked scope. Prior evidence and all mathematical source bytes are preserved. `SHA256SUMS.txt` covers all other payload files. The ZIP contains no fabricated compiled artifacts or native receipts.
''')

write(OUT / 'OPEN_OBLIGATIONS.txt', '''CURRENT PACKAGE: v0.2.17 construction, exact-process shutdown repair
PROOF BASELINE: v0.2.16 reported successful standard-axiom reuse audit

1. Run the changed runner on the user's native Windows target. The latest
   v0.2.16 run reused the final 370-declaration audit but failed at shutdown.
   The v0.2.17 repair has no native PASS yet. Static/Node mock checks are
   not Windows, WMI, Lean or axiom-audit execution.

2. All 92 Lean sources, exact theorem statements, hypotheses, audit targets
   and declaration inventory remain unchanged. The earlier reported
   successful proof-audit evidence is preserved separately from this failure.

3. Formal closure remains OPEN:
     (exists W : FiniteWitness, check W = true) iff _root_.RiemannHypothesis
   Remaining work: finite raw data format, terminating actual-RH checker,
   soundness and completeness. An obtained witness is not required to prove
   the equivalence; no accepted witness has been supplied.

4. A finite natural B or K whose admissibility is quantified over all orders
   is not itself a terminating finite raw checker. A finite prefix has not
   been certified as an infinite tail bound.

5. Actual subexponential growth and unconditional RH are not established.
   The ordinary root-scale limit exists in the frozen source; its existence
   alone does not establish value one. Unrooted variation convergence is
   not asserted.

6. Native process queries must resolve each uncertain row or retain the
   lock. Parent identity, executable name or a retry timeout alone never
   establishes that an unreadable live worker is unrelated or terminated.
   The old retained lock is preserved; no forced cleanup is introduced.
''')
write(OUT / 'RUNNER_NOTES.txt', '\n'.join([
    'PACKAGE=' + OUT.name, 'RUNNER=' + RUNNER_VERSION, 'MODE=A_TIER_LEAN', 'TARGET=LOCAL_COMPILER',
    'LATEST_NATIVE_RUN=V0_2_16_FAIL_AT_WORKER_SHUTDOWN', 'PREVIOUS_NATIVE_PROOF_AUDIT=USER_REPORTED_V0_2_16_PASS',
    'NATIVE_V0_2_17_EXECUTION=PENDING', 'LEAN_SOURCE_FILES_BYTE_PRESERVED=92',
    'SELECTED_FINAL_AUDIT=AnalyticAudit.lean', 'SELECTED_AUDIT_DECLARATIONS=370',
    'PROOF_AND_AUDIT_INPUT_CHANGES=NONE', 'DECLARATION_INVENTORY=BYTE_PRESERVED_1105_ENTRIES',
    'CACHE_ACCEPTANCE=UNCHANGED_SAME_TARGET_FULL_VALIDATION',
    'SHUTDOWN=SEALED_OWN_LAUNCHES_AND_EXACT_PROCESS_REVALIDATION',
    'PARENT_CHILD_EXEMPTION=NONE', 'PERSISTENT_UNCERTAINTY=RETAIN_LOCK',
    'ACQUISITION_AND_STALE_LOCK_RECOVERY=UNCHANGED', 'OLD_V0_2_16_LOCK=UNTOUCHED',
    'NEW_NATIVE_EXECUTION_BY_ASSISTANT=NOT_RUN', 'NEW_RUNTIME_TESTS=TARGETED_NODE_VM_MOCKS_ONLY',
    'FORMAL_CLOSURE=OPEN', 'FINITE_CHECKER_EQUIVALENCE=OPEN', 'UNCONDITIONAL_RH=NOT_ESTABLISHED', '',
]))
dump(WORK / 'ASSEMBLY.json', {
    'baseline': str(BASE), 'baseline_zip': str(BASE_ZIP), 'baseline_zip_sha256': sha(BASE_ZIP),
    'candidate': str(OUT), 'metadata_changed': metadata,
    'changed_runtime_files': ['tools/native_runner.js'],
    'changed_lean_sources': [], 'all_lean_sources_preserved': 92,
    'latest_user_evidence': report, 'prepared_at': datetime.now(ZoneInfo('Europe/Berlin')).isoformat(),
})
print(json.dumps({'candidate': str(OUT), 'metadata_ready': True, 'native_validation': 'PENDING'}, indent=2))
