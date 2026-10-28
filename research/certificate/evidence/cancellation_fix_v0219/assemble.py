from pathlib import Path
import hashlib
import json
import shutil

ROOT = Path('/workspace/scratch/f128c1434505')
WORK = ROOT / 'tmp/cancellation_fix_v0219'
BASE = ROOT / 'output/RH_HILBERT_LIMIT_LEAN_v0_2_18_construction'
OUT = ROOT / 'output/RH_HILBERT_LIMIT_LEAN_v0_2_19_construction'
EVREL = 'evidence/cancellation_fix_v0219'
EV = OUT / EVREL
OLD_RUNNER = 'RH_HILBERT_NATIVE_RUNNER_v0_2_18_SEMANTIC_CANCELLATION'
NEW_RUNNER = 'RH_HILBERT_NATIVE_RUNNER_v0_2_19_ROW_VARIATION_UNFOLD'


def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def read_json(p):
    return json.loads(p.read_text(encoding='utf-8'))


def dump(p, value):
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(json.dumps(value, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')


assert sha(BASE.with_suffix('.zip')) == 'f7dcae7d6855b303ee9489b09cb473460cba30ca6118306af56fe6429b41a8be'
assert not OUT.exists()
shutil.copytree(BASE, OUT)
archive = EV / 'baseline_v0218_metadata'
archive.mkdir(parents=True)
for rel in [
    'STATUS.json', 'CHECKPOINT.json', 'README.md', 'OPEN_OBLIGATIONS.txt',
    'RUNNER_NOTES.txt', 'runner-version.txt', 'DECLARATIONS.json',
    'PROVENANCE.json', 'STATIC_REVIEW.json', 'RUNNER_LOGIC_VALIDATION.json',
    'SHA256SUMS.txt',
]:
    shutil.copyfile(BASE / rel, archive / rel)

source_rel = 'RH_HilbertLimit/Cancellation.lean'
old = b'      rw [Finset.sum_add_distrib, \xe2\x86\x90 Finset.mul_sum, sum_forward_differences]'
new = b'      rw [rowVariation, Finset.sum_add_distrib, \xe2\x86\x90 Finset.mul_sum,\n        sum_forward_differences]'
source = (BASE / source_rel).read_bytes()
assert source.count(old) == 1
(OUT / source_rel).write_bytes(source.replace(old, new, 1))

runner = (BASE / 'tools/native_runner.js').read_bytes()
assert runner.count(BASE.name.encode()) == 1
assert runner.count(OLD_RUNNER.encode()) == 1
runner = runner.replace(BASE.name.encode(), OUT.name.encode(), 1)
runner = runner.replace(OLD_RUNNER.encode(), NEW_RUNNER.encode(), 1)
(OUT / 'tools/native_runner.js').write_bytes(runner)
(OUT / 'runner-version.txt').write_text(NEW_RUNNER + '\n', encoding='utf-8')

transcript = r'''ed goals
u : ℕ → ℝ
n : ℕ
K : ℝ
H : ℕ → ℝ
hlocal : ∀ j ≤ n, cancellationDefect u n j ≤ K * |bernsteinWeight u n j| + (H (j + 1) - H j)
hboundary : H (n + 1) ≤ H 0
⊢ K * ∑ i ∈ Finset.range (n + 1), |bernsteinWeight u n i| + (H (n + 1) - H 0) = K * rowVariation u n + (H (n + 1) - H 0)

COMPILE_FAIL=RH_HilbertLimit.Cancellation
MODULE_ELAPSED_MS=RH_HilbertLimit.Cancellation|5714|COMPILE_FAILED
MODULE_BLOCKED=RH_HilbertLimit.ActualCancellationWitness DEPENDENCY=RH_HilbertLimit.Cancellation
COMPILE_START=RH_HilbertLimit.EventualGrowth
PARALLEL_WORKER=RH_HilbertLimit.EventualGrowth|PHASE=COMPILE|THREADS=16|SHELL_PID=45792
PARALLEL_PROGRESS=91/92|ACTIVE=1|READY=0|LEAN_THREADS=16
AXIOM_AUDIT_START=RH_HilbertLimit.EventualGrowth
PARALLEL_WORKER=RH_HilbertLimit.EventualGrowth|PHASE=AUDIT|THREADS=16|SHELL_PID=45304
PARALLEL_PROGRESS=91/92|ACTIVE=1|READY=0|LEAN_THREADS=16
PARALLEL_PROGRESS=91/92|ACTIVE=1|READY=0|LEAN_THREADS=16
HASH_PHASE=SAVE_ORIGINALS:RH_HilbertLimit.EventualGrowth|FILES=1|BACKEND=CERTUTIL|ELAPSED_MS=30|COMPLETE
HASH_PHASE=SAVE_STAGED:RH_HilbertLimit.EventualGrowth|FILES=3|BACKEND=CERTUTIL|ELAPSED_MS=92|COMPLETE
ANCHOR_SAVE_LAYOUT=COMPACT_V1
ANCHOR_SAVED=E:\RH-FAST\anchors\RH_HILBERT_LIMIT\LOCAL_COMPILER\lean-4.33.0\c\c6870f025216435e\807c325eeddcdaf0dd2685bd33df9688\01a17f5f3ea2a10b\receipt.txt
COMPILE_AND_AXIOM_AUDIT_PASS=RH_HilbertLimit.EventualGrowth
MODULE_ELAPSED_MS=RH_HilbertLimit.EventualGrowth|22161|COMPILED_AUDITED
PARALLEL_PROGRESS=92/92|ACTIVE=0|READY=0|LEAN_THREADS=0
PARALLEL_PEAK_MODULE_WORKERS=1
PARALLEL_NEW_OR_REAUDITED_MODULE_TASKS=2
RAM_WARM=SKIPPED_NO_ELIGIBLE_DIRTY_FRONTIER
STAGE_ELAPSED_MS=PROJECT_MODULES|76267|RETURNED
PROJECT_BUILD=FAIL
FAILED_STAGE=MODULE:RH_HilbertLimit.EventualGrowth
REASON=Some modules failed or were blocked. Independent modules were still attempted.
RUN=FAIL
NATIVE_LAUNCH_INVENTORY=SEALED|RECORDS=408
SHUTDOWN_PROCESS_SNAPSHOT=CAPTURED|ROWS=665|UNREADABLE=0
WORKER_INVENTORY_RECHECK=CLEAR|ATTEMPTS:1|FULL_INVENTORIES:1|EXACT_WORKER_QUERIES:0
Logs: E:\RH-FAST\workspaces\RH_HILBERT_LIMIT_LEAN_v0_2_18_construction\run-build.log and E:\RH-FAST\workspaces\RH_HILBERT_LIMIT_LEAN_v0_2_18_construction\run-audit.log

C:\Users\Simon\Downloads>
'''
transcript_path = EV / 'USER_NATIVE_V0218_FAIL_TAIL.txt'
transcript_path.write_text(transcript, encoding='utf-8')
native = {
    'evidence_kind': 'USER_MESSAGE_UTF8_LF_TRANSCRIPTION_NOT_ORIGINAL_NATIVE_LOG_BYTES',
    'reported_package': BASE.name,
    'reported_build': 'FAIL', 'reported_run': 'FAIL',
    'visible_failed_module': 'RH_HilbertLimit.Cancellation',
    'visible_blocked_module': 'RH_HilbertLimit.ActualCancellationWitness',
    'reported_failed_stage_label': 'MODULE:RH_HilbertLimit.EventualGrowth',
    'failed_stage_interpretation': 'LAST_ATTEMPTED_MODULE_LABEL; EVENTUALGROWTH_HAS_EXPLICIT_COMPILE_AND_AXIOM_AUDIT_PASS',
    'reported_passed_module': 'RH_HilbertLimit.EventualGrowth',
    'reported_passed_module_elapsed_ms': 22161,
    'passed_module_source_in_delivered_package_sha256': sha(BASE / 'RH_HilbertLimit/EventualGrowth.lean'),
    'passed_module_source_in_candidate_is_byte_identical': True,
    'reported_anchor_receipt_path': r'E:\RH-FAST\anchors\RH_HILBERT_LIMIT\LOCAL_COMPILER\lean-4.33.0\c\c6870f025216435e\807c325eeddcdaf0dd2685bd33df9688\01a17f5f3ea2a10b\receipt.txt',
    'reported_project_modules_elapsed_ms': 76267,
    'reported_shutdown': {'clear': True, 'attempts': 1, 'full_inventories': 1, 'exact_worker_queries': 0},
    'aggregate_module_counts': 'NOT_SUPPLIED_IN_EXCERPT',
    'final_audit': 'NOT_REACHED_AFTER_PROJECT_MODULE_FAILURE',
    'source': EVREL + '/' + transcript_path.name,
    'source_sha256': sha(transcript_path),
    'first_marker': 'CLIPPED_PREFIX_ED_GOALS_PRESERVED_WITHOUT_RECONSTRUCTION',
    'direct_native_receipt_contents': 'NOT_SUPPLIED; PATH_ONLY',
    'native_source_dependency_toolchain_and_artifact_fingerprints': 'NOT_SUPPLIED_IN_EXCERPT',
    'direct_per_declaration_axiom_output': 'NOT_SUPPLIED; MODULE_PASS_MARKER_ONLY',
    'independent_native_verification': 'NOT_PERFORMED',
    'reuse_requirement': 'NATIVE_RUNNER_REVALIDATES_SAME_TARGET_SOURCE_DEPENDENCIES_TOOLCHAIN_ARTIFACTS_AND_AUDIT',
}
dump(EV / 'USER_REPORTED_NATIVE_RESULT.json', native)

review = {
    'schema': 'RH_HILBERT_V0219_CANCELLATION_REPAIR_SOURCE_REVIEW_V1',
    'status': 'SOURCE_REVIEW_ONLY_NATIVE_COMPILATION_PENDING',
    'source': source_rel,
    'old_source_sha256': sha(BASE / source_rel),
    'new_source_sha256': sha(OUT / source_rel),
    'declaration': 'RH_HilbertLimit.rowCancellation_le_of_local_flux',
    'repair': 'EXPLICIT_ROWVARIATION_UNFOLD_BEFORE_FINITE_SUM_AND_TELESCOPING_REWRITES',
    'remaining_goal': 'The right-hand rowVariation definition is exactly the left-hand finite sum shown by the user.',
    'subsequent_step': 'hboundary implies H (n + 1) - H 0 <= 0; existing linarith needs no additional hypothesis on K.',
    'reviewed_independently_by': '/root/proof_repair',
    'theorem_statement_definitions_and_assumptions': 'UNCHANGED',
    'previous_static_review': 'HISTORICAL_ONLY; V0218_NATIVE_COMPILATION_EXPOSED_THIS_MISSING_UNFOLD',
    'lean_execution': False, 'native_compilation': False, 'axiom_audit_execution': False,
}
dump(EV / 'SOURCE_REPAIR_REVIEW.json', review)

inventory = read_json(BASE / 'DECLARATIONS.json')
for d in inventory:
    if d['module'] == 'RH_HilbertLimit.Cancellation':
        d.update({
            'source_sha256': sha(OUT / source_rel),
            'status': 'NATIVE_AUDIT_PENDING_AFTER_PROOF_REPAIR',
            'evidence': EVREL + '/SOURCE_REPAIR_REVIEW.json',
            'receipt_validation': 'FIRST_SUCCESSFUL_NATIVE_COMPILE_AND_AXIOM_AUDIT_REQUIRED',
        })
    elif d['module'] == 'RH_HilbertLimit.EventualGrowth':
        d.update({
            'status': 'USER_REPORTED_V0_2_18_COMPILED_AXIOM_AUDIT_PASS_SOURCE_UNCHANGED',
            'evidence': EVREL + '/USER_REPORTED_NATIVE_RESULT.json',
            'receipt_validation': 'NATIVE_REVALIDATION_REQUIRED; RECEIPT_CONTENTS_NOT_SUPPLIED',
        })
dump(OUT / 'DECLARATIONS.json', inventory)

invalidation = [source_rel, 'RH_HilbertLimit/ActualCancellationWitness.lean', 'CancellationAudit.lean']
base_status = read_json(BASE / 'STATUS.json')
status = {
    'package': OUT.name, 'version': '0.2.19', 'suffix': 'construction',
    'mode': 'A_TIER_LEAN', 'target': 'LOCAL_COMPILER',
    'branch': 'RH_HILBERT_LIMIT / Hilbert.vector',
    'revision_scope': 'SINGLE_CANCELLATION_PROOF_UNFOLD; PACKAGE_IDENTITY_AND_EVIDENCE_METADATA',
    'requested_goal': base_status['requested_goal'],
    'requested_forward_goal': base_status['requested_forward_goal'],
    'prepared_source_forward_goal': '(exists W : CancellationBudget, W.Admissible) -> _root_.RiemannHypothesis',
    'semantic_cancellation_witness_forward': 'SOURCE_PREPARED_NATIVE_AUDIT_PENDING',
    'semantic_cancellation_witness_equivalence': 'SOURCE_PREPARED_NATIVE_AUDIT_PENDING',
    'goal_limitation': 'ADMISSIBILITY_IS_AN_EXPLICIT_ALL_ORDER_PREDICATE; NO_BOOL_CHECKER',
    'formal_closure': 'OPEN', 'obtained_witness_required_for_formal_closure': False,
    'finite_raw_format': 'OPEN', 'terminating_actual_rh_checker': 'OPEN',
    'finite_checker_soundness': 'OPEN', 'finite_checker_completeness': 'OPEN',
    'finite_checker_equivalence': 'OPEN', 'accepted_finite_witness': None,
    'unconditional_rh': 'NOT_ESTABLISHED', 'actual_subexponential_bound': 'OPEN',
    'ordinary_limit_sequence': 'rootScale actualVariation',
    'root_limit_value_one': 'NOT_ESTABLISHED; PRIOR_ANALYTIC_EQUIVALENCE_PRESERVED',
    'unrooted_variation_limit': 'NOT_ASSERTED',
    'analytic_equivalence_status': base_status['analytic_equivalence_status'],
    'analytic_source_sha256': base_status['analytic_source_sha256'],
    'latest_user_native_evidence': native,
    'latest_user_successful_full_native_evidence': base_status['latest_user_successful_native_evidence'],
    'eventual_growth_status': 'USER_REPORTED_V0_2_18_COMPILE_AND_AXIOM_AUDIT_PASS_SOURCE_BYTE_PRESERVED',
    'new_lean_build': 'NOT_RUN_BY_ASSISTANT', 'new_axiom_audit': 'NOT_RUN_BY_ASSISTANT',
    'local_lean_executed': False, 'lake_executed': False, 'ci_executed': False,
    'native_windows_execution_by_assistant': False, 'csharp_execution_or_compilation': False,
    'lean_toolchain': base_status['lean_toolchain'],
    'changed_lean_source_files': [source_rel], 'added_lean_source_files': [],
    'changed_proof_bodies': ['RH_HilbertLimit.rowCancellation_le_of_local_flux'],
    'theorem_statements_preserved': True, 'assumptions_preserved': True,
    'old_lean_files_byte_preserved': 95, 'total_lean_source_files': 96,
    'ordered_source_modules': 92, 'selected_final_audit': 'CancellationAudit.lean',
    'active_modules_including_final_audit': 93, 'selected_axiom_audit_declarations': 394,
    'declaration_inventory_entries': 1129, 'new_public_declarations': 0,
    'direct_mathlib_requirements': 91, 'added_direct_mathlib_requirements': [],
    'source_change_invalidation_cone': invalidation,
    'first_run_expected_reuse': '90 active modules eligible if all baseline and EventualGrowth same-target identities validate.',
    'first_run_expected_compilation': 'Cancellation, ActualCancellationWitness, CancellationAudit; invalid or missing anchors may require more.',
    'expected_counts_are_observed': False,
    'working_artifact_retention_next_run': 'A new v0.2.19 workspace may restore validated shared anchors; later runs may retain validated working artifacts.',
    'runtime_logic_change': 'NONE; TWO_PACKAGE_AND_VERSION_CONSTANTS_ONLY',
    'cache_implementation': base_status['cache_implementation'],
    'runtime_profile': base_status['runtime_profile'],
    'new_runtime_mocks_run': False, 'measured_runtime_speedup_claimed': False,
    'native_validation': 'V0218_PARTIAL_USER_REPORT_ONLY; V0219_NATIVE_RUN_PENDING',
    'delivery_filename': OUT.name + '.zip', 'canonical_archive_root': OUT.name,
    'new_version_workspace': 'E:\\RH-FAST\\workspaces\\' + OUT.name,
    'earlier_status_archive': EVREL + '/baseline_v0218_metadata/STATUS.json',
    'checkpoint_file': 'CHECKPOINT.json',
}
for k in [
    'parallel_module_workers_default', 'lean_total_thread_budget_default',
    'parallel_lean_thread_reserve_when_multiple_workers', 'worker_memory_admission_mib_default',
    'system_reserve', 'ram_warm_default', 'ram_warm_cap_mib_default', 'ram_warm_cap_mib_max',
    'ram_warm_capacity', 'ram_warm_scope', 'module_admission',
    'serial_fallback_threshold_mib_default', 'serial_fallback_worker_estimate_mib_default',
    'serial_fallback_host_floor_mib_default', 'serial_fallback_after_known_pressure',
    'relative_runner_shutdown_exception', 'stale_lock_recovery', 'shutdown_inventory_recheck',
    'old_retained_lock_policy',
]:
    status[k] = base_status[k]
dump(OUT / 'STATUS.json', status)

checkpoint = {
    'schema': 'RH_HILBERT_V0219_SINGLE_PROOF_REPAIR_CHECKPOINT_V1',
    'branch': 'RH_HILBERT_LIMIT', 'mode': 'A_TIER_LEAN', 'target': 'LOCAL_COMPILER',
    'source_package': BASE.name, 'source_zip_sha256': sha(BASE.with_suffix('.zip')),
    'checkpoint_package': OUT.name,
    'evidence_class': 'USER_REPORTED_V0218_PARTIAL_FAILURE_AND_EVENTUALGROWTH_PASS; REPAIR_NATIVE_PENDING',
    'latest_user_run': native,
    'latest_successful_full_run': base_status['latest_user_successful_native_evidence'],
    'lean_sources_byte_preserved': 95,
    'changed_source': source_rel, 'changed_source_sha256': sha(OUT / source_rel),
    'changed_proof_bodies': status['changed_proof_bodies'],
    'added_or_removed_mathematical_declarations': [],
    'definitions_theorem_statements_and_assumptions': 'UNCHANGED',
    'eventual_growth_source_sha256': sha(OUT / 'RH_HilbertLimit/EventualGrowth.lean'),
    'changed_runtime_policy': False, 'runner_changes': 'TWO_PACKAGE_AND_VERSION_CONSTANTS_ONLY',
    'source_manifest': EVREL + '/FROZEN_SOURCE_MANIFEST.json',
    'selected_final_audit': 'CancellationAudit.lean', 'selected_axiom_targets': 394,
    'exact_endpoint_declarations': read_json(BASE / 'CHECKPOINT.json')['exact_endpoint_declarations'],
    'forward_endpoint': 'RH_HilbertLimit.nativeRH_of_exists_admissible_cancellationBudget',
    'forward_endpoint_type': status['prepared_source_forward_goal'],
    'forward_endpoint_status': 'SOURCE_UNCHANGED; NATIVE_AUDIT_PENDING',
    'formal_closure': 'OPEN', 'finite_checker_soundness': 'OPEN', 'finite_checker_equivalence': 'OPEN',
    'accepted_finite_witness': None, 'unconditional_rh': 'NOT_ESTABLISHED',
    'obtained_witness_required_for_formal_closure': False,
    'expected_first_run_if_all_relevant_anchors_validate': {'frozen_reused': 90, 'compiled_and_audited': 3},
    'counts_are_observed': False,
    'source_change_invalidation_cone': invalidation,
    'cache_reuse': 'MATCHING_SAME_TARGET_SOURCE_DEPENDENCIES_TOOLCHAIN_ARTIFACTS_AND_AUDIT_REQUIRED',
    'new_native_or_lean_execution': False, 'new_runtime_test_execution': False,
    'not_an_init_record': True,
    'previous_checkpoint': EVREL + '/baseline_v0218_metadata/CHECKPOINT.json',
    'delivery_filename': OUT.name + '.zip', 'canonical_archive_root': OUT.name,
}
dump(OUT / 'CHECKPOINT.json', checkpoint)

command = f'cd /d "%USERPROFILE%\\Downloads" && (if not exist "E:\\RH-FAST\\workspaces" mkdir "E:\\RH-FAST\\workspaces") && tar -xf "{OUT.name}.zip" -C "E:\\RH-FAST\\workspaces" && cmd /k call "E:\\RH-FAST\\workspaces\\{OUT.name}\\run.cmd"'
(WORK / 'RUN_COMMAND.txt').write_text(command + '\n', encoding='utf-8')

readme = '''# RH Hilbert Limit v0.2.19 — Cancellation proof repair

Mode **A_TIER_LEAN**. Target **LOCAL_COMPILER**, native Windows Lean **4.33.0**.
The supplied v0.2.18 log reports a compilation failure in `Cancellation` and a
compilation-and-axiom-audit PASS for `EventualGrowth`. This package repairs the
displayed goal. The repaired source has not been compiled here.

## Exact repair

The remaining equality contains the finite sum on one side and its definition
`rowVariation u n` on the other. The last equality in
`rowCancellation_le_of_local_flux` now unfolds that definition explicitly:

```lean
    _ = K * rowVariation u n + (H (n + 1) - H 0) := by
      rw [rowVariation, Finset.sum_add_distrib, ← Finset.mul_sum,
        sum_forward_differences]
```

This is the only Lean source edit. All 95 other Lean files are byte-identical,
including the now PASS-reported `EventualGrowth`. Definitions, theorem
statements, hypotheses, selected audit targets, and compile order are unchanged.
The `FAILED_STAGE=...EventualGrowth` line names the last attempted module;
the explicit failure is `Cancellation`, while `EventualGrowth` has its own PASS.

## Witness-to-RH endpoint retained

```lean
theorem nativeRH_of_exists_admissible_cancellationBudget
    (hWitness : ∃ W : CancellationBudget, W.Admissible) :
    _root_.RiemannHypothesis
```

`CancellationBudget` contains `cutoff : Nat` and `coefficient : Nat`.
Its admissibility is the explicit all-order condition:

```lean
def CancellationBudget.Admissible (W : CancellationBudget) : Prop :=
  ∀ n : ℕ, W.cutoff ≤ n →
    rowCancellation actualNormalizedMoment n ≤
      (W.coefficient : ℝ) * actualVariation n
```

The source derives the actual RH endpoint from this hypothesis through the
cancellation identity and eventual subexponential growth. The reverse semantic
implication is also present. `ActualCancellationWitness` was blocked by the
failed dependency, so these declarations still await the native compiler and
axiom audit. No particular admissible witness is obtained.

The source does not supply a terminating finite Bool checker for this universal
predicate. Finite-checker soundness, completeness and formal closure remain
**OPEN**. No concrete accepted finite witness or unconditional RH is established.

## Run

Save the ZIP in Downloads and run:

```cmd
''' + command + '''
```

The command extracts into a new workspace under `E:\\RH-FAST\\workspaces` and
leaves CMD open. The existing native cached runner, RAM admission, parallel
scheduling, hashing, anchor validation and worker-lock policy are preserved.
Its only edits are package/version constants. It uses installed Lean and cached
Mathlib, with shared anchors under `E:\\RH-FAST\\anchors`.

The active graph remains 92 ordinary modules plus `CancellationAudit`, with
394 selected declarations. If all matching same-target source, dependency,
toolchain, artifact and audit identities validate, 90 modules are eligible for
reuse; `Cancellation`, `ActualCancellationWitness` and `CancellationAudit` need
compilation and audit. These are expected counts, not observed results. Missing
or invalid cache evidence can require further work.

## Evidence and status

The supplied failure tail is preserved with its clipped opening. It contains an
EventualGrowth receipt path but not the receipt contents or per-declaration
axiom output; the native runner must revalidate that evidence before reuse.
The last supplied successful whole-package run remains v0.2.17.

No Lean, Lake, Windows compiler, C# compiler, native runner or CI execution was
performed here. Static source, manifest and archive checks do not establish a
native proof PASS. The previous package's evidence is preserved, and the
current evidence distinguishes that history from this pending repair.
`SHA256SUMS.txt` covers every other payload file in this archive.
'''
(OUT / 'README.md').write_text(readme, encoding='utf-8')
(OUT / 'OPEN_OBLIGATIONS.txt').write_text('''PACKAGE=v0.2.19 construction
MODE=A_TIER_LEAN
TARGET=LOCAL_COMPILER

1. Compile and axiom-audit the repaired Cancellation, then its dependent
   ActualCancellationWitness and CancellationAudit, on native Windows Lean
   4.33.0. EventualGrowth is source-frozen after the supplied module PASS;
   reuse still requires the runner's exact identity and receipt validation.

2. The forward source theorem assumes an admissible CancellationBudget.
   Admissibility remains an explicit universal condition after a finite cutoff.
   The hypothetical witness has not been obtained, and the blocked forward
   and reverse declarations still await successful native compilation/audit.

3. Derive an actual-source invariant that makes a finite arithmetic certificate
   imply the universal cancellation budget. The local-flux adapter assumes
   its displayed local and boundary inequalities at every required order.

4. Implement a terminating finite raw checker and prove soundness, then
   completeness for (exists W : FiniteWitness, check W = true) iff RH.
   Obtaining a witness is not required for proving these implications.

5. Finite-checker soundness/equivalence and formal closure remain OPEN.
   Actual subexponential growth, an unconditional admissible budget, an
   accepted finite witness and unconditional RH are not established.

6. No native/Lean/Lake/compiler/CI execution was performed during this repair.
   Existing cache validation, worker-lock policy and other workspaces remain
   unchanged.
''', encoding='utf-8')
(OUT / 'RUNNER_NOTES.txt').write_text('''PACKAGE=''' + OUT.name + '''
RUNNER=''' + NEW_RUNNER + '''
MODE=A_TIER_LEAN
TARGET=LOCAL_COMPILER
LATEST_FULL_NATIVE_BASELINE=V0_2_17_USER_REPORTED_PASS
LATEST_NATIVE_RUN=V0_2_18_USER_REPORTED_FAIL_CANCELLATION
EVENTUALGROWTH=V0_2_18_USER_REPORTED_COMPILE_AND_AXIOM_AUDIT_PASS_SOURCE_FROZEN
REPAIR_NATIVE_AUDIT=PENDING
CHANGED_LEAN_SOURCES=1
OTHER_LEAN_SOURCES_BYTE_PRESERVED=95
ACTIVE_MODULES=93
EXPECTED_REUSE_IF_ALL_IDENTITIES_VALIDATE=90
EXPECTED_COMPILE_AND_AUDIT_IF_ALL_OTHER_IDENTITIES_VALIDATE=3
EXPECTED_COUNTS_ARE_OBSERVED=FALSE
SELECTED_FINAL_AUDIT=CancellationAudit.lean
SELECTED_AUDIT_DECLARATIONS=394
CACHE_AND_SCHEDULING_AND_SHUTDOWN_DECISIONS=UNCHANGED
RUNNER_CHANGE=TWO_PACKAGE_AND_VERSION_CONSTANTS_ONLY
NEW_NATIVE_EXECUTION_BY_ASSISTANT=NOT_RUN
NEW_RUNTIME_MOCKS=NOT_RUN
WITNESS_ADMISSIBILITY=EXPLICIT_ALL_ORDER_PREDICATE
FINITE_CHECKER_SOUNDNESS=OPEN
FINITE_CHECKER_EQUIVALENCE=OPEN
FORMAL_CLOSURE=OPEN
UNCONDITIONAL_RH=NOT_ESTABLISHED
''', encoding='utf-8')

frozen = []
for p in sorted(BASE.rglob('*.lean')):
    rel = p.relative_to(BASE).as_posix()
    if rel != source_rel:
        assert (OUT / rel).read_bytes() == p.read_bytes(), rel
        frozen.append({'path': rel, 'sha256': sha(p), 'bytes': p.stat().st_size})
assert len(frozen) == 95
dump(EV / 'FROZEN_SOURCE_MANIFEST.json', {'count': 95, 'files': frozen})

assembly = {
    'package': OUT.name, 'parent_package': BASE.name,
    'mode': 'A_TIER_LEAN', 'target': 'LOCAL_COMPILER',
    'changed_source': source_rel,
    'old_source_sha256': sha(BASE / source_rel), 'new_source_sha256': sha(OUT / source_rel),
    'runner_sha256': sha(OUT / 'tools/native_runner.js'),
    'eventual_growth_source_sha256': sha(OUT / 'RH_HilbertLimit/EventualGrowth.lean'),
    'other_lean_sources_byte_preserved': 95, 'total_lean_sources': 96,
    'ordinary_modules': 92, 'active_modules': 93, 'selected_audit_targets': 394,
    'declaration_inventory_records': 1129, 'source_change_invalidation_cone': invalidation,
    'runtime_algorithm_changes': False, 'native_or_lean_execution': False,
    'formal_closure': 'OPEN', 'finite_checker_soundness': 'OPEN',
}
dump(WORK / 'ASSEMBLY.json', assembly)
dump(EV / 'ASSEMBLY.json', assembly)
shutil.copyfile(Path(__file__), EV / 'assemble.py')
shutil.copyfile(WORK / 'RUN_COMMAND.txt', EV / 'RUN_COMMAND.txt')
print(json.dumps(assembly, indent=2))
