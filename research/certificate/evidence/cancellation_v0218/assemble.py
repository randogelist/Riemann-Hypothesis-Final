from pathlib import Path
from datetime import datetime
from zoneinfo import ZoneInfo
import hashlib
import json
import re
import shutil

ROOT = Path('/workspace/scratch/f128c1434505')
WORK = ROOT / 'tmp/cancellation_v0218'
BASE = ROOT / 'output/RH_HILBERT_LIMIT_LEAN_v0_2_17_construction'
OUT = ROOT / 'output/RH_HILBERT_LIMIT_LEAN_v0_2_18_construction'
EVREL = 'evidence/cancellation_v0218'
EV = OUT / EVREL
RUNVER = 'RH_HILBERT_NATIVE_RUNNER_v0_2_18_SEMANTIC_CANCELLATION'
NEW = ['RH_HilbertLimit/Cancellation.lean',
       'RH_HilbertLimit/EventualGrowth.lean',
       'RH_HilbertLimit/ActualCancellationWitness.lean']


def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def write(p, value):
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(value, encoding='utf-8')


def dump(p, value):
    write(p, json.dumps(value, indent=2, ensure_ascii=False) + '\n')


def read_json(p):
    return json.loads(p.read_text(encoding='utf-8'))


def clean_source(text):
    out = list(text)
    depth = 0
    quoted = False
    i = 0
    while i < len(text):
        pair = text[i:i + 2]
        if depth:
            if pair == '/-':
                out[i:i + 2] = '  '; depth += 1; i += 2; continue
            if pair == '-/':
                out[i:i + 2] = '  '; depth -= 1; i += 2; continue
            if text[i] != '\n':
                out[i] = ' '
        elif quoted:
            if text[i] == '\\':
                out[i:i + 2] = '  '; i += 2; continue
            if text[i] == '"':
                quoted = False
            if text[i] != '\n':
                out[i] = ' '
        elif pair == '/-':
            out[i:i + 2] = '  '; depth = 1; i += 2; continue
        elif pair == '--':
            while i < len(text) and text[i] != '\n':
                out[i] = ' '; i += 1
            continue
        elif text[i] == '"':
            out[i] = ' '; quoted = True
        i += 1
    assert depth == 0 and not quoted
    return ''.join(out)


def declarations(rel):
    src = OUT / rel
    text = clean_source(src.read_text(encoding='utf-8'))
    assert not re.search(r'\b(sorry|admit|axiom|unsafe|native_decide)\b', text), rel
    scopes = []
    result = []
    for line_no, line in enumerate(text.splitlines(), 1):
        line = line.strip()
        m = re.match(r'^namespace\s+(\S+)\s*$', line)
        if m:
            scopes.append(('namespace', m[1])); continue
        m = re.match(r'^(?:noncomputable\s+)?section(?:\s+(\S+))?\s*$', line)
        if m:
            scopes.append(('section', m[1])); continue
        m = re.match(r'^end(?:\s+(\S+))?\s*$', line)
        if m:
            assert scopes, (rel, line_no)
            kind, name = scopes.pop()
            if m[1]:
                assert m[1] == name, (rel, line_no, name)
            continue
        m = re.match(r'^(?:@\[[^\]]*\]\s*)*(?P<private>private\s+)?'
                     r'(?:noncomputable\s+)?(?P<kind>theorem|lemma|def|abbrev|structure)'
                     r'\s+(?P<name>[^\s(:{]+)', line)
        if m and not m['private']:
            name = '.'.join([v for k, v in scopes if k == 'namespace'] + [m['name']])
            assert re.fullmatch(r'[A-Za-z_][A-Za-z0-9_.]*', name)
            result.append({'module': rel[:-5].replace('/', '.'), 'kind': m['kind'],
                           'name': name, 'source': rel, 'source_line': line_no,
                           'source_sha256': sha(src), 'status': 'NATIVE_AUDIT_PENDING',
                           'evidence': EVREL + '/SOURCE_REVIEW.json',
                           'receipt_validation': 'FIRST_NATIVE_COMPILE_AND_AXIOM_AUDIT_REQUIRED'})
    return result


def lines(p):
    return [s.strip() for s in p.read_text(encoding='utf-8').splitlines()
            if s.strip() and not s.lstrip().startswith('#')]


assert sha(ROOT / 'output/RH_HILBERT_LIMIT_LEAN_v0_2_17_construction.zip') == \
    'c01cd5d67fbbc805f588e588f8f1c818a3098eb424e5d6f5a203faf1aa5346ec'
assert (EV / 'baseline_v0217_metadata/STATUS.json').is_file()
for rel in NEW:
    shutil.copyfile(WORK / 'proof' / Path(rel).name, OUT / rel)
old_sources = sorted(p.relative_to(BASE).as_posix() for p in BASE.rglob('*.lean'))
assert len(old_sources) == 92
for rel in old_sources:
    assert (BASE / rel).read_bytes() == (OUT / rel).read_bytes(), rel

new_decls = [item for rel in NEW for item in declarations(rel)]
assert len(new_decls) == 24, len(new_decls)
old_decls = read_json(BASE / 'DECLARATIONS.json')
assert len(old_decls) == 1105
old_text = (BASE / 'DECLARATIONS.json').read_text(encoding='utf-8').rstrip()
assert old_text.endswith(']')
prefix = old_text[:-1].rstrip()
append_text = json.dumps(new_decls, indent=2, ensure_ascii=False)[1:-1].strip('\n')
write(OUT / 'DECLARATIONS.json', prefix + ',\n' + append_text + '\n]\n')
assert read_json(OUT / 'DECLARATIONS.json')[:1105] == old_decls

old_order = lines(BASE / 'compile-order.txt')
assert len(old_order) == 89
order = old_order + NEW
assert len(order) == len(set(order)) == 92
write(OUT / 'compile-order.txt', '\n'.join(order) + '\n')
write(OUT / 'final-audit.txt', 'CancellationAudit.lean\n')
old_rows = lines(BASE / 'audit-targets.tsv')
assert len(old_rows) == 370
new_rows = [d['module'] + '|' + d['name'] for d in new_decls]
rows = old_rows + new_rows
assert len(rows) == len(set(rows)) == 394
write(OUT / 'audit-targets.tsv', (BASE / 'audit-targets.tsv').read_text().rstrip() +
      '\n' + '\n'.join(new_rows) + '\n')
names = [r.split('|')[1] for r in rows]
assert len(names) == len(set(names))
audit = '''import RH_HilbertLimit.ActualCancellationWitness
import RH_HilbertLimit.CanonicalBridge
import RH_HilbertLimit.FinitePrefix

/- Native-target aggregate audit. All 370 previous targets are retained.
   The 24 new declarations formalize cancellation, eventual growth, and RH
   from a hypothetical universally admissible budget. These new sources are
   not locally compiled. A successful audit does not certify a finite checker.
   The printed data and predicates expose the two natural fields and the
   all-order admissibility and unrestricted auxiliary-function obligations. -/

#print RH_HilbertLimit.ActualSpectralCalibration
#print RH_HilbertLimit.DominantExtraction
#print RH_HilbertLimit.NaturalGrowthStep
#print RH_HilbertLimit.CanonicalPowerSums
#print RH_HilbertLimit.CancellationBudget
#print RH_HilbertLimit.CancellationBudget.Admissible
#print RH_HilbertLimit.CancellationBudget.LocalFlux
#print RH_HilbertLimit.EventualNaturalGrowthStep

'''
audit += '\n'.join('#check ' + n + '\n#print axioms ' + n for n in names) + '\n'
write(OUT / 'CancellationAudit.lean', audit)
assert re.findall(r'^#print axioms (\S+)\s*$', audit, re.M) == names

# Change package identity and status reporting only. All runner decisions stay exact.
runner = (BASE / 'tools/native_runner.js').read_text(encoding='utf-8')
runner = runner.replace('var PACKAGE = "' + BASE.name + '";', 'var PACKAGE = "' + OUT.name + '";')
runner = runner.replace('RH_HILBERT_NATIVE_RUNNER_v0_2_17_EXACT_PROCESS_RECHECK', RUNVER)
runner = runner.replace('ANALYTIC_CRITERIA_AUDITED_FINITE_CHECKER_OPEN',
                        'ANALYTIC_AND_SEMANTIC_CANCELLATION_AUDITED_FINITE_CHECKER_OPEN')
anchor = '    \'  "ordinary_limit_sequence": "rootScale actualVariation",\',\n'
assert runner.count(anchor) == 1
runner = runner.replace(anchor, anchor + '''    '  "semantic_cancellation_witness_forward": '+quoteJSON(pass?"DECLARATION_AUDITED":"NATIVE_AUDIT_PENDING")+",",
    '  "semantic_cancellation_witness_equivalence": '+quoteJSON(pass?"DECLARATION_AUDITED":"NATIVE_AUDIT_PENDING")+",",
    '  "witness_admissibility": "UNIVERSAL_AFTER_FINITE_CUTOFF_NOT_A_BOOL_CHECK",',
    '  "finite_checker_soundness": "OPEN",',
''')
anchor = '  log("ORDINARY_LIMIT_SEQUENCE=rootScale actualVariation");log("ACTUAL_SUBEXPONENTIAL_BOUND=OPEN");\n'
assert runner.count(anchor) == 1
runner = runner.replace(anchor, anchor + '''  log("CANCELLATION_IDENTITY=DECLARATION_AUDITED");
  log("SEMANTIC_CANCELLATION_WITNESS_FORWARD=DECLARATION_AUDITED");
  log("SEMANTIC_CANCELLATION_WITNESS_EQUIVALENCE=DECLARATION_AUDITED");
  log("WITNESS_ADMISSIBILITY=UNIVERSAL_AFTER_FINITE_CUTOFF_NOT_A_BOOL_CHECK");
  log("FINITE_CHECKER_SOUNDNESS=OPEN");
''')
write(OUT / 'tools/native_runner.js', runner)
write(OUT / 'runner-version.txt', RUNVER + '\n')

transcript = r'''SHUTDOWN_PREEXISTING_ADMITTED_UNRESOLVED_HOST=PID:34008
WORKER_INVENTORY_RECHECK=CLEAR|ATTEMPTS:1|FULL_INVENTORIES:1|EXACT_WORKER_QUERIES:2
STAGE_ELAPSED_MS=WORKER_SHUTDOWN|1062|RETURNED
AXIOM_AUDIT=PASS_STANDARD_LOGICAL_AXIOMS_ONLY
SORRYAX=NONE
MATHEMATICAL_STATUS=ANALYTIC_CRITERIA_AUDITED_FINITE_CHECKER_OPEN
CANONICAL_POWER_SUMS=EXACT_CONSTRUCTION_AUDITED
ACTUAL_SPECTRAL_CALIBRATION=EXACT_CONSTRUCTION_AUDITED
DOMINANT_EXTRACTION=EXACT_CONSTRUCTION_AUDITED
UNCONDITIONAL_ACTUAL_LIMIT=ROOT_SCALE_LIMIT_DECLARATION_AUDITED
ORDINARY_LIMIT_SEQUENCE=rootScale actualVariation
ACTUAL_SUBEXPONENTIAL_BOUND=OPEN
UNCONDITIONAL_RH=NOT_ESTABLISHED
FINITE_ACCEPTED_WITNESS=NOT_ESTABLISHED
FINITE_CHECKER_EQUIVALENCE=OPEN
FORMAL_CLOSURE=OPEN
COMPILED_MODULES=0
FROZEN_REUSED_MODULES=90
AUDIT_ONLY_MODULES=0
LEGACY_MIGRATED_MODULES=0
PROJECT_BUILD=PASS
RUN=PASS
WORKING_ARTIFACT_MODULES_RETAINED=0
RESTORED_ARTIFACT_FILES=90
ANCHOR_HISTORY_SCANS=0
COMPACT_ANCHORS_SAVED=0
COMBINED_WORKING_DIGESTS_CONSUMED=0
LOGICAL_TOOL_LAUNCHES={"certutil":401,"csc":0,"helper":2,"lean":2,"other":0,"ram_warm":0,"total":405}
HASH_PHASE_TOTALS={"batch_sets":1,"certutil_sets":183,"elapsed_ms":43337,"failed_sets":0,"files":37509,"sets":184}
Logs: E:\RH-FAST\workspaces\RH_HILBERT_LIMIT_LEAN_v0_2_17_construction\run-build.log and E:\RH-FAST\workspaces\RH_HILBERT_LIMIT_LEAN_v0_2_17_construction\run-audit.log

C:\Users\Simon\Downloads>
'''
write(EV / 'USER_NATIVE_V0217_PASS_TAIL.txt', transcript)
report = {
    'evidence_kind': 'USER_MESSAGE_UTF8_LF_TRANSCRIPTION_NOT_ORIGINAL_NATIVE_LOG_BYTES',
    'reported_package': BASE.name, 'reported_build': 'PASS', 'reported_run': 'PASS',
    'reported_axiom_audit': 'PASS_STANDARD_LOGICAL_AXIOMS_ONLY', 'reported_sorryax': 'NONE',
    'reported_compiled_modules': 0, 'reported_frozen_reused_modules': 90,
    'reported_restored_artifact_files': 90, 'reported_working_artifact_modules_retained': 0,
    'reported_shutdown_elapsed_ms': 1062, 'reported_shutdown_full_inventories': 1,
    'reported_shutdown_exact_worker_queries': 2, 'reported_formal_closure': 'OPEN',
    'reported_finite_checker_equivalence': 'OPEN',
    'source': EVREL + '/USER_NATIVE_V0217_PASS_TAIL.txt',
    'source_sha256': sha(EV / 'USER_NATIVE_V0217_PASS_TAIL.txt'),
    'direct_receipt_contents_and_per_declaration_axiom_output': 'NOT_SUPPLIED',
    'independent_native_verification': 'NOT_PERFORMED',
    'new_v0218_source_execution': 'NOT_PERFORMED',
}
dump(EV / 'USER_REPORTED_NATIVE_PASS.json', report)

source_hashes = {rel: sha(OUT / rel) for rel in NEW + ['CancellationAudit.lean']}
summary = {
    'package': OUT.name, 'mode': 'A_TIER_LEAN', 'target': 'LOCAL_COMPILER',
    'new_source_sha256': source_hashes,
    'old_lean_sources_byte_preserved': len(old_sources), 'new_lean_sources': 4,
    'ordinary_modules': 92, 'active_modules_including_final_audit': 93,
    'old_ordinary_modules_eligible_for_reuse': 89,
    'old_final_audit': 'AnalyticAudit.lean', 'old_final_audit_preserved_but_unselected': True,
    'new_final_audit': 'CancellationAudit.lean', 'audit_targets': 394,
    'old_audit_targets_preserved': 370, 'new_public_declarations': 24,
    'declaration_inventory_entries': 1129,
    'mathlib_requirements_byte_preserved': (BASE / 'mathlib-imports.txt').read_bytes() ==
                                          (OUT / 'mathlib-imports.txt').read_bytes(),
    'runner_change_scope': 'PACKAGE_IDENTITY_AND_ACCURATE_STATUS_REPORTING_ONLY',
    'runtime_algorithm_changes': False, 'native_or_lean_execution': False,
    'formal_closure': 'OPEN', 'finite_checker_soundness': 'OPEN',
    'semantic_hypothesis': 'exists W : CancellationBudget, W.Admissible',
    'admissibility': 'forall n, W.cutoff <= n -> rowCancellation actualNormalizedMoment n <= W.coefficient * actualVariation n',
}
dump(WORK / 'ASSEMBLY.json', summary)
dump(EV / 'ASSEMBLY.json', summary)
dump(EV / 'FROZEN_SOURCE_MANIFEST.json', {
    'source_package': BASE.name,
    'files': [{'path': r, 'sha256': sha(BASE / r), 'bytes': (BASE / r).stat().st_size} for r in old_sources],
    'preservation': 'EXACT_BYTES', 'native_reuse': 'VALIDATE_ON_USER_SAME_TARGET_ONLY',
})

status = read_json(BASE / 'STATUS.json')
status['previous_user_native_evidence'] = status['latest_user_native_evidence']
status['latest_user_native_evidence'] = report
status['latest_user_successful_native_evidence'] = report
status.update({
    'package': OUT.name, 'version': '0.2.18', 'delivery_filename': OUT.name + '.zip',
    'canonical_archive_root': OUT.name, 'revision_scope': 'NEW_SEMANTIC_CANCELLATION_WITNESS_SOURCE_AND_AUDIT',
    'requested_forward_goal': '(exists W : FiniteWitness, check W = true) -> _root_.RiemannHypothesis',
    'new_proved_source_goal': '(exists W : CancellationBudget, W.Admissible) -> _root_.RiemannHypothesis',
    'new_proved_source_goal_native_status': 'PENDING_COMPILATION_AND_AXIOM_AUDIT',
    'goal_limitation': 'UNIVERSAL_ADMISSIBILITY_IS_NOT_FINITE_CHECKER_ACCEPTANCE',
    'semantic_cancellation_witness_forward': 'SOURCE_PREPARED_NATIVE_AUDIT_PENDING',
    'semantic_cancellation_witness_equivalence': 'SOURCE_PREPARED_NATIVE_AUDIT_PENDING',
    'finite_checker_soundness': 'OPEN', 'formal_closure': 'OPEN',
    'new_proof_modules': NEW, 'new_source_sha256': source_hashes,
    'changed_lean_source_files': [], 'added_lean_source_files': NEW + ['CancellationAudit.lean'],
    'old_lean_files_byte_preserved': 92, 'total_lean_source_files': 96,
    'ordered_source_modules': 92, 'selected_final_audit': 'CancellationAudit.lean',
    'active_modules_including_final_audit': 93, 'selected_axiom_audit_declarations': 394,
    'prior_audit_targets_retained': 370, 'new_public_declarations_audited': 0,
    'new_public_declarations_selected_for_audit': 24, 'declaration_inventory_entries': 1129,
    'prior_declaration_metadata': 'All 1105 prior records preserved; 24 appended with native-audit-pending status.',
    'first_run_expected_reuse': '89 unchanged ordinary modules eligible, subject to same-target full validation. Prior AnalyticAudit is preserved but unselected.',
    'first_run_expected_new_compilation': 'Three new ordinary modules and CancellationAudit; additional invalid or missing anchors rebuild or fail.',
    'expected_warm_counts_are_observed': False,
    'warm_count_observation_scope': '90_REUSED_WAS_USER_REPORTED_FOR_V0_2_17; V0_2_18_PENDING',
    'runtime_native_verification': 'V0_2_17_USER_REPORTED_PASS; V0_2_18_STATUS_REPORTING_AND_NEW_PROOFS_PENDING',
    'native_validation': 'NO_ASSISTANT_NATIVE_EXECUTION; USER_REPORTED_V0_2_17_PASS_PRESERVED',
    'new_runtime_mocks_run': False, 'runtime_logic_change': 'NONE; IDENTITY_AND_STATUS_REPORTING_ONLY',
    'runtime_mock_scope': 'NO_NEW_RUNTIME_MOCKS; PRIOR_SOURCE_BOUND_EVIDENCE_PRESERVED',
    'source_review_scope': 'NEW_PROOF_AND_EXACT_FROZEN_SOURCE_AND_MANIFEST_REVIEW_ONLY',
    'analytic_equivalence_status': 'USER_REPORTED_V0_2_17_STANDARD_AXIOM_AUDIT_PASS_REUSED; SOURCE_STATEMENTS_AND_AUDIT_COVERAGE_PRESERVED',
    'source_change_invalidation_cone': NEW + ['CancellationAudit.lean'],
    'earlier_status_archive': EVREL + '/baseline_v0217_metadata/STATUS.json',
    'new_version_workspace': 'E:\\RH-FAST\\workspaces\\' + OUT.name,
    'old_retained_lock_policy': 'OTHER_WORKSPACES_UNTOUCHED; EXISTING_LOCK_PROTOCOL_PRESERVED',
})
for key in ['canonical_power_sums', 'actual_spectral_calibration', 'dominant_extraction',
            'unconditional_actual_root_limit']:
    status[key] = 'USER_REPORTED_V0_2_17_STANDARD_AXIOM_AUDIT_PASS_REUSED; DIRECT_NATIVE_RECEIPT_CONTENTS_NOT_SUPPLIED'
dump(OUT / 'STATUS.json', status)

checkpoint = read_json(BASE / 'CHECKPOINT.json')
checkpoint.update({
    'schema': 'RH_HILBERT_V0218_SEMANTIC_CANCELLATION_SOURCE_CHECKPOINT_V1',
    'source_package': BASE.name,
    'source_zip_sha256': sha(ROOT / 'output' / (BASE.name + '.zip')),
    'checkpoint_package': OUT.name, 'delivery_filename': OUT.name + '.zip',
    'canonical_archive_root': OUT.name, 'latest_user_run': report,
    'previous_reported_run': checkpoint.get('reported_run'), 'reported_run': report,
    'source_manifest': EVREL + '/FROZEN_SOURCE_MANIFEST.json',
    'evidence_class': 'V0_2_17_USER_REPORTED_PASS_FROZEN; NEW_CANCELLATION_SOURCE_NATIVE_AUDIT_PENDING',
    'all_lean_sources_byte_preserved': 92, 'new_lean_sources': NEW + ['CancellationAudit.lean'],
    'changed_mathematical_declarations': [], 'added_mathematical_declarations': [d['name'] for d in new_decls],
    'changed_runtime_policy': False, 'runtime_change_scope': 'IDENTITY_AND_STATUS_REPORTING_ONLY',
    'selected_final_audit': 'CancellationAudit.lean', 'selected_axiom_targets': 394,
    'new_forward_endpoint': 'RH_HilbertLimit.nativeRH_of_exists_admissible_cancellationBudget',
    'new_forward_endpoint_type': '(exists W : CancellationBudget, W.Admissible) -> _root_.RiemannHypothesis',
    'new_forward_endpoint_status': 'NATIVE_AUDIT_PENDING; SEMANTIC_ALL_ORDER_ADMISSIBILITY',
    'not_an_init_record': True, 'new_native_execution': False,
    'new_native_or_test_execution': False, 'new_runtime_test_scope': 'NO_NEW_RUNTIME_TESTS',
    'reported_run_scope': 'User-reported aggregate v0.2.17 PASS; no new source included in that run.',
    'warm_counts_are_observed': False, 'warm_count_observation_scope': 'V0_2_18_NOT_RUN',
    'previous_checkpoint': EVREL + '/baseline_v0217_metadata/CHECKPOINT.json',
})
checkpoint.pop('expected_warm_counts_if_all_90_anchors_validate', None)
checkpoint['expected_first_run_if_valid_baseline_anchors'] = {'frozen_reused': 89, 'new_compiled': 4}
dump(OUT / 'CHECKPOINT.json', checkpoint)

command = ('cd /d "%USERPROFILE%\\Downloads" && (if not exist "E:\\RH-FAST\\workspaces" mkdir "E:\\RH-FAST\\workspaces")'
           ' && tar -xf "' + OUT.name + '.zip" -C "E:\\RH-FAST\\workspaces" && cmd /k call "E:\\RH-FAST\\workspaces\\' + OUT.name + '\\run.cmd"')
write(WORK / 'RUN_COMMAND.txt', command + '\n')
write(OUT / 'README.md', '''# RH Hilbert Limit v0.2.18 — hypothetical cancellation witness

Mode **A_TIER_LEAN**. Target **LOCAL_COMPILER**, native Windows Lean **4.33.0**.
This is a source package prepared for your compiler. The four new Lean files
have not been compiled or axiom-audited here. The last supplied v0.2.17 run
reported PASS with 90 frozen reused modules and no sorryAx.

## Exact new forward statement

```lean
theorem nativeRH_of_exists_admissible_cancellationBudget
    (hWitness : ∃ W : CancellationBudget, W.Admissible) :
    _root_.RiemannHypothesis
```

`CancellationBudget` contains only `cutoff : Nat` and `coefficient : Nat`.
Its validity is separate and explicit:

```lean
def CancellationBudget.Admissible (W : CancellationBudget) : Prop :=
  ∀ n : ℕ, W.cutoff ≤ n →
    rowCancellation actualNormalizedMoment n ≤
      (W.coefficient : ℝ) * actualVariation n
```

The assumed existence includes this all-order property. The source supplies
the cancellation identity, the eventual subexponential growth argument, and
the transfer to actual Mathlib RH. The imported spectral calibration and
dominant extraction are already constructed; neither is an extra endpoint
hypothesis. No particular admissible budget is obtained.

The module also supplies the reverse implication from RH, giving an analytic
equivalence with semantic admissibility. It does **not** supply a terminating
finite Bool checker or prove `(exists W, check W = true) -> RH`. The finite
checker soundness and full finite-witness equivalence remain **OPEN**.

## What is formalized in the new source

* `Cancellation.lean`: literal finite adjacent triangle defects, their exact
  row sum `(n+1) * (V(n+1)-V(n))`, nonnegativity, and the local telescoping bound.
* `EventualGrowth.lean`: a nonnegative sequence whose inverse-linear growth
  step holds after a finite cutoff is subexponential. This proof uses the
  existing exponential-step theorem and does not require a finite-prefix bound
  as an additional hypothesis.
* `ActualCancellationWitness.lean`: the semantic budget, explicit forward and
  reverse actual-RH transfers, and the local-flux adapter. The auxiliary
  function in `LocalFlux` is unrestricted; it is not asserted to be finite data.
* `CancellationAudit.lean`: all 370 prior selected declarations plus 24 new
  public declarations. It prints the witness data and admissibility definitions
  so the universal hypotheses remain visible in the native audit log.

The paper's explicit binomial-product upper bound is not claimed as a new
Lean declaration in this release. The eventual exponential-step proof already
gives the precise Subexponential predicate needed for the RH endpoint.

## Run

Save the ZIP in Downloads and run:

```cmd
''' + command + '''
```

The command leaves CMD open. The existing fast native runner, cache validation,
parallel scheduling, RAM admission and shutdown logic are preserved. Only its
package identity and mathematical status reporting change. The runner uses
the shared `E:\\RH-FAST\\anchors` store and already installed cached Mathlib.
It performs no Lake setup and uses no Python, PowerShell, WSL or network setup.

All 92 inherited Lean files are byte-preserved. The old AnalyticAudit source
and cache remain preserved but are no longer selected. The active graph has
92 ordinary modules plus CancellationAudit. If all baseline identities validate,
89 ordinary modules are eligible for reuse and four new modules need compilation
and audit. Actual counts depend on source, dependency, toolchain, artifact and
same-target receipt validation; the runner rebuilds or fails on invalid evidence.

## Reading a successful native run

`SEMANTIC_CANCELLATION_WITNESS_FORWARD=DECLARATION_AUDITED` means the displayed
conditional declaration passed its native audit. Its hypothesis still contains
the universal admissibility predicate. A successful build keeps these separate:

```text
FINITE_CHECKER_SOUNDNESS=OPEN
FINITE_CHECKER_EQUIVALENCE=OPEN
FORMAL_CLOSURE=OPEN
FINITE_ACCEPTED_WITNESS=NOT_ESTABLISHED
UNCONDITIONAL_RH=NOT_ESTABLISHED
```

No concrete witness, native receipts, compiled artifacts, or compiler PASS were
fabricated during preparation. STATUS.json, CHECKPOINT.json and the evidence
directory distinguish user-reported historical PASS from pending new source.
SHA256SUMS.txt covers every other delivered payload file.
''')
write(OUT / 'OPEN_OBLIGATIONS.txt', '''PACKAGE=v0.2.18 construction
MODE=A_TIER_LEAN
TARGET=LOCAL_COMPILER

1. Compile and axiom-audit the three new ordinary Lean modules and the new
   CancellationAudit on the user's native Windows Lean 4.33.0 compiler.
   No local Lean/Lake/compiler/CI execution was performed during preparation.

2. The new forward theorem assumes existence of a CancellationBudget satisfying
   its explicit universal admissibility predicate. The record has two natural
   fields. No all-order proof is hidden as a record field and no Bool checker
   is supplied for the predicate.

3. Derive the actual-theta invariant/forcing bound needed to turn a finite
   arithmetic certificate into this universal cancellation budget. The local
   telescoping adapter is proved conditionally on its displayed local and
   boundary inequalities; these are still semantic all-order hypotheses.

4. Implement a terminating finite raw checker and prove its actual-source
   soundness. Prove completeness separately for the full equivalence:
      (exists W : FiniteWitness, check W = true) iff RiemannHypothesis.
   No accepted witness needs to be obtained to prove soundness/equivalence.

5. Actual subexponential growth, an unconditional admissible budget, a concrete
   accepted finite witness and unconditional RH are not established.

6. Existing native source/dependency/toolchain/artifact/audit cache requirements
   and safe worker-lock policy remain in effect. Other workspaces are untouched.
''')
write(OUT / 'RUNNER_NOTES.txt', '\n'.join([
    'PACKAGE=' + OUT.name, 'RUNNER=' + RUNVER, 'MODE=A_TIER_LEAN', 'TARGET=LOCAL_COMPILER',
    'LATEST_NATIVE_BASELINE=V0_2_17_USER_REPORTED_PASS_90_REUSED',
    'NEW_SOURCE_NATIVE_AUDIT=PENDING', 'OLD_LEAN_SOURCES_BYTE_PRESERVED=92',
    'NEW_LEAN_SOURCES=4', 'ACTIVE_MODULES=93', 'BASELINE_ORDINARY_REUSE_ELIGIBLE=89',
    'SELECTED_FINAL_AUDIT=CancellationAudit.lean', 'SELECTED_AUDIT_DECLARATIONS=394',
    'CACHE_AND_SCHEDULING_AND_SHUTDOWN_DECISIONS=UNCHANGED',
    'RUNNER_CHANGE=IDENTITY_AND_STATUS_REPORTING_ONLY',
    'NEW_NATIVE_EXECUTION_BY_ASSISTANT=NOT_RUN', 'NEW_RUNTIME_MOCKS=NOT_RUN',
    'WITNESS_ADMISSIBILITY=UNIVERSAL_AFTER_FINITE_CUTOFF_NOT_A_BOOL_CHECK',
    'FINITE_CHECKER_SOUNDNESS=OPEN', 'FINITE_CHECKER_EQUIVALENCE=OPEN',
    'FORMAL_CLOSURE=OPEN', 'UNCONDITIONAL_RH=NOT_ESTABLISHED', '',
]))
print(json.dumps(summary, indent=2))
