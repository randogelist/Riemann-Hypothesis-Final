#!/usr/bin/env python3
"""Static integration only. Never invokes Lean, Lake, the runner, or CI."""
from pathlib import Path
from datetime import datetime
from zoneinfo import ZoneInfo
import hashlib
import json
import re
import shutil
import subprocess

ROOT = Path('/workspace/scratch/f1cc8a0db89c')
BASE = ROOT / 'hilbert_work/RH_HILBERT_LIMIT_LEAN_v0_2_24_construction'
OUT = ROOT / 'hilbert_work/RH_HILBERT_LIMIT_LEAN_v0_2_25_construction'
PARENT_ZIP = ROOT / 'hilbert_input/RH_HILBERT_LIMIT_LEAN_v0_2_24_construction.zip'
EVREL = 'evidence/zero_budget_second_v0225'
EV = OUT / EVREL
NEW = ['RH_HilbertLimit/ZeroBudgetSecondSector.lean',
       'RH_HilbertLimit/ZeroBudgetSecondMoment.lean']
FINAL = 'SecondMomentAudit.lean'
OLD_RUNNER = 'RH_HILBERT_NATIVE_RUNNER_v0_2_24_ZERO_BUDGET_FIRST_CHECK'
NEW_RUNNER = 'RH_HILBERT_NATIVE_RUNNER_v0_2_25_ZERO_BUDGET_SECOND_CHECK'
OLD_MATH = 'ZERO_BUDGET_FIRST_REFINEMENT_AUDITED_UNIVERSAL_ADMISSIBILITY_OPEN'
NEW_MATH = 'ZERO_BUDGET_FIRST_TWO_REFINEMENTS_AUDITED_UNIVERSAL_ADMISSIBILITY_OPEN'
META = ['STATUS.json', 'CHECKPOINT.json', 'README.md', 'OPEN_OBLIGATIONS.txt',
        'RUNNER_NOTES.txt', 'runner-version.txt', 'DECLARATIONS.json',
        'compile-order.txt', 'final-audit.txt', 'audit-targets.tsv',
        'mathlib-imports.txt', 'PROVENANCE.json', 'STATIC_REVIEW.json',
        'RUNNER_LOGIC_VALIDATION.json', 'SHA256SUMS.txt']

USER_EXCERPT = r'''ZERO_BUDGET_CANDIDATE=CUTOFF_0_COEFFICIENT_0
ZERO_BUDGET_FIRST_MOMENT_BOUNDS=DECLARATIONS_AUDITED
ZERO_BUDGET_FIRST_REFINEMENT_CANCELLATION=ZERO_DECLARATION_AUDITED
ZERO_BUDGET_VERIFIED_REFINEMENT_SCOPE=INDEX_0_ONLY
ZERO_BUDGET_UNIVERSAL_PROPAGATION=OPEN
ZERO_BUDGET_ADMISSIBILITY=OPEN
FINITE_CHECKER_SOUNDNESS=OPEN
UNCONDITIONAL_RH=NOT_ESTABLISHED
FINITE_ACCEPTED_WITNESS=NOT_ESTABLISHED
FINITE_CHECKER_EQUIVALENCE=OPEN
FORMAL_CLOSURE=OPEN
COMPILED_MODULES=3
FROZEN_REUSED_MODULES=92
AUDIT_ONLY_MODULES=0
LEGACY_MIGRATED_MODULES=0
PROJECT_BUILD=PASS
RUN=PASS
WORKING_ARTIFACT_MODULES_RETAINED=0
RESTORED_ARTIFACT_FILES=92
ANCHOR_HISTORY_SCANS=3
COMPACT_ANCHORS_SAVED=3
COMBINED_WORKING_DIGESTS_CONSUMED=0
LOGICAL_TOOL_LAUNCHES={"certutil":421,"csc":0,"helper":2,"lean":7,"other":0,"ram_warm":0,"total":430}
HASH_PHASE_TOTALS={"batch_sets":1,"certutil_sets":193,"elapsed_ms":34085,"failed_sets":0,"files":37534,"sets":194}
Logs: E:\RH-FAST\workspaces\RH_HILBERT_LIMIT_LEAN_v0_2_24_construction\run-build.log and E:\RH-FAST\workspaces\RH_HILBERT_LIMIT_LEAN_v0_2_24_construction\run-audit.log

C:\Users\Simon\Downloads>
'''


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def write(path, text):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding='utf-8')


def dump(path, data):
    write(path, json.dumps(data, indent=2, ensure_ascii=False) + '\n')


def read_json(path):
    return json.loads(path.read_text(encoding='utf-8'))


def lines(path):
    return [s.strip() for s in path.read_text(encoding='utf-8').splitlines()
            if s.strip() and not s.lstrip().startswith('#')]


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
    assert depth == 0 and not quoted, 'unterminated comment or string'
    return ''.join(out)


def declarations(rel):
    path = OUT / rel
    text = clean_source(path.read_text(encoding='utf-8'))
    assert not re.search(r'\b(sorry|admit|axiom|unsafe|native_decide)\b', text), rel
    assert 'debug.skipKernel' not in text, rel
    scopes = []
    result = []
    for line_no, line in enumerate(text.splitlines(), 1):
        line = line.strip()
        match = re.match(r'^namespace\s+(\S+)\s*$', line)
        if match:
            scopes.append(('namespace', match[1])); continue
        match = re.match(r'^(?:noncomputable\s+)?section(?:\s+(\S+))?\s*$', line)
        if match:
            scopes.append(('section', match[1])); continue
        match = re.match(r'^end(?:\s+(\S+))?\s*$', line)
        if match:
            assert scopes, (rel, line_no)
            kind, name = scopes.pop()
            if match[1]:
                assert match[1] == name, (rel, line_no, name)
            continue
        match = re.match(r'^(?:@\[[^\]]*\]\s*)*(?P<private>private\s+)?'
                         r'(?:noncomputable\s+)?(?P<kind>theorem|lemma|def|abbrev|structure)'
                         r'\s+(?P<name>[^\s(:{]+)', line)
        if match and not match['private']:
            name = '.'.join([v for k, v in scopes if k == 'namespace'] + [match['name']])
            assert re.fullmatch(r'[A-Za-z_][A-Za-z0-9_.]*', name), name
            result.append({'module': rel[:-5].replace('/', '.'), 'kind': match['kind'],
                           'name': name, 'source': rel, 'source_line': line_no,
                           'source_sha256': sha(path), 'status': 'NATIVE_AUDIT_PENDING',
                           'evidence': EVREL + '/STATIC_INTEGRATION.json',
                           'receipt_validation': 'FIRST_NATIVE_COMPILE_AND_AXIOM_AUDIT_REQUIRED'})
    # Lean permits an anonymous section (such as `noncomputable section`)
    # to remain open at end of file. Named namespaces must close explicitly.
    assert all(kind == 'section' for kind, _ in scopes), (rel, scopes)
    assert result, rel
    return result


def main():
    assert BASE.is_dir() and OUT.is_dir() and PARENT_ZIP.is_file()
    for rel in NEW:
        assert (OUT / rel).is_file(), 'Source not ready: ' + rel
    old_sources = sorted(p.relative_to(BASE).as_posix() for p in BASE.rglob('*.lean'))
    assert len(old_sources) == 99
    for rel in old_sources:
        assert (OUT / rel).read_bytes() == (BASE / rel).read_bytes(), rel
    old_order = lines(BASE / 'compile-order.txt')
    old_rows = lines(BASE / 'audit-targets.tsv')
    old_decls = read_json(BASE / 'DECLARATIONS.json')
    assert len(old_order) == 94 and len(old_rows) == 428 and len(old_decls) == 1163
    assert len(old_order) == len(set(old_order))
    new_decls = [d for rel in NEW for d in declarations(rel)]
    assert len(new_decls) == len({d['name'] for d in new_decls})
    assert not ({d['name'] for d in old_decls} & {d['name'] for d in new_decls})
    assert 'RH_HilbertLimit.zeroBudget_canonicalNode_cube_re_pos' in {d['name'] for d in new_decls}
    assert any('Cancellation' in d['name'] and 'one' in d['name'] for d in new_decls)

    archive = EV / 'baseline_v0224_metadata'
    for rel in META:
        (archive / rel).parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(BASE / rel, archive / rel)
    shutil.copyfile(Path(__file__), EV / 'prepare_v25.py')
    write(EV / 'USER_NATIVE_V0224_PASS_EXCERPT.txt', USER_EXCERPT)
    excerpt_path = EV / 'USER_NATIVE_V0224_PASS_EXCERPT.txt'
    native = {
        'evidence_kind': 'USER_MESSAGE_EXCERPT_UTF8_LF_TRANSCRIPTION_NOT_ORIGINAL_NATIVE_LOG_BYTES',
        'reported_package': BASE.name,
        'reported_build': 'PASS', 'reported_run': 'PASS',
        'reported_final_audit_declarations': None,
        'final_audit_count_in_excerpt': 'NOT_PRINTED',
        'package_selected_audit_targets_from_manifest': 428,
        'explicitly_printed_axiom_declarations': 0,
        'reported_axiom_audit': 'NOT_PRINTED_IN_SUPPLIED_EXCERPT',
        'reported_sorryax': 'NOT_PRINTED_IN_SUPPLIED_EXCERPT',
        'reported_first_moment_bounds': 'DECLARATIONS_AUDITED',
        'reported_first_refinement_cancellation': 'ZERO_DECLARATION_AUDITED',
        'reported_verified_refinement_scope': 'INDEX_0_ONLY',
        'reported_counts': {'COMPILED_MODULES': 3, 'FROZEN_REUSED_MODULES': 92,
                            'AUDIT_ONLY_MODULES': 0, 'LEGACY_MIGRATED_MODULES': 0,
                            'WORKING_ARTIFACT_MODULES_RETAINED': 0,
                            'RESTORED_ARTIFACT_FILES': 92, 'ANCHOR_HISTORY_SCANS': 3,
                            'COMPACT_ANCHORS_SAVED': 3, 'COMBINED_WORKING_DIGESTS_CONSUMED': 0},
        'reported_logical_tool_launches': {'certutil': 421, 'csc': 0, 'helper': 2,
                                          'lean': 7, 'other': 0, 'ram_warm': 0, 'total': 430},
        'reported_hash_phase_totals': {'batch_sets': 1, 'certutil_sets': 193,
                                       'elapsed_ms': 34085, 'failed_sets': 0,
                                       'files': 37534, 'sets': 194},
        'reported_zero_budget_admissibility': 'OPEN',
        'reported_universal_propagation': 'OPEN',
        'reported_finite_checker_soundness': 'OPEN',
        'reported_finite_checker_equivalence': 'OPEN',
        'reported_formal_closure': 'OPEN',
        'reported_unconditional_rh': 'NOT_ESTABLISHED',
        'reported_accepted_finite_witness': 'NOT_ESTABLISHED',
        'source': EVREL + '/USER_NATIVE_V0224_PASS_EXCERPT.txt',
        'source_sha256': sha(excerpt_path), 'source_bytes': excerpt_path.stat().st_size,
        'direct_native_receipt_contents': 'NOT_SUPPLIED',
        'independent_native_verification': 'NOT_PERFORMED',
        'aggregate_coverage_scope': 'USER_REPORTED_PASS_AND_INDEX_0_RESULT_MARKERS; AXIOM_LISTS_AND_AUDIT_COUNT_NOT_PRINTED',
        'reuse_requirement': 'EXACT_SAME_TARGET_SOURCE_DEPENDENCIES_TOOLCHAIN_ARTIFACTS_AND_PRIOR_AUDIT_PASS_VALIDATION',
    }
    dump(EV / 'USER_REPORTED_NATIVE_PASS.json', native)

    dump(OUT / 'DECLARATIONS.json', old_decls + new_decls)
    order = old_order + NEW
    assert len(order) == len(set(order)) == 96
    write(OUT / 'compile-order.txt', '\n'.join(order) + '\n')
    write(OUT / 'final-audit.txt', FINAL + '\n')
    rows = old_rows + [d['module'] + '|' + d['name'] for d in new_decls]
    assert len(rows) == len(set(rows))
    write(OUT / 'audit-targets.tsv', '# module|fully.qualified.declaration\n' + '\n'.join(rows) + '\n')
    targets = [row.split('|')[1] for row in rows]
    audit = '''import RH_HilbertLimit.ZeroBudgetSecondMoment
import RH_HilbertLimit.CanonicalBridge
import RH_HilbertLimit.FinitePrefix

/- Aggregate native audit for the second cancellation row of (0,0).
All 428 previous selected targets are preserved. The new finite analytic
proof sources have no RH hypothesis and await the user's native compiler.
Universal admissibility, accepted finite witness, and unconditional RH remain open.
-/

#print RH_HilbertLimit.CancellationBudget
#print RH_HilbertLimit.CancellationBudget.Admissible
#print RH_HilbertLimit.zeroBudgetCandidate

'''
    audit += ''.join('#check ' + name + '\n#print axioms ' + name + '\n\n' for name in targets)
    write(OUT / FINAL, audit)

    active = order + [FINAL]
    all_local = {rel[:-5].replace('/', '.') for rel in order}
    seen, mathlib, graph = set(), set(), {}
    for rel in active:
        source = clean_source((OUT / rel).read_text(encoding='utf-8'))
        assert not re.search(r'\b(sorry|admit|axiom|unsafe|native_decide)\b', source), rel
        assert 'debug.skipKernel' not in source, rel
        imports = re.findall(r'^import\s+([A-Za-z_][A-Za-z0-9_.]*)\s*$', source, re.M)
        graph[rel] = imports
        for dep in imports:
            if dep in all_local:
                assert dep in seen, (rel, dep, 'non-topological')
            else:
                assert dep.startswith(('Mathlib.', 'Lean.', 'Init', 'Std.')), (rel, dep)
            if dep.startswith('Mathlib.'):
                mathlib.add(dep)
        seen.add(rel[:-5].replace('/', '.'))
    old_mathlib = set(lines(BASE / 'mathlib-imports.txt'))
    assert old_mathlib <= mathlib
    if mathlib == old_mathlib:
        shutil.copyfile(BASE / 'mathlib-imports.txt', OUT / 'mathlib-imports.txt')
    else:
        write(OUT / 'mathlib-imports.txt', '\n'.join(sorted(mathlib)) + '\n')
    dump(EV / 'IMPORT_GRAPH.json', graph)

    runner = (BASE / 'tools/native_runner.js').read_bytes()
    assert runner.count(BASE.name.encode()) == runner.count(OLD_RUNNER.encode()) == 1
    runner = runner.replace(BASE.name.encode(), OUT.name.encode(), 1)
    runner = runner.replace(OLD_RUNNER.encode(), NEW_RUNNER.encode(), 1)
    assert runner.count(OLD_MATH.encode()) == 2
    runner = runner.replace(OLD_MATH.encode(), NEW_MATH.encode())
    assert runner.count(b'INDEX_0_ONLY') == 2
    runner = runner.replace(b'INDEX_0_ONLY', b'INDICES_0_AND_1_ONLY')
    json_anchor = b'''    '  "zero_budget_first_refinement_cancellation": '+quoteJSON(pass?"ZERO_DECLARATION_AUDITED":"NATIVE_AUDIT_PENDING")+",",
'''
    json_add = b'''    '  "zero_budget_second_moment_bounds": '+quoteJSON(pass?"DECLARATIONS_AUDITED":"NATIVE_AUDIT_PENDING")+",",
    '  "zero_budget_second_refinement_cancellation": '+quoteJSON(pass?"ZERO_DECLARATION_AUDITED":"NATIVE_AUDIT_PENDING")+",",
'''
    log_anchor = b'''  log("ZERO_BUDGET_FIRST_REFINEMENT_CANCELLATION=ZERO_DECLARATION_AUDITED");
'''
    log_add = b'''  log("ZERO_BUDGET_SECOND_MOMENT_BOUNDS=DECLARATIONS_AUDITED");
  log("ZERO_BUDGET_SECOND_REFINEMENT_CANCELLATION=ZERO_DECLARATION_AUDITED");
'''
    assert runner.count(json_anchor) == runner.count(log_anchor) == 1
    runner = runner.replace(json_anchor, json_anchor + json_add, 1)
    runner = runner.replace(log_anchor, log_anchor + log_add, 1)
    normalized = runner.replace(OUT.name.encode(), BASE.name.encode(), 1)
    normalized = normalized.replace(NEW_RUNNER.encode(), OLD_RUNNER.encode(), 1)
    normalized = normalized.replace(NEW_MATH.encode(), OLD_MATH.encode())
    normalized = normalized.replace(b'INDICES_0_AND_1_ONLY', b'INDEX_0_ONLY')
    normalized = normalized.replace(json_add, b'', 1).replace(log_add, b'', 1)
    assert normalized == (BASE / 'tools/native_runner.js').read_bytes()
    (OUT / 'tools/native_runner.js').write_bytes(runner)
    write(OUT / 'runner-version.txt', NEW_RUNNER + '\n')
    syntax = subprocess.run(['node', '--check', str(OUT / 'tools/native_runner.js')],
                            text=True, capture_output=True, check=False)
    assert syntax.returncode == 0, syntax.stderr
    syntax_record = {'command_kind': 'NODE_SYNTAX_CHECK_ONLY', 'exit_code': syntax.returncode,
                     'stdout': syntax.stdout, 'stderr': syntax.stderr,
                     'runner_sha256': sha(OUT / 'tools/native_runner.js'),
                     'runner_entrypoint_executed': False, 'lean_or_native_compiler_executed': False}
    dump(EV / 'NODE_SYNTAX_CHECK.json', syntax_record)
    report_edits = {'runner_sha256': sha(OUT / 'tools/native_runner.js'),
                    'baseline_runner_sha256': sha(BASE / 'tools/native_runner.js'),
                    'normalized_exact_raw_bytes_match': True,
                    'changes': ['PACKAGE', 'RUNNER_VERSION', 'two mathematical-status literals',
                                'two verified-scope literals', 'two JSON result fields', 'two success log lines'],
                    'json_addition': json_add.decode(), 'log_addition': log_add.decode(),
                    'execution_cache_audit_memory_lock_shutdown_policy_changed': False,
                    'runner_entrypoint_executed': False}
    dump(EV / 'RUNNER_REPORTING_EDITS.json', report_edits)

    new_sources = NEW + [FINAL]
    new_hashes = {rel: sha(OUT / rel) for rel in new_sources}
    old_status = read_json(BASE / 'STATUS.json')
    status = dict(old_status)
    status.update({
        'package': OUT.name, 'version': '0.2.25', 'suffix': 'construction',
        'mode': 'A_TIER_LEAN', 'target': 'LOCAL_COMPILER',
        'revision_scope': 'ADDITIVE_INDEPENDENT_SECOND_CANCELLATION_ROW_SOURCE',
        'current_user_request': 'Try to prove admissibility of the explicit (0,0) witness.',
        'selected_candidate_admissibility': 'OPEN', 'universal_propagation': 'OPEN',
        'first_refinement_source_status': 'USER_REPORTED_V0_2_24_PASS_INDEX_0_ONLY_SOURCE_UNCHANGED',
        'first_refinement_verified_here': False,
        'second_refinement_source_goal': 'rowCancellation actualNormalizedMoment 1 = 0',
        'second_refinement_source_status': 'PROOF_SOURCE_WITHOUT_RH_HYPOTHESIS; NATIVE_AUDIT_PENDING',
        'second_refinement_verified_here': False,
        'second_moment_source_goals': ['0 < actualNormalizedMoment 2',
                                       'actualNormalizedMoment 2 <= actualNormalizedMoment 1',
                                       '2 * actualNormalizedMoment 1 <= 1 + actualNormalizedMoment 2'],
        'new_source_claimed_refinement_scope_after_successful_native_audit': 'INDICES_0_AND_1_ONLY',
        'latest_user_native_evidence': native, 'latest_successful_full_run': native,
        'native_validation': 'V0_2_25_NOT_RUN; USER_V0_2_24_PASS_EXCERPT_RECORDED',
        'changed_lean_source_files': [], 'added_lean_source_files': new_sources,
        'changed_existing_proof_bodies': [], 'new_source_sha256': new_hashes,
        'old_lean_files_byte_preserved': len(old_sources),
        'total_lean_source_files': len(old_sources) + len(new_sources),
        'ordered_source_modules': len(order), 'active_modules_including_final_audit': len(active),
        'selected_final_audit': FINAL, 'selected_axiom_audit_declarations': len(targets),
        'prior_audit_targets_retained': len(old_rows), 'new_public_declarations': len(new_decls),
        'declaration_inventory_entries': len(old_decls) + len(new_decls),
        'old_declaration_records_preserved': len(old_decls), 'new_public_declarations_audited_here': 0,
        'direct_mathlib_requirements': len(mathlib),
        'added_direct_mathlib_requirements': sorted(mathlib - old_mathlib),
        'source_change_invalidation_cone': new_sources,
        'first_run_expected_reuse_if_valid': len(old_order),
        'first_run_expected_source_driven_compilation_tasks': len(new_sources),
        'expected_counts_are_observed': False,
        'runtime_execution_policy_change': False, 'runner_reporting_changes': True,
        'new_runtime_mocks_run': False, 'assistant_lean_native_or_ci_execution': False,
        'delivery_filename': OUT.name + '.zip', 'canonical_archive_root': OUT.name,
        'new_version_workspace': 'E:\\RH-FAST\\workspaces\\' + OUT.name,
        'earlier_status_archive': EVREL + '/baseline_v0224_metadata/STATUS.json',
    })
    for key in ['finite_checker_soundness', 'finite_checker_completeness', 'finite_checker_equivalence',
                'terminating_actual_rh_checker', 'formal_closure', 'actual_subexponential_bound']:
        status[key] = 'OPEN'
    status['accepted_finite_witness'] = None
    status['unconditional_rh'] = 'NOT_ESTABLISHED'
    dump(OUT / 'STATUS.json', status)
    checkpoint = {
        'schema': 'RH_HILBERT_ZERO_BUDGET_SECOND_SOURCE_CHECKPOINT_V1',
        'branch': old_status['branch'], 'mode': 'A_TIER_LEAN', 'target': 'LOCAL_COMPILER',
        'checkpoint_package': OUT.name, 'revision_kind': 'ADDITIVE_PROOF_SOURCE_NOT_INIT',
        'parent_package': BASE.name, 'parent_zip_sha256': sha(PARENT_ZIP),
        'latest_user_run': native,
        'prior_explicit_endpoint_axiom_evidence': old_status['prior_explicit_endpoint_axiom_evidence'],
        'selected_candidate': {'cutoff': 0, 'coefficient': 0},
        'admissibility': 'OPEN',
        'first_refinement': 'USER_REPORTED_V0_2_24_PASS_INDEX_0_ONLY_SOURCE_UNCHANGED',
        'second_refinement': 'PROOF_SOURCE_WITHOUT_RH_HYPOTHESIS; NATIVE_AUDIT_PENDING',
        'new_source_sha256': new_hashes,
        'previous_checkpoint': EVREL + '/baseline_v0224_metadata/CHECKPOINT.json',
        'current_native_execution': 'NOT_RUN', 'new_native_or_lean_execution': False,
        'changed_runtime_policy': False, 'runtime_reporting_only': True,
        'finite_checker_equivalence': 'OPEN', 'formal_closure': 'OPEN',
    }
    dump(OUT / 'CHECKPOINT.json', checkpoint)
    write(OUT / 'README.md', f'''# RH Hilbert Limit v0.2.25 construction — second check of (0,0)

This is a proof-source continuation toward the admissibility of
`zeroBudgetCandidate : CancellationBudget := ⟨0,0⟩`. It prepares an independent
analytic proof of the second cancellation row:

```lean
rowCancellation actualNormalizedMoment 1 = 0
```

The sources have not been compiled or axiom-audited here. They must pass the
user's native Windows Lean 4.33.0 and compatible cached Mathlib audit before
the new endpoint is certified. A passing build establishes the two finite
refinement indices 0 and 1 only. It does not establish full admissibility,
an accepted finite RH witness, a complete terminating checker, or RH.

## Proof scope

The previous user excerpt reports v0.2.24 `RUN=PASS`, 3 compiled modules,
92 reused modules, and the first cancellation row audited at index 0 only.
It does not print the audit declaration count, explicit axiom lists, or a
`SORRYAX` line. The previous package selects 428 targets; that manifest count
is kept separate from what the excerpt actually prints. Earlier explicit
axiom evidence for the conditional witness-to-RH transfer remains preserved.

The new sector module strengthens the unconditional analytic geometry enough
to give positive real parts of the cubed canonical nodes. The new moment
module uses exact canonical power sums and unit real mass to prepare:

    0 < u₂,    u₂ ≤ u₁,    2u₁ ≤ 1 + u₂,

where `uₙ = actualNormalizedMoment n`. These are exactly the second-row
conditions exposed by the preserved v0.2.24 algebra. No RH hypothesis is
used in the new finite-row proofs. Source inspection is not native validation.

## Remaining endpoint

Full admissibility of (0,0) still requires the unchanged universal statement

```lean
∀ n : ℕ, rowCancellation actualNormalizedMoment n = 0
```

No uniform propagation theorem is supplied here. Two finite rows do not
imply that statement, and this package must not report witness acceptance.
The separate finite-checker soundness and equivalence goals remain open.

## Native build and preserved sources

All {len(old_sources)} previous Lean files and {len(old_decls)} previous declaration records
are retained unchanged. The new active order has {len(order)} ordinary modules plus
`{FINAL}`. All 428 former audit targets are retained, with {len(new_decls)} new
public declarations added ({len(targets)} selected targets total).

With valid same-target source/dependency/toolchain/artifact/audit identities,
{len(old_order)} old ordinary modules are eligible for reuse and the two new source
modules plus the new audit are expected to compile. Missing or invalid cache
records rebuild or fail. These are expected counts, not an observed run.

Only package identity and mathematical result reporting change in the runner.
Compiler, cache, audit, scheduling, memory, lock, and shutdown decisions retain
the baseline bytes. The existing offline setup is used without Lake setup,
Python, PowerShell, WSL, or CI in the runner.

```cmd
cd /d "%USERPROFILE%\\Downloads" && (if not exist "E:\\RH-FAST\\workspaces" mkdir "E:\\RH-FAST\\workspaces") && tar -xf "{OUT.name}.zip" -C "E:\\RH-FAST\\workspaces" && cmd /k call "E:\\RH-FAST\\workspaces\\{OUT.name}\\run.cmd"
```
''')
    write(OUT / 'OPEN_OBLIGATIONS.txt', f'''PACKAGE=v0.2.25 construction
MODE=A_TIER_LEAN
TARGET=LOCAL_COMPILER
EXPLICIT_CANDIDATE=cutoff 0, coefficient 0

1. Native-compile and axiom-audit the two new modules and {FINAL}.
   This package is source-only here; static checks are not a native PASS.
2. The proposed new endpoint is cancellation index 1, without an RH premise.
   If it passes, indices 0 and 1 are covered. Prove the unchanged universal
   all-index cancellation condition to establish (0,0)'s admissibility.
3. Universal propagation is OPEN. Finite rows alone do not imply it.
4. Terminating finite-checker soundness, completeness, and equivalence to RH
   remain OPEN. No accepted witness or unconditional RH is established.
5. Reuse only exact same-target source/dependency/toolchain/artifact/audit
   identities validated by the user's native runner.
''')
    write(OUT / 'RUNNER_NOTES.txt', f'''CURRENT=v0.2.25 construction
New second-sector and second-moment source modules; final audit {FINAL}.
{len(active)} active modules; {len(old_order)} old ordinary modules eligible for validated reuse;
3 expected source-driven tasks. v0.2.25 has not been run natively here.
Only identity and result reporting change in the runner. A successful audit
covers indices 0 and 1; universal admissibility remains OPEN.

PRESERVED HISTORICAL RUNNER NOTES FOLLOW:
''' + (BASE / 'RUNNER_NOTES.txt').read_text())

    frozen = {rel: sha(BASE / rel) for rel in old_sources}
    dump(EV / 'FROZEN_SOURCE_MANIFEST.json', {'count': len(frozen), 'sources': frozen})
    dump(EV / 'NEW_SOURCE_MANIFEST.json', {'count': len(new_hashes), 'sources': new_hashes})
    allowed_changes = set(META) | {'tools/native_runner.js'}
    preserved = []
    for path in sorted(BASE.rglob('*')):
        if not path.is_file():
            continue
        rel = path.relative_to(BASE).as_posix()
        assert (OUT / rel).is_file(), rel
        if rel not in allowed_changes:
            assert path.read_bytes() == (OUT / rel).read_bytes(), rel
            preserved.append({'path': rel, 'sha256': sha(path), 'bytes': path.stat().st_size})
    dump(EV / 'PRESERVED_PRIOR_FILES.json', {'count': len(preserved), 'files': preserved})
    integration = {
        'schema': 'RH_HILBERT_V0225_STATIC_INTEGRATION_V1',
        'status': 'STATIC_PACKAGE_INVARIANTS_VERIFIED; NATIVE_AUDIT_PENDING',
        'package': OUT.name, 'revision_kind': 'ADDITIVE_PROOF_SOURCE_NOT_INIT',
        'old_lean_sources_byte_preserved': len(old_sources),
        'new_lean_sources': new_sources, 'new_source_sha256': new_hashes,
        'old_declaration_records_preserved': len(old_decls),
        'new_public_declarations': len(new_decls),
        'ordinary_modules': len(order), 'active_modules': len(active),
        'audit_targets': len(targets), 'prior_audit_targets_retained': len(old_rows),
        'declaration_inventory_records': len(old_decls) + len(new_decls),
        'direct_mathlib_requirements': len(mathlib),
        'added_direct_mathlib_requirements': sorted(mathlib - old_mathlib),
        'import_topology': 'VERIFIED_FROM_COMMENT_STRIPPED_ACTIVE_SOURCES',
        'final_audit_exact_type_and_axiom_output_coverage': 'EVERY_SELECTED_TARGET_EXACTLY_ONCE',
        'expected_frozen_ordinary_reuse_if_valid': len(old_order),
        'expected_new_source_driven_tasks': len(new_sources), 'expected_counts_are_observed': False,
        'source_token_scan': 'NO_SORRY_ADMIT_AXIOM_UNSAFE_NATIVE_DECIDE_OR_SKIP_KERNEL_TOKENS',
        'proof_source_review_is_native_compilation': False,
        'second_check': 'SOURCE_ONLY; NATIVE_AUDIT_PENDING',
        'universal_propagation': 'OPEN', 'universal_admissibility': 'OPEN',
        'finite_checker_equivalence': 'OPEN', 'formal_closure': 'OPEN',
        'current_native_run': 'NOT_RUN', 'assistant_native_lean_lake_or_ci_execution': False,
        'node_syntax_check_exit_code': syntax.returncode,
        'runtime_logic_normalization_matches_baseline': True,
    }
    audit_clean = clean_source((OUT / FINAL).read_text())
    assert re.findall(r'^#check ([A-Za-z_][A-Za-z0-9_.]*)$', audit_clean, re.M) == targets
    assert re.findall(r'^#print axioms ([A-Za-z_][A-Za-z0-9_.]*)$', audit_clean, re.M) == targets
    assert read_json(OUT / 'DECLARATIONS.json')[:len(old_decls)] == old_decls
    assert len(list(OUT.rglob('*.lean'))) == 102
    dump(EV / 'STATIC_INTEGRATION.json', integration)
    dump(OUT / 'STATIC_REVIEW.json', integration)
    dump(OUT / 'RUNNER_LOGIC_VALIDATION.json', {
        'schema': 'RH_HILBERT_V0225_REPORTING_ONLY_REVIEW_V1',
        'status': 'STATIC_SYNTAX_AND_NORMALIZED_EXECUTION_LOGIC_IDENTITY_VERIFIED',
        **report_edits, 'node_syntax_check': 'PASS',
        'whole_runner_entrypoint_executed': False, 'new_runtime_mocks_run': False,
        'compile_cache_audit_scheduling_memory_lock_shutdown_decisions': 'BYTE_PRESERVED',
        'launcher_and_native_helpers': 'BYTE_PRESERVED',
        'native_or_lean_execution': False,
    })
    dump(OUT / 'PROVENANCE.json', {
        'package': OUT.name, 'prepared_at': datetime.now(ZoneInfo('Europe/Berlin')).isoformat(),
        'branch': old_status['branch'], 'mode': 'A_TIER_LEAN', 'target': 'LOCAL_COMPILER',
        'revision_kind': 'ADDITIVE_PROOF_SOURCE_NOT_INIT',
        'parent_package': BASE.name, 'parent_zip_sha256': sha(PARENT_ZIP),
        'parent_library_file_id': 'libfile_48346676be6481919f67e8f904a3bd73',
        'parent_library_version': 27,
        'user_evidence': native['source'], 'user_evidence_scope': native['aggregate_coverage_scope'],
        'all_old_lean_sources_byte_preserved': len(old_sources),
        'old_declaration_records_preserved': len(old_decls),
        'new_lean_sources': new_sources, 'new_public_declarations': len(new_decls),
        'new_source_sha256': new_hashes, 'runner_sha256': sha(OUT / 'tools/native_runner.js'),
        'retained_goal': old_status['requested_goal'],
        'current_subgoal': 'Prove zeroBudgetCandidate.Admissible without an RH premise.',
        'candidate': {'cutoff': 0, 'coefficient': 0},
        'new_proof_scope': 'SECOND_CANCELLATION_ROW; SOURCE_ONLY_NATIVE_AUDIT_PENDING',
        'universal_admissibility': 'OPEN', 'finite_checker_equivalence': 'OPEN',
        'formal_closure': 'OPEN', 'current_native_or_lean_execution': False,
        'runtime_policy_changes': False,
        'evidence_sha256': {p.relative_to(EV).as_posix(): sha(p)
                            for p in sorted(EV.rglob('*')) if p.is_file()},
    })
    files = sorted(p for p in OUT.rglob('*') if p.is_file())
    assert not any(p.is_symlink() for p in files)
    assert not any(p.suffix in {'.olean', '.ilean'} for p in files)
    write(OUT / 'SHA256SUMS.txt', ''.join(sha(p) + '  ' + p.relative_to(OUT).as_posix() + '\n'
                                        for p in files if p != OUT / 'SHA256SUMS.txt'))
    print(json.dumps({'package': str(OUT), 'audit_targets': len(targets),
                      'new_public_declarations': len(new_decls),
                      'new_sources': new_hashes, 'old_lean_files_preserved': len(old_sources),
                      'ordinary_modules': len(order), 'active_modules': len(active),
                      'node_syntax_check': syntax.returncode, 'native_execution': False,
                      'zip_created': False}, indent=2))


if __name__ == '__main__':
    main()
