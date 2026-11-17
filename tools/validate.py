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
    for path in sorted((ROOT / "tools").rglob("*.luau")):
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
    # Execute only the module's export contract. Stub Color3 constants; NOT engine geometry.
    model_source = (ROOT / "src/server/Dragons/VarkhionModel.luau").read_text(encoding="utf-8")
    def model_contract(source):
        return ("local Color3 = { fromRGB = function(...) return table.pack(...) end }\n"
                "local function module()\n" + source + "\nend\n"
                "local exported = module()\n"
                'assert(type(exported) == "table", "VarkhionModel must return its module table")\n'
                'assert(type(exported.build) == "function", "VarkhionModel.build export required")\n')
    with tempfile.TemporaryDirectory() as d:
        contract = Path(d) / "model-export.luau"
        contract.write_text(model_contract(model_source), encoding="utf-8")
        run([vm, str(contract)])
        negative = model_source.replace("\nreturn Model\n", "\n")
        if negative == model_source:
            raise RuntimeError("Model export negative fixture did not remove the return")
        contract.write_text(model_contract(negative), encoding="utf-8")
        rejected = subprocess.run([vm, str(contract)], capture_output=True)
        if rejected.returncode == 0:
            raise RuntimeError("Model export gate accepted missing module return")
    results.append({"name": "VarkhionModel export + missing-return negative (Color3 stub, NOT geometry)", "status": "PASS"})
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
