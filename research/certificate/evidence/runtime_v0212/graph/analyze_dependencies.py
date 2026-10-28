#!/usr/bin/env python3
"""Source-only DAG analysis; never invokes Lean, Lake, or native Windows tools."""
from __future__ import annotations

import argparse
import hashlib
import json
import re
from pathlib import Path


def sha(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def clean_source(text: str) -> str:
    """Remove nested Lean comments and strings, preserving line boundaries."""
    out, i, depth, string = [], 0, 0, False
    while i < len(text):
        pair, char = text[i : i + 2], text[i]
        if depth:
            if pair == "/-":
                depth += 1
                out.append("  ")
                i += 2
            elif pair == "-/":
                depth -= 1
                out.append("  ")
                i += 2
            else:
                out.append("\n" if char == "\n" else " ")
                i += 1
        elif string:
            if char == "\\" and i + 1 < len(text):
                out.append("  ")
                i += 2
            else:
                if char == '"':
                    string = False
                out.append("\n" if char == "\n" else " ")
                i += 1
        elif pair == "/-":
            depth = 1
            out.append("  ")
            i += 2
        elif pair == "--":
            end = text.find("\n", i)
            if end < 0:
                end = len(text)
            out.append(" " * (end - i))
            i = end
        elif char == '"':
            string = True
            out.append(" ")
            i += 1
        else:
            out.append(char)
            i += 1
    assert depth == 0 and not string, "Unterminated source comment/string"
    return "".join(out)


def imports_of(text: str) -> list[str]:
    imports = []
    for line in clean_source(text).splitlines():
        line = line.strip()
        if not line or line in ("prelude", "module"):
            continue
        match = re.fullmatch(r"(?:(?:public|private|meta)\s+)*import\s+(.+)", line)
        if not match:
            break
        for name in match[1].split():
            assert re.fullmatch(r"[A-Za-z_][A-Za-z0-9_'.]*", name), name
            if name not in imports:
                imports.append(name)
    return imports


def graph_stats(nodes: list[str], dependencies: dict[str, list[str]]) -> dict:
    pos = {name: i for i, name in enumerate(nodes)}
    chosen = set(nodes)
    deps = {name: [d for d in dependencies[name] if d in chosen] for name in nodes}
    children = {name: [] for name in nodes}
    rank, path, path_count = {}, {}, {}
    for name in nodes:
        assert all(pos[d] < pos[name] for d in deps[name]), name
        for dep in deps[name]:
            children[dep].append(name)
        longest = max((rank[d] for d in deps[name]), default=0)
        parent = next((d for d in deps[name] if rank[d] == longest), None)
        rank[name] = longest + 1
        path[name] = (path[parent] if parent else []) + [name]
        path_count[name] = sum(path_count[d] for d in deps[name] if rank[d] == longest) if parent else 1

    descendants = {name: set() for name in nodes}
    remaining = {}
    for name in reversed(nodes):
        remaining[name] = 1 + max((remaining[c] for c in children[name]), default=0)
        for dep in deps[name]:
            descendants[dep].add(name)
            descendants[dep].update(descendants[name])

    # Dilworth certificate: maximum matching in the reachability bipartite graph.
    match_r = {}

    def augment(left: str, seen: set[str]) -> bool:
        for right in sorted(descendants[left], key=pos.get):
            if right in seen:
                continue
            seen.add(right)
            if right not in match_r or augment(match_r[right], seen):
                match_r[right] = left
                return True
        return False

    for left in nodes:
        augment(left, set())
    match_l = {left: right for right, left in match_r.items()}
    z_left, z_right = set(nodes) - set(match_l), set()
    pending = list(z_left)
    while pending:
        left = pending.pop()
        for right in descendants[left]:
            if match_l.get(left) == right or right in z_right:
                continue
            z_right.add(right)
            if right in match_r and match_r[right] not in z_left:
                z_left.add(match_r[right])
                pending.append(match_r[right])
    antichain = [n for n in nodes if n in z_left and n not in z_right]
    chains = []
    for start in nodes:
        if start in match_r:
            continue
        chain, current = [start], start
        while current in match_l:
            current = match_l[current]
            chain.append(current)
        chains.append(chain)
    assert len(antichain) == len(chains) == len(nodes) - len(match_r)
    assert set(n for chain in chains for n in chain) == chosen
    assert sum(map(len, chains)) == len(nodes)
    assert all(b not in descendants[a] for a in antichain for b in antichain)

    levels = [[n for n in nodes if rank[n] == level] for level in range(1, max(rank.values()) + 1)]
    schedules = []
    for workers in (1, 2, 3, 4, 8, 16):
        done, slots = set(), []
        while len(done) < len(nodes):
            ready = sorted(
                (n for n in nodes if n not in done and set(deps[n]) <= done),
                key=lambda n: (-remaining[n], pos[n]),
            )
            batch = ready[:workers]
            assert batch
            slots.append(batch)
            done.update(batch)
        schedules.append({"workers": workers, "unit_slots": len(slots), "slots": slots})

    longest_end = max(nodes, key=lambda n: rank[n])
    return {
        "nodes": len(nodes),
        "direct_local_edges": sum(map(len, deps.values())),
        "critical_path_module_units": rank[longest_end],
        "one_critical_path": path[longest_end],
        "longest_path_count_to_selected_endpoint": path_count[nodes[-1]],
        "maximum_asap_layer": max(map(len, levels)),
        "asap_layers": levels,
        "exact_antichain_width": len(antichain),
        "width_certificate": {"antichain": antichain, "chain_cover": chains},
        "priority_rule": "Descending remaining critical-path length, then original compile-order position.",
        "unit_cost_schedules": schedules,
        "per_module": {
            n: {
                "local_dependencies": deps[n],
                "direct_local_dependents": children[n],
                "earliest_unit_slot": rank[n],
                "remaining_critical_path_units": remaining[n],
                "local_ancestor_count": sum(n in descendants[a] for a in nodes),
                "invalidation_cone": [a for a in nodes if a == n or a in descendants[n]],
            }
            for n in nodes
        },
    }


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("package", type=Path)
    parser.add_argument("--out", type=Path, default=Path(__file__).resolve().parent)
    args = parser.parse_args()
    package, out = args.package.resolve(), args.out.resolve()
    listed = [line.strip() for line in (package / "compile-order.txt").read_text().splitlines()
              if line.strip() and not line.lstrip().startswith("#")]
    final = (package / "final-audit.txt").read_text().strip()
    relative = listed + [final]
    names = [name[:-5].replace("/", ".") for name in relative]
    assert len(names) == len(set(names))
    selected = set(names)
    source_bytes = {name: (package / rel).read_bytes() for name, rel in zip(names, relative)}
    imports = {name: imports_of(data.decode("utf-8-sig")) for name, data in source_bytes.items()}
    deps = {name: [d for d in imports[name] if d in selected] for name in names}
    all_local_sources = {str(path.relative_to(package)).replace("\\", "/")[:-5].replace("/", ".")
                         for path in package.rglob("*.lean")}
    missing = sorted({d for ds in imports.values() for d in ds if d in all_local_sources and d not in selected})
    assert not missing, missing
    cold = graph_stats(names, deps)
    reached, todo = set(), [names[-1]]
    while todo:
        current = todo.pop()
        if current in reached:
            continue
        reached.add(current)
        todo.extend(deps[current])
    assert reached == selected

    new = ["RH_HilbertLimit." + name for name in (
        "CanonicalPowerSums", "SpectralPhase", "SpectralGenerating", "SpectralExtraction", "AnalyticClosure"
    )] + [names[-1]]
    assert names[-6:] == new
    warm = graph_stats(new, deps)
    for name in new:
        warm["per_module"][name]["verified_cached_prerequisites"] = [d for d in deps[name] if d not in new]

    # Keep the report compact: full schedules for four workers and warm two/three;
    # counts for other worker budgets. All selected module identities remain bound.
    for scenario, keep in ((cold, {4}), (warm, {2, 3})):
        for schedule in scenario["unit_cost_schedules"]:
            if schedule["workers"] not in keep:
                del schedule["slots"]
    per_module = cold.pop("per_module")
    for name in per_module:
        if name not in new:
            per_module[name].pop("invalidation_cone")
    metadata_files = ["tools/native_runner.js", "run.cmd", "compile-order.txt", "final-audit.txt", "audit-targets.tsv", "mathlib-imports.txt"]
    binding = {rel: sha((package / rel).read_bytes()) for rel in metadata_files}
    all_lean_hashes = {str(path.relative_to(package)).replace("\\", "/"): sha(path.read_bytes())
                      for path in sorted(package.rglob("*.lean"))}
    report = {
        "schema": "RH_HILBERT_SOURCE_DAG_PLAN_V1",
        "scope": "Read-only source/header graph analysis; no Lean, Lake, native Windows, C#, CI, or runtime benchmarks.",
        "package": package.name,
        "inputs_sha256": binding,
        "all_lean_file_count": len(all_lean_hashes),
        "all_lean_manifest_sha256": sha("".join(f"{k}\t{v}\n" for k, v in sorted(all_lean_hashes.items())).encode()),
        "selected_source_sha256": {rel: sha(source_bytes[name]) for name, rel in zip(names, relative)},
        "ordinary_module_count": len(listed),
        "selected_final_audit": names[-1],
        "direct_external_imports_excluding_implicit_Init": sorted({d for ds in imports.values() for d in ds if d not in selected}),
        "validation": {"selected_local_closure_complete": True, "compile_order_topological": True,
                       "all_scheduled_modules_reachable_from_final_audit": True,
                       "all_input_source_files_unchanged_at_end": True},
        "model": {
            "unit": "One module transaction (compile/restore plus required audit and acceptance). All units are assumed equal only for this model.",
            "external_prerequisites": "Compatible externally compiled dependency artifacts are present and freshly verified before local work.",
            "cache_hit_cost": "Set to zero only in the warm-six-node structural model; actual hashing/restoration takes time.",
            "module_release_barrier": "Successful exact artifact identity and standard-axiom audit accepted by the parent coordinator.",
            "timing_claims": False,
        },
        "cold_local_graph": cold,
        "warm_84_old_ordinary_modules_verified": warm,
        "per_module": per_module,
        "native_process_counts_from_existing_control_flow": {
            "cold_compile_and_per_module_audit_calls": 179,
            "warm_six_new_nodes_compile_and_audit_calls": 11,
            "all_90_verified_reuse_compile_and_audit_calls": 0,
            "exclusions": "Compiler/version queries, hashing, cache migration, and any audit-only refreshes; counts are conditional source deductions, not observed runs.",
        },
        "recommendation": {
            "total_lean_thread_budget": 16,
            "default_max_lean_workers_with_sufficient_memory": 4,
            "full_four_worker_threads_each": 4,
            "two_worker_threads_each": 8,
            "three_worker_allocation_example": [6, 5, 5],
            "single_worker_threads": 16,
            "thread_rule": "Sum of launch-time thread reservations across all live compile/audit processes must not exceed the configured budget; no retrospective increase to a running process.",
            "ram_policy": {
                "status": "Suggested conservative starting policy; no process-RAM observations are available.",
                "reserve_mib": "max(4096, ceil(0.20 * total_physical_MiB))",
                "initial_worker_reservation_mib": 4096,
                "planned_read_only_mapping_sidecar_reservation": "Also reserve the sidecar's announced maximum charged-page cap, conservatively even if clean file-backed pages overlap Lean mappings; the sidecar is not a residency guarantee or shared Lean environment.",
                "admission": "Cap workers by min(4, ready work, CPU token budget, free-RAM reservations). Recheck RAM before each launch and reserve for active processes not yet at their estimated peak.",
                "unknown_ram_fallback": "One Lean process; report that memory-based admission was unavailable.",
                "low_ram_fallback": "Use one process when the reserve permits one; if even one cannot be admitted, wait/recheck and give an actionable resource message instead of spawning more workers.",
                "measurement_limit": "4 GiB is an adjustable admission estimate, not a memory cap or guarantee. Native evidence is needed before tuning it downward.",
            },
            "cache_identity": "Preserve SCHEMA, COMPILE_POLICY, AUDIT_POLICY, COMPILE_FLAGS, source hashes, local/external dependency fingerprints, and exact audit targets. Worker count, thread budget, and RAM observations are runtime provenance only.",
        },
        "integration_requirements": [
            "Use one coordinator and the existing workspace lock. Only compiler/audit child processes run concurrently; coordinator serializes cache verification, state acceptance, and immutable receipt commits.",
            "Build ready queues from the actual verified local import graph, preserving compile-order position only as a deterministic tie-breaker.",
            "Try validated anchor reuse for each ready module before occupying a Lean worker. A ready cache hit can immediately unblock its dependents.",
            "Do not publish moduleKeys/artifactHashes at compile exit. Audit-only restores and fresh compiles release dependents only after the existing acceptance/save path succeeds.",
            "Count compile and audit child processes in the same CPU/RAM pool. Keep generated audit source, output family, and log paths unique per module.",
            "Failure blocks only the transitive dependents; independent ready modules remain eligible. Global hash/transport failures remain fatal.",
            "Drain or safely account for every owned live child before releasing the workspace lock or reporting final completion. Preserve per-module failure stage and logs.",
            "Keep the selected aggregate as a final barrier after all ordinary modules are accepted, preserving the exact 370-target audit and mathematical status reporting.",
            "Fresh operation-scoped content verification remains mandatory; parallelism does not authorize persistent digest reuse or trusting unverified working artifacts.",
            "Avoid unbudgeted overlap of a 16-thread hashing helper with a full 16-thread Lean pool; account for that work or perform the coordinator's hash phases at controlled boundaries.",
        ],
        "implementation_blockers_in_current_runner": [
            "runToFile uses synchronous shell.Run(..., true); the existing processModuleBody cannot run asynchronously as written.",
            "processModuleBody combines cache restore, compile, audit, and receipt commit in one synchronous call; a scheduler needs explicit per-module phase records.",
            "The main loop processes ordered modules serially, and stage is one mutable global; parallel status must retain each task's stage without weakening final error reporting.",
            "No current RAM admission probe/reservation or compiler worker pool exists. Thread count is currently a per-process jobs value.",
        ],
        "not_established": ["Native compilation or axiom audit", "Measured speedup", "Per-module peak RAM", "RH", "Finite checker equivalence"],
    }
    for name, rel in zip(names, relative):
        assert (package / rel).read_bytes() == source_bytes[name]
    for rel, digest in binding.items():
        assert sha((package / rel).read_bytes()) == digest
    out.mkdir(parents=True, exist_ok=True)
    (out / "dependency_plan.json").write_text(json.dumps(report, indent=2) + "\n")
    print(json.dumps({
        "runner_sha256": binding["tools/native_runner.js"],
        "ordinary_modules": len(listed), "selected_modules": len(names),
        "local_edges": cold["direct_local_edges"],
        "cold_critical_path": cold["critical_path_module_units"],
        "cold_asap_width": cold["maximum_asap_layer"],
        "cold_poset_width": cold["exact_antichain_width"],
        "warm_critical_path": warm["critical_path_module_units"],
        "warm_poset_width": warm["exact_antichain_width"],
        "report_sha256": sha((out / "dependency_plan.json").read_bytes()),
    }, indent=2))


if __name__ == "__main__":
    main()
