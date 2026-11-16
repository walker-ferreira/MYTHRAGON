from pathlib import Path
import sys
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "tools"))
import publish
from release import PLACE, UNIVERSE


class PublishGateTests(unittest.TestCase):
    def test_resume_polls_operation_without_upload(self):
        m = {"git_sha": "a" * 40, "operation": "operations/accepted"}
        result = {"done": True, "response": {
            "path": "assets/" + PLACE, "revisionId": "42", "isPublished": True}}
        with patch.object(publish, "request", return_value=result) as request, patch.object(publish, "save"):
            publish.poll_operation(m, "test-not-secret")
            self.assertEqual(m["state"], "PUBLISHED")
            self.assertEqual(m["revision"], "42")
            self.assertEqual(request.call_count, 1)
            self.assertEqual(request.call_args.args[0],
                             "https://apis.roblox.com/assets/v1/operations/accepted")

    def test_resume_rejects_untrusted_operation_path(self):
        with patch.object(publish, "request") as request:
            with self.assertRaises(ValueError):
                publish.poll_operation({"operation": "https://untrusted"}, "test")
            request.assert_not_called()

    def test_duplicate_journal_cannot_resume_another_artifact(self):
        with self.assertRaises(ValueError):
            publish.recover_receipt(None, [{"id": 42, "payload": {"sha256": "other"}}],
                                    {"sha256": "reviewed", "build_run_id": "1"})

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
