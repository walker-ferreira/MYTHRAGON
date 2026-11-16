"""Serial staging publisher. Never retries an upload; preserve accepted operations."""
import json
import os
from pathlib import Path
import re
import sys
import time
import urllib.error
import urllib.request
import uuid

from release import ROOT, PLACE, UNIVERSE, verify_manifest

OUT = ROOT / "dist"


def save(name, data):
    (OUT / name).write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def request(url, key=None, data=None, method="GET", content_type="application/json", github=False):
    headers = {"Accept": "application/vnd.github+json" if github else "application/json",
               "User-Agent": "MYTHRAGON-release"}
    if key:
        headers["Authorization" if github else "x-api-key"] = ("Bearer " if github else "") + key
    if data is not None:
        headers["Content-Type"] = content_type
        if not isinstance(data, bytes):
            data = json.dumps(data).encode()
    req = urllib.request.Request(url, headers=headers, data=data, method=method)
    # Authenticated calls may not redirect to an untrusted host.
    class NoRedirect(urllib.request.HTTPRedirectHandler):
        def redirect_request(self, req, fp, code, msg, headers, newurl):
            return None
    with urllib.request.build_opener(NoRedirect).open(req, timeout=90) as resp:
        return json.load(resp)


def publication_response(result):
    if result.get("done") is not True or result.get("error"):
        raise ValueError("Operation incomplete or failed")
    r = result.get("response", {})
    if r.get("path") != f"assets/{PLACE}" or r.get("isPublished") is not True:
        raise ValueError("Operation did not publish the authorized Place")
    revision = str(r.get("revisionId", ""))
    if not re.fullmatch("[1-9][0-9]*", revision):
        raise ValueError("Missing numeric Roblox revision")
    return revision


def main():
    sha, run = os.environ["BUILD_SHA"], os.environ["BUILD_RUN_ID"]
    m = verify_manifest(OUT, sha, run)
    key = os.environ["ROBLOX_OPEN_CLOUD_API_KEY"].strip()
    gh = os.environ["GH_TOKEN"]
    repo = os.environ["GITHUB_REPOSITORY"]
    if not key:
        raise ValueError("Missing Roblox secret")
    base = f"https://api.github.com/repos/{repo}"
    api = lambda path, data=None, method="GET": request(base + path, gh, data, method, github=True)
    origin = api(f"/actions/runs/{run}")
    if any((origin.get("path") != ".github/workflows/ci.yml",
            origin.get("event") != "push", origin.get("head_branch") != "main",
            origin.get("conclusion") != "success", origin.get("head_sha") != sha)):
        raise ValueError("Untrusted build origin")
    if api("/commits/main")["sha"] != sha:
        raise ValueError("Obsolete candidate: main advanced")
    target = request(f"https://apis.roblox.com/universes/v1/places/{PLACE}/universe")
    if str(target.get("universeId")) != UNIVERSE:
        raise ValueError("Place belongs to another universe")
    save("target.json", target)
    previous = api(f"/deployments?sha={sha}&environment=staging&per_page=100")
    if previous:
        raise ValueError("Deployment journal already exists for this SHA. Inspect prior receipt/operation; no duplicate upload.")
    # The persistent GitHub deployment is a fail-closed fence if the runner dies mid-upload.
    deployment = api("/deployments", {"ref": sha, "environment": "staging",
                     "auto_merge": False, "required_contexts": [], "production_environment": False,
                     "description": "MYTHRAGON experimental staging",
                     "payload": {"build_run_id": run, "sha256": m["sha256"]}}, "POST")
    dep_id = deployment["id"]
    save("deployment.json", {"id": dep_id, "sha": sha})
    status_path = f"/deployments/{dep_id}/statuses"
    log = f"https://github.com/{repo}/actions/runs/{os.environ['GITHUB_RUN_ID']}"
    api(status_path, {"state": "in_progress", "log_url": log, "auto_inactive": False}, "POST")
    try:
        # Last freshness check inside the Place-wide concurrency lock, immediately before PATCH.
        if api("/commits/main")["sha"] != sha:
            raise ValueError("Candidate superseded before upload")
        boundary = "mythragon-" + uuid.uuid4().hex
        metadata = json.dumps({"assetId": int(PLACE), "assetType": "Place", "published": True})
        body = (f"--{boundary}\r\nContent-Disposition: form-data; name=\"request\"\r\n\r\n"
                f"{metadata}\r\n--{boundary}\r\nContent-Disposition: form-data; "
                'name="fileContent"; filename="mythragon.rbxlx"\r\n'
                "Content-Type: application/xml\r\n\r\n").encode()
        body += (OUT / "mythragon.rbxlx").read_bytes() + f"\r\n--{boundary}--\r\n".encode()
        save("upload-intent.json", {"sha": sha, "sha256": m["sha256"], "deployment_id": dep_id,
                                   "state": "UPLOAD_MAY_HAVE_OCCURRED", "place_id": PLACE})
        result = request(f"https://apis.roblox.com/assets/v1/assets/{PLACE}", key, body, "PATCH",
                         "multipart/form-data; boundary=" + boundary)
        save("upload-response.json", result)
        operation = result.get("path", "")
        if not re.fullmatch(r"operations/[A-Za-z0-9_-]+", operation):
            raise ValueError("Unexpected operation path; inspect upload-response, do not resend")
        m["operation"] = operation
        save("receipt.json", m)
        deadline = time.monotonic() + 360
        while time.monotonic() < deadline:
            result = request("https://apis.roblox.com/assets/v1/" + operation, key)
            save("operation.json", result)
            if result.get("done") is True:
                m["revision"] = publication_response(result)
                m["state"] = "PUBLISHED"
                save("receipt.json", m)
                api(status_path, {"state": "success", "log_url": log,
                                 "environment_url": f"https://www.roblox.com/games/{PLACE}",
                                 "description": "Published experimental revision " + m["revision"],
                                 "auto_inactive": True}, "POST")
                print(f"PUBLISHED experimental staging: {sha}, revision {m['revision']}, {operation}")
                return
            time.sleep(5)
        raise TimeoutError("Operation not definitive; resume GET polling, never duplicate PATCH")
    except Exception:
        api(status_path, {"state": "failure", "log_url": log,
                         "description": "Inspect operation/receipt before any retry", "auto_inactive": False}, "POST")
        raise


if __name__ == "__main__":
    try:
        main()
    except urllib.error.HTTPError as exc:
        # Do not dump request headers or credentials.
        save("api-error.json", {"status": exc.code, "body": exc.read(4000).decode(errors="replace")})
        sys.exit(f"Publication API HTTP {exc.code}; evidence preserved; no automatic upload retry")
