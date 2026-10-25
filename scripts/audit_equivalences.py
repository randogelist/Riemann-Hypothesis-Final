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

# Literature provenance is independent of native verification. The two views
# must partition the original 51 formulations without losing or duplicating IDs.
literature = json.loads((FOLDER / 'literature-classification.json').read_text())
categories = {x['name']: x for x in literature['categories']}
require(set(categories) == {'Identified by Literature', 'Potentially novel'},
        'Expected the two requested literature categories')
require(literature['catalogue_sha256'] == hashlib.sha256(
    (FOLDER / 'catalog.json').read_bytes()).hexdigest(), 'Classification catalogue hash is stale')
require(literature['novelty_established'] is False, 'Literature review must not certify novelty')
classified = literature['entries']
original_ids = {x['id'] for x in native + models}
require(len(classified) == len(original_ids), 'Wrong number of classified entries')
require({x['id'] for x in classified} == original_ids, 'Classification omits or adds catalogue IDs')
references = {x['id']: x for x in literature['references']}
require(len(references) == len(literature['references']), 'Duplicate literature reference IDs')
bibliography = (FOLDER / 'LITERATURE.md').read_text()
catalogue_markdown = (FOLDER / 'CATALOG.md').read_text()
for ref in references.values():
    require(ref['url'].startswith('https://'), f"{ref['id']}: expected primary-source URL")
    require(bool(ref['citation'].strip()) and bool(ref['scope'].strip()),
            f"{ref['id']}: missing bibliography or scope")
    require(f'<a id="{ref["id"].lower()}"></a>' in bibliography,
            f"{ref['id']}: bibliography anchor missing")
for entry in classified:
    require(entry['category'] in categories, f"{entry['id']}: unknown literature category")
    require(bool(entry['basis'].strip()) and bool(entry['relationship'].strip()),
            f"{entry['id']}: missing classification rationale")
    require(set(entry['reference_ids']) <= references.keys(),
            f"{entry['id']}: unknown literature reference")
    if entry['category'] == 'Identified by Literature':
        require(bool(entry['reference_ids']), f"{entry['id']}: literature label lacks reference")
    require(entry['novelty_established'] is False, f"{entry['id']}: unsupported priority claim")
    require(f'<a id="{entry["id"].lower()}"></a>' in catalogue_markdown,
            f"{entry['id']}: catalogue anchor missing")
literature_counts = {}
for name, category in categories.items():
    selected = [x for x in classified if x['category'] == name]
    view = FOLDER / category['path']
    require(view.is_file(), f'Missing category view: {view}')
    if view.is_file():
        visible_ids = re.findall(r'^\| \[(E\d{2}|M\d{2})\]', view.read_text(), re.M)
        require(visible_ids == [x['id'] for x in selected],
                f'{name}: view and classification IDs differ')
    counts = {'native_target': sum(x['id'].startswith('E') for x in selected),
              'opaque_model': sum(x['id'].startswith('M') for x in selected),
              'total': len(selected)}
    require(category['counts'] == counts, f'{name}: stale formulation counts')
    literature_counts[name] = counts
supplementary = literature['supplementary_entries']
require([x['id'] for x in supplementary] == [f'L{i:02}' for i in range(1, 13)],
        'Expected twelve selected local criteria, separately counted')
for entry in supplementary:
    require(entry['category'] in categories, f"{entry['id']}: unknown supplementary category")
    require(entry['local_criteria_item'] == int(entry['id'][1:]),
            f"{entry['id']}: mismatched LOCAL_CRITERIA item")
    require(set(entry['reference_ids']) <= references.keys(),
            f"{entry['id']}: unknown supplementary reference")

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
    'literature_classification_entries_checked': len(classified),
    'literature_category_counts': literature_counts,
    'supplementary_literature_items_checked': len(supplementary),
    'literature_review_certifies_novelty': False,
    'native_lean_compilation': 'NOT_RUN',
    'native_axiom_audit': 'NOT_RUN',
    'rh_proved': False,
    'errors': errors,
}
(FOLDER / 'validation.json').write_text(json.dumps(report, indent=2) + '\n')
print(json.dumps(report, indent=2))
sys.exit(bool(errors))
