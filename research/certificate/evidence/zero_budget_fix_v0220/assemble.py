from pathlib import Path
import hashlib
import json
import shutil

ROOT = Path('/workspace/scratch/f128c1434505')
WORK = ROOT / 'tmp/zero_budget_fix_v0220'
BASE = ROOT / 'output/RH_HILBERT_LIMIT_LEAN_v0_2_19_construction'
OUT = ROOT / 'output/RH_HILBERT_LIMIT_LEAN_v0_2_20_construction'
EVREL = 'evidence/zero_budget_fix_v0220'
EV = OUT / EVREL
SOURCE = 'RH_HilbertLimit/ActualCancellationWitness.lean'
ATTACHMENT = ROOT / 'upload/Pasted text(20261027-221151).txt'
OLD_RUNNER = 'RH_HILBERT_NATIVE_RUNNER_v0_2_19_ROW_VARIATION_UNFOLD'
NEW_RUNNER = 'RH_HILBERT_NATIVE_RUNNER_v0_2_20_ZERO_BUDGET_CAST'


def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def read_json(p):
    return json.loads(p.read_text(encoding='utf-8'))


def dump(p, value):
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(json.dumps(value, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')


assert sha(BASE.with_suffix('.zip')) == 'ecf5a4b0c673a80e6a4a6f55db3304a39b0826bb499eb7ce6268a41dbd4c0551'
assert sha(ATTACHMENT) == 'b67440bcce9903c20caadacf47d824450ab020d538a8187febf4f0a174c3c6f0'
assert not OUT.exists()
shutil.copytree(BASE, OUT)
archive = EV / 'baseline_v0219_metadata'
archive.mkdir(parents=True)
for rel in [
    'STATUS.json', 'CHECKPOINT.json', 'README.md', 'OPEN_OBLIGATIONS.txt',
    'RUNNER_NOTES.txt', 'runner-version.txt', 'DECLARATIONS.json',
    'PROVENANCE.json', 'STATIC_REVIEW.json', 'RUNNER_LOGIC_VALIDATION.json', 'SHA256SUMS.txt',
]:
    shutil.copyfile(BASE / rel, archive / rel)

old = b'    (0 : \xe2\x84\x9d) * actualVariation n\n'
new = b'    ((0 : \xe2\x84\x95) : \xe2\x84\x9d) * actualVariation n\n'
source = (BASE / SOURCE).read_bytes()
assert source.count(old) == 1
(OUT / SOURCE).write_bytes(source.replace(old, new, 1))
runner = (BASE / 'tools/native_runner.js').read_bytes()
assert runner.count(BASE.name.encode()) == runner.count(OLD_RUNNER.encode()) == 1
runner = runner.replace(BASE.name.encode(), OUT.name.encode(), 1).replace(OLD_RUNNER.encode(), NEW_RUNNER.encode(), 1)
(OUT / 'tools/native_runner.js').write_bytes(runner)
(OUT / 'runner-version.txt').write_text(NEW_RUNNER + '\n', encoding='utf-8')

log = EV / 'USER_NATIVE_V0219_FAIL_TAIL.txt'
shutil.copyfile(ATTACHMENT, log)
native = {
    'evidence_kind': 'UPLOADED_TEXT_FILE_EXACT_BYTES; USER_SUPPLIED_NATIVE_LOG_TAIL',
    'reported_package': BASE.name, 'reported_build': 'FAIL', 'reported_run': 'FAIL',
    'visible_failed_module': 'RH_HilbertLimit.ActualCancellationWitness',
    'reported_failed_stage_label': 'MODULE:RH_HilbertLimit.ActualCancellationWitness',
    'reported_diagnostic': 'ActualCancellationWitness.lean:87:2 change tactic fails on real zero versus the cast natural-number coefficient.',
    'reported_failed_module_elapsed_ms': 8121,
    'reported_passed_module': 'RH_HilbertLimit.Cancellation',
    'reported_passed_module_elapsed_ms': 12312,
    'passed_module_source_in_delivered_package_sha256': sha(BASE / 'RH_HilbertLimit/Cancellation.lean'),
    'passed_module_source_in_candidate_is_byte_identical': True,
    'reported_anchor_receipt_path': r'E:\RH-FAST\anchors\RH_HILBERT_LIMIT\LOCAL_COMPILER\lean-4.33.0\c\cb56a71ccd3692f7\2b9d54be7d58009ec11f7c69d3598f1c\01a17f6a89b06275\receipt.txt',
    'eventual_growth': 'EXPLICIT_FROZEN_REUSE_IN_SUPPLIED_TAIL',
    'visible_frozen_reuse_markers': 16,
    'aggregate_module_counts': 'NOT_SUPPLIED; VISIBLE_TAIL_COUNT_IS_NOT_THE_FULL_PROJECT_COUNT',
    'reported_project_modules_elapsed_ms': 80375,
    'reported_peak_module_workers': 1,
    'reported_new_or_reaudited_module_tasks': 2,
    'reported_shutdown': {'clear': True, 'attempts': 1, 'full_inventories': 1, 'exact_worker_queries': 2},
    'final_audit': 'NOT_REACHED_AFTER_PROJECT_MODULE_FAILURE',
    'source': EVREL + '/' + log.name, 'source_sha256': sha(log), 'source_bytes': log.stat().st_size,
    'original_uploaded_filename': ATTACHMENT.name,
    'first_marker': 'CLIPPED_PREFIX_ILD_ARTIFACT_RESTORED_PRESERVED_WITHOUT_RECONSTRUCTION',
    'original_file_bytes_preserved': True,
    'direct_native_receipt_contents': 'NOT_SUPPLIED; PATH_ONLY',
    'native_source_dependency_toolchain_and_artifact_fingerprints': 'NOT_SUPPLIED_IN_EXCERPT',
    'direct_per_declaration_axiom_output': 'NOT_SUPPLIED; MODULE_PASS_MARKER_ONLY',
    'independent_native_verification': 'NOT_PERFORMED',
    'reuse_requirement': 'NATIVE_RUNNER_REVALIDATES_SAME_TARGET_SOURCE_DEPENDENCIES_TOOLCHAIN_ARTIFACTS_AND_AUDIT',
}
dump(EV / 'USER_REPORTED_NATIVE_RESULT.json', native)
review = {
    'schema': 'RH_HILBERT_V0220_ZERO_BUDGET_SOURCE_REVIEW_V1',
    'status': 'SOURCE_REVIEW_ONLY_NATIVE_COMPILATION_PENDING',
    'source': SOURCE, 'old_source_sha256': sha(BASE / SOURCE), 'new_source_sha256': sha(OUT / SOURCE),
    'declaration': 'RH_HilbertLimit.zero_cancellationBudget_admissible_of_nativeRH',
    'repair': 'PRESERVE_NATURAL_NUMBER_CAST_IN_CHANGE; REPLACE_REAL_ZERO_WITH_CAST_NAT_ZERO',
    'old_expression': '(0 : ℝ)', 'new_expression': '((0 : ℕ) : ℝ)',
    'reason': 'The record coefficient is Nat. Reducing its zero projection leaves a Nat-to-Real cast. change requires definitional equality; the final simp applies Nat.cast_zero and zero arithmetic.',
    'left_side_alignment': 'actualVariation n is defined as rowVariation actualNormalizedMoment n.',
    'reviewed_independently_by': '/root/proof_repair',
    'theorem_statements_definitions_hypotheses_and_line_numbers': 'UNCHANGED',
    'lean_execution': False, 'native_compilation': False, 'axiom_audit_execution': False,
}
dump(EV / 'SOURCE_REPAIR_REVIEW.json', review)

inventory = read_json(BASE / 'DECLARATIONS.json')
for d in inventory:
    if d['module'] == 'RH_HilbertLimit.ActualCancellationWitness':
        d.update({
            'source_sha256': sha(OUT / SOURCE), 'status': 'NATIVE_AUDIT_PENDING_AFTER_PROOF_REPAIR',
            'evidence': EVREL + '/SOURCE_REPAIR_REVIEW.json',
            'receipt_validation': 'FIRST_SUCCESSFUL_NATIVE_COMPILE_AND_AXIOM_AUDIT_REQUIRED',
        })
    elif d['module'] == 'RH_HilbertLimit.Cancellation':
        d.update({
            'status': 'USER_REPORTED_V0_2_19_COMPILED_AXIOM_AUDIT_PASS_SOURCE_UNCHANGED',
            'evidence': EVREL + '/USER_REPORTED_NATIVE_RESULT.json',
            'receipt_validation': 'NATIVE_REVALIDATION_REQUIRED; RECEIPT_CONTENTS_NOT_SUPPLIED',
        })
dump(OUT / 'DECLARATIONS.json', inventory)

invalidation = [SOURCE, 'CancellationAudit.lean']
status = read_json(BASE / 'STATUS.json')
status.update({
    'package': OUT.name, 'version': '0.2.20',
    'revision_scope': 'SINGLE_ZERO_BUDGET_CAST_REPAIR; PACKAGE_IDENTITY_AND_EVIDENCE_METADATA',
    'latest_user_native_evidence': native,
    'cancellation_status': 'USER_REPORTED_V0_2_19_COMPILE_AND_AXIOM_AUDIT_PASS_SOURCE_BYTE_PRESERVED',
    'eventual_growth_status': 'USER_REPORTED_V0_2_18_COMPILE_AND_AXIOM_AUDIT_PASS; V0_2_19_FROZEN_REUSE; SOURCE_BYTE_PRESERVED',
    'changed_lean_source_files': [SOURCE],
    'changed_proof_bodies': ['RH_HilbertLimit.zero_cancellationBudget_admissible_of_nativeRH'],
    'source_change_invalidation_cone': invalidation,
    'first_run_expected_reuse': '91 active modules eligible if all baseline, EventualGrowth and Cancellation same-target identities validate.',
    'first_run_expected_compilation': 'ActualCancellationWitness and CancellationAudit; invalid or missing anchors may require more.',
    'working_artifact_retention_next_run': 'A new v0.2.20 workspace may restore validated shared anchors; later runs may retain validated working artifacts.',
    'native_validation': 'V0219_PARTIAL_USER_UPLOAD_ONLY; V0220_NATIVE_RUN_PENDING',
    'delivery_filename': OUT.name + '.zip', 'canonical_archive_root': OUT.name,
    'new_version_workspace': 'E:\\RH-FAST\\workspaces\\' + OUT.name,
    'earlier_status_archive': EVREL + '/baseline_v0219_metadata/STATUS.json',
})
dump(OUT / 'STATUS.json', status)

checkpoint = read_json(BASE / 'CHECKPOINT.json')
checkpoint.update({
    'schema': 'RH_HILBERT_V0220_ZERO_BUDGET_CAST_REPAIR_CHECKPOINT_V1',
    'source_package': BASE.name, 'source_zip_sha256': sha(BASE.with_suffix('.zip')),
    'checkpoint_package': OUT.name,
    'evidence_class': 'USER_SUPPLIED_V0219_PARTIAL_FAILURE_AND_CANCELLATION_PASS; REPAIR_NATIVE_PENDING',
    'latest_user_run': native,
    'changed_source': SOURCE, 'changed_source_sha256': sha(OUT / SOURCE),
    'changed_proof_bodies': status['changed_proof_bodies'],
    'cancellation_source_sha256': sha(OUT / 'RH_HilbertLimit/Cancellation.lean'),
    'source_manifest': EVREL + '/FROZEN_SOURCE_MANIFEST.json',
    'forward_endpoint_status': 'THEOREM_STATEMENT_AND_PROOF_BODY_UNCHANGED; MODULE_NATIVE_AUDIT_PENDING',
    'expected_first_run_if_all_relevant_anchors_validate': {'frozen_reused': 91, 'compiled_and_audited': 2},
    'source_change_invalidation_cone': invalidation,
    'previous_checkpoint': EVREL + '/baseline_v0219_metadata/CHECKPOINT.json',
    'delivery_filename': OUT.name + '.zip', 'canonical_archive_root': OUT.name,
})
dump(OUT / 'CHECKPOINT.json', checkpoint)

command = f'cd /d "%USERPROFILE%\\Downloads" && (if not exist "E:\\RH-FAST\\workspaces" mkdir "E:\\RH-FAST\\workspaces") && tar -xf "{OUT.name}.zip" -C "E:\\RH-FAST\\workspaces" && cmd /k call "E:\\RH-FAST\\workspaces\\{OUT.name}\\run.cmd"'
(WORK / 'RUN_COMMAND.txt').write_text(command + '\n', encoding='utf-8')
readme = '''# RH Hilbert Limit v0.2.20 — zero-budget cast repair

Mode **A_TIER_LEAN**. Target **LOCAL_COMPILER**, native Windows Lean **4.33.0**.
The uploaded v0.2.19 tail reports compilation and axiom-audit PASS for
`Cancellation`, followed by a compilation failure in `ActualCancellationWitness`.
This package repairs that displayed failure. Native validation remains pending.

## Exact repair

In `zero_cancellationBudget_admissible_of_nativeRH`, the `change` target now
retains the cast of the natural-number coefficient:

```lean
  rw [rowCancellation_eq]
  change ((n : ℝ) + 1) * (actualVariation (n + 1) - actualVariation n) ≤
    ((0 : ℕ) : ℝ) * actualVariation n
  rw [hv (n + 1), hv n]
  simp
```

Only `(0 : ℝ)` was replaced with `((0 : ℕ) : ℝ)`. The record coefficient has
type Nat. `change` requires definitional equality and does not supply the
propositional cast-zero simplification; the final `simp` performs that step.
All definitions, theorem statements, quantifiers and hypotheses are unchanged.
All other 95 Lean sources are byte-identical, including the newly passed
`Cancellation` and the previously passed and now reused `EventualGrowth`.
The harmless unused-simp warning in the frozen Cancellation source is retained.

## Witness-to-RH endpoint retained

```lean
theorem nativeRH_of_exists_admissible_cancellationBudget
    (hWitness : ∃ W : CancellationBudget, W.Admissible) :
    _root_.RiemannHypothesis
```

The witness data are `cutoff : Nat` and `coefficient : Nat`, with explicit
all-order admissibility:

```lean
def CancellationBudget.Admissible (W : CancellationBudget) : Prop :=
  ∀ n : ℕ, W.cutoff ≤ n →
    rowCancellation actualNormalizedMoment n ≤
      (W.coefficient : ℝ) * actualVariation n
```

The forward proof and the semantic reverse implication remain in the source.
The entire module and selected aggregate still need successful native
compilation and axiom audit. The reported failure occurred in the reverse
zero-budget lemma; earlier declaration positions are not counted as an audited
module PASS.

Admissibility has not been reduced to a terminating finite Bool checker.
Finite-checker soundness, completeness and formal closure remain **OPEN**.
No particular admissible witness, accepted finite witness, actual
subexponential bound or unconditional RH is established.

## Run

Save the ZIP in Downloads and run:

```cmd
''' + command + '''
```

The command extracts into a new workspace under `E:\\RH-FAST\\workspaces` and
leaves CMD open. The existing native runner uses the shared
`E:\\RH-FAST\\anchors` cache and installed compatible Mathlib. Its only changes
are package/version constants. Cache validation, hashing, RAM admission,
parallel scheduling and worker-lock handling remain byte-for-byte the same
after those two constants are normalized.

The active graph remains 92 ordinary modules plus `CancellationAudit`, with
394 selected audit declarations. If all matching same-target source,
dependency, toolchain, artifact and audit identities validate, 91 modules are
eligible for reuse and only `ActualCancellationWitness` and `CancellationAudit`
need compilation and audit. These counts are conditional expectations;
missing or invalid anchors can require additional work.

## Evidence

The uploaded log tail is preserved byte-for-byte, including its clipped first
line. It supplies module PASS/reuse markers and receipt paths, but no receipt
contents or individual printed axiom lists. Reuse requires native revalidation.
The overall v0.2.19 run failed; the final aggregate was not reached. Its shutdown
inventory cleared. The last supplied whole-package PASS remains v0.2.17.

No Lean, Lake, Windows runner/compiler, C# compiler or CI was run here. Static
source and archive verification do not establish native proof PASS.
All prior evidence is preserved. Current metadata records the narrower
module evidence and leaves the repaired source pending. `SHA256SUMS.txt`
covers every other delivered payload file.
'''
(OUT / 'README.md').write_text(readme, encoding='utf-8')
(OUT / 'OPEN_OBLIGATIONS.txt').write_text('''PACKAGE=v0.2.20 construction
MODE=A_TIER_LEAN
TARGET=LOCAL_COMPILER

1. Compile and axiom-audit the repaired ActualCancellationWitness module and
   CancellationAudit on native Windows Lean 4.33.0. Cancellation and
   EventualGrowth are source-frozen after supplied module PASS evidence;
   reuse still requires exact same-target identity and receipt validation.

2. The forward source theorem assumes an admissible CancellationBudget.
   Admissibility remains an explicit universal condition after a finite cutoff.
   The entire forward/reverse module awaits a successful native audit.

3. Derive an actual-source invariant that makes a finite arithmetic certificate
   imply the universal cancellation budget. The local-flux adapter assumes
   its displayed local and boundary inequalities at every required order.

4. Implement a terminating finite raw checker and prove soundness, then
   completeness for (exists W : FiniteWitness, check W = true) iff RH.
   Obtaining a witness is not required to prove these implications.

5. Finite-checker soundness/equivalence and formal closure remain OPEN.
   Actual subexponential growth, an unconditional admissible budget, an
   accepted finite witness and unconditional RH are not established.

6. No native/Lean/Lake/compiler/CI execution was performed during preparation.
   Existing cache validation and worker-lock policy remain unchanged.
''', encoding='utf-8')
(OUT / 'RUNNER_NOTES.txt').write_text('''PACKAGE=''' + OUT.name + '''
RUNNER=''' + NEW_RUNNER + '''
MODE=A_TIER_LEAN
TARGET=LOCAL_COMPILER
LATEST_FULL_NATIVE_BASELINE=V0_2_17_USER_REPORTED_PASS
LATEST_NATIVE_RUN=V0_2_19_USER_UPLOADED_FAIL_ACTUALCANCELLATIONWITNESS
CANCELLATION=V0_2_19_USER_REPORTED_COMPILE_AND_AXIOM_AUDIT_PASS_SOURCE_FROZEN
EVENTUALGROWTH=V0_2_18_USER_REPORTED_PASS_AND_V0_2_19_FROZEN_REUSE
REPAIR_NATIVE_AUDIT=PENDING
CHANGED_LEAN_SOURCES=1
OTHER_LEAN_SOURCES_BYTE_PRESERVED=95
ACTIVE_MODULES=93
EXPECTED_REUSE_IF_ALL_IDENTITIES_VALIDATE=91
EXPECTED_COMPILE_AND_AUDIT_IF_ALL_OTHER_IDENTITIES_VALIDATE=2
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
    if rel != SOURCE:
        assert (OUT / rel).read_bytes() == p.read_bytes(), rel
        frozen.append({'path': rel, 'sha256': sha(p), 'bytes': p.stat().st_size})
assert len(frozen) == 95
dump(EV / 'FROZEN_SOURCE_MANIFEST.json', {'count': 95, 'files': frozen})
assembly = {
    'package': OUT.name, 'parent_package': BASE.name,
    'mode': 'A_TIER_LEAN', 'target': 'LOCAL_COMPILER',
    'changed_source': SOURCE,
    'old_source_sha256': sha(BASE / SOURCE), 'new_source_sha256': sha(OUT / SOURCE),
    'runner_sha256': sha(OUT / 'tools/native_runner.js'),
    'cancellation_source_sha256': sha(OUT / 'RH_HilbertLimit/Cancellation.lean'),
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
