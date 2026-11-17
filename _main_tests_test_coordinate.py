from pathlib import Path
import sqlite3
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "tools"))
from coordinate import change


class CoordinationTests(unittest.TestCase):
    def setUp(self):
        self.db = sqlite3.connect(":memory:")
        self.db.execute("""CREATE TABLE tasks(id TEXT PRIMARY KEY,owner TEXT,token TEXT,state TEXT,
                          worktree TEXT,base TEXT,checkpoint TEXT,updated TEXT)""")
        self.db.execute("CREATE TABLE events(task TEXT,owner TEXT,state TEXT,checkpoint TEXT,updated TEXT)")

    def test_claim_blocks_duplicate_and_foreign_checkpoint(self):
        claim = change(self.db, "REC-TEST", "CODEX", "claim")
        with self.assertRaises(ValueError):
            change(self.db, "REC-TEST", "GLM", "claim")
        with self.assertRaises(ValueError):
            change(self.db, "OTHER", "GLM", "claim")
        with self.assertRaises(ValueError):
            change(self.db, "REC-TEST", "GLM", "checkpoint", claim["token"])
        self.assertEqual(change(self.db, "REC-TEST", "CODEX", "checkpoint",
                                claim["token"], "tests passed")["state"], "IMPLEMENTING")
        self.assertEqual(change(self.db, "REC-TEST", "CODEX", "submit",
                                claim["token"])["state"], "REVIEW")
        with self.assertRaises(ValueError):
            change(self.db, "REC-TEST", "CODEX", "checkpoint", claim["token"])

    def tearDown(self):
        self.db.close()