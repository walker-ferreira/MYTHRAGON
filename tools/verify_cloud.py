"""Persisted script equality + explicit engine bootstrap; never labels this live playtest."""
import json
import os
import re
import sys
import time
import urllib.error

from publish import OUT, request, save
from release import PLACE, UNIVERSE, artifact_sources


def main():
    receipt = json.loads((OUT / "receipt.json").read_text())
    key = os.environ["ROBLOX_OPEN_CLOUD_API_KEY"]
    sha = receipt["git_sha"]
    expected = artifact_sources(OUT / "mythragon.rbxlx")
    # Equality of actual persisted Source to the exact reviewed artifact, not object names.
    script = """
local HttpService = game:GetService("HttpService")
local expected = HttpService:JSONDecode(%s)
local count = 0
for path, source in pairs(expected) do
    local at = game
    for segment in string.gmatch(path, "[^/]+") do
        at = assert(at:FindFirstChild(segment), "Persisted module missing: " .. path)
    end
    assert(string.gsub(at.Source, "\\r\\n", "\\n") == source, "Persisted source differs: " .. path)
    count += 1
end
local actualCount = 0
for _, root in {
    game.ServerScriptService.Mythragon,
    game.StarterPlayer.StarterPlayerScripts,
} do
    for _, value in root:GetDescendants() do
        if value:IsA("LuaSourceContainer") then actualCount += 1 end
    end
end
assert(actualCount == count, "Unexpected persisted script modules")
local info = require(game.ServerScriptService.Mythragon.Diagnostics.BuildInfo)
assert(info.gitSha == %s, "Wrong build identity")
assert(tostring(game.GameId) == %s and tostring(game.PlaceId) == %s, "Wrong engine destination")
assert(tostring(game.PlaceVersion) == %s, "Wrong engine revision")
local probe = function()
%s
end
local ok, result = xpcall(probe, debug.traceback)
return HttpService:JSONEncode({ git_sha = info.gitSha, universe_id = tostring(game.GameId),
    place_id = tostring(game.PlaceId), revision = tostring(game.PlaceVersion), job_id = game.JobId,
    persisted_modules = count, persisted_ok = true, bootstrap_ok = ok, bootstrap = result,
    runtime_new_server = "PENDING", playtest = "PENDING" })
""" % (json.dumps(json.dumps(expected)), json.dumps(sha), json.dumps(UNIVERSE), json.dumps(PLACE),
       json.dumps(receipt["revision"]), (OUT.parent / "tools/engine_probe.luau").read_text(encoding="utf-8"))
    prefix = f"universes/{UNIVERSE}/places/{PLACE}/"
    endpoint = prefix + f"versions/{receipt['revision']}/luau-execution-session-tasks"
    try:
        result = request("https://apis.roblox.com/cloud/v2/" + endpoint, key, {"script": script}, "POST")
        # Avoid saving source twice in receipts.
        result.pop("script", None)
        save("engine-task.json", result)
        path = result.get("path", "")
        if not path.startswith(prefix) or not re.fullmatch(r"[A-Za-z0-9/_-]+", path):
            raise ValueError("Invalid engine task path")
        deadline = time.monotonic() + 420
        while time.monotonic() < deadline:
            result = request("https://apis.roblox.com/cloud/v2/" + path, key)
            result.pop("script", None)
            save("engine-task.json", result)
            state = result.get("state")
            if state in ("COMPLETE", "FAILED", "CANCELLED"):
                # Preserve structured engine errors; do not turn missing logs into a false PASS.
                from inspect_staging import collect_logs
                try:
                    collect_logs(path, receipt["revision"], key)
                except Exception as log_error:
                    save("engine-log-error.json", {"type": type(log_error).__name__, "message": str(log_error)})
            if state == "COMPLETE":
                if result.get("error"):
                    raise ValueError("Engine COMPLETE contains error")
                values = result.get("output", {}).get("results")
                if not isinstance(values, list) or len(values) != 1 or not isinstance(values[0], str):
                    raise ValueError("Engine COMPLETE without a single serialized evidence object")
                evidence = json.loads(result["output"]["results"][0])
                save("engine-evidence.json", evidence)
                if (evidence["git_sha"], evidence["revision"], evidence["place_id"], evidence["universe_id"]) != (
                        sha, receipt["revision"], PLACE, UNIVERSE) or evidence["persisted_ok"] is not True:
                    raise ValueError("Persisted identity mismatch")
                receipt["verification"]["persisted"] = "PASS"
                receipt["verification"]["engine_bootstrap"] = "PASS" if evidence["bootstrap_ok"] is True else "FAIL"
                save("receipt.json", receipt)
                if evidence["bootstrap_ok"] is not True:
                    raise ValueError("Published candidate bootstrap FAILED; read engine-evidence")
                print("PERSISTED_OK + isolated engine bootstrap PASS. Normal runtime/physics/client remain PENDING.")
                return
            if state not in ("QUEUED", "PROCESSING"):
                raise ValueError("Engine task failed: " + str(result.get("error", state)))
            time.sleep(5)
        raise TimeoutError("Engine verification timed out; task evidence retained")
    except urllib.error.HTTPError as exc:
        save("engine-api-error.json", {"status": exc.code, "body": exc.read(4000).decode(errors="replace")})
        if exc.code not in (401, 403):
            raise
        receipt["verification"]["persisted"] = "PENDING_ACCESS"
        receipt["verification"]["engine_bootstrap"] = "PENDING_ACCESS"
        pending = "Roblox Luau Execution API access: HTTP " + str(exc.code)
        if pending not in receipt["pending"]:
            receipt["pending"].append(pending)
        save("receipt.json", receipt)
        print("EXPERIMENTAL PUBLISHED; engine/persisted inspection PENDING_ACCESS, not PASS.")


def finalize_deployment(state, description):
    path = OUT / "receipt.json"
    if not path.exists():
        return
    receipt = json.loads(path.read_text())
    deployment_id = receipt.get("deployment_id")
    if not isinstance(deployment_id, int):
        raise ValueError("Receipt missing deployment journal")
    repo = os.environ["GITHUB_REPOSITORY"]
    url = f"https://api.github.com/repos/{repo}/deployments/{deployment_id}/statuses"
    request(url, os.environ["GH_TOKEN"], {
        "state": state, "description": description,
        "log_url": f"https://github.com/{repo}/actions/runs/{os.environ['GITHUB_RUN_ID']}",
        "environment_url": f"https://www.roblox.com/games/{PLACE}", "auto_inactive": state == "success"
    }, "POST", github=True)


if __name__ == "__main__":
    try:
        main()
        receipt = json.loads((OUT / "receipt.json").read_text())
        verified = receipt["verification"]["engine_bootstrap"] == "PASS"
        finalize_deployment("success", "Experimental published; isolated engine PASS, playtest pending"
                            if verified else "Experimental published; engine PENDING_ACCESS, NOT certified")
    except Exception as exc:
        save("verification-error.json", {"type": type(exc).__name__, "message": str(exc)})
        finalize_deployment("failure", "Published candidate verification failed; inspect evidence")
        raise
