from pathlib import Path
import hashlib
import json
import re
import shutil

ROOT = Path('/workspace/scratch/f128c1434505')
WORK = ROOT / 'tmp/native_pass_v0221'
BASE = ROOT / 'output/RH_HILBERT_LIMIT_LEAN_v0_2_20_construction'
OUT = ROOT / 'output/RH_HILBERT_LIMIT_LEAN_v0_2_21_construction'
EVREL = 'evidence/native_pass_v0221'
EV = OUT / EVREL
OLD_RUNNER = 'RH_HILBERT_NATIVE_RUNNER_v0_2_20_ZERO_BUDGET_CAST'
NEW_RUNNER = 'RH_HILBERT_NATIVE_RUNNER_v0_2_21_SEMANTIC_PASS_CHECKPOINT'


def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def read_json(p):
    return json.loads(p.read_text(encoding='utf-8'))


def dump(p, value):
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(json.dumps(value, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')


assert sha(BASE.with_suffix('.zip')) == '19326e755f2b42b04cf2ecf995412e5ab6b2947cd23886a70d3d20c4324cb1d7'
assert not OUT.exists()
shutil.copytree(BASE, OUT)
archive = EV / 'baseline_v0220_metadata'
archive.mkdir(parents=True)
for rel in [
    'STATUS.json', 'CHECKPOINT.json', 'README.md', 'OPEN_OBLIGATIONS.txt',
    'RUNNER_NOTES.txt', 'runner-version.txt', 'DECLARATIONS.json',
    'PROVENANCE.json', 'STATIC_REVIEW.json', 'RUNNER_LOGIC_VALIDATION.json', 'SHA256SUMS.txt',
]:
    shutil.copyfile(BASE / rel, archive / rel)

runner = (BASE / 'tools/native_runner.js').read_bytes()
assert runner.count(BASE.name.encode()) == runner.count(OLD_RUNNER.encode()) == 1
runner = runner.replace(BASE.name.encode(), OUT.name.encode(), 1).replace(OLD_RUNNER.encode(), NEW_RUNNER.encode(), 1)
(OUT / 'tools/native_runner.js').write_bytes(runner)
(OUT / 'runner-version.txt').write_text(NEW_RUNNER + '\n', encoding='utf-8')

log = EV / 'USER_NATIVE_V0220_PASS_TAIL.txt'
shutil.copyfile(WORK / log.name, log)
text = log.read_text(encoding='utf-8')
explicit = {}
for name, kind, values in re.findall(r"'([^']+)' (does not depend on any axioms|depends on axioms:\s*\[([^]]*)\])", text, re.S):
    assert name not in explicit
    explicit[name] = [] if kind == 'does not depend on any axioms' else [v.strip() for v in values.split(',')]
assert len(explicit) == 14
assert all(set(axioms) <= {'propext', 'Classical.choice', 'Quot.sound'} for axioms in explicit.values())
assert explicit['RH_HilbertLimit.CancellationBudget'] == []
for name in [
    'RH_HilbertLimit.nativeRH_of_exists_admissible_cancellationBudget',
    'RH_HilbertLimit.exists_admissible_cancellationBudget_iff_nativeRH',
]:
    assert set(explicit[name]) == {'propext', 'Classical.choice', 'Quot.sound'}


def scalar(key):
    matches = re.findall(r'^' + re.escape(key) + r'=(.*)$', text, re.M)
    assert len(matches) == 1, (key, matches)
    return matches[0]


assert scalar('RUN') == scalar('PROJECT_BUILD') == 'PASS'
assert scalar('FINAL_AUDIT_DECLARATIONS') == '394'
counts = {key: int(scalar(key)) for key in [
    'COMPILED_MODULES', 'FROZEN_REUSED_MODULES', 'AUDIT_ONLY_MODULES', 'LEGACY_MIGRATED_MODULES',
    'WORKING_ARTIFACT_MODULES_RETAINED', 'RESTORED_ARTIFACT_FILES', 'ANCHOR_HISTORY_SCANS',
    'COMPACT_ANCHORS_SAVED', 'COMBINED_WORKING_DIGESTS_CONSUMED',
]}
assert counts['COMPILED_MODULES'] == 2 and counts['FROZEN_REUSED_MODULES'] == 91
selected_rows = [r for r in (OUT / 'audit-targets.tsv').read_text().splitlines() if r.strip() and not r.startswith('#')]
selected_names = {r.split('|')[1] for r in selected_rows}
assert len(selected_names) == 394 and set(explicit) <= selected_names
dump(EV / 'EXPLICIT_USER_AXIOM_OUTPUT.json', {
    'scope': '14_DECLARATIONS_EXPLICITLY_PRINTED_IN_SUPPLIED_TAIL',
    'source': EVREL + '/' + log.name, 'source_sha256': sha(log),
    'axioms_by_declaration': explicit,
})
native = {
    'evidence_kind': 'USER_MESSAGE_UTF8_LF_TRANSCRIPTION_NOT_ORIGINAL_NATIVE_LOG_BYTES',
    'reported_package': BASE.name, 'reported_build': 'PASS', 'reported_run': 'PASS',
    'reported_final_audit': 'CancellationAudit.lean',
    'reported_final_audit_declarations': 394,
    'explicitly_printed_axiom_declarations': 14,
    'explicit_axioms': explicit,
    'reported_axiom_audit': scalar('AXIOM_AUDIT'), 'reported_sorryax': scalar('SORRYAX'),
    'reported_final_audit_module_elapsed_ms': 9914,
    'reported_stages': {'FINAL_AUDIT': 10036, 'WORKER_SHUTDOWN': 1044},
    'reported_counts': counts,
    'reported_logical_tool_launches': json.loads(scalar('LOGICAL_TOOL_LAUNCHES')),
    'reported_hash_phase_totals': json.loads(scalar('HASH_PHASE_TOTALS')),
    'reported_shutdown': {'clear': True, 'attempts': 1, 'full_inventories': 1, 'exact_worker_queries': 0},
    'reported_mathematical_status': scalar('MATHEMATICAL_STATUS'),
    'reported_semantic_forward': scalar('SEMANTIC_CANCELLATION_WITNESS_FORWARD'),
    'reported_semantic_equivalence': scalar('SEMANTIC_CANCELLATION_WITNESS_EQUIVALENCE'),
    'reported_formal_closure': scalar('FORMAL_CLOSURE'),
    'reported_finite_checker_soundness': scalar('FINITE_CHECKER_SOUNDNESS'),
    'reported_finite_checker_equivalence': scalar('FINITE_CHECKER_EQUIVALENCE'),
    'reported_accepted_finite_witness': scalar('FINITE_ACCEPTED_WITNESS'),
    'reported_unconditional_rh': scalar('UNCONDITIONAL_RH'),
    'reported_anchor_receipt_path': scalar('ANCHOR_SAVED'),
    'source': EVREL + '/' + log.name, 'source_sha256': sha(log), 'source_bytes': log.stat().st_size,
    'first_marker': 'AXIOM_OUTPUT_TAIL_STARTS_WITHOUT_THE_PRECEDING_DECLARATION_SIGNATURE',
    'direct_native_receipt_contents': 'NOT_SUPPLIED; PATH_ONLY',
    'native_source_dependency_toolchain_and_artifact_fingerprints': 'NOT_SUPPLIED_IN_EXCERPT',
    'independent_native_verification': 'NOT_PERFORMED',
    'aggregate_coverage_scope': '394_SELECTED_TARGETS; 14_EXPLICIT_AXIOM_LISTS_IN_THIS_TAIL',
    'reuse_requirement': 'EXACT_SAME_TARGET_SOURCE_DEPENDENCIES_TOOLCHAIN_ARTIFACTS_AND_PRIOR_AUDIT_PASS_VALIDATION',
    'timing_scope': 'REPORTED_STAGES_AND_HASH_AGGREGATES_ONLY; NO_WHOLE_RUN_WALL_TIME',
}
dump(EV / 'USER_REPORTED_NATIVE_PASS.json', native)

source_claim = {
    'status': 'STATIC_SOURCE_INTERPRETATION_OF_USER_SUPPLIED_NATIVE_PASS',
    'reviewed_independently_by': '/root/proof_repair',
    'checkpoint_kind': 'EVIDENCE_ONLY_NOT_INIT',
    'source': 'RH_HilbertLimit/ActualCancellationWitness.lean',
    'source_sha256': sha(OUT / 'RH_HilbertLimit/ActualCancellationWitness.lean'),
    'forward_declaration': 'RH_HilbertLimit.nativeRH_of_exists_admissible_cancellationBudget',
    'forward_statement': '(∃ W : CancellationBudget, W.Admissible) → _root_.RiemannHypothesis',
    'equivalence_declaration': 'RH_HilbertLimit.exists_admissible_cancellationBudget_iff_nativeRH',
    'equivalence_statement': '(∃ W : CancellationBudget, W.Admissible) ↔ _root_.RiemannHypothesis',
    'expanded_admissibility': '∃ N K : ℕ, ∀ n : ℕ, N ≤ n → rowCancellation actualNormalizedMoment n ≤ (K : ℝ) * actualVariation n',
    'data_fields': ['cutoff : ℕ', 'coefficient : ℕ'],
    'admissibility_kind': 'EXPLICIT_UNIVERSALLY_QUANTIFIED_PROP',
    'extra_analytic_hypotheses_in_endpoint_signature': [],
    'under_rh': 'THE_EXPLICIT_BUDGET_WITH_CUTOFF_ZERO_AND_COEFFICIENT_ZERO_IS_ADMISSIBLE',
    'data_existence_alone_implies_rh': 'NOT_CLAIMED; THE_HYPOTHESIS_INCLUDES_ADMISSIBILITY',
    'finite_bool_checker': 'NOT_IMPLEMENTED', 'finite_checker_soundness': 'OPEN',
    'finite_checker_completeness': 'OPEN', 'finite_checker_equivalence': 'OPEN',
    'formal_closure_for_finite_checker_goal': 'OPEN',
    'unconditionally_admissible_budget': 'NOT_ESTABLISHED',
    'accepted_finite_checker_witness': None, 'unconditional_rh': 'NOT_ESTABLISHED',
    'native_receipt_artifact_and_toolchain_identity_verification': 'NOT_PERFORMED',
    'assistant_native_or_lean_execution': 'NONE', 'source_changes': [],
}
dump(EV / 'SEMANTIC_ENDPOINT_REVIEW.json', source_claim)

inventory = read_json(BASE / 'DECLARATIONS.json')
for d in inventory:
    if d['name'] in selected_names:
        d.update({
            'source_sha256': sha(OUT / d['source']),
            'status': 'USER_REPORTED_V0_2_20_SELECTED_AGGREGATE_AXIOM_AUDIT_PASS_SOURCE_UNCHANGED',
            'evidence': EVREL + '/USER_REPORTED_NATIVE_PASS.json',
            'receipt_validation': 'NATIVE_REVALIDATION_REQUIRED; RECEIPT_CONTENTS_NOT_SUPPLIED',
            'latest_audit_evidence_scope': 'EXPLICIT_USER_AXIOM_OUTPUT' if d['name'] in explicit else 'USER_REPORTED_SELECTED_AGGREGATE_AUDIT',
        })
        if d['name'] in explicit:
            d['latest_reported_axioms'] = explicit[d['name']]
dump(OUT / 'DECLARATIONS.json', inventory)

status = read_json(BASE / 'STATUS.json')
prior_evidence = status['latest_user_native_evidence']
status.update({
    'package': OUT.name, 'version': '0.2.21',
    'revision_scope': 'EVIDENCE_ONLY_NATIVE_PASS_CHECKPOINT; ALL_PROOF_SOURCES_FROZEN',
    'semantic_cancellation_witness_forward': 'USER_SUPPLIED_NATIVE_DECLARATION_AND_AXIOM_AUDIT_PASS_SOURCE_UNCHANGED',
    'semantic_cancellation_witness_equivalence': 'USER_SUPPLIED_NATIVE_DECLARATION_AND_AXIOM_AUDIT_PASS_SOURCE_UNCHANGED',
    'analytic_equivalence_status': 'USER_REPORTED_V0_2_20_SELECTED_AGGREGATE_AUDIT_PASS_SOURCE_UNCHANGED',
    'latest_user_native_evidence': native, 'latest_user_successful_full_native_evidence': native,
    'previous_user_native_evidence': prior_evidence,
    'cancellation_status': 'USER_REPORTED_V0_2_19_MODULE_PASS_AND_V0_2_20_AGGREGATE_AUDIT_PASS_SOURCE_FROZEN',
    'eventual_growth_status': 'USER_REPORTED_V0_2_18_MODULE_PASS_AND_V0_2_20_AGGREGATE_AUDIT_PASS_SOURCE_FROZEN',
    'actual_cancellation_witness_status': 'USER_REPORTED_V0_2_20_NATIVE_PASS_WITH_12_EXPLICIT_DECLARATION_AXIOM_OUTPUTS',
    'changed_lean_source_files': [], 'changed_proof_bodies': [],
    'old_lean_files_byte_preserved': 96,
    'source_change_invalidation_cone': [],
    'selected_inventory_records_updated': 394, 'unselected_inventory_records_preserved': 735,
    'explicit_axiom_outputs_in_latest_tail': 14,
    'first_run_expected_reuse': 'All 93 active modules eligible if every matching same-target anchor validates.',
    'first_run_expected_compilation': 'None from source changes. Invalid or missing anchors still rebuild or fail.',
    'expected_counts_are_observed': False,
    'working_artifact_retention_next_run': 'A new v0.2.21 workspace may restore validated shared anchors; later runs may retain validated working artifacts.',
    'native_validation': 'USER_SUPPLIED_V0_2_20_FULL_RUN_PASS_AND_EXPLICIT_ENDPOINT_AXIOMS; V0_2_21_NOT_RUN',
    'delivery_filename': OUT.name + '.zip', 'canonical_archive_root': OUT.name,
    'new_version_workspace': 'E:\\RH-FAST\\workspaces\\' + OUT.name,
    'earlier_status_archive': EVREL + '/baseline_v0220_metadata/STATUS.json',
})
dump(OUT / 'STATUS.json', status)

checkpoint = read_json(BASE / 'CHECKPOINT.json')
checkpoint.pop('changed_source', None)
checkpoint.pop('changed_source_sha256', None)
checkpoint.update({
    'schema': 'RH_HILBERT_V0221_SEMANTIC_NATIVE_PASS_CHECKPOINT_V1',
    'source_package': BASE.name, 'source_zip_sha256': sha(BASE.with_suffix('.zip')),
    'checkpoint_package': OUT.name,
    'evidence_class': 'USER_SUPPLIED_NATIVE_DECLARATION_AXIOM_OUTPUT_AND_RUN_PASS; ALL_SOURCES_FROZEN',
    'latest_user_run': native, 'latest_successful_full_run': native,
    'lean_sources_byte_preserved': 96, 'changed_lean_sources': [], 'changed_proof_bodies': [],
    'source_manifest': EVREL + '/FROZEN_SOURCE_MANIFEST.json',
    'forward_endpoint_status': 'USER_REPORTED_NATIVE_COMPILE_AND_EXPLICIT_AXIOM_AUDIT_PASS_SOURCE_UNCHANGED',
    'equivalence_endpoint': source_claim['equivalence_declaration'],
    'equivalence_endpoint_type': source_claim['equivalence_statement'],
    'equivalence_endpoint_status': 'USER_REPORTED_NATIVE_COMPILE_AND_EXPLICIT_AXIOM_AUDIT_PASS_SOURCE_UNCHANGED',
    'endpoint_evidence': EVREL + '/SEMANTIC_ENDPOINT_REVIEW.json',
    'expected_first_run_if_all_relevant_anchors_validate': {'frozen_reused': 93, 'compiled_and_audited': 0},
    'counts_are_observed': False, 'source_change_invalidation_cone': [],
    'previous_checkpoint': EVREL + '/baseline_v0220_metadata/CHECKPOINT.json',
    'delivery_filename': OUT.name + '.zip', 'canonical_archive_root': OUT.name,
})
dump(OUT / 'CHECKPOINT.json', checkpoint)

command = f'cd /d "%USERPROFILE%\\Downloads" && (if not exist "E:\\RH-FAST\\workspaces" mkdir "E:\\RH-FAST\\workspaces") && tar -xf "{OUT.name}.zip" -C "E:\\RH-FAST\\workspaces" && cmd /k call "E:\\RH-FAST\\workspaces\\{OUT.name}\\run.cmd"'
(WORK / 'RUN_COMMAND.txt').write_text(command + '\n', encoding='utf-8')
(OUT / 'README.md').write_text('''# RH Hilbert Limit v0.2.21 — reported native semantic-equivalence checkpoint

Mode **A_TIER_LEAN**. Target **LOCAL_COMPILER**, native Windows Lean **4.33.0**.
This is an evidence-only checkpoint of the supplied successful v0.2.20 run.
All **96 Lean files** are byte-identical. No proof or definition was changed.

## What the supplied run establishes

The user-supplied output reports `PROJECT_BUILD=PASS`, `RUN=PASS`,
`AXIOM_AUDIT=PASS_STANDARD_LOGICAL_AXIOMS_ONLY`, `SORRYAX=NONE`,
2 compiled modules, 91 frozen reused modules, and 394 selected audit targets.
The exact endpoint declarations and their axiom lists are explicitly printed:

```lean
theorem nativeRH_of_exists_admissible_cancellationBudget
    (hWitness : ∃ W : CancellationBudget, W.Admissible) :
    _root_.RiemannHypothesis

theorem exists_admissible_cancellationBudget_iff_nativeRH :
    (∃ W : CancellationBudget, W.Admissible) ↔ _root_.RiemannHypothesis
```

Both printed axiom lists contain only `propext`, `Classical.choice` and
`Quot.sound`. The selected aggregate `CancellationAudit` reports its own
compilation-and-audit PASS, and the shutdown inventory clears.

## Exact meaning of the hypothetical witness

`CancellationBudget` has two natural-number fields: `cutoff` and `coefficient`.
Its required property is explicit:

```lean
def CancellationBudget.Admissible (W : CancellationBudget) : Prop :=
  ∀ n : ℕ, W.cutoff ≤ n →
    rowCancellation actualNormalizedMoment n ≤
      (W.coefficient : ℝ) * actualVariation n
```

Thus the assumed existence includes the inequality at every order after the
cutoff. From this hypothesis, the audited forward declaration concludes actual
Mathlib RH. Conversely, under RH the budget with cutoff zero and coefficient
zero is admissible. There are no extra spectral-calibration or dominant-
extraction hypotheses in the endpoint signatures.

The pair of natural numbers alone is not the full hypothesis. The universal
admissibility predicate has not been replaced by a terminating finite Bool
checker. Consequently, finite-checker soundness, completeness and the requested
finite-checker equivalence remain **OPEN**. The package retains
`FORMAL_CLOSURE=OPEN`. No unconditional admissible budget, accepted finite
checker witness, actual subexponential bound or unconditional RH is obtained.

## Frozen reuse

The active graph remains 92 ordinary modules plus `CancellationAudit`, with
394 audit targets. All compile/audit manifests and every Lean source remain
unchanged. The native runner differs only in package/version constants; its
cache, hashing, parallel/RAM admission, worker ownership and shutdown logic
are unchanged.

If all matching same-target source, dependency, toolchain, artifact and audit
identities validate, all **93 active modules are eligible for reuse**, with
**zero source-driven compilation tasks**. These are conditional expectations
for this version, separate from the observed 2 compiled / 91 reused counts
of v0.2.20. Missing or invalid cache evidence still causes a rebuild or failure.

## Run

Save the ZIP in Downloads and run:

```cmd
''' + command + '''
```

The command leaves CMD open and uses a new workspace under
`E:\\RH-FAST\\workspaces`, sharing the established `E:\\RH-FAST\\anchors` cache.
The runner uses installed native Lean and compatible cached Mathlib. No Lake,
Python, PowerShell, WSL or network setup is added to the runner.

## Evidence boundaries

The supplied message is preserved as a UTF-8/LF transcription of the log tail.
It includes explicit axiom output for **14 declarations**, including all
12 public declarations in `ActualCancellationWitness`; the reported aggregate
audit covers the selected **394 targets**. The declaration inventory has
1129 records: only those 394 selected records receive this new audit status;
the other 735 records retain their previous metadata.

Native receipt contents and source/dependency/toolchain/artifact fingerprints
were not supplied for independent inspection. The native runner must validate
them before cache reuse. No Lean, native runner/compiler, Lake, C# compiler or
CI was executed here, and no compiled artifacts or PASS receipts were created.
This checkpoint is not an Init and does not change the goal, mode or target.

Prior evidence is preserved. `SHA256SUMS.txt` covers every other payload file.
''', encoding='utf-8')
(OUT / 'OPEN_OBLIGATIONS.txt').write_text('''PACKAGE=v0.2.21 construction
MODE=A_TIER_LEAN
TARGET=LOCAL_COMPILER

RECORDED_NATIVE_MILESTONE:
The supplied v0.2.20 run reports standard-axiom-audited forward and reverse
semantic transfers: (exists W : CancellationBudget, W.Admissible) iff actual RH.
The endpoint signatures and axiom lists are explicitly printed. All96 Lean
source files are frozen. No mathematical edit is made in this checkpoint.

1. Derive an actual-source invariant that makes an effectively checkable finite
   certificate imply the universally quantified cancellation budget.
   The existing local-flux adapter retains its all-order inequalities.

2. Implement a terminating finite raw checker and prove its soundness for
   actual xi/zeta. The semantic Admissible predicate is not such a checker.

3. Prove completeness for the full scoped goal:
   (exists W : FiniteWitness, check W = true) iff RiemannHypothesis.
   Obtaining an accepted witness is not required to prove the equivalence.

4. Finite-checker soundness/equivalence and formal closure remain OPEN.
   Actual subexponential growth, an unconditional admissible budget, an
   accepted finite witness and unconditional RH are not established.

5. Reuse requires exact same-target source/dependency/toolchain/artifact and
   prior-audit verification on the user's native machine. The supplied tail
   contains receipt paths, not their contents. All93 active modules are
   eligible for reuse only when that validation succeeds.

6. No native/Lean/Lake/compiler/CI execution was performed here.
''', encoding='utf-8')
(OUT / 'RUNNER_NOTES.txt').write_text('''PACKAGE=''' + OUT.name + '''
RUNNER=''' + NEW_RUNNER + '''
MODE=A_TIER_LEAN
TARGET=LOCAL_COMPILER
LATEST_FULL_NATIVE_BASELINE=V0_2_20_USER_SUPPLIED_RUN_AND_AUDIT_PASS
LATEST_REPORTED_COMPILED_MODULES=2
LATEST_REPORTED_FROZEN_REUSED_MODULES=91
EXPLICIT_AXIOM_OUTPUT_DECLARATIONS_IN_SUPPLIED_TAIL=14
SELECTED_AGGREGATE_AUDIT_TARGETS=394
SELECTED_INVENTORY_RECORDS_UPDATED=394
UNSELECTED_INVENTORY_RECORDS_PRESERVED=735
CHANGED_LEAN_SOURCES=0
LEAN_SOURCES_BYTE_PRESERVED=96
ACTIVE_MODULES=93
EXPECTED_REUSE_IF_ALL_IDENTITIES_VALIDATE=93
EXPECTED_SOURCE_DRIVEN_COMPILE_AND_AUDIT=0
EXPECTED_COUNTS_ARE_OBSERVED=FALSE
SELECTED_FINAL_AUDIT=CancellationAudit.lean
CACHE_AND_SCHEDULING_AND_SHUTDOWN_DECISIONS=UNCHANGED
RUNNER_CHANGE=TWO_PACKAGE_AND_VERSION_CONSTANTS_ONLY
NEW_NATIVE_EXECUTION_BY_ASSISTANT=NOT_RUN
NEW_RUNTIME_MOCKS=NOT_RUN
SEMANTIC_CANCELLATION_FORWARD=USER_SUPPLIED_NATIVE_AXIOM_OUTPUT_PASS
SEMANTIC_CANCELLATION_EQUIVALENCE=USER_SUPPLIED_NATIVE_AXIOM_OUTPUT_PASS
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
assembly = {
    'package': OUT.name, 'parent_package': BASE.name,
    'mode': 'A_TIER_LEAN', 'target': 'LOCAL_COMPILER',
    'revision_kind': 'EVIDENCE_ONLY_NOT_INIT', 'changed_lean_sources': [],
    'lean_sources_byte_preserved': 96, 'total_lean_sources': 96,
    'ordinary_modules': 92, 'active_modules': 93, 'selected_audit_targets': 394,
    'declaration_inventory_records': 1129, 'selected_inventory_records_updated': 394,
    'unselected_inventory_records_preserved': 735, 'explicit_axiom_outputs': 14,
    'runner_sha256': sha(OUT / 'tools/native_runner.js'),
    'actual_cancellation_source_sha256': sha(OUT / 'RH_HilbertLimit/ActualCancellationWitness.lean'),
    'reported_native_counts': counts,
    'source_change_invalidation_cone': [],
    'runtime_algorithm_changes': False, 'native_or_lean_execution': False,
    'formal_closure': 'OPEN', 'finite_checker_soundness': 'OPEN',
}
dump(WORK / 'ASSEMBLY.json', assembly)
dump(EV / 'ASSEMBLY.json', assembly)
shutil.copyfile(Path(__file__), EV / 'assemble.py')
shutil.copyfile(WORK / 'RUN_COMMAND.txt', EV / 'RUN_COMMAND.txt')
print(json.dumps(assembly, indent=2))
