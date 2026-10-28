from pathlib import Path
from datetime import datetime
from zoneinfo import ZoneInfo
import copy
import hashlib
import json
import re
import shutil

ROOT = Path('/workspace/scratch/f128c1434505')
WORK = ROOT / 'tmp/reuse_record_v0216'
BASE = ROOT / 'output/RH_HILBERT_LIMIT_LEAN_v0_2_16_construction'
OUT = ROOT / 'output/reuse_record_v0216' / BASE.name
DELIVERY = 'RH_HILBERT_LIMIT_LEAN_v0_2_16_REUSE_RECORD_construction.zip'
EVIDENCE = 'evidence/reuse_record_v0216'

def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()

def read_json(p):
    return json.loads(p.read_text(encoding='utf-8'))

def write(p, text):
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(text, encoding='utf-8')

def dump(p, value):
    write(p, json.dumps(value, indent=2, ensure_ascii=False) + '\n')

assert sha(BASE.with_suffix('.zip')) == 'f041746f97af01435d93d40388c33fa53e69aaa41096599b58edd72f300cc620'
assert sha(BASE / 'tools/native_runner.js') == 'd5eb2c1f33b4fafcd0b1d366850cc860c7e73552dd739ee9cdd238559e679c86'
assert not OUT.exists(), 'Preserve any existing candidate for inspection instead of overwriting it.'
shutil.copytree(BASE, OUT)
ev = OUT / EVIDENCE
ev.mkdir(parents=True)
changed_metadata = [
    'CHECKPOINT.json', 'DECLARATIONS.json', 'OPEN_OBLIGATIONS.txt', 'PROVENANCE.json',
    'README.md', 'RUNNER_LOGIC_VALIDATION.json', 'RUNNER_NOTES.txt', 'SHA256SUMS.txt',
    'STATIC_REVIEW.json', 'STATUS.json',
]
for name in changed_metadata:
    dest = ev / 'baseline_v0216_metadata' / name
    dest.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(BASE / name, dest)

transcript = WORK / 'evidence/USER_NATIVE_REUSE_TAIL.txt'
text = transcript.read_text(encoding='utf-8')
assert text.splitlines()[0] == 'LLEL_NEW_OR_REAUDITED_MODULE_TASKS=0'
markers = {}
stages = {}
for line in text.splitlines():
    if '=' in line and not line.startswith('Logs:'):
        key, val = line.split('=', 1)
        if key == 'STAGE_ELAPSED_MS':
            stage, ms, result = val.split('|')
            stages[stage] = {'elapsed_ms': int(ms), 'result': result}
        else:
            markers[key] = val
assert markers['PROJECT_BUILD'] == markers['RUN'] == 'PASS'
assert markers['AXIOM_AUDIT'] == 'PASS_STANDARD_LOGICAL_AXIOMS_ONLY'
assert markers['SORRYAX'] == 'NONE'
assert markers['FINAL_AUDIT_START'] == 'AnalyticAudit.lean'
assert markers['FINAL_AUDIT_DECLARATIONS'] == '370'
assert markers['COMPILED_MODULES'] == '0' and markers['FROZEN_REUSED_MODULES'] == '90'
assert markers['FINITE_CHECKER_EQUIVALENCE'] == markers['FORMAL_CLOSURE'] == 'OPEN'

count_keys = ['COMPILED_MODULES', 'FROZEN_REUSED_MODULES', 'AUDIT_ONLY_MODULES',
              'LEGACY_MIGRATED_MODULES', 'WORKING_ARTIFACT_MODULES_RETAINED',
              'RESTORED_ARTIFACT_FILES', 'ANCHOR_HISTORY_SCANS', 'COMPACT_ANCHORS_SAVED',
              'COMBINED_WORKING_DIGESTS_CONSUMED', 'FINAL_AUDIT_DECLARATIONS']
counts = {k.lower(): int(markers[k]) for k in count_keys}
report = {
    'evidence_kind': 'USER_MESSAGE_UTF8_LF_TRANSCRIPTION_NOT_ORIGINAL_NATIVE_LOG_BYTES',
    'reported_package': BASE.name,
    'reported_build': markers['PROJECT_BUILD'], 'reported_run': markers['RUN'],
    'reported_axiom_audit': markers['AXIOM_AUDIT'], 'reported_sorryax': markers['SORRYAX'],
    'reported_final_audit': markers['FINAL_AUDIT_START'],
    'reported_formal_closure': markers['FORMAL_CLOSURE'],
    'reported_finite_checker_equivalence': markers['FINITE_CHECKER_EQUIVALENCE'],
    'reported_compiled_modules': 0, 'reported_frozen_reused_modules': 90,
    'reported_counts': counts,
    'reported_stages': stages,
    'reported_logical_tool_launches': json.loads(markers['LOGICAL_TOOL_LAUNCHES']),
    'reported_hash_phase_totals': json.loads(markers['HASH_PHASE_TOTALS']),
    'reported_ram_warm': markers['RAM_WARM'],
    'source_sha256': sha(transcript), 'source_bytes': transcript.stat().st_size,
    'source': EVIDENCE + '/evidence/USER_NATIVE_REUSE_TAIL.txt',
    'review': EVIDENCE + '/evidence/NATIVE_REUSE_TAIL_REVIEW.json',
    'source_anchor_receipt_path_as_reported': markers['SOURCE_ANCHOR_RECEIPT'],
    'native_receipt_contents': 'NOT_SUPPLIED; PATH_ONLY',
    'native_source_dependency_toolchain_and_artifact_fingerprints': 'NOT_SUPPLIED_IN_EXCERPT',
    'direct_per_declaration_axiom_output': 'NOT_SUPPLIED; EXPLICIT_AGGREGATE_AUDIT_SUMMARY_PRESENT',
    'independent_exact_native_verification': 'NOT_PERFORMED',
    'first_marker': 'CLIPPED_PREFIX_PRESERVED_VERBATIM; NOT_RECONSTRUCTED',
    'timing_scope': 'Stage and hash aggregate counters only; whole-run wall time is absent.',
}
dump(ev / 'USER_REPORTED_NATIVE_REUSE.json', report)

status = read_json(BASE / 'STATUS.json')
status['previous_successful_native_evidence'] = status['latest_user_successful_native_evidence']
status['latest_user_native_evidence'] = report
status['latest_user_successful_native_evidence'] = report
evidence_status = 'USER_REPORTED_V0_2_16_STANDARD_AXIOM_AUDIT_PASS_REUSED'
for key in ['canonical_power_sums', 'actual_spectral_calibration', 'dominant_extraction', 'unconditional_actual_root_limit']:
    status[key] = evidence_status + '; DIRECT_NATIVE_RECEIPT_CONTENTS_NOT_SUPPLIED'
status.update({
    'revision_scope': 'REUSE_EVIDENCE_METADATA_ONLY; PACKAGE_AND_RUNNER_IDENTITY_UNCHANGED',
    'delivery_filename': DELIVERY, 'canonical_archive_root': BASE.name,
    'runtime_logic_change': 'NONE; ALL_RUNNER_AND_HELPER_BYTES_IDENTICAL',
    'runtime_native_verification': 'USER_REPORTED_V0_2_16_RUN_PASS_WITH_90_FROZEN_REUSED_MODULES',
    'native_validation': evidence_status + '; NO_ASSISTANT_NATIVE_EXECUTION',
    'source_review_scope': 'EXACT_PROOF_AND_RUNTIME_BYTE_PRESERVATION_PLUS_EXPLICIT_USER_REUSE_AUDIT_SUMMARY',
    'analytic_equivalence_status': evidence_status + '; SOURCE_STATEMENTS_AND_AUDIT_COVERAGE_PRESERVED',
    'expected_warm_counts_are_observed': True,
    'warm_count_observation_scope': 'USER_REPORTED_V0_2_16_RUN; NOT_A_PROMISE_FOR_FUTURE_RUNS',
    'prior_declaration_metadata': '1038 older entries unchanged; 67 analytic entries retain exact names, source locations and local hashes with updated user-reported aggregate reuse evidence.',
    'earlier_status_archive': EVIDENCE + '/baseline_v0216_metadata/STATUS.json',
    'same_workspace_reused': r'E:\RH-FAST\workspaces' + chr(92) + BASE.name,
    'working_artifact_retention_next_run': 'ELIGIBLE_IF_UNCHANGED_WORKING_FILES_AND_ALL_EXISTING_VALIDATIONS_PASS; NOT_YET_OBSERVED_FOR_V0_2_16',
    'measured_runtime_speedup_claimed': False,
    'new_lean_build': 'NOT_RUN_BY_ASSISTANT', 'new_axiom_audit': 'NOT_RUN_BY_ASSISTANT',
})
dump(OUT / 'STATUS.json', status)

checkpoint = read_json(BASE / 'CHECKPOINT.json')
checkpoint['previous_reported_run'] = checkpoint['reported_run']
checkpoint.update({
    'schema': 'RH_HILBERT_REPORTED_NATIVE_REUSE_CHECKPOINT_V1',
    'source_package': BASE.name, 'source_zip_sha256': sha(BASE.with_suffix('.zip')),
    'delivery_filename': DELIVERY, 'canonical_archive_root': BASE.name,
    'evidence_class': evidence_status + '; SOURCE_AND_RUNTIME_BYTES_PRESERVED_LOCALLY',
    'reported_run': report, 'warm_counts_are_observed': True,
    'warm_count_observation_scope': 'USER_REPORTED_V0_2_16_RUN',
    'package_and_runner_identity_changed': False,
    'all_runner_and_helper_bytes_preserved': True,
    'previous_checkpoint': EVIDENCE + '/baseline_v0216_metadata/CHECKPOINT.json',
})
dump(OUT / 'CHECKPOINT.json', checkpoint)

declarations = read_json(BASE / 'DECLARATIONS.json')
delta = []
for item in declarations:
    if item.get('status') == 'USER_REPORTED_V0_2_15_AGGREGATE_RUN_PASS':
        before = copy.deepcopy(item)
        item['status'] = evidence_status
        item['evidence'] = report['review']
        item['evidence_scope'] = 'Explicit user-reported selected AnalyticAudit summary: 370 declarations, standard logical axioms only, no sorryAx, all 90 active modules reused. Exact selected source coverage is preserved; individual native axiom output and receipt contents are not supplied.'
        delta.append({'name': item['name'], 'before': before, 'after': copy.deepcopy(item)})
assert len(declarations) == 1105 and len(delta) == 67
dump(OUT / 'DECLARATIONS.json', declarations)
dump(ev / 'DECLARATION_EVIDENCE_DELTA.json', delta)

command = ('cd /d "%USERPROFILE%\\Downloads" && (if not exist "E:\\RH-FAST\\workspaces" mkdir "E:\\RH-FAST\\workspaces")'
           ' && tar -xf "' + DELIVERY + '" -C "E:\\RH-FAST\\workspaces" && cmd /k call "E:\\RH-FAST\\workspaces\\' + BASE.name + '\\run.cmd"')
previous_readme = (BASE / 'README.md').read_text(encoding='utf-8')
endpoint_and_runtime = previous_readme.split('## Exact analytic endpoint retained\n', 1)[1].split('## Preservation and checkpoint files\n', 1)[0]
readme = '''# RH Hilbert Limit v0.2.16 — cached reuse record

Mode **A_TIER_LEAN**; target **LOCAL_COMPILER**; native Windows Lean **4.33.0**.

The supplied v0.2.16 run reports **PASS**, **0 modules compiled**, **90 frozen modules reused**, and a selected `AnalyticAudit.lean` summary covering **370 declarations**, with standard logical axioms only and no `sorryAx`. The finite-checker equivalence and formal closure remain **OPEN**.

This delivery records that result and preserves all **92 Lean source files**, every runner/helper/launcher byte, package identity, audit targets and execution settings. The external ZIP filename distinguishes this evidence update; its internal root and Windows workspace remain `RH_HILBERT_LIMIT_LEAN_v0_2_16_construction`.

## Run in the same workspace

Save this ZIP to Downloads and run in Windows CMD:

```cmd
''' + command + '''
```

The command updates the existing v0.2.16 workspace and leaves its CMD window open. The ZIP contains source and metadata, without compiled artifacts or working cache files. Extraction therefore preserves the workspace's existing `.native-build` files. The unchanged runner can retain those artifacts when its source, dependency, toolchain, artifact and audit checks pass. Shared anchors remain under `E:\\RH-FAST\\anchors`. No cache check or lock policy is weakened.

The supplied run restored 90 artifact files and retained zero working modules. Keeping the same workspace allows future reuse of the working files; the next run still validates them. Future counters or timing are not guaranteed. No new native execution was performed while preparing this delivery.

## Recorded evidence

| User-reported field | Value |
|---|---:|
| Compiled modules | 0 |
| Frozen reused modules | 90 |
| Selected audit declarations | 370 |
| Axiom audit | PASS_STANDARD_LOGICAL_AXIOMS_ONLY |
| sorryAx | NONE |
| Working artifact modules retained | 0 |
| Restored artifact files | 90 |
| Anchor history scans / compact anchors saved | 0 / 0 |
| Project build / run | PASS / PASS |
| Finite-checker equivalence / formal closure | OPEN / OPEN |

The transcript preserves the clipped first line exactly and records the supplied anchor receipt path. Receipt contents, individual declaration audit output and native dependency/toolchain fingerprints were not supplied. This is explicitly user-reported aggregate audit evidence. The locally verified source preservation is recorded separately.

The project-module stage was 53,350 ms; the aggregate hash-phase counter was 34,526 ms. Those counters are not total run duration and must not be added as disjoint elapsed times. RAM warming was skipped because there was no eligible dirty compilation frontier. The two logical Lean launches do not indicate that any module was newly compiled.

## Exact analytic endpoint retained
''' + endpoint_and_runtime + '''## Preservation and evidence files

`CHECKPOINT.json` retains all ten exact `AnalyticClosure.lean` endpoint statements and links the new reuse evidence. `STATUS.json` records the observed user-reported 0/90 result separately from assistant execution, which was not performed. `OPEN_OBLIGATIONS.txt` retains the finite-checker goal.

All older evidence is preserved. The previous top-level metadata is archived under `evidence/reuse_record_v0216/baseline_v0216_metadata`. The 67 analytic declaration inventory entries now reference the explicit aggregate reuse audit summary; their names, source locations and source hashes are unchanged. The remaining 1,038 inventory entries are unchanged.

Historical preparation comments in the Lean files remain byte-identical. Current reported status is recorded in metadata to preserve proof cache inputs. No new tests, Lean/Lake runs, native Windows execution, C# compilation, Wine or CI were performed. Static byte comparison and ZIP integrity checks validate this metadata-only delivery. `SHA256SUMS.txt` covers every other payload file.
'''
write(OUT / 'README.md', readme)
write(OUT / 'OPEN_OBLIGATIONS.txt', '''CURRENT PACKAGE: v0.2.16 construction, reported cached-reuse record
SOURCE AND RUNNER BASELINE: v0.2.16; exact bytes and canonical workspace preserved

1. The user reports PROJECT_BUILD=PASS, RUN=PASS, all 90 active modules
   frozen-reused, and a 370-declaration selected AnalyticAudit summary with
   standard logical axioms only and no sorryAx. This delivery records that
   evidence. It does not independently inspect the native receipt contents
   or rerun Lean. Full original cache validation remains mandatory.

2. The unchanged analytic package includes actual canonical calibration,
   dominant extraction, the ordinary root-scale limit, and all-order RH
   equivalences. No mathematical statement or assumption is changed here.

3. Formal closure remains OPEN:
     (exists W : FiniteWitness, check W = true) iff _root_.RiemannHypothesis
   Remaining work: finite raw data format, terminating actual-RH checker,
   soundness and completeness. An obtained witness is not required for the
   equivalence, and no accepted witness has been supplied.

4. A finite natural B or K with a universal all-order admissibility
   condition is not itself a terminating finite raw checker. A finite
   prefix has not been certified as an infinite tail bound.

5. Actual subexponential growth and unconditional RH are not established.
   Existence of the root-scale limit alone does not show its value is one.
   Convergence of the unrooted variation sequence is not asserted.

6. The same Windows workspace is retained for working-artifact reuse.
   Future retention and elapsed times remain subject to native validation;
   no speedup measurement is claimed from the supplied aggregate counters.
''')
write(OUT / 'RUNNER_NOTES.txt', '\n'.join([
    'PACKAGE=' + BASE.name, 'DELIVERY=' + DELIVERY,
    'RUNNER=RH_HILBERT_NATIVE_RUNNER_v0_2_16_PASS_CHECKPOINT',
    'MODE=A_TIER_LEAN', 'TARGET=LOCAL_COMPILER',
    'CHECKPOINT=' + evidence_status,
    'REPORTED_COMPILED_MODULES=0', 'REPORTED_FROZEN_REUSED_MODULES=90',
    'REPORTED_FINAL_AUDIT_DECLARATIONS=370', 'REPORTED_SORRYAX=NONE',
    'REPORTED_AXIOM_AUDIT=PASS_STANDARD_LOGICAL_AXIOMS_ONLY',
    'LEAN_SOURCE_FILES_BYTE_PRESERVED=92', 'ALL_RUNNER_HELPER_AND_LAUNCHER_BYTES=UNCHANGED',
    'PACKAGE_RUNNER_AND_WORKSPACE_IDENTITY=UNCHANGED', 'CACHE_ACCEPTANCE=UNCHANGED_FULL_VALIDATION',
    'REPORTED_WORKING_ARTIFACT_MODULES_RETAINED=0', 'REPORTED_RESTORED_ARTIFACT_FILES=90',
    'FUTURE_WORKING_RETENTION=ELIGIBLE_IF_ALL_EXISTING_VALIDATIONS_PASS',
    'NATIVE_RECEIPT_CONTENTS=NOT_SUPPLIED', 'NEW_NATIVE_EXECUTION_BY_ASSISTANT=NOT_RUN',
    'NEW_RUNTIME_TESTS=NOT_RUN', 'FORMAL_CLOSURE=OPEN', 'FINITE_CHECKER_EQUIVALENCE=OPEN',
    'ACCEPTED_FINITE_WITNESS=NOT_ESTABLISHED', 'UNCONDITIONAL_RH=NOT_ESTABLISHED', '',
]))

dump(WORK / 'ASSEMBLY.json', {
    'baseline': str(BASE), 'candidate': str(OUT), 'delivery': DELIVERY,
    'metadata_changed': changed_metadata, 'reported_run': report,
    'runner_sha256': sha(OUT / 'tools/native_runner.js'),
    'proof_or_runtime_changes': False, 'new_native_or_test_execution': False,
    'prepared_at': datetime.now(ZoneInfo('Europe/Berlin')).isoformat(),
})
print(json.dumps({'candidate': str(OUT), 'runner_unchanged': True, 'analytic_evidence_entries_updated': len(delta), 'transcript_sha256': sha(transcript)}, indent=2))
