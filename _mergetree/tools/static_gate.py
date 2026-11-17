"""Roblox-aware static gate for pure policies; enum references across all source."""
import json
import os
from pathlib import Path
import re
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]


def main():
    definitions = Path(os.environ["ROBLOX_DEFINITIONS"])
    text = definitions.read_text(encoding="utf-8")
    # Check real type analysis, not merely whether a tool exists.
    modules = ["Ember/EncounterState", "Profile/Profile", "Dragons/InteractionState",
               "Latunia/Codex/Layout", "Latunia/Codex/TravelState"]
    for module in modules:
        subprocess.run(["luau-lsp", "analyze", "--definitions=" + str(definitions),
                        str(ROOT / f"src/server/{module}.luau")], check=True, cwd=ROOT)
    with tempfile.TemporaryDirectory() as d:
        bad = Path(d) / "bad.luau"
        bad.write_text('--!strict\nlocal bad: number = "wrong"\nprint(bad)\n')
        result = subprocess.run(["luau-lsp", "analyze", "--definitions=" + str(definitions), str(bad)],
                                capture_output=True, text=True)
        if result.returncode == 0 or "TypeError" not in result.stdout + result.stderr:
            raise RuntimeError("Negative type gate did not reject incorrect types")
    # Engine-facing modules remain gradually typed; enforce Enum contracts everywhere.
    # Let LSP itself resolve each referenced Enum against pinned Roblox definitions.
    refs = sorted(set(re.findall(r"Enum\.[A-Za-z_]\w*\.[A-Za-z_]\w*",
                                "\n".join(p.read_text(encoding="utf-8")
                                          for p in (ROOT / "src").rglob("*.luau")))))
    with tempfile.TemporaryDirectory() as d:
        check = Path(d) / "enums.luau"
        check.write_text("--!strict\n" + "\n".join("print(" + r + ")" for r in refs))
        subprocess.run(["luau-lsp", "analyze", "--definitions=" + str(definitions), str(check)], check=True)
    report = ROOT / "dist/tests.json"
    results = json.loads(report.read_text())
    results.append({"name": "Roblox LSP: 5 policies + all Enum references + negative type gate", "status": "PASS"})
    report.write_text(json.dumps(results, indent=2) + "\n")
    print("Static gate PASS; full engine-module type coverage remains incremental, not claimed.")


if __name__ == "__main__":
    main()