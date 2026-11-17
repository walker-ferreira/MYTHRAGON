import copy
import json
from pathlib import Path
import sys
import tempfile
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "tools"))
import release
from publish import publication_response


class ReleaseTests(unittest.TestCase):
    def test_publication_requires_exact_destination_and_published_revision(self):
        good = {"done": True, "response": {"path": "assets/" + release.PLACE,
                                         "isPublished": True, "revisionId": "42"}}
        self.assertEqual(publication_response(good), "42")
        for field, value in [("path", "assets/other"), ("isPublished", False), ("revisionId", "")]:
            bad = copy.deepcopy(good)
            bad["response"][field] = value
            with self.assertRaises(ValueError):
                publication_response(bad)
        for bad in [{"done": False}, {"done": True, "error": {"code": 1}}]:
            with self.assertRaises(ValueError):
                publication_response(bad)
    def test_identity_rejects_injection(self):
        for sha, run in [("bad", "1"), ("a" * 40, '1";error()')]:
            with self.assertRaises(ValueError):
                release.identity(sha, run)

    def test_source_path(self):
        self.assertEqual(release.instance_path("Start.server.luau"),
                         "ServerScriptService/Mythragon/Start")
        self.assertEqual(release.instance_path("Hub/Latunia.luau"),
                         "ServerScriptService/Mythragon/Hub/Latunia")

    def test_wrong_destination_and_tamper(self):
        with tempfile.TemporaryDirectory() as d:
            p = Path(d)
            (p / "mythragon.rbxlx").write_bytes(b"candidate")
            m = {"git_sha": "a" * 40, "build_run_id": "1",
                 "universe_id": release.UNIVERSE, "place_id": "PRODUCTION",
                 "state": "PREVIEW_OK", "sha256": release.digest(b"candidate")}
            (p / "manifest.json").write_text(json.dumps(m))
            with self.assertRaisesRegex(ValueError, "destination"):
                release.verify_manifest(p, "a" * 40, "1")
            m["place_id"] = release.PLACE
            (p / "manifest.json").write_text(json.dumps(m))
            (p / "mythragon.rbxlx").write_bytes(b"tampered")
            with self.assertRaisesRegex(ValueError, "checksum"):
                release.verify_manifest(p, "a" * 40, "1")

    def test_source_missing_or_modified(self):
        xml = """<roblox><Item class="ServerScriptService"><Properties>
        <string name="Name">ServerScriptService</string></Properties>
        <Item class="Folder"><Properties><string name="Name">Mythragon</string></Properties>
        <Item class="Script"><Properties><string name="Name">Start</string>
        <ProtectedString name="Source">print(1)</ProtectedString></Properties>
        </Item></Item></Item></roblox>"""
        with tempfile.TemporaryDirectory() as d:
            p = Path(d) / "test.rbxlx"
            p.write_text(xml)
            release.verify_sources(p, {"Start.server.luau": "print(1)"})
            p.write_text(xml.replace("ProtectedString", "string"))
            release.verify_sources(p, {"Start.server.luau": "print(1)"})
            with self.assertRaisesRegex(ValueError, "mismatch"):
                release.verify_sources(p, {"Start.server.luau": "print(2)"})
            with self.assertRaisesRegex(ValueError, "mismatch"):
                release.verify_sources(p, {})


if __name__ == "__main__":
    unittest.main()
