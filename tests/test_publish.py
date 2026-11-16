from pathlib import Path
import sys
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "tools"))
import publish
from release import PLACE, UNIVERSE


class PublishGateTests(unittest.TestCase):
    def attempt(self, *, current=None, workflow=None, universe=None, previous=None):
        sha = "a" * 40
        calls = []
        origin = {"path": ".github/workflows/ci.yml", "event": "push",
                  "head_branch": "main", "conclusion": "success", "head_sha": sha}
        if workflow:
            origin.update(workflow)

        def fake(url, key=None, data=None, method="GET", **kwargs):
            calls.append((url, method))
            if "/actions/runs/" in url:
                return origin
            if url.endswith("/commits/main"):
                return {"sha": current or sha}
            if url.endswith("/universe"):
                return {"universeId": universe or UNIVERSE}
            if "/deployments?" in url:
                return previous or []
            self.fail("Unexpected external request beyond fail-closed gate: " + url)

        env = {"BUILD_SHA": sha, "BUILD_RUN_ID": "1", "ROBLOX_OPEN_CLOUD_API_KEY": "test-not-secret",
               "GH_TOKEN": "test-not-secret", "GITHUB_REPOSITORY": "walker-ferreira/MYTHRAGON"}
        with patch.dict(publish.os.environ, env), patch.object(
                publish, "verify_manifest", return_value={"sha256": "test"}), patch.object(
                publish, "request", side_effect=fake), patch.object(publish, "save"):
            with self.assertRaises(ValueError):
                publish.main()
        self.assertFalse(any(method == "PATCH" for _, method in calls), "Must not upload")

    def test_stale_commit_never_uploads(self):
        self.attempt(current="b" * 40)

    def test_wrong_build_origin_never_uploads(self):
        for fields in [{"event": "pull_request"}, {"head_branch": "other"},
                       {"conclusion": "failure"}, {"path": ".github/workflows/untrusted.yml"}]:
            self.attempt(workflow=fields)

    def test_wrong_universe_never_uploads(self):
        self.attempt(universe="123")

    def test_duplicate_or_ambiguous_deployment_never_uploads(self):
        self.attempt(previous=[{"id": 42}])
