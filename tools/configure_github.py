"""Apply repository-scoped staging/main protections with authenticated GitHub CLI."""
import argparse
import json
import os
import subprocess

REPO = "walker-ferreira/MYTHRAGON"


def api(path, method="GET", payload=None):
    endpoint = f"repos/{REPO}" + ("/" + path if path else "")
    cmd = [os.environ.get("GH", "gh"), "api", endpoint, "--method", method]
    if payload is not None:
        cmd += ["--input", "-"]
    result = subprocess.run(cmd, input=json.dumps(payload) if payload is not None else None,
                            text=True, capture_output=True)
    if result.returncode:
        raise RuntimeError(f"GitHub {method} {path}: {result.stderr.strip()}")
    return json.loads(result.stdout) if result.stdout.strip() else None


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--apply", action="store_true")
    a = p.parse_args()
    if not a.apply:
        print("PREVIEW: require build check + conversations on main; no human approval; staging main-only.")
        return
    api("branches/main/protection", "PUT", {
        "required_status_checks": {"strict": True, "contexts": ["build"]},
        "enforce_admins": True, "required_pull_request_reviews": {
            "dismiss_stale_reviews": True, "require_code_owner_reviews": False,
            "required_approving_review_count": 0},
        "restrictions": None, "required_conversation_resolution": True,
        "allow_force_pushes": False, "allow_deletions": False})
    api("", "PATCH", {"allow_auto_merge": True})
    api("environments/staging", "PUT", {
        "deployment_branch_policy": {"protected_branches": False, "custom_branch_policies": True}})
    existing = api("environments/staging/deployment-branch-policies")
    if not any(p["name"] == "main" and p.get("type", "branch") == "branch"
               for p in existing["branch_policies"]):
        api("environments/staging/deployment-branch-policies", "POST", {"name": "main", "type": "branch"})
    print(json.dumps({
        "main": api("branches/main/protection"),
        "staging": api("environments/staging"),
        "branches": api("environments/staging/deployment-branch-policies")
    }, indent=2))


if __name__ == "__main__":
    main()
