from pathlib import Path
from datetime import datetime
from zoneinfo import ZoneInfo
import hashlib
import json
import re
import shutil

ROOT = Path('/workspace/scratch/f128c1434505')
WORK = ROOT / 'tmp/zero_budget_v0224'
BASE = ROOT / 'output/RH_HILBERT_LIMIT_LEAN_v0_2_23_construction'
OUT = ROOT / 'output/RH_HILBERT_LIMIT_LEAN_v0_2_24_construction'
EVREL = 'evidence/zero_budget_v0224'
EV = OUT / EVREL
NEW = ['RH_HilbertLimit/ZeroBudgetCandidate.lean',
       'RH_HilbertLimit/ZeroBudgetFirstMoment.lean']
FINAL = 'ZeroBudgetAudit.lean'
OLD_RUNNER = 'RH_HILBERT_NATIVE_RUNNER_v0_2_23_NATIVE_REUSE_PASS_CHECKPOINT'
NEW_RUNNER = 'RH_HILBERT_NATIVE_RUNNER_v0_2_24_ZERO_BUDGET_FIRST_CHECK'
OLD_MATH = 'ANALYTIC_AND_SEMANTIC_CANCELLATION_AUDITED_FINITE_CHECKER_OPEN'
NEW_MATH = 'ZERO_BUDGET_FIRST_REFINEMENT_AUDITED_UNIVERSAL_ADMISSIBILITY_OPEN'


def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def write(p, value):
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(value, encoding='utf-8')


def dump(p, value):
    write(p, json.dumps(value, indent=2, ensure_ascii=False) + '\n')


def read_json(p):
    return json.loads(p.read_text(encoding='utf-8'))


def lines(p):
    return [s.strip() for s in p.read_text(encoding='utf-8').splitlines()
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
    assert depth == 0 and not quoted
    return ''.join(out)


def declarations(rel):
    src = OUT / rel
    text = clean_source(src.read_text(encoding='utf-8'))
    assert not re.search(r'\b(sorry|admit|axiom|unsafe|native_decide)\b', text), rel
    assert 'debug.skipKernel' not in text
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


def assemble():
    assert sha(BASE.with_suffix('.zip')) == 'ecb83a0018c8b1789b8444437e353a8229169b69ef13ed06fcd982bcfb5af369'
    if not OUT.exists():
        shutil.copytree(BASE, OUT)
    archive = EV / 'baseline_v0223_metadata'
    archive.mkdir(parents=True, exist_ok=True)
    for rel in ['STATUS.json', 'CHECKPOINT.json', 'README.md', 'OPEN_OBLIGATIONS.txt',
                'RUNNER_NOTES.txt', 'runner-version.txt', 'DECLARATIONS.json',
                'compile-order.txt', 'final-audit.txt', 'audit-targets.tsv',
                'PROVENANCE.json', 'STATIC_REVIEW.json', 'RUNNER_LOGIC_VALIDATION.json', 'SHA256SUMS.txt']:
        shutil.copyfile(BASE / rel, archive / rel)
    for rel in NEW:
        assert (WORK / 'proof' / Path(rel).name).is_file(), rel
        shutil.copyfile(WORK / 'proof' / Path(rel).name, OUT / rel)

    old_sources = sorted(p.relative_to(BASE).as_posix() for p in BASE.rglob('*.lean'))
    assert len(old_sources) == 96
    for rel in old_sources:
        assert (OUT / rel).read_bytes() == (BASE / rel).read_bytes(), rel
    new_decls = [d for rel in NEW for d in declarations(rel)]
    old_decls = read_json(BASE / 'DECLARATIONS.json')
    assert len(old_decls) == 1129
    assert not ({d['name'] for d in old_decls} & {d['name'] for d in new_decls})
    assert len({d['name'] for d in new_decls}) == len(new_decls)
    old_text = (BASE / 'DECLARATIONS.json').read_text(encoding='utf-8').rstrip()
    assert old_text.endswith(']')
    append_text = json.dumps(new_decls, indent=2, ensure_ascii=False)[1:-1].strip('\n')
    write(OUT / 'DECLARATIONS.json', old_text[:-1].rstrip() + ',\n' + append_text + '\n]\n')
    assert read_json(OUT / 'DECLARATIONS.json')[:1129] == old_decls
    old_order = lines(BASE / 'compile-order.txt')
    assert len(old_order) == 92
    order = old_order + NEW
    assert len(order) == len(set(order)) == 94
    write(OUT / 'compile-order.txt', (BASE / 'compile-order.txt').read_text().rstrip() + '\n' + '\n'.join(NEW) + '\n')
    write(OUT / 'final-audit.txt', FINAL + '\n')
    old_rows = lines(BASE / 'audit-targets.tsv')
    assert len(old_rows) == 394
    rows = old_rows + [d['module'] + '|' + d['name'] for d in new_decls]
    assert len(rows) == len(set(rows))
    write(OUT / 'audit-targets.tsv', (BASE / 'audit-targets.tsv').read_text().rstrip() +
          '\n' + '\n'.join(rows[len(old_rows):]) + '\n')
    names = [r.split('|')[1] for r in rows]
    audit = '''import RH_HilbertLimit.ZeroBudgetFirstMoment
import RH_HilbertLimit.CanonicalBridge
import RH_HilbertLimit.FinitePrefix

/- Native aggregate audit for the explicit (0,0) candidate.
All 394 prior selected targets are retained. New source proves exact candidate
checks and the first actual cancellation row without assuming RH. Universal
admissibility and the terminating finite-checker endpoint remain OPEN.
Prepared without running Lean; the user native run must compile and audit it.
-/

#print RH_HilbertLimit.CancellationBudget
#print RH_HilbertLimit.CancellationBudget.Admissible
#print RH_HilbertLimit.zeroBudgetCandidate

'''
    audit += ''.join('#check ' + name + '\n#print axioms ' + name + '\n\n' for name in names)
    write(OUT / FINAL, audit)

    active = order + [FINAL]
    all_local = {str(Path(rel).with_suffix('')).replace('/', '.') for rel in order}
    seen = set()
    mathlib = set()
    imported_graph = {}
    for rel in active:
        source = clean_source((OUT / rel).read_text(encoding='utf-8'))
        assert not re.search(r'\b(sorry|admit|axiom|unsafe|native_decide)\b', source), rel
        imports = re.findall(r'^import\s+([A-Za-z_][A-Za-z0-9_.]*)\s*$', source, re.M)
        imported_graph[rel] = imports
        for dep in imports:
            if dep in all_local:
                assert dep in seen, (rel, dep, 'non-topological')
            elif not dep.startswith(('Mathlib.', 'Lean.', 'Init', 'Std.')):
                raise AssertionError((rel, dep, 'unplanned local import'))
            if dep.startswith('Mathlib.'):
                mathlib.add(dep)
        seen.add(rel[:-5].replace('/', '.'))
    assert mathlib == set(lines(BASE / 'mathlib-imports.txt'))
    assert len(mathlib) == 91
    assert (BASE / 'mathlib-imports.txt').read_bytes() == (OUT / 'mathlib-imports.txt').read_bytes()

    runner = (BASE / 'tools/native_runner.js').read_bytes()
    assert runner.count(BASE.name.encode()) == runner.count(OLD_RUNNER.encode()) == 1
    runner = runner.replace(BASE.name.encode(), OUT.name.encode(), 1).replace(OLD_RUNNER.encode(), NEW_RUNNER.encode(), 1)
    assert runner.count(OLD_MATH.encode()) == 2
    runner = runner.replace(OLD_MATH.encode(), NEW_MATH.encode())
    json_anchor = b'''    '  "witness_admissibility": "UNIVERSAL_AFTER_FINITE_CUTOFF_NOT_A_BOOL_CHECK",',\n'''
    json_add = b'''    '  "zero_budget_candidate": {"cutoff":0,"coefficient":0},',
    '  "zero_budget_first_moment_bounds": '+quoteJSON(pass?"DECLARATIONS_AUDITED":"NATIVE_AUDIT_PENDING")+",",
    '  "zero_budget_first_refinement_cancellation": '+quoteJSON(pass?"ZERO_DECLARATION_AUDITED":"NATIVE_AUDIT_PENDING")+",",
    '  "zero_budget_verified_refinement_scope": '+quoteJSON(pass?"INDEX_0_ONLY":"NOT_CERTIFIED")+",",
    '  "zero_budget_universal_propagation": "OPEN",',
    '  "zero_budget_admissibility": "OPEN",',
'''
    assert runner.count(json_anchor) == 1
    runner = runner.replace(json_anchor, json_anchor + json_add, 1)
    log_anchor = b'''  log("WITNESS_ADMISSIBILITY=UNIVERSAL_AFTER_FINITE_CUTOFF_NOT_A_BOOL_CHECK");\n'''
    log_add = b'''  log("ZERO_BUDGET_CANDIDATE=CUTOFF_0_COEFFICIENT_0");
  log("ZERO_BUDGET_FIRST_MOMENT_BOUNDS=DECLARATIONS_AUDITED");
  log("ZERO_BUDGET_FIRST_REFINEMENT_CANCELLATION=ZERO_DECLARATION_AUDITED");
  log("ZERO_BUDGET_VERIFIED_REFINEMENT_SCOPE=INDEX_0_ONLY");
  log("ZERO_BUDGET_UNIVERSAL_PROPAGATION=OPEN");
  log("ZERO_BUDGET_ADMISSIBILITY=OPEN");
'''
    assert runner.count(log_anchor) == 1
    runner = runner.replace(log_anchor, log_anchor + log_add, 1)
    (OUT / 'tools/native_runner.js').write_bytes(runner)
    write(OUT / 'runner-version.txt', NEW_RUNNER + '\n')
    normalized = runner.replace(OUT.name.encode(), BASE.name.encode(), 1).replace(NEW_RUNNER.encode(), OLD_RUNNER.encode(), 1)
    normalized = normalized.replace(NEW_MATH.encode(), OLD_MATH.encode()).replace(json_add, b'', 1).replace(log_add, b'', 1)
    assert normalized == (BASE / 'tools/native_runner.js').read_bytes()
    dump(WORK / 'RUNNER_REPORTING_EDITS.json', {'runner_sha256': sha(OUT / 'tools/native_runner.js'),
        'baseline_runner_sha256': sha(BASE / 'tools/native_runner.js'),
        'normalization_exact_bytes_match': True,
        'changes': ['PACKAGE', 'RUNNER_VERSION', 'two mathematical-status literals',
                    'six JSON reporting fields', 'six post-success log lines'],
        'json_addition': json_add.decode(), 'log_addition': log_add.decode(),
        'execution_cache_audit_memory_lock_shutdown_policy_changed': False,
        'native_or_whole_runner_execution': False})

    log_name = 'USER_NATIVE_V0223_PASS_EXCERPT.txt'
    shutil.copyfile(WORK / log_name, EV / log_name)
    log = (EV / log_name).read_text()
    def scalar(key):
        values = re.findall(r'^' + re.escape(key) + r'=(.*)$', log, re.M)
        assert len(values) == 1, key
        return values[0]
    assert scalar('RUN') == scalar('PROJECT_BUILD') == 'PASS'
    assert scalar('SORRYAX') == 'NONE'
    assert scalar('FINAL_AUDIT_DECLARATIONS') == '394'
    assert scalar('COMPILED_MODULES') == '0' and scalar('FROZEN_REUSED_MODULES') == '93'
    native = {
        'evidence_kind': 'USER_MESSAGE_EXCERPT_UTF8_LF_TRANSCRIPTION_NOT_ORIGINAL_NATIVE_LOG_BYTES',
        'reported_package': BASE.name, 'reported_build': 'PASS', 'reported_run': 'PASS',
        'reported_final_audit': 'CancellationAudit.lean', 'reported_final_audit_state': 'FROZEN_REUSED',
        'reported_final_audit_declarations': 394, 'explicitly_printed_axiom_declarations': 0,
        'reported_axiom_audit': scalar('AXIOM_AUDIT'), 'reported_sorryax': scalar('SORRYAX'),
        'reported_final_audit_module_elapsed_ms': 315,
        'reported_stages_ms': {'PROJECT_MODULES': 60054, 'FINAL_AUDIT': 407, 'WORKER_SHUTDOWN': 796},
        'reported_counts': {k: int(scalar(k)) for k in [
            'COMPILED_MODULES', 'FROZEN_REUSED_MODULES', 'AUDIT_ONLY_MODULES', 'LEGACY_MIGRATED_MODULES',
            'WORKING_ARTIFACT_MODULES_RETAINED', 'RESTORED_ARTIFACT_FILES', 'ANCHOR_HISTORY_SCANS',
            'COMPACT_ANCHORS_SAVED', 'COMBINED_WORKING_DIGESTS_CONSUMED']},
        'reported_logical_tool_launches': json.loads(scalar('LOGICAL_TOOL_LAUNCHES')),
        'reported_hash_phase_totals': json.loads(scalar('HASH_PHASE_TOTALS')),
        'reported_shutdown': {'clear': True, 'attempts': 1, 'full_inventories': 1,
            'exact_worker_queries': 0, 'snapshot_rows': 759, 'initial_unreadable_rows': 0,
            'initial_unresolved_relative_runners': 0,
            'relative_runner_absence_and_second_inventory_branch_exercised': False},
        'reported_formal_closure': scalar('FORMAL_CLOSURE'),
        'reported_finite_checker_soundness': scalar('FINITE_CHECKER_SOUNDNESS'),
        'reported_finite_checker_equivalence': scalar('FINITE_CHECKER_EQUIVALENCE'),
        'reported_accepted_finite_witness': scalar('FINITE_ACCEPTED_WITNESS'),
        'reported_unconditional_rh': scalar('UNCONDITIONAL_RH'),
        'source': EVREL + '/' + log_name, 'source_sha256': sha(EV / log_name),
        'source_bytes': (EV / log_name).stat().st_size,
        'direct_native_receipt_contents': 'NOT_SUPPLIED; PATH_ONLY',
        'native_source_dependency_toolchain_and_artifact_fingerprints': 'NOT_SUPPLIED_IN_EXCERPT',
        'independent_native_verification': 'NOT_PERFORMED',
        'aggregate_coverage_scope': '394_SELECTED_TARGETS_REUSED_PRIOR_AUDIT; NO_FRESH_PER_DECLARATION_PRINTS_IN_THIS_EXCERPT',
        'timing_scope': 'REPORTED_STAGES_AND_HASH_AGGREGATES_ONLY; NO_WHOLE_RUN_WALL_TIME',
    }
    dump(EV / 'USER_REPORTED_NATIVE_PASS.json', native)
    baseline_status = read_json(BASE / 'STATUS.json')
    prior_explicit = baseline_status['prior_explicit_endpoint_axiom_evidence']
    assert prior_explicit['reported_package'] == 'RH_HILBERT_LIMIT_LEAN_v0_2_20_construction'
    source_hashes = {rel: sha(OUT / rel) for rel in NEW + [FINAL]}
    dump(EV / 'FROZEN_SOURCE_MANIFEST.json', {rel: sha(OUT / rel) for rel in old_sources})
    dump(EV / 'NEW_SOURCE_MANIFEST.json', source_hashes)
    dump(EV / 'IMPORT_GRAPH.json', imported_graph)
    status = {
        'package': OUT.name, 'version': '0.2.24', 'suffix': 'construction',
        'mode': 'A_TIER_LEAN', 'target': 'LOCAL_COMPILER', 'branch': 'RH_HILBERT_LIMIT / Hilbert.vector',
        'revision_scope': 'ADDITIVE_EXPLICIT_ZERO_BUDGET_CANDIDATE_AND_INDEPENDENT_FIRST_REFINEMENT',
        'requested_goal': '(exists W : FiniteWitness, check W = true) iff _root_.RiemannHypothesis',
        'current_user_request': 'Explicitly try (0,0) in Lean without assuming RH.',
        'selected_candidate': {'cutoff': 0, 'coefficient': 0},
        'selected_candidate_definition': 'RH_HilbertLimit.zeroBudgetCandidate',
        'selected_candidate_admissibility': 'OPEN', 'universal_propagation': 'OPEN',
        'first_refinement_source_goal': 'rowCancellation actualNormalizedMoment 0 = 0',
        'first_refinement_source_status': 'PROOF_SOURCE_PREPARED_WITHOUT_RH_HYPOTHESIS; NATIVE_AUDIT_PENDING',
        'first_refinement_verified_here': False,
        'first_normalized_moment_source_goal': '0 < actualNormalizedMoment 1 and actualNormalizedMoment 1 <= 1',
        'source_review_is_native_compilation': False,
        'semantic_cancellation_witness_forward': 'USER_V0220_EXPLICIT_AXIOMS_AND_V0223_REUSED_AGGREGATE_PASS_SOURCE_UNCHANGED',
        'semantic_cancellation_witness_equivalence': 'USER_V0220_EXPLICIT_AXIOMS_AND_V0223_REUSED_AGGREGATE_PASS_SOURCE_UNCHANGED',
        'finite_checker_soundness': 'OPEN', 'finite_checker_completeness': 'OPEN',
        'finite_checker_equivalence': 'OPEN', 'terminating_actual_rh_checker': 'OPEN',
        'formal_closure': 'OPEN', 'accepted_finite_witness': None,
        'actual_subexponential_bound': 'OPEN', 'unconditional_rh': 'NOT_ESTABLISHED',
        'ordinary_limit_sequence': 'rootScale actualVariation',
        'latest_user_native_evidence': native, 'latest_successful_full_run': native,
        'prior_explicit_endpoint_axiom_evidence': prior_explicit,
        'native_validation': 'V0_2_24_NOT_RUN; USER_V0_2_23_HISTORICAL_CACHED_PASS_RECORDED',
        'changed_lean_source_files': [], 'added_lean_source_files': NEW + [FINAL],
        'changed_existing_proof_bodies': [], 'new_source_sha256': source_hashes,
        'old_lean_files_byte_preserved': 96, 'total_lean_source_files': 99,
        'ordered_source_modules': 94, 'active_modules_including_final_audit': 95,
        'selected_final_audit': FINAL, 'selected_axiom_audit_declarations': len(rows),
        'prior_audit_targets_retained': 394, 'new_public_declarations': len(new_decls),
        'declaration_inventory_entries': 1129 + len(new_decls),
        'old_declaration_records_preserved': 1129, 'new_public_declarations_audited_here': 0,
        'direct_mathlib_requirements': 91, 'added_direct_mathlib_requirements': [],
        'source_change_invalidation_cone': NEW + [FINAL],
        'first_run_expected_reuse_if_valid': 92, 'first_run_expected_source_driven_compilation_tasks': 3,
        'expected_counts_are_observed': False,
        'cache_reuse_condition': 'SAME_TARGET_EXACT_SOURCE_DEPENDENCIES_TOOLCHAIN_ARTIFACTS_AND_PRIOR_AUDIT_VALIDATION',
        'runtime_profile': 'LOCAL_FAST_CACHED_RAM_PARALLEL',
        'runtime_execution_policy_change': False, 'runner_reporting_changes': True,
        'new_runtime_mocks_run': False, 'assistant_lean_native_or_ci_execution': False,
        'delivery_filename': OUT.name + '.zip', 'canonical_archive_root': OUT.name,
        'new_version_workspace': 'E:\\RH-FAST\\workspaces\\' + OUT.name,
        'earlier_status_archive': EVREL + '/baseline_v0223_metadata/STATUS.json',
    }
    dump(OUT / 'STATUS.json', status)
    dump(OUT / 'CHECKPOINT.json', {
        'schema': 'RH_HILBERT_ZERO_BUDGET_SOURCE_CHECKPOINT_V1',
        'branch': status['branch'], 'mode': 'A_TIER_LEAN', 'target': 'LOCAL_COMPILER',
        'checkpoint_package': OUT.name, 'revision_kind': 'ADDITIVE_PROOF_SOURCE_NOT_INIT',
        'parent_package': BASE.name, 'parent_zip_sha256': sha(BASE.with_suffix('.zip')),
        'latest_user_run': native, 'prior_explicit_endpoint_axiom_evidence': prior_explicit,
        'selected_candidate': status['selected_candidate'], 'admissibility': 'OPEN',
        'first_refinement': status['first_refinement_source_status'],
        'new_source_sha256': source_hashes, 'previous_checkpoint': EVREL + '/baseline_v0223_metadata/CHECKPOINT.json',
        'current_native_execution': 'NOT_RUN', 'new_native_or_lean_execution': False,
        'changed_runtime_policy': False, 'runtime_reporting_only': True,
        'finite_checker_equivalence': 'OPEN', 'formal_closure': 'OPEN',
    })
    command = ('cd /d "%USERPROFILE%\\Downloads" && (if not exist "E:\\RH-FAST\\workspaces" mkdir "E:\\RH-FAST\\workspaces")'
        ' && tar -xf "' + OUT.name + '.zip" -C "E:\\RH-FAST\\workspaces"'
        ' && cmd /k call "E:\\RH-FAST\\workspaces\\' + OUT.name + '\\run.cmd"')
    write(WORK / 'RUN_COMMAND.txt', command + '\n')
    readme = '''# RH Hilbert Limit v0.2.24 construction — explicit (0,0) candidate

This package instantiates `zeroBudgetCandidate : CancellationBudget := ⟨0,0⟩`
and prepares an independent proof of its **first cancellation check**:

```lean
rowCancellation actualNormalizedMoment 0 = 0
```

The new sources have not been compiled here. They contain no proof holes,
extra axioms, or RH hypotheses in the first-check proof. Run the package with
the user's native Windows Lean 4.33.0 and cached compatible Mathlib.
**A passing build of this package does not establish universal admissibility
of (0,0), an accepted RH witness, or unconditional RH.**

## What is actually tested

Writing `W = (0,0)` fixes the cutoff and cancellation coefficient. Its
admissibility still means `∀ n, rowCancellation actualNormalizedMoment n ≤ 0`.
Each row cancellation is already nonnegative, so every such row must vanish.
The zero in the pair does not limit the check to index zero.

The new candidate module derives the exact first-row condition. With
`u₁ = actualNormalizedMoment 1`,

    C₀ = |1 − u₁| + |u₁| − 1,
    C₀ = 0 iff 0 ≤ u₁ and u₁ ≤ 1.

The first-moment module supplies these inequalities from the actual analytic
data, independently of RH. Its argument uses the existing theta-kernel bound
`‖completedRiemannZeta₀ s‖ ≤ 3/8` on the critical strip. At height at most 5/4,
the xi correction has norm at most `(41/16)*(3/8)=123/128<1`, excluding zeros.
That stronger height bound places each complex zero scale in the sector
`Re(a)/‖a‖ ≥ 21/29`. Because `2*(21/29)^2>1`, the real part of its square is
positive. Inversion and the positive normalization preserve this sign.
The exact canonical power sums then give `0 < u₁`; positive real canonical
masses of total one give `u₁ ≤ 1`. Consequently `C₀=0` and `actualVariation 1=1`.

These are source arguments awaiting the native compiler and axiom audit.
They use exact rational inequalities and analytic theorems, not a numerical
sample or a call that assumes an RH conclusion.

## What remains open

The candidate module also exposes the next row and the universal induction
obligation. Once the first check is supplied, the missing propagation is:

```lean
∀ n : ℕ,
  rowCancellation actualNormalizedMoment n = 0 →
  rowCancellation actualNormalizedMoment (n + 1) = 0
```

This universal step is **not proved** by this package. No `sorry`, `admit`,
axiom, or finite sample is used to substitute for it. The preserved audited
transfer gives RH if universal admissibility is eventually established.
The complete finite raw-data / terminating-checker equivalence also remains
open. Finite witness existence and semantic admissibility remain distinct.

## Files and native audit

- `RH_HilbertLimit/ZeroBudgetCandidate.lean`: explicit data, exact finite-row
  formulas and candidate criteria, and the displayed induction obligation.
- `RH_HilbertLimit/ZeroBudgetFirstMoment.lean`: the independent analytic first
  moment bounds and the first cancellation check.
- `ZeroBudgetAudit.lean`: every previous selected target plus every new
  public declaration, with exact type and axiom prints.

All 96 previous Lean files and all 1129 prior declaration records are
preserved. The active build has 94 ordinary modules plus the new final audit.
If the matching native anchors validate, 92 old ordinary modules are reused
and only the two new source modules and final audit compile. The old
CancellationAudit source and its history remain preserved but are inactive
as this version's selected audit. Missing or invalid anchors rebuild or fail.

The latest recorded historical user run is v0.2.23: 0 compiled, 93 reused,
394 selected declarations, standard logical axioms only, no sorryAx, and
RUN PASS. Its excerpt reports reused audit coverage rather than new explicit
per-declaration axiom output. The earlier v0.2.20 explicit endpoint evidence
is retained separately. Native receipts themselves were not supplied.

This v0.2.24 package remains **NATIVE AUDIT PENDING**. A successful run reports
`ZERO_BUDGET_VERIFIED_REFINEMENT_SCOPE=INDEX_0_ONLY` together with
`ZERO_BUDGET_ADMISSIBILITY=OPEN` and `UNCONDITIONAL_RH=NOT_ESTABLISHED`.

## Run

Use the existing offline Windows Lean and compatible Mathlib cache. The
runner retains E:\\RH-FAST workspaces and verified LEAN_ANCHORINGS. Its cache,
thread/memory admission, lock, and shutdown decisions are unchanged. Only
package identity and explicit mathematical result reporting change.
No Lake setup, Python, PowerShell, WSL, network setup, or CI is used by the
runner. The command window stays open for inspection.

```cmd
''' + command + '\n```\n'
    write(OUT / 'README.md', readme)
    write(OUT / 'OPEN_OBLIGATIONS.txt', '''PACKAGE=v0.2.24 construction
MODE=A_TIER_LEAN
TARGET=LOCAL_COMPILER
EXPLICIT_CANDIDATE=cutoff 0, coefficient 0

1. Native-compile and axiom-audit the two new Lean modules and ZeroBudgetAudit.
   Preparation and source review are not a native PASS.
2. The source establishes the first row C0=0 without assuming RH. The universal
   propagation Cn=0 -> C(n+1)=0 remains OPEN. Universal (0,0) admissibility
   is not supplied, and this package must never report witness acceptance.
3. Construct a terminating finite raw checker with proved actual-xi soundness
   and completeness for (exists W, check W = true) iff RiemannHypothesis.
4. No unconditional RH, accepted finite witness, or actual subexponential
   bound is established. Formal closure for the finite-checker goal is OPEN.
5. Reuse only exact same-target source/dependency/toolchain/artifact/audit
   identities; historical receipts remain subject to native validation.
''')
    old_notes = (BASE / 'RUNNER_NOTES.txt').read_text(encoding='utf-8')
    write(OUT / 'RUNNER_NOTES.txt', '''CURRENT=v0.2.24 construction
New candidate and first-moment modules; final audit ZeroBudgetAudit.lean.
95 active modules; 92 old ordinary modules eligible for validated reuse;
3 new source-driven tasks. v0.2.24 has not been run natively here.
Only identity and reporting change in the runner. The first cancellation
check is separate from universal admissibility, which remains OPEN.

PRESERVED HISTORICAL RUNNER NOTES FOLLOW:
''' + old_notes)
    shutil.copyfile(Path(__file__), EV / 'assemble.py')
    assembly = {
        'package': OUT.name, 'parent_package': BASE.name,
        'prepared_at': datetime.now(ZoneInfo('Europe/Berlin')).isoformat(),
        'runner_sha256': sha(OUT / 'tools/native_runner.js'),
        'old_lean_sources_byte_preserved': 96, 'new_lean_sources': NEW + [FINAL],
        'new_source_sha256': source_hashes, 'new_public_declarations': new_decls,
        'ordinary_modules': 94, 'active_modules': 95, 'total_lean_sources': 99,
        'audit_targets': len(rows), 'declaration_records': 1129 + len(new_decls),
        'direct_mathlib_requirements': 91, 'native_or_lean_execution': False,
        'universal_admissibility': 'OPEN', 'finite_checker_equivalence': 'OPEN',
    }
    dump(WORK / 'ASSEMBLY.json', assembly)
    print(json.dumps({k: v for k, v in assembly.items() if k != 'new_public_declarations'}, indent=2))


if __name__ == '__main__':
    assemble()
