from pathlib import Path
import sys
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "tools"))
import inspect_staging
from release import PLACE, UNIVERSE


class InspectionTests(unittest.TestCase):
    def test_latest_attempt_selection_is_numeric_and_run_bound(self):
        def artifact(attempt, identifier):
            return {"id": identifier, "name": f"staging-evidence-123-{attempt}", "expired": False}
        older, latest = artifact(9, 90), artifact(10, 100)
        other = {"id": 999, "name": "staging-evidence-999-99", "expired": False}
        expired = dict(artifact(11, 110), expired=True)
        self.assertEqual(inspect_staging.latest_evidence([older, latest, other, expired], "123"), latest)
        with self.assertRaises(ValueError):
            inspect_staging.latest_evidence([other, expired], "123")

    def test_task_path_is_revision_and_destination_bound(self):
        path = f"universes/{UNIVERSE}/places/{PLACE}/versions/13/luau-execution-sessions/a/tasks/b"
        self.assertEqual(inspect_staging.task_path(path, "13"), path)
        for wrong in [path.replace("/13/", "/12/"), path.replace(PLACE, "999"), "https://untrusted"]:
            with self.assertRaises(ValueError):
                inspect_staging.task_path(wrong, "13")

    def test_log_collection_only_gets_and_preserves_pages(self):
        path = f"universes/{UNIVERSE}/places/{PLACE}/versions/13/luau-execution-sessions/a/tasks/b"
        with patch.object(inspect_staging, "request", side_effect=[
                {"luauExecutionSessionTaskLogs": [], "nextPageToken": "a/b"},
                {"luauExecutionSessionTaskLogs": []}]) as request, patch.object(inspect_staging, "save"):
            self.assertEqual(len(inspect_staging.collect_logs(path, "13", "test")), 2)
            self.assertEqual(request.call_count, 2)
            self.assertTrue(request.call_args.args[0].endswith("pageToken=a%2Fb"))
            self.assertTrue(all(len(c.args) == 2 for c in request.call_args_list))
