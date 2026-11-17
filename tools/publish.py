"""Serial staging publisher. Never retries an upload; preserve accepted operations."""
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile
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


def poll_operation(m, key):
    operation = m.get("operation", "")
    if not re.fullmatch(r"operations/[A-Za-z0-9_-]+", operation):
        raise ValueError("Missing valid operation; inspect prior upload, never resend blindly")
    deadline = time.monotonic() + 360
    while time.monotonic() < deadline:
        result = request("https://apis.roblox.com/assets/v1/" + operation, key)
        save("operation.json", result)
        if result.get("done") is True:
            m["revision"] = publication_response(result)
            m["state"] = "PUBLISHED"
            save("receipt.json", m)
            print(f"PUBLISHED experimental staging: {m['git_sha']}, revision {m['revision']}, {operation}")
            return
        time.sleep(5)
    raise TimeoutError("Operation not definitive; resume GET polling, never duplicate PATCH")


def recover_receipt(api, deployments, candidate):
    """Recover an earlier attempt's accepted operation, not another upload."""
    if len(deployments) != 1:
        raise ValueError("Ambiguous deployment journal; investigate before resuming")
    deployment = deployments[0]
    payload = deployment.get("payload", {})
    if isinstance(payload, str):
        payload = json.loads(payload)
    if payload.get("sha256") != candidate["sha256"] or str(payload.get("build_run_id")) != candidate["build_run_id"]:
        raise ValueError("Prior deployment has a different artifact/build")
    statuses = api(f"/deployments/{deployment['id']}/statuses")
    repo = re.escape(os.environ["GITHUB_REPOSITORY"])
    for status in statuses:
        match = re.fullmatch(rf"https://github.com/{repo}/actions/runs/([0-9]+)", status.get("log_url", ""))
        if not match:
            continue
        run_id = match[1]
        artifacts = api(f"/actions/runs/{run_id}/artifacts?per_page=100")["artifacts"]
        for artifact in sorted(artifacts, key=lambda a: a["id"], reverse=True):
            if not artifact["name"].startswith("staging-evidence-") or artifact["expired"]:
                continue
            with tempfile.TemporaryDirectory() as d:
                subprocess.run(["gh", "run", "download", run_id, "--repo", os.environ["GITHUB_REPOSITORY"],
                                "--name", artifact["name"], "--dir", d], check=True, capture_output=True)
                path = Path(d) / "receipt.json"
                if not path.exists():
                    continue
                prior = json.loads(path.read_text(encoding="utf-8"))
                for field in ("git_sha", "build_run_id", "sha256", "place_id", "universe_id"):
                    if str(prior.get(field)) != str(candidate[field]):
                        raise ValueError("Prior receipt identity mismatch: " + field)
                if prior.get("deployment_id") != deployment["id"]:
                    raise ValueError("Prior receipt belongs to another deployment")
                if not re.fullmatch(r"operations/[A-Za-z0-9_-]+", prior.get("operation", "")):
                    continue
                return prior
    raise ValueError("Deployment exists without recoverable operation receipt; inspect prior upload. No duplicate PATCH.")


def publication_journals(deployments):
    """Environment jobs create empty GitHub deployments before our publisher starts."""
    journals = []
    for deployment in deployments:
        payload = deployment.get("payload", {})
        if isinstance(payload, str):
            payload = json.loads(payload)
        if not isinstance(payload, dict):
            raise ValueError("Unexpected deployment payload; investigate before uploading")
        if payload.get("mythragon_journal_schema") == 1 or (
                payload.get("build_run_id") and payload.get("sha256")):
            journals.append(deployment)
        elif not payload and deployment.get("task") == "deploy" and deployment.get("ref") == "main":
            # GitHub Actions environment bookkeeping, not an upload/operation fence.
            continue
        else:
            raise ValueError("Unrecognized deployment journal; investigate before uploading")
    return journals


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
    previous = publication_journals(api(f"/deployments?sha={sha}&environment=staging&per_page=100"))
    if previous:
        m = recover_receipt(api, previous, m)
        save("receipt.json", m)
        print("RESUMING prior operation; no upload will be sent")
        status_path = f"/deployments/{m['deployment_id']}/statuses"
        log = f"https://github.com/{repo}/actions/runs/{os.environ['GITHUB_RUN_ID']}"
        try:
            api(status_path, {"state": "in_progress", "log_url": log,
                              "description": "Resuming accepted operation; no new upload",
                              "auto_inactive": False}, "POST")
            poll_operation(m, key)
        except Exception:
            api(status_path, {"state": "failure", "log_url": log,
                              "description": "Resume failed; inspect prior operation, never duplicate upload",
                              "auto_inactive": False}, "POST")
            raise
        return
    # The persistent GitHub deployment is a fail-closed fence if the runner dies mid-upload.
    deployment = api("/deployments", {"ref": sha, "environment": "staging",
                     "auto_merge": False, "required_contexts": [], "production_environment": False,
                     "description": "MYTHRAGON experimental staging",
                     "payload": {"mythragon_journal_schema": 1,
                                 "build_run_id": run, "sha256": m["sha256"]}}, "POST")
    dep_id = deployment["id"]
    m["deployment_id"] = dep_id
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
        poll_operation(m, key)
        api(status_path, {"state": "in_progress", "log_url": log,
                          "environment_url": f"https://www.roblox.com/games/{PLACE}",
                          "description": "Published revision " + m["revision"] + "; verification pending",
                          "auto_inactive": False}, "POST")
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
    except (urllib.error.URLError, TimeoutError) as exc:
        save("transport-error.json", {"type": type(exc).__name__, "message": str(exc)})
        sys.exit("Publication transport failure; inspect saved operation/intent before retry")
