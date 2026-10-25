#!/usr/bin/env python3
"""Validate the RH catalogue's source identity and links; does not execute Lean."""
from pathlib import Path
import hashlib
import json
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
FOLDER = ROOT / 'RH-Equivalences'
errors = []


def require(ok, message):
    if not ok:
        errors.append(message)


def checked_file(rel, expected_hash):
    path = ROOT / rel
    require(path.is_file(), f'Missing source: {rel}')
    if not path.is_file():
        return ''
    data = path.read_bytes()
    require(hashlib.sha256(data).hexdigest() == expected_hash, f'Hash mismatch: {rel}')
    return data.decode('utf-8')


catalog = json.loads((FOLDER / 'catalog.json').read_text())
mapping = json.loads((FOLDER / 'source-map.json').read_text())
sources = {x['original_path']: x for x in mapping['sources']}
require(len(sources) == len(mapping['sources']), 'Duplicate original source paths')
texts = {p: checked_file(x['path'], x['sha256']) for p, x in sources.items()}
for notice in mapping['license_notices']:
    checked_file(notice['path'], notice['sha256'])
original = catalog['original_catalogue']
checked_file(original['path'], original['sha256'])

native = catalog['native_target_entries']
models = catalog['opaque_model_entries']
require([x['id'] for x in native] == [f'E{i:02}' for i in range(1, 42)], 'Native ID set changed')
require([x['id'] for x in models] == [f'M{i:02}' for i in range(1, 11)], 'Model ID set changed')
require(len(catalog['native_criterion_groups']) == 22, 'Expected 22 native criterion groups')
require(catalog['rh_proved'] is False, 'Catalogue must not certify RH')
definitions = {x['id']: x for x in catalog['definition_evidence']}
require(len(definitions) == 115, 'Expected 115 definition records')

for entry in native + models:
    ref = entry['reported_source']
    path = ref['bundle_relative_path']
    require(path in sources, f"{entry['id']}: source not recovered")
    if path not in sources:
        continue
    source = sources[path]
    require(source['sha256'] == ref['sha256'], f"{entry['id']}: historical hash differs")
    leaf = entry['lean_declaration'].split('.')[-1]
    require(bool(re.search(r'\b(?:theorem|lemma)\s+' + re.escape(leaf) + r'(?:\s|:)', texts[path])),
            f"{entry['id']}: theorem name absent from recovered source")
    require(1 <= ref['line'] <= len(texts[path].splitlines()), f"{entry['id']}: bad source line")
    require('↔' in entry['lean_signature_exact'], f"{entry['id']}: missing iff signature")
    require(bool(entry['additional_hypotheses_exact'].strip()), f"{entry['id']}: missing hypothesis record")
    require(entry['native_compilation'] == 'NOT_RUN', f"{entry['id']}: unsupported new build status")
    for name in entry['definition_evidence_ids']:
        require(name in definitions, f"{entry['id']}: unknown definition {name}")

for item in definitions.values():
    path = item['reported_source_path']
    require(path in sources, f"{item['id']}: definition source absent")
    if path in sources:
        require(1 <= item['reported_source_line'] <= len(texts[path].splitlines()),
                f"{item['id']}: bad definition line")

local = json.loads((FOLDER / 'local-criteria.json').read_text())
local_entries = local['entries'] + local['rh_linked_auxiliary_entries']
require(len(local['entries']) == 115, 'Expected 115 local declaration records')
require(len(local['rh_linked_auxiliary_entries']) == 27, 'Expected 27 local auxiliaries')
for entry in local_entries:
    checked_file(entry['source_path'], entry['source_sha256'])
    require(entry['native_verification'] == 'NOT_RUN',
            f"{entry['id']}: unsupported new native verification")
master = json.loads((FOLDER / 'master-chain-evidence.json').read_text())
for entry in master['records']:
    root = entry['archive_repository_root']
    if entry.get('source_relative_path'):
        checked_file(root + '/' + entry['source_relative_path'], entry['source_sha256'])
    else:
        checked_file(root + '/' + entry['receipt_relative_path'], entry['receipt_sha256'])
    require(entry['native_mathlib_rh_iff'] is False,
            f"{entry['id']}: master auxiliary incorrectly promoted to native RH")

# Check relative Markdown file links in this collection. Fragment targets are
# navigational labels; source identity is validated independently above.
for doc in FOLDER.rglob('*.md'):
    for target in re.findall(r'\]\(([^)]+)\)', doc.read_text()):
        target = target.split('#', 1)[0]
        if not target or '://' in target or target.startswith('mailto:'):
            continue
        if (doc.parent / target).resolve() == (FOLDER / 'validation.json').resolve():
            continue  # The report is generated at the end of this command.
        require((doc.parent / target).is_file(), f'{doc.name}: broken link {target}')

report = {
    'kind': 'STATIC_SOURCE_IDENTITY_ONLY_NOT_LEAN',
    'status': 'FAIL' if errors else 'PASS',
    'native_target_formulations': len(native),
    'opaque_model_formulations': len(models),
    'native_criterion_groups': len(catalog['native_criterion_groups']),
    'primary_source_hashes_matched': len(native) + len(models) if not errors else None,
    'definition_records': len(definitions),
    'recovered_source_bodies': len(sources),
    'preserved_license_notices': len(mapping['license_notices']),
    'local_declaration_source_records_checked': len(local_entries),
    'master_chain_auxiliary_records_checked': len(master['records']),
    'native_lean_compilation': 'NOT_RUN',
    'native_axiom_audit': 'NOT_RUN',
    'rh_proved': False,
    'errors': errors,
}
(FOLDER / 'validation.json').write_text(json.dumps(report, indent=2) + '\n')
print(json.dumps(report, indent=2))
sys.exit(bool(errors))
