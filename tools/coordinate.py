"""Local durable task leases across worktrees. Does NOT pretend to launch desktop agents."""
import argparse
import datetime
import json
from pathlib import Path
import re
import sqlite3
import subprocess
import uuid


def database():
    common = subprocess.check_output(["git", "rev-parse", "--git-common-dir"], text=True).strip()
    folder = Path(common).resolve() / "mythragon-coordination"
    folder.mkdir(exist_ok=True)
    db = sqlite3.connect(folder / "leases.sqlite", timeout=30)
    db.execute("""CREATE TABLE IF NOT EXISTS tasks(
        id TEXT PRIMARY KEY, owner TEXT NOT NULL, token TEXT NOT NULL,
        state TEXT NOT NULL, worktree TEXT NOT NULL, base TEXT NOT NULL,
        checkpoint TEXT NOT NULL, updated TEXT NOT NULL)""")
    db.execute("""CREATE TABLE IF NOT EXISTS events(
        task TEXT, owner TEXT, state TEXT, checkpoint TEXT, updated TEXT)""")
    return db


def change(db, task, owner, mode, token=None, checkpoint=""):
    now = datetime.datetime.now(datetime.timezone.utc).isoformat()
    with db:
        db.execute("BEGIN IMMEDIATE")
        row = db.execute("SELECT owner,token,state,worktree FROM tasks WHERE id=?", (task,)).fetchone()
        worktree = str(Path.cwd())
        if mode == "claim":
            if row:
                raise ValueError("Task already recorded; resume with its token, do not duplicate execution")
            active = db.execute("SELECT id FROM tasks WHERE worktree=? AND state='IMPLEMENTING'",
                                (worktree,)).fetchone()
            if active:
                raise ValueError("Worktree already leased by task " + active[0])
            token = uuid.uuid4().hex
            base = subprocess.check_output(["git", "rev-parse", "HEAD"], text=True).strip()
            db.execute("INSERT INTO tasks VALUES(?,?,?,?,?,?,?,?)",
                       (task, owner, token, "IMPLEMENTING", worktree, base, checkpoint, now))
            state = "IMPLEMENTING"
        else:
            if not row or row[0] != owner or row[1] != token or row[3] != worktree:
                raise ValueError("Wrong task owner/token/worktree")
            if row[2] != "IMPLEMENTING":
                raise ValueError("Task is not active; no silent reactivation")
            state = "IMPLEMENTING" if mode == "checkpoint" else "REVIEW"
            db.execute("UPDATE tasks SET state=?,checkpoint=?,updated=? WHERE id=?",
                       (state, checkpoint, now, task))
        db.execute("INSERT INTO events VALUES(?,?,?,?,?)", (task, owner, state, checkpoint, now))
    return {"task": task, "owner": owner, "token": token, "state": state, "updated": now}


def main():
    p = argparse.ArgumentParser()
    p.add_argument("mode", choices=["claim", "checkpoint", "submit", "status"])
    p.add_argument("--task")
    p.add_argument("--owner", choices=["CODEX", "GLM"])
    p.add_argument("--token")
    p.add_argument("--checkpoint", default="")
    a = p.parse_args()
    db = database()
    if a.mode == "status":
        for row in db.execute("SELECT id,owner,state,worktree,base,checkpoint,updated FROM tasks"):
            print(json.dumps(row))
    else:
        if not a.task or not re.fullmatch("[A-Z0-9-]+", a.task) or not a.owner:
            p.error("--task ID and --owner required")
        print(json.dumps(change(db, a.task, a.owner, a.mode, a.token, a.checkpoint)))


if __name__ == "__main__":
    main()
