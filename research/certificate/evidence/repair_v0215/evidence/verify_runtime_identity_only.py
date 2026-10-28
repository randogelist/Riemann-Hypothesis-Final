from pathlib import Path
import argparse, hashlib, json, re

parser = argparse.ArgumentParser(description='Static byte review only; no runner or compiler execution.')
parser.add_argument('--baseline', required=True, type=Path)
parser.add_argument('--candidate', required=True, type=Path)
parser.add_argument('--report', required=True, type=Path)
args = parser.parse_args()

def sha(b): return hashlib.sha256(b).hexdigest()
base = (args.baseline/'tools/native_runner.js').read_bytes()
candidate = (args.candidate/'tools/native_runner.js').read_bytes()
assert sha(base) == '828af9d989ae820ad43784839a2d140fe3f7495a55c7e43e66df3e1d145bbb02', 'unexpected reviewed baseline'

def normalise(b):
    identities = {}
    for name in (b'PACKAGE', b'RUNNER_VERSION'):
        pattern = rb'(?m)^var ' + name + rb' = "([^"\r\n]+)";$'
        matches = list(re.finditer(pattern, b))
        assert len(matches) == 1, 'identity declaration count'
        identities[name.decode()] = matches[0].group(1).decode()
        b, count = re.subn(pattern, b'var ' + name + b' = "NORMALIZED_IDENTITY";', b)
        assert count == 1
    return b, identities
base_norm, old_ids = normalise(base)
candidate_norm, new_ids = normalise(candidate)
assert base_norm == candidate_norm, 'runtime changed outside two identity literals'
assert new_ids['PACKAGE'] == 'RH_HILBERT_LIMIT_LEAN_v0_2_15_construction'
assert new_ids['RUNNER_VERSION'].startswith('RH_HILBERT_NATIVE_RUNNER_v0_2_15_')
assert (args.candidate/'runner-version.txt').read_text().strip() == new_ids['RUNNER_VERSION']
old_files = {p.relative_to(args.baseline/'tools').as_posix() for p in (args.baseline/'tools').rglob('*') if p.is_file()}
new_files = {p.relative_to(args.candidate/'tools').as_posix() for p in (args.candidate/'tools').rglob('*') if p.is_file()}
assert old_files == new_files, 'runtime helper file set changed'
unchanged = []
for rel in sorted(old_files - {'native_runner.js'}):
    a = (args.baseline/'tools'/rel).read_bytes(); b = (args.candidate/'tools'/rel).read_bytes()
    assert a == b, 'runtime helper changed: ' + rel
    unchanged.append({'path':'tools/'+rel, 'bytes':len(a), 'sha256':sha(a)})
a=(args.baseline/'run.cmd').read_bytes();b=(args.candidate/'run.cmd').read_bytes()
assert a==b, 'run.cmd changed'
unchanged.append({'path':'run.cmd','bytes':len(a),'sha256':sha(a)})
report={
 'schema':'RH_V0215_RUNTIME_IDENTITY_ONLY_STATIC_REVIEW_V1', 'status':'PASS_STATIC_BYTE_COMPARISON',
 'baseline_runner_sha256':sha(base),'candidate_runner_sha256':sha(candidate),
 'normalised_runner_sha256':sha(base_norm),
 'changed_identity_literals':{'baseline':old_ids,'candidate':new_ids},
 'all_other_runner_bytes_unchanged':True,'unchanged_runtime_files':unchanged,
 'new_runtime_tests_run':False,'reason_no_new_runtime_mocks':'Functional code is byte-identical after replacing the two package/version identity literals. Prior test evidence remains historical and is not relabeled as a v0.2.15 execution.',
 'no_native_or_lean_execution':True,
 'limitations':['This is a static byte comparison, not native Windows runtime verification.','No new proof/axiom or runtime PASS is established for the candidate package.']
}
args.report.parent.mkdir(parents=True,exist_ok=True)
args.report.write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps({'status':report['status'],'candidate_runner_sha256':report['candidate_runner_sha256'],'report':str(args.report),'report_sha256':sha(args.report.read_bytes())},indent=2))
