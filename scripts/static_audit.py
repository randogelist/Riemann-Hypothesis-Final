#!/usr/bin/env python3
"""Repository integrity and exact-integer diagnostics. This does not run Lean.

Run with Python 3 from any directory. The native Windows runner does not depend
on this optional development audit. Results go to provenance/static-audit.json.
"""
from __future__ import annotations

import hashlib
import itertools
import json
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
ERRORS: list[str] = []
CHECKS: dict[str, object] = {}
# Public theorem coverage for the original integration and the newly active
# analytic/native finite-program closures. This remains a static target-list
# check; only the native runner executes the corresponding axiom reports.
AUDITED_SOURCE_PREFIXES = (
    'RHFinal/', 'AWPIRH/', 'AngularMaster/', 'FiveInduction/',
    'SoloAdmission/', 'SoloboloAdmission/',
)


def require(condition: bool, message: str) -> None:
    if not condition:
        ERRORS.append(message)


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def lean_code(text: str) -> str:
    """Mask strings, line comments and nested Lean block comments, keeping lines."""
    out, i, depth = [], 0, 0
    string = False
    while i < len(text):
        c, pair = text[i], text[i:i + 2]
        if depth:
            if pair == '/-':
                depth += 1
                out.extend('  ')
                i += 2
            elif pair == '-/':
                depth -= 1
                out.extend('  ')
                i += 2
            else:
                out.append('\n' if c == '\n' else ' ')
                i += 1
        elif string:
            if c == '\\' and i + 1 < len(text):
                out.extend('  ')
                i += 2
            else:
                if c == '"':
                    string = False
                out.append('\n' if c == '\n' else ' ')
                i += 1
        elif pair == '/-':
            depth = 1
            out.extend('  ')
            i += 2
        elif pair == '--':
            end = text.find('\n', i)
            if end < 0:
                end = len(text)
            out.extend(' ' * (end - i))
            i = end
        elif c == '"':
            string = True
            out.append(' ')
            i += 1
        else:
            out.append(c)
            i += 1
    require(depth == 0 and not string, 'Unclosed comment or string in inspected source')
    return ''.join(out)


def read_plan(name: str, expected: int | None = None) -> list[str]:
    plan = [s.strip() for s in (ROOT / name).read_text().splitlines()
            if s.strip() and not s.lstrip().startswith('#')]
    if expected is not None:
        require(len(plan) == expected, f'{name}: expected {expected} modules, got {len(plan)}')
    require(len(set(plan)) == len(plan), f'{name}: duplicate modules')
    # Windows is case-insensitive; receipt keys use dots in place of separators.
    keys = [m.replace('/', '.').casefold() for m in plan]
    require(len(set(keys)) == len(keys), f'{name}: colliding Windows receipt/module keys')
    seen: set[str] = set()
    for module in plan:
        require(bool(re.fullmatch(r'[A-Za-z0-9_]+(?:/[A-Za-z0-9_]+)*', module)),
                f'{name}: unsafe module name {module}')
        path = ROOT / (module + '.lean')
        require(path.is_file(), f'{name}: missing module {module}')
        if not path.is_file():
            continue
        code = lean_code(path.read_text())
        for dependency in re.findall(r'^\s*import\s+([A-Za-z0-9_.]+)', code, re.M):
            dep = dependency.replace('.', '/')
            if (ROOT / (dep + '.lean')).is_file():
                require(dep in seen, f'{name}: {module} imports unlisted/later {dep}')
            else:
                require(dependency == 'Std' or dependency == 'Lean' or
                        dependency == 'Mathlib' or dependency.startswith('Mathlib.'),
                        f'{name}: unexplained external import {dependency}')
        if name == 'build-modules.txt':
            require(not re.search(r'^\s*import\s+Mathlib\b', code, re.M),
                    f'Core module unexpectedly requires Mathlib: {module}')
        seen.add(module)
    require(any(m.endswith('Audit') for m in plan), f'{name}: no Audit module')
    return plan


def theorem_names(code: str) -> list[str]:
    stack: list[tuple[str, str]] = []
    names = []
    for line in code.splitlines():
        s = line.strip()
        match = re.match(r'namespace\s+([\w.]+)', s)
        if match:
            stack.append(('namespace', match[1]))
        elif re.match(r'(?:noncomputable\s+)?section(?:\s|$)', s):
            stack.append(('section', ''))
        elif re.match(r'end(?:\s|$)', s):
            if stack:
                stack.pop()
        else:
            match = re.match(r'(?:@\[[^]]*\]\s*)*(?:(private|protected)\s+)?(?:theorem|lemma)\s+([\w.]+)', s)
            if match and match[1] != 'private':
                ns = '.'.join(n for kind, n in stack if kind == 'namespace')
                names.append(f'{ns}.{match[2]}' if ns else match[2])
    return names


def verify_manifest(name: str, field: str, suffix: str = '') -> int:
    entries = json.loads((ROOT / 'provenance' / name).read_text())
    paths = set()
    for entry in entries:
        rel = entry[field] + suffix
        require(rel not in paths, f'{name}: duplicate {rel}')
        paths.add(rel)
        p = ROOT / rel
        require(p.is_file(), f'{name}: missing {rel}')
        if p.is_file():
            require(digest(p) == entry['sha256'], f'{name}: hash mismatch {rel}')
    return len(entries)


def verify_analytic_publication(full: list[str], core: list[str]) -> None:
    """Check exact recovered bytes and the explicit native-RH audit types.

    These are source-text and hash checks, not Lean elaboration or executed
    axiom reports. The ordinary native build remains the proof gate.
    """
    entries = json.loads((ROOT / 'provenance/recovered-analytic-sources.json')
                         .read_text())['originals']
    checked = []
    for entry in entries:
        for field in ['active_path', 'archive_path']:
            path = ROOT / entry[field]
            require(path.is_file(), f'Recovered analytic source missing: {entry[field]}')
            if path.is_file():
                require(digest(path) == entry['sha256'],
                        f'Recovered analytic hash mismatch: {entry[field]}')
        module = entry['active_path'].removesuffix('.lean')
        require(module in full and module not in core,
                f'Recovered analytic source must be full-only: {module}')
        checked.append(entry['active_path'])
    typed_checks = {
        'ReciprocalAudit': (
            '#check (SoloAdmission.ANALYTIC_ADMISSION_IFF_RH : '
            'SoloAdmission.AnalyticReciprocalAdmission ↔ _root_.RiemannHypothesis)',
        ),
        'AnalyticPublicationAudit': (
            '#check (SoloboloAdmission.slitODEAdmission_iff_RH : '
            'SoloboloAdmission.SlitODEAdmission ↔ _root_.RiemannHypothesis)',
        ),
        'AnalyticEndpointAudit': (
            '#check (SoloboloAdmission.FiniteProgram.nativeRH_of_uniformResidual : '
            '∀ G : SoloboloAdmission.FiniteProgram, '
            'SoloboloAdmission.ActualUniformResidualCondition G → _root_.RiemannHypothesis)',
            '#check (SoloboloAdmission.exists_finiteProgram_uniformResidual_implies_RH : '
            '(∃ G : SoloboloAdmission.FiniteProgram, '
            'SoloboloAdmission.ActualUniformResidualCondition G) → _root_.RiemannHypothesis)',
        ),
    }
    for module, statements in typed_checks.items():
        flat = ' '.join(lean_code((ROOT / (module + '.lean')).read_text()).split())
        for statement in statements:
            require(statement in flat, f'Missing exact native RH audit type: {module}')
    endpoint_code = ' '.join(lean_code((ROOT / 'AnalyticEndpointAudit.lean').read_text()).split())
    expanded = (
        '(Iff.rfl : SoloboloAdmission.ActualUniformResidualCondition G ↔ '
        'TendstoLocallyUniformlyOn (fun (n : ℕ) (z : ℂ) => '
        'deriv AWPIRH.theta z + SoloboloAdmission.rationalODECoefficient '
        '(G.emit n) z * AWPIRH.theta z) (fun _ : ℂ => 0) '
        'Filter.atTop Complex.slitPlane)'
    )
    require(expanded in endpoint_code, 'Missing definitional expansion of the single actual condition')
    original_audit_count = sum(len(re.findall(r'#print\s+axioms\s+',
        lean_code((ROOT / (m + '.lean')).read_text())))
        for m in ['ReciprocalAudit', 'AnalyticPublicationAudit'])
    require(original_audit_count == 61, 'Recovered analytic audit command count changed')
    CHECKS['analytic_publication'] = {
        'original_active_and_archive_hashes_verified': checked,
        'exact_native_RH_typed_checks': sum(map(len, typed_checks.values())),
        'single_actual_condition_definitional_check': expanded in endpoint_code,
        'preserved_analytic_axiom_print_commands': original_audit_count,
        'native_compilation': 'NOT_RUN', 'native_axiom_audit': 'NOT_RUN',
        'finite_witness_iff_rh': 'OPEN',
    }


def plus(a: list[int], b: list[int]) -> list[int]:
    return [(a[i] if i < len(a) else 0) + (b[i] if i < len(b) else 0)
            for i in range(max(len(a), len(b)))]


def convolution(a: list[int], b: list[int]) -> list[int]:
    # Independent dense convolution, retaining the source representation length.
    if not a:
        return []
    values = [0] * (len(a) + max(1, len(b)) - 1)
    for i, x in enumerate(a):
        for j, y in enumerate(b):
            values[i + j] += x * y
    return values


def squares(factors: list[list[int]]) -> list[int]:
    result: list[int] = []
    for factor in factors:
        result = plus(result, convolution(factor, factor))
    return result


def regression() -> dict[str, object]:
    source = lean_code((ROOT / 'RHFinal/Core/LocalWitness.lean').read_text())
    expected_fields = {
        'base': '[1, 2, 1]', 'multiplier': '[1]', 'next': '[1, 2, 2]',
    }
    compact = re.sub(r'\s+', '', source)
    for field, value in expected_fields.items():
        require(f'{field}:={value.replace(" ", "")}' in compact,
                f'Diagnostic fixture changed: {field}; update independent regression')
    require('baseFactors:=[[1,1]],remainderFactors:=[[0,1]]' in compact,
            'Accepted diagnostic fixture changed')
    require('baseFactors:=[[1,1]],remainderFactors:=[]' in compact,
            'Rejected diagnostic fixture changed')
    raw = re.search(r'structure\s+FiniteWitness\s+where(.*?)deriving', source, re.S)
    require(raw is not None, 'Cannot locate raw witness declaration')
    if raw:
        require(re.sub(r'\s+', '', raw[1]) ==
                'baseFactors:ListPolyremainderFactors:ListPoly',
                'Raw witness format changed; review data-only admission boundary')
    search = re.sub(r'\s+', '', lean_code((ROOT / 'RHFinal/Core/BoundedSearch.lean').read_text()))
    require('(List.range(2*bound+1)).map(funn=>Int.ofNatn-Int.ofNatbound)' in search,
            'Coefficient range changed; update independent search regression')
    base, multiplier, following = [1, 2, 1], [1], [1, 2, 2]

    def check(bs: list[list[int]], rs: list[list[int]], nxt=following) -> bool:
        return base == squares(bs) and nxt == plus(
            convolution(convolution(multiplier, multiplier), base), squares(rs))

    require(check([[1, 1]], [[0, 1]]), 'Accepted diagnostic failed integer arithmetic')
    mutations = [([[1, 1]], []), ([[1, 0]], [[0, 1]]),
                 ([[1, 1]], [[1, 1]]), ([[1, 1]], [[0, 2]])]
    require(all(not check(b, r) for b, r in mutations), 'Corrupt diagnostic accepted')
    factors = [list(p) for p in itertools.product(range(-1, 2), repeat=2)]
    candidates = [(b, r) for b in factors for r in factors]
    accepted = [(b, r) for b, r in candidates if check([b], [r])]
    require(len(candidates) == 81, 'Bound-one candidate count differs from 81')
    require(len(accepted) == 4, 'Expected four sign-equivalent accepted diagnostics')
    require(accepted[0] == ([-1, -1], [0, -1]), 'Unexpected first diagnostic candidate')
    return {'kind': 'INDEPENDENT_PYTHON_EXACT_INTEGER_CHECK_NOT_LEAN',
            'candidate_count': len(candidates), 'accepted_count': len(accepted),
            'first_accepted': accepted[0], 'corrupt_packets_rejected': len(mutations),
            'actual_xi_or_rh_witness_tested': False}


def main() -> int:
    core = read_plan('build-modules.txt', 6)
    full = read_plan('build-modules-full.txt')
    require(full[:len(core)] == core, 'Full plan does not preserve the core prefix')
    source_inventory = {
        p.relative_to(ROOT).with_suffix('').as_posix()
        for p in ROOT.rglob('*.lean')
        if p.relative_to(ROOT).parts[0] not in {'research', 'scripts', '.git', '.rh-cache'}
    }
    require(set(full) == source_inventory,
            'Full plan differs from active Lean source inventory: ' +
            str(sorted(set(full) ^ source_inventory)))
    CHECKS['plan_module_counts'] = {'core': len(core), 'full': len(full)}
    reports, new_theorems = set(), []
    for module in full:
        code = lean_code((ROOT / (module + '.lean')).read_text())
        for forbidden in [r'\bsorry\b', r'\badmit\b', r'\baxiom\s', r'\bunsafe\b', r'\bnative_decide\b',
                          r'\bLean\.(?:ofReduceBool|trustCompiler)\b']:
            require(not re.search(forbidden, code), f'{module}: forbidden proof token {forbidden}')
        printed = re.findall(r'#print\s+axioms\s+([\w.]+)', code)
        if module.endswith('Audit'):
            require(bool(printed), f'{module}: no explicit axiom audit declarations')
            reports.update(printed)
        if module.startswith(AUDITED_SOURCE_PREFIXES):
            new_theorems.extend(theorem_names(code))
    require(len(new_theorems) == len(set(new_theorems)), 'Duplicate new theorem declarations')
    missing = sorted(set(new_theorems) - reports)
    require(not missing, f'New public theorems missing axiom audit: {missing}')
    CHECKS['new_theorems_audit_coverage'] = {'declarations': sorted(new_theorems),
                                           'count': len(new_theorems), 'missing': missing,
                                           'source_prefixes': list(AUDITED_SOURCE_PREFIXES),
                                           'native_execution': 'NOT_RUN'}
    CHECKS['active_source_sha256'] = {m + '.lean': digest(ROOT / (m + '.lean')) for m in full}
    CHECKS['reviewed_tooling_sha256'] = {
        name: digest(ROOT / name) for name in
        ['run.cmd', 'scripts/cache/Build.lean', 'docs/BUILD.md', 'scripts/static_audit.py']}
    CHECKS['upstream_hashes_verified'] = verify_manifest('upstream-files.json', 'path')
    CHECKS['active_import_hashes_verified'] = verify_manifest('active-imports.json', 'module', '.lean')
    verify_analytic_publication(full, core)
    inputs = json.loads((ROOT / 'provenance/input-files.json').read_text())
    checked_inputs, unavailable_inputs = 0, []
    for entry in inputs:
        require(bool(re.fullmatch(r'[0-9a-f]{64}', entry['sha256'])), 'Malformed input digest')
        matches = [ROOT.parent / folder / entry['file'] for folder in
                   ['project_sources', 'solobolo_sources', 'gp_sources/Riemann-Hypothesis-Final',
                    'equivalence_sources/Riemann-Hypothesis-Final']]
        present = next((p for p in matches if p.is_file()), None)
        if present:
            require(digest(present) == entry['sha256'], f'Input hash mismatch: {entry["file"]}')
            checked_inputs += 1
        else:
            unavailable_inputs.append(entry['file'])
    CHECKS['original_input_hashes'] = {'verified': checked_inputs, 'not_available_in_checkout': unavailable_inputs}
    require((ROOT / 'lean-toolchain').read_text().strip() == 'leanprover/lean4:v4.33.0', 'Wrong Lean toolchain')
    public_files = [p for p in ROOT.rglob('*') if p.is_file() and '.git' not in p.relative_to(ROOT).parts
                    and '.rh-cache' not in p.relative_to(ROOT).parts]
    cmds = [str(p.relative_to(ROOT)) for p in public_files if p.suffix.lower() == '.cmd']
    require(cmds == ['run.cmd'], f'Expected exactly one canonical CMD runner: {cmds}')
    binary_suffixes = ('.olean', '.olean.private', '.olean.server', '.ilean', '.o', '.exe', '.dll', '.so', '.zip')
    binaries = [str(p.relative_to(ROOT)) for p in public_files if p.name.endswith(binary_suffixes)]
    require(not binaries, f'Unexpected binary artifacts: {binaries}')
    ignore = (ROOT / '.gitignore').read_text()
    for required in ['.rh-cache/', '*.olean', 'logs/', 'receipts/local/']:
        require(required in ignore.splitlines(), f'Missing gitignore entry: {required}')
    CHECKS['independent_arithmetic_regression'] = regression()
    report = {'audit_kind': 'STATIC_ONLY_NOT_LEAN', 'status': 'FAIL' if ERRORS else 'PASS',
              'lean_compilation': 'NOT_RUN', 'native_axiom_audit': 'NOT_RUN',
              'rh_proved': False, 'checks': CHECKS, 'errors': ERRORS}
    (ROOT / 'provenance/static-audit.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps({'audit_kind': report['audit_kind'], 'status': report['status'],
                      'errors': ERRORS, 'new_theorem_count': len(new_theorems),
                      'candidate_count': 81}, indent=2))
    return bool(ERRORS)


if __name__ == '__main__':
    sys.exit(main())
