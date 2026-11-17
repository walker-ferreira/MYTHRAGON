import io
import json
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch
from urllib.error import HTTPError

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "tools"))
import verify_cloud
from release import PLACE, UNIVERSE


class CloudEvidenceTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.out = self.root / "dist"
        self.out.mkdir()
        (self.root / "tools").mkdir()
        (self.root / "tools/engine_probe.luau").write_text("return {}\n")
        self.receipt = {"git_sha": "a" * 40, "revision": "42", "verification": {
            "persisted": "PENDING", "engine_bootstrap": "PENDING",
            "runtime_new_server": "PENDING"}, "pending": []}
        (self.out / "receipt.json").write_text(json.dumps(self.receipt))
        (self.out / "mythragon.rbxlx").write_text(
            '<roblox><Item class="Script"><Properties><string name="Name">Start</string>'
            '<string name="Source">print(1)</string></Properties></Item></roblox>')

    def run_probe(self, result=None, error=None):
        if error:
            self.addCleanup(error.close)
        task = {"path": f"universes/{UNIVERSE}/places/{PLACE}/versions/42/luau-execution-sessions/test/tasks/test"}
        side_effect = error if error else [task, result]
        with patch.object(verify_cloud, "OUT", self.out), patch.object(
                verify_cloud, "save", side_effect=lambda name, value: (self.out / name).write_text(json.dumps(value))), patch.object(
                verify_cloud, "request", side_effect=side_effect), patch.dict(
                verify_cloud.os.environ, {"ROBLOX_OPEN_CLOUD_API_KEY": "test-only"}), patch(
                "inspect_staging.collect_logs", return_value=[]), patch("builtins.print"):
            verify_cloud.main()

    def complete(self, **changes):
        evidence = {"git_sha": "a" * 40, "revision": "42", "place_id": PLACE,
                    "universe_id": UNIVERSE, "persisted_ok": True, "bootstrap_ok": True}
        evidence.update(changes)
        return {"state": "COMPLETE", "output": {"results": [json.dumps(evidence)]}}

    def test_inspection_counts_client_scripts_as_well_as_server_scripts(self):
        import inspect
        script_builder = inspect.getsource(verify_cloud.main)
        self.assertIn("game.StarterPlayer.StarterPlayerScripts", script_builder)
        self.assertIn("game.ServerScriptService.Mythragon", script_builder)
        # Engine auto-injects standard PlayerModule/controls and sounds.
        # The authored client LocalScript must still be counted and matched.
        for name in ("PlayerModule", "PlayerScriptsLoader", "RbxCharacterSounds"):
            self.assertIn(name, script_builder)
        self.assertIn("countAuthored(child)", script_builder)
        self.assertIn("Unexpected persisted authored scripts", script_builder)

    def test_complete_with_error_is_not_success(self):
        result = self.complete()
        result["error"] = {"message": "engine failed"}
        with self.assertRaises(ValueError):
            self.run_probe(result)

    def test_wrong_universe_and_false_bootstrap_fail(self):
        for result in [self.complete(universe_id="wrong"), self.complete(bootstrap_ok=False),
                       self.complete(bootstrap_ok="false")]:
            with self.assertRaises(ValueError):
                self.run_probe(result)

    def test_403_pending_but_404_is_failure(self):
        self.run_probe(error=HTTPError("https://test", 403, "Forbidden", {}, io.BytesIO(b"scope")))
        receipt = json.loads((self.out / "receipt.json").read_text())
        self.assertEqual(receipt["verification"]["engine_bootstrap"], "PENDING_ACCESS")
        with self.assertRaises(HTTPError):
            self.run_probe(error=HTTPError("https://test", 404, "Not found", {}, io.BytesIO(b"wrong endpoint")))

    def test_isolated_engine_never_certifies_normal_runtime(self):
        self.run_probe(self.complete())
        receipt = json.loads((self.out / "receipt.json").read_text())
        self.assertEqual(receipt["verification"]["persisted"], "PASS")
        self.assertEqual(receipt["verification"]["engine_bootstrap"], "PASS")
        self.assertEqual(receipt["verification"]["runtime_new_server"], "PENDING")

    def tearDown(self):
        self.tmp.cleanup()
