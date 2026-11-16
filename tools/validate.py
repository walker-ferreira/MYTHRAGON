"""Execute all standalone specs; keep engine tests explicitly separate."""
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[1]


def run(args, **kwargs):
    subprocess.run(args, cwd=ROOT, check=True, **kwargs)


def main():
    vm = os.environ.get("LUAU", "luau")
    compiler = os.environ.get("LUAU_COMPILE", "luau-compile")
    sources = sorted((ROOT / "src").rglob("*.luau"))
    for path in sources:
        run([compiler, "--null", str(path)])
    with tempfile.TemporaryDirectory() as d:
        bad = Path(d) / "invalid.luau"
        bad.write_text("local = invalid\n")
        result = subprocess.run([compiler, "--null", str(bad)], capture_output=True)
        if result.returncode == 0:
            raise RuntimeError("Compiler accepted invalid syntax")
    results = [{"name": f"Luau syntax ({len(sources)} files) + negative gate", "status": "PASS"}]
    specs = sorted((ROOT / "src").rglob("*.spec.luau"))
    pure = [p for p in specs if not p.name.endswith(".engine.spec.luau")]
    if len(pure) < 4:
        raise RuntimeError("Existing standalone specs disappeared")
    for path in pure:
        run([vm, str(path)])
        results.append({"name": path.relative_to(ROOT).as_posix(), "status": "PASS"})
    run([sys.executable, "-m", "unittest", "discover", "-s", "tests", "-v"])
    results.append({"name": "Python release/contracts negative tests", "status": "PASS"})
    registry = json.loads((ROOT / "assets/registry.json").read_text())
    all_source = "\n".join(p.read_text(encoding="utf-8") for p in sources)
    external = sorted(set(re.findall(r"rbxassetid://(\d+)", all_source)))
    native = sorted(set(re.findall(r'rbxasset://[^"\s]+', all_source)))
    if external != sorted(registry["external_ids"]) or native != sorted(registry["native_references"]):
        raise RuntimeError("Unregistered or stale asset references")
    if re.search(r"require\s*\(\s*\d", all_source):
        raise RuntimeError("Unreviewed numeric asset module require")
    results.append({"name": "Asset references registry / no numeric imports", "status": "PASS"})
    (ROOT / "dist").mkdir(exist_ok=True)
    (ROOT / "dist/tests.json").write_text(json.dumps(results, indent=2) + "\n")
    print("Engine-only tests NOT RUN:", [p.name for p in specs if p not in pure])


if __name__ == "__main__":
    main()
