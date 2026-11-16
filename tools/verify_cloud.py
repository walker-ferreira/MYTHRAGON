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
            if state == "COMPLETE":
                evidence = json.loads(result["output"]["results"][0])
                save("engine-evidence.json", evidence)
                if (evidence["git_sha"], evidence["revision"], evidence["place_id"]) != (
                        sha, receipt["revision"], PLACE) or not evidence["persisted_ok"]:
                    raise ValueError("Persisted identity mismatch")
                receipt["verification"]["persisted"] = "PASS"
                receipt["verification"]["engine_bootstrap"] = "PASS" if evidence["bootstrap_ok"] else "FAIL"
                save("receipt.json", receipt)
                if not evidence["bootstrap_ok"]:
                    raise ValueError("Published candidate bootstrap FAILED; read engine-evidence")
                print("PERSISTED_OK + isolated engine bootstrap PASS. Normal runtime/physics/client remain PENDING.")
                return
            if state not in ("QUEUED", "PROCESSING"):
                raise ValueError("Engine task failed: " + str(result.get("error", state)))
            time.sleep(5)
        raise TimeoutError("Engine verification timed out; task evidence retained")
    except urllib.error.HTTPError as exc:
        save("engine-api-error.json", {"status": exc.code, "body": exc.read(4000).decode(errors="replace")})
        if exc.code not in (401, 403, 404):
            raise
        receipt["verification"]["persisted"] = "PENDING_ACCESS"
        receipt["verification"]["engine_bootstrap"] = "PENDING_ACCESS"
        receipt["pending"].append("Roblox Luau Execution API access: HTTP " + str(exc.code))
        save("receipt.json", receipt)
        print("EXPERIMENTAL PUBLISHED; engine/persisted inspection PENDING_ACCESS, not PASS.")


if __name__ == "__main__":
    main()
