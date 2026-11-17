"""MYTHRAGON build identity and fail-closed artifact contracts (standard library)."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
UNIVERSE = "10777026486"
PLACE = "135004978091658"
EXPECTED = {"latunia": True, "island_slots": 5, "detailed_islands": 3,
            "travel_prompts": 10, "latunia_gate": True,
            "provisional_islands": ["Gelo", "Selva"]}


def digest(data):
    return hashlib.sha256(data).hexdigest()


def sources(root=ROOT):
    return {p.relative_to(root / "src/server").as_posix(): p.read_text(encoding="utf-8")
            for p in sorted((root / "src/server").rglob("*.luau"))}


def normalized(text):
    return text.replace("\r\n", "\n")


def artifact_sources(path):
    """Read exact Rojo script hierarchy; reject duplicate paths."""
    tree = ET.parse(path)
    found = {}

    def walk(item, parents):
        props = item.find("Properties")
        name = props.find("string[@name='Name']").text if props is not None else None
        at = parents + [name or item.attrib["class"]]
        if item.attrib["class"] in ("Script", "LocalScript", "ModuleScript"):
            key = "/".join(at)
            if key in found:
                raise ValueError("Duplicate script: " + key)
            source = props.find("*[@name='Source']")
            if source is None:
                raise ValueError("Missing source: " + key)
            found[key] = normalized(source.text or "")
        for child in item.findall("Item"):
            walk(child, at)

    for item in tree.getroot().findall("Item"):
        walk(item, [])
    return found


def instance_path(path):
    suffix = ".server.luau" if path.endswith(".server.luau") else ".luau"
    return "ServerScriptService/Mythragon/" + path[:-len(suffix)]


def verify_sources(artifact, expected):
    actual = artifact_sources(artifact)
    wanted = {instance_path(p): normalized(s) for p, s in expected.items()}
    if actual != wanted:
        missing = sorted(set(wanted) - set(actual))
        extra = sorted(set(actual) - set(wanted))
        changed = sorted(p for p in wanted.keys() & actual.keys() if wanted[p] != actual[p])
        raise ValueError(f"Artifact source mismatch: missing={missing}, extra={extra}, changed={changed}")
    return actual


def identity(sha, run):
    if not re.fullmatch(r"[0-9a-f]{40}", sha) or not re.fullmatch(r"[1-9][0-9]*|local", run):
        raise ValueError("Invalid build SHA/run")
    return f'return table.freeze({{ gitSha = "{sha}", buildRunId = "{run}", experimental = true }})\n'


def prepare(sha, run):
    dest = ROOT / "src/server/Diagnostics/BuildInfo.luau"
    dest.parent.mkdir(parents=True, exist_ok=True)
    dest.write_text(identity(sha, run), encoding="utf-8", newline="\n")


def manifest(sha, run):
    artifact = ROOT / "dist/mythragon.rbxlx"
    included = verify_sources(artifact, sources())
    info = included["ServerScriptService/Mythragon/Diagnostics/BuildInfo"]
    if info != identity(sha, run):
        raise ValueError("Embedded build identity does not match")
    return {"schema": 1, "project": "MYTHRAGON", "release_id": "REC-001-" + sha[:12],
            "git_sha": sha, "build_run_id": run, "artifact": "mythragon.rbxlx",
            "sha256": digest(artifact.read_bytes()), "universe_id": UNIVERSE, "place_id": PLACE,
            "expected_content": EXPECTED, "modules_expected": sorted(included),
            "source_sha256": {p: digest(s.encode()) for p, s in included.items()},
            "assets_expected": sorted(set(re.findall(r"rbxassetid://(\d+)", "\n".join(included.values())))),
            "tests": json.loads((ROOT / "dist/tests.json").read_text()),
            "state": "PREVIEW_OK", "revision": None, "operation": None,
            "verification": {"persisted": "PENDING", "engine_bootstrap": "PENDING",
                             "runtime_new_server": "PENDING", "client": "PENDING", "visual": "PENDING"},
            "pending": ["Fresh normal server runtime", "Physics/client/mobile/multiplayer playtest",
                        "Owner visual evaluation", "Gelo/Selva detailed content",
                        "Engine inspection specs are shipped as inert ModuleScripts, not automatic tests",
                        "Studio engine specs and isolated cloud probe share contracts; no player simulation"]}


def verify_manifest(folder, sha, run):
    folder = Path(folder)
    m = json.loads((folder / "manifest.json").read_text(encoding="utf-8"))
    if (m["git_sha"], str(m["build_run_id"]), m["universe_id"], m["place_id"]) != (
            sha, str(run), UNIVERSE, PLACE):
        raise ValueError("Wrong SHA/build/destination")
    if m["state"] != "PREVIEW_OK" or m["sha256"] != digest((folder / "mythragon.rbxlx").read_bytes()):
        raise ValueError("Artifact checksum/state invalid")
    actual = artifact_sources(folder / "mythragon.rbxlx")
    if {p: digest(s.encode()) for p, s in actual.items()} != m["source_sha256"]:
        raise ValueError("Artifact modules differ from manifest")
    if sorted(actual) != m["modules_expected"] or m["expected_content"] != EXPECTED:
        raise ValueError("Module/content contract mismatch")
    if actual["ServerScriptService/Mythragon/Diagnostics/BuildInfo"] != identity(sha, str(run)):
        raise ValueError("Artifact identity mismatch")
    if not m["tests"] or any(t["status"] != "PASS" for t in m["tests"]):
        raise ValueError("Required available test did not pass")
    return m


def main():
    p = argparse.ArgumentParser()
    p.add_argument("mode", choices=["prepare", "manifest", "verify"])
    p.add_argument("--sha", default=os.environ.get("BUILD_SHA"))
    p.add_argument("--run", default=os.environ.get("BUILD_RUN_ID", "local"))
    args = p.parse_args()
    sha = args.sha or subprocess.check_output(["git", "rev-parse", "HEAD"], text=True).strip()
    if args.mode == "prepare":
        prepare(sha, args.run)
    elif args.mode == "manifest":
        (ROOT / "dist/manifest.json").write_text(json.dumps(manifest(sha, args.run), indent=2) + "\n")
    else:
        verify_manifest(ROOT / "dist", sha, args.run)
        print("Artifact, identity, SHA-256 and available tests: PASS")


if __name__ == "__main__":
    main()
