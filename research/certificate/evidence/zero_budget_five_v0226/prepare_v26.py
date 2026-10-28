#!/usr/bin/env python3
"""Static integration; never runs Lean, Lake, the Windows runner, or CI."""
from pathlib import Path
from datetime import datetime
from zoneinfo import ZoneInfo
import hashlib, importlib.util, json, re, shutil, subprocess, zipfile

ROOT = Path('/workspace/scratch/f1cc8a0db89c')
BASE = ROOT/'hilbert_work/RH_HILBERT_LIMIT_LEAN_v0_2_25_construction'
OUT = ROOT/'hilbert_work/RH_HILBERT_LIMIT_LEAN_v0_2_26_construction'
EVREL = 'evidence/zero_budget_five_v0226'
EV = OUT/EVREL
NEW = ['RH_HilbertLimit/ZeroBudgetFiveSector.lean',
       'RH_HilbertLimit/ZeroBudgetFiveAlgebra.lean',
       'RH_HilbertLimit/ZeroBudgetFiveRows.lean']
FINAL = 'FiveRowsAudit.lean'
spec = importlib.util.spec_from_file_location('v25_static_helpers', ROOT/'prepare_v25.py')
helpers = importlib.util.module_from_spec(spec)
spec.loader.exec_module(helpers)
helpers.OUT, helpers.EVREL = OUT, EVREL
clean, declarations = helpers.clean_source, helpers.declarations
sha, lines = helpers.sha, helpers.lines
def write(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(value, encoding='utf-8')
def dump(path, value):
    write(path, json.dumps(value, indent=2, ensure_ascii=False)+'\n')
def read(path):
    return json.loads(path.read_text())

def main():
    EV.mkdir(parents=True, exist_ok=True)
    old_sources = sorted(p.relative_to(BASE).as_posix() for p in BASE.rglob('*.lean'))
    assert len(old_sources) == 102
    for rel in old_sources:
        assert (BASE/rel).read_bytes() == (OUT/rel).read_bytes(), rel
    old_order, old_rows = lines(BASE/'compile-order.txt'), lines(BASE/'audit-targets.tsv')
    old_decls = read(BASE/'DECLARATIONS.json')
    assert len(old_order) == 96 and len(old_rows) == 448
    new_decls = [d for rel in NEW for d in declarations(rel)]
    assert len({d['name'] for d in new_decls}) == len(new_decls)
    assert not ({d['name'] for d in old_decls} & {d['name'] for d in new_decls})
    assert 'RH_HilbertLimit.zeroBudgetCandidate_first_five_cancellations' in {d['name'] for d in new_decls}
    for rel in helpers.META:
        src = BASE/rel
        if src.is_file():
            dest = EV/'baseline_v0225_metadata'/rel
            dest.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(src,dest)
    order = old_order + NEW
    rows = old_rows + [d['module']+'|'+d['name'] for d in new_decls]
    targets = [r.split('|')[1] for r in rows]
    assert len(set(targets)) == len(targets)
    write(OUT/'compile-order.txt','\n'.join(order)+'\n')
    write(OUT/'final-audit.txt',FINAL+'\n')
    write(OUT/'audit-targets.tsv','# module|fully.qualified.declaration\n'+'\n'.join(rows)+'\n')
    dump(OUT/'DECLARATIONS.json',old_decls+new_decls)
    audit = '''import RH_HilbertLimit.ZeroBudgetFiveRows
import RH_HilbertLimit.ZeroBudgetSecondMoment
import RH_HilbertLimit.CanonicalBridge
import RH_HilbertLimit.FinitePrefix

/- Aggregate audit for the first five cancellation indices, 0 through 4.
All previous selected targets remain. No unconditional RH or universal
admissibility is asserted. Native Windows compilation and audit are pending.
-/

#print RH_HilbertLimit.CancellationBudget
#print RH_HilbertLimit.CancellationBudget.Admissible
#print RH_HilbertLimit.zeroBudgetCandidate
#print RH_HilbertLimit.zeroBudgetCandidate_first_five_cancellations

'''
    audit += ''.join('#check '+name+'\n#print axioms '+name+'\n\n' for name in targets)
    write(OUT/FINAL,audit)
    active = order+[FINAL]
    local = {r[:-5].replace('/','.') for r in order}
    seen, mathlib, graph = set(), set(), {}
    for rel in active:
        source = clean((OUT/rel).read_text())
        assert not re.search(r'\b(sorry|admit|axiom|unsafe|native_decide)\b', source),rel
        assert 'debug.skipKernel' not in source
        imports = re.findall(r'^import\s+([A-Za-z_][A-Za-z0-9_.]*)\s*$',source,re.M)
        graph[rel] = imports
        for dep in imports:
            if dep in local: assert dep in seen,(rel,dep)
            else: assert dep.startswith(('Mathlib.','Lean.','Init','Std.')),(rel,dep)
            if dep.startswith('Mathlib.'): mathlib.add(dep)
        seen.add(rel[:-5].replace('/','.'))
    old_mathlib=set(lines(BASE/'mathlib-imports.txt'))
    assert old_mathlib <= mathlib
    if old_mathlib == mathlib:
        shutil.copyfile(BASE/'mathlib-imports.txt',OUT/'mathlib-imports.txt')
    else: write(OUT/'mathlib-imports.txt','\n'.join(sorted(mathlib))+'\n')
    dump(EV/'IMPORT_GRAPH.json',graph)
    replacements = [
      (BASE.name, OUT.name, 1),
      ('RH_HILBERT_NATIVE_RUNNER_v0_2_25_ZERO_BUDGET_SECOND_CHECK',
       'RH_HILBERT_NATIVE_RUNNER_v0_2_26_ZERO_BUDGET_FIRST_FIVE',1),
      ('ZERO_BUDGET_FIRST_TWO_REFINEMENTS_AUDITED_UNIVERSAL_ADMISSIBILITY_OPEN',
       'ZERO_BUDGET_FIRST_FIVE_REFINEMENTS_AUDITED_UNIVERSAL_ADMISSIBILITY_OPEN',2),
      ('INDICES_0_AND_1_ONLY','INDICES_0_THROUGH_4_ONLY',2)]
    runner=(BASE/'tools/native_runner.js').read_bytes()
    for old,new,count in replacements:
        assert runner.count(old.encode()) == count, old
        runner=runner.replace(old.encode(),new.encode())
    json_anchor=b'''    '  "zero_budget_second_refinement_cancellation": '+quoteJSON(pass?"ZERO_DECLARATION_AUDITED":"NATIVE_AUDIT_PENDING")+",",
'''
    json_add=b'''    '  "zero_budget_first_five_cancellations": '+quoteJSON(pass?"DECLARATION_AUDITED":"NATIVE_AUDIT_PENDING")+",",
    '  "next_requested_batch": "INDICES_5_THROUGH_9_AFTER_FIRST_BATCH_NATIVE_PASS",',
    '  "next_batch_status": "NOT_INCLUDED_NOT_VERIFIED",',
'''
    log_anchor=b'''  log("ZERO_BUDGET_SECOND_REFINEMENT_CANCELLATION=ZERO_DECLARATION_AUDITED");
'''
    log_add=b'''  log("ZERO_BUDGET_FIRST_FIVE_CANCELLATIONS=DECLARATION_AUDITED");
  log("ZERO_BUDGET_NEXT_REQUESTED_BATCH=INDICES_5_THROUGH_9_AFTER_FIRST_BATCH_NATIVE_PASS");
  log("ZERO_BUDGET_NEXT_BATCH_STATUS=NOT_INCLUDED_NOT_VERIFIED");
'''
    assert runner.count(json_anchor)==runner.count(log_anchor)==1
    runner=runner.replace(json_anchor,json_anchor+json_add,1).replace(log_anchor,log_anchor+log_add,1)
    normalized=runner.replace(json_add,b'',1).replace(log_add,b'',1)
    for old,new,count in reversed(replacements):
        assert normalized.count(new.encode())==count
        normalized=normalized.replace(new.encode(),old.encode())
    assert normalized == (BASE/'tools/native_runner.js').read_bytes()
    (OUT/'tools/native_runner.js').write_bytes(runner)
    write(OUT/'runner-version.txt',replacements[1][1]+'\n')
    syntax=subprocess.run(['node','--check',str(OUT/'tools/native_runner.js')],capture_output=True,text=True)
    assert syntax.returncode==0,syntax.stderr
    edits={'normalized_execution_logic_byte_identical':True,'runner_sha256':sha(OUT/'tools/native_runner.js'),
       'baseline_runner_sha256':sha(BASE/'tools/native_runner.js'),'replacements':replacements,
       'json_addition':json_add.decode(),'log_addition':log_add.decode(),
       'node_syntax_exit_code':syntax.returncode,'runner_entrypoint_executed':False,
       'compiler_cache_audit_lock_shutdown_policy_changed':False}
    dump(EV/'RUNNER_REPORTING_EDITS.json',edits)
    sources=NEW+[FINAL]
    hashes={rel:sha(OUT/rel) for rel in sources}
    status=read(BASE/'STATUS.json')
    status.update({
      'package':OUT.name,'version':'0.2.26','mode':'A_TIER_LEAN','target':'LOCAL_COMPILER',
      'revision_scope':'ADDITIVE_FIRST_FIVE_CANCELLATION_PROOF_SOURCE',
      'current_user_request':'First five cancellation indices 0..4; next five 5..9 only after first batch native PASS.',
      'native_validation':'V0_2_26_NOT_RUN; V0_2_25_PASS_NOT_SUPPLIED; LAST_USER_PASS_V0_2_24',
      'first_five_source_goal':'forall n : Nat, n < 5 -> rowCancellation actualNormalizedMoment n = 0',
      'first_five_source_status':'PROOF_SOURCE_WITHOUT_RH_HYPOTHESIS; NATIVE_AUDIT_PENDING',
      'new_source_claimed_refinement_scope_after_successful_native_audit':'INDICES_0_THROUGH_4_ONLY',
      'first_batch_indices':[0,1,2,3,4],'next_batch_indices':[5,6,7,8,9],
      'next_batch_gate':'FIRST_BATCH_USER_NATIVE_BUILD_AND_AXIOM_AUDIT_PASS',
      'next_batch_status':'NOT_INCLUDED_NOT_VERIFIED',
      'changed_lean_source_files':[],'added_lean_source_files':sources,'changed_existing_proof_bodies':[],
      'new_source_sha256':hashes,'old_lean_files_byte_preserved':len(old_sources),
      'total_lean_source_files':len(old_sources)+len(sources),'ordered_source_modules':len(order),
      'active_modules_including_final_audit':len(active),'selected_final_audit':FINAL,
      'selected_axiom_audit_declarations':len(targets),'prior_audit_targets_retained':len(old_rows),
      'new_public_declarations':len(new_decls),'declaration_inventory_entries':len(old_decls)+len(new_decls),
      'old_declaration_records_preserved':len(old_decls),'new_public_declarations_audited_here':0,
      'direct_mathlib_requirements':len(mathlib),'added_direct_mathlib_requirements':sorted(mathlib-old_mathlib),
      'source_change_invalidation_cone':sources,'first_run_expected_reuse_if_valid':len(old_order),
      'first_run_expected_source_driven_compilation_tasks':len(sources),
      'if_only_v0224_cache_valid_expected_old_reuse':94,
      'if_only_v0224_cache_valid_expected_source_driven_tasks':6,
      'expected_counts_are_observed':False,'runtime_execution_policy_change':False,
      'runner_reporting_changes':True,'new_runtime_mocks_run':False,
      'assistant_lean_native_or_ci_execution':False,
      'delivery_filename':OUT.name+'.zip','canonical_archive_root':OUT.name,
      'new_version_workspace':'E:\\RH-FAST\\workspaces\\'+OUT.name,
      'earlier_status_archive':EVREL+'/baseline_v0225_metadata/STATUS.json'})
    for key in ['selected_candidate_admissibility','universal_propagation','finite_checker_soundness',
       'finite_checker_completeness','finite_checker_equivalence','terminating_actual_rh_checker',
       'formal_closure','actual_subexponential_bound']: status[key]='OPEN'
    status['accepted_finite_witness']=None
    status['unconditional_rh']='NOT_ESTABLISHED'
    dump(OUT/'STATUS.json',status)
    dump(OUT/'CHECKPOINT.json',{'schema':'RH_HILBERT_FIRST_FIVE_SOURCE_CHECKPOINT_V1',
       'branch':status['branch'],'mode':'A_TIER_LEAN','target':'LOCAL_COMPILER',
       'checkpoint_package':OUT.name,'parent_package':BASE.name,
       'parent_zip_sha256':sha(ROOT/'output'/ (BASE.name+'.zip')),
       'revision_kind':'ADDITIVE_PROOF_SOURCE_NOT_INIT','selected_candidate':{'cutoff':0,'coefficient':0},
       'new_source_sha256':hashes,'native_execution':'NOT_RUN','native_audit':'PENDING',
       'latest_user_native_evidence':status['latest_user_native_evidence'],
       'first_batch_indices':[0,1,2,3,4],'next_batch_gate':status['next_batch_gate'],
       'next_batch_status':'NOT_INCLUDED_NOT_VERIFIED','universal_admissibility':'OPEN'})
    write(OUT/'README.md',f'''# RH Hilbert Limit v0.2.26 construction — first five cancellation checks

This package prepares the exact finite endpoint, with no RH hypothesis:

```lean
forall n : Nat, n < 5 -> rowCancellation actualNormalizedMoment n = 0
```

The first five terms mean cancellation indices 0,1,2,3,4. They require
Bernstein row degrees through 5 and normalized moments through u_5.
The requested next batch is indices 5,6,7,8,9. That batch is not included
or verified and is gated on the first batch passing the user's native
compiler and axiom audit. It is not started merely by source packaging.

## Proof construction and status

The stronger theta-kernel bound prepares a zero-free strip through height
17/4, and hence the canonical-node inequality 4*abs(im node) <= re node.
Unit complex mass gives the complementary inequality
4*abs(im node) <= 1-re node. Exact rational cone multiplication handles
products of at most six factors. The canonical power sums identify these
products with the actual Bernstein weights; nonnegative weights give row
variation one and zero cancellation at indices below five.

No Lean, Lake, native Windows runner, or CI was run while preparing this
archive. All new proof claims remain pending native compilation and audit.
The latest supplied native PASS is v0.2.24 (index 0); no v0.2.25 PASS was
provided in this turn. Historical evidence and all prior sources remain.

## Preserved project and native run

All {len(old_sources)} previous Lean source files and {len(old_rows)} audit
targets are preserved. There are {len(new_decls)} new public declarations,
{len(targets)} selected audit targets, and {len(active)} active modules.
With valid v0.2.25 anchors, {len(old_order)} ordinary modules may be reused
and the three added modules plus the final audit need compilation. With
only valid v0.2.24 ordinary anchors, 94 may be reused and six tasks need
compilation. These are eligibility estimates, not observed results.
Every reuse still requires exact same-target source/dependency/toolchain/
artifact fingerprints and a prior validated native audit PASS.

Compiler, cache, audit, scheduling, memory, lock, and shutdown behavior
are byte-preserved after normalizing package identity and result reporting.
The single run.cmd uses the established native Windows Lean 4.33.0 and
compatible cached Mathlib. It adds no Lake setup, Python, PowerShell or WSL.

## Open endpoint

Full admissibility of (0,0) still requires zero cancellation for EVERY
natural index. No universal propagation, accepted finite RH witness,
terminating finite-checker equivalence, or unconditional RH is established.
Even a successful first-five audit proves only the stated finite range.

```cmd
cd /d "%USERPROFILE%\\Downloads" && (if not exist "E:\\RH-FAST\\workspaces" mkdir "E:\\RH-FAST\\workspaces") && tar -xf "{OUT.name}.zip" -C "E:\\RH-FAST\\workspaces" && cmd /k call "E:\\RH-FAST\\workspaces\\{OUT.name}\\run.cmd"
```
''')
    write(OUT/'OPEN_OBLIGATIONS.txt','''MODE=A_TIER_LEAN
TARGET=LOCAL_COMPILER
FIRST_BATCH=INDICES_0_THROUGH_4; NATIVE_COMPILATION_AND_AXIOM_AUDIT_PENDING
NEXT_BATCH=INDICES_5_THROUGH_9; START_AFTER_FIRST_BATCH_NATIVE_PASS
NEXT_BATCH_STATUS=NOT_INCLUDED_NOT_VERIFIED
ZERO_BUDGET_ADMISSIBILITY=OPEN
ZERO_BUDGET_UNIVERSAL_PROPAGATION=OPEN
FINITE_CHECKER_SOUNDNESS=OPEN
FINITE_CHECKER_EQUIVALENCE=OPEN
FORMAL_CLOSURE=OPEN
UNCONDITIONAL_RH=NOT_ESTABLISHED
FINITE_ACCEPTED_WITNESS=NOT_ESTABLISHED
''')
    write(OUT/'RUNNER_NOTES.txt',f'''CURRENT=v0.2.26 construction
Three added first-five source modules and {FINAL}.
Current native build and audit pending. Next five are gated on first-batch PASS.
Only package identity and result reporting differ in the runner.

PRESERVED HISTORICAL NOTES FOLLOW:
'''+(BASE/'RUNNER_NOTES.txt').read_text())
    integration={'status':'STATIC_INVARIANTS_VERIFIED_NATIVE_AUDIT_PENDING',
       'package':OUT.name,'old_lean_files_preserved':len(old_sources),
       'new_source_sha256':hashes,'new_public_declarations':len(new_decls),
       'old_audit_targets_preserved':len(old_rows),'audit_targets':len(targets),
       'active_modules':len(active),'import_topology':'VERIFIED',
       'source_token_scan':'NO_SORRY_ADMIT_AXIOM_UNSAFE_NATIVE_DECIDE_OR_SKIP_KERNEL',
       'runtime_policy_byte_preserved':True,'native_compilation':'NOT_RUN','native_audit':'PENDING',
       'first_batch_indices':[0,1,2,3,4],'next_batch_status':'NOT_INCLUDED_NOT_VERIFIED',
       'universal_admissibility':'OPEN','unconditional_rh':'NOT_ESTABLISHED'}
    dump(OUT/'STATIC_REVIEW.json',integration)
    dump(EV/'STATIC_INTEGRATION.json',integration)
    dump(OUT/'RUNNER_LOGIC_VALIDATION.json',edits)
    dump(OUT/'PROVENANCE.json',{'package':OUT.name,'parent':BASE.name,
       'prepared_at':datetime.now(ZoneInfo('Europe/Berlin')).isoformat(),
       'revision_kind':'ADDITIVE_PROOF_SOURCE_NOT_INIT','source_sha256':hashes,
       'assistant_lean_native_or_ci_execution':False})
    dump(EV/'FROZEN_SOURCE_MANIFEST.json',{'count':len(old_sources),
       'sources':{r:sha(BASE/r) for r in old_sources}})
    allowed=set(helpers.META)|{'tools/native_runner.js'}
    preserved=[]
    for p in BASE.rglob('*'):
        if p.is_file():
            rel=p.relative_to(BASE).as_posix()
            if rel not in allowed:
                assert p.read_bytes()==(OUT/rel).read_bytes(),rel
                preserved.append(rel)
    dump(EV/'PRESERVED_PRIOR_FILES.json',{'count':len(preserved),'files':preserved})
    shutil.copyfile(Path(__file__),EV/'prepare_v26.py')
    assert len(list(OUT.rglob('*.lean')))==106
    assert re.findall(r'^#check (\S+)$',clean(audit),re.M)==targets
    assert re.findall(r'^#print axioms (\S+)$',clean(audit),re.M)==targets
    print(json.dumps(integration,indent=2))

if __name__=='__main__': main()
