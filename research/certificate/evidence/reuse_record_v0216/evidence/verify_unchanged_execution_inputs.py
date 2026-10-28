from pathlib import Path
import argparse, hashlib, json, re

parser = argparse.ArgumentParser(description='Static equality review only; executes no runner, compiler, or native code.')
parser.add_argument('--baseline', required=True, type=Path)
parser.add_argument('--candidate', required=True, type=Path)
parser.add_argument('--report', required=True, type=Path)
args = parser.parse_args()

def sha(b): return hashlib.sha256(b).hexdigest()
base = (args.baseline/'tools/native_runner.js').read_bytes()
candidate = (args.candidate/'tools/native_runner.js').read_bytes()
assert sha(base) == 'd5eb2c1f33b4fafcd0b1d366850cc860c7e73552dd739ee9cdd238559e679c86', 'unexpected baseline runner'
assert candidate == base, 'runner changed'
ids = {}
for name in (b'PACKAGE',b'RUNNER_VERSION'):
    values=re.findall(rb'(?m)^var '+name+rb' = "([^"\r\n]+)";$',candidate)
    assert len(values)==1
    ids[name.decode()]=values[0].decode()
assert ids == {'PACKAGE':'RH_HILBERT_LIMIT_LEAN_v0_2_16_construction','RUNNER_VERSION':'RH_HILBERT_NATIVE_RUNNER_v0_2_16_PASS_CHECKPOINT'}
base_tools = {p.relative_to(args.baseline/'tools').as_posix() for p in (args.baseline/'tools').rglob('*') if p.is_file()}
new_tools = {p.relative_to(args.candidate/'tools').as_posix() for p in (args.candidate/'tools').rglob('*') if p.is_file()}
assert base_tools == new_tools, 'tool file set changed'
unchanged=[]
for rel in sorted('tools/'+p for p in base_tools):
    a=(args.baseline/rel).read_bytes();b=(args.candidate/rel).read_bytes()
    assert a==b, 'tool changed: '+rel
    unchanged.append({'path':rel,'bytes':len(a),'sha256':sha(a)})
for rel in ['run.cmd','runner-version.txt','compile-order.txt','audit-targets.tsv','mathlib-imports.txt','final-audit.txt','lean-toolchain']:
    a=(args.baseline/rel).read_bytes();b=(args.candidate/rel).read_bytes()
    assert a==b, 'execution input changed: '+rel
    unchanged.append({'path':rel,'bytes':len(a),'sha256':sha(a)})
assert (args.candidate/'runner-version.txt').read_text().strip()==ids['RUNNER_VERSION']
lean_files=sorted(p.relative_to(args.baseline).as_posix() for p in args.baseline.rglob('*.lean') if 'evidence' not in p.relative_to(args.baseline).parts)
new_lean_files=sorted(p.relative_to(args.candidate).as_posix() for p in args.candidate.rglob('*.lean') if 'evidence' not in p.relative_to(args.candidate).parts)
assert len(lean_files)==92 and new_lean_files==lean_files, 'Lean source file set changed'
lean_manifest=[]
for rel in lean_files:
    a=(args.baseline/rel).read_bytes();b=(args.candidate/rel).read_bytes()
    assert a==b, 'Lean source changed: '+rel
    lean_manifest.append({'path':rel,'bytes':len(a),'sha256':sha(a)})
report={
 'schema':'RH_V0216_REUSE_RECORD_EXECUTION_INPUTS_STATIC_REVIEW_V1','status':'PASS_STATIC_BYTE_COMPARISON',
 'baseline_runner_sha256':sha(base),'candidate_runner_sha256':sha(candidate),'runner_identical':True,
 'unchanged_package_and_runner_identity':ids,'lean_source_files_unchanged':92,
 'lean_manifest_sha256':sha(json.dumps(lean_manifest,sort_keys=True,separators=(',',':')).encode()),
 'unchanged_runtime_and_execution_inputs':unchanged,
 'new_runtime_tests_run':False,'no_native_or_lean_execution':True,
 'scope':'Byte equality of every Lean source, all runner/helper sources, launcher and execution plans/settings between baseline v0.2.16 and the metadata-only reuse record.',
 'limitations':['This comparison does not execute Windows, Lean, Lake or the runner.','The external archive name may differ while its canonical package and runner identity remain unchanged. The archive root must be verified separately by packaging.','Historical native evidence is preserved as user-reported evidence; this static check does not independently re-execute or promote it.']
}
args.report.parent.mkdir(parents=True,exist_ok=True)
args.report.write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps({'status':report['status'],'candidate_runner_sha256':report['candidate_runner_sha256'],'report':str(args.report),'report_sha256':sha(args.report.read_bytes())},indent=2))
