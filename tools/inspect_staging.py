"""Inspect an existing published revision; never submits a Place upload."""
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import urllib.parse

from publish import OUT, request, save
from release import PLACE, UNIVERSE, verify_manifest


def task_path(path, revision):
    expected = rf"universes/{UNIVERSE}/places/{PLACE}/versions/{revision}/luau-execution-sessions/[A-Za-z0-9_-]+/tasks/[A-Za-z0-9_-]+"
    if not isinstance(path, str) or not re.fullmatch(expected, path):
        raise ValueError("Unexpected engine task destination/path")
    return path


def collect_logs(path, revision, key):
    task_path(path, revision)
    pages, token = [], ""
    for _ in range(20):
        query = "?view=STRUCTURED&maxPageSize=10000"
        if token:
            query += "&pageToken=" + urllib.parse.quote(token, safe="")
        result = request("https://apis.roblox.com/cloud/v2/" + path + "/logs" + query, key)
        pages.append(result)
        save("engine-logs.json", {"pages": pages})
        token = result.get("nextPageToken", "")
        if not token:
            return pages
    raise ValueError("Log pagination exceeded bound; partial evidence preserved")


def latest_evidence(artifacts, run):
    eligible = []
    for artifact in artifacts:
        match = re.fullmatch(rf"staging-evidence-{re.escape(run)}-([1-9][0-9]*)", artifact.get("name", ""))
        if match and not artifact.get("expired", True):
            eligible.append((int(match[1]), artifact["id"], artifact))
    if not eligible:
        raise ValueError("No retained staging evidence for this run")
    return max(eligible, key=lambda value: (value[0], value[1]))[2]


def main():
    run = os.environ["PUBLISH_RUN_ID"]
    mode = os.environ["INSPECT_MODE"]
    repo = os.environ["GITHUB_REPOSITORY"]
    if not re.fullmatch("[1-9][0-9]*", run) or mode not in ("logs", "verify"):
        raise ValueError("Invalid inspection run/mode")
    info = request(f"https://api.github.com/repos/{repo}/actions/runs/{run}",
                   os.environ["GH_TOKEN"], github=True)
    if info.get("path") != ".github/workflows/publish-staging.yml" or info.get("head_branch") != "main":
        raise ValueError("Only official main staging publications may be inspected")
    artifacts = request(f"https://api.github.com/repos/{repo}/actions/runs/{run}/artifacts?per_page=100",
                        os.environ["GH_TOKEN"], github=True)
    artifact = latest_evidence(artifacts["artifacts"], run)
    OUT.mkdir(exist_ok=True)
    with tempfile.TemporaryDirectory() as d:
        subprocess.run(["gh", "run", "download", run, "--repo", repo,
                        "--name", artifact["name"], "--dir", d], check=True, capture_output=True)
        receipts = sorted(Path(d).rglob("receipt.json"))
        if len(receipts) != 1:
            raise ValueError("Expected one unambiguous publication receipt")
        folder = receipts[0].parent
        receipt = json.loads(receipts[0].read_text(encoding="utf-8"))
        verify_manifest(folder, receipt["git_sha"], str(receipt["build_run_id"]))
        if receipt["git_sha"] != info["head_sha"] or receipt["state"] != "PUBLISHED":
            raise ValueError("Run and confirmed publication identity differ")
        if not re.fullmatch("[1-9][0-9]*", str(receipt["revision"])):
            raise ValueError("Missing published revision")
        for file in folder.iterdir():
            if file.is_file():
                shutil.copyfile(file, OUT / file.name)
    save("inspection-origin.json", {"publish_run_id": run, "artifact_id": artifact["id"],
                                    "artifact_name": artifact["name"], "revision": receipt["revision"]})
    if mode == "logs":
        task = json.loads((OUT / "engine-task.json").read_text(encoding="utf-8"))
        collect_logs(task["path"], receipt["revision"], os.environ["ROBLOX_OPEN_CLOUD_API_KEY"])
        print("Existing engine logs recovered; no task or upload was submitted")
    else:
        subprocess.run(["python", "tools/verify_cloud.py"], check=True)


if __name__ == "__main__":
    main()
