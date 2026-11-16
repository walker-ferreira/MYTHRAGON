-- Isolated Open Cloud engine bootstrap; NO physics, players, SavePlaceAsync or DataStore writes.
local app = game:GetService("ServerScriptService").Mythragon
local result = require(app.Diagnostics.Bootstrap).run()
assert(result == require(app.Diagnostics.Bootstrap).run(), "Bootstrap must be idempotent")
assert(result.healthy, "Mandatory component failed; inspect structured logs")
local root = assert(workspace:FindFirstChild("LatuniaCodex"), "Latunia missing")
local Layout = require(app.Latunia.Codex.Layout)
local islands = root.Islands
assert(#islands:GetChildren() == 5, "Exactly five island slots")
assert(islands.Central.Content:FindFirstChild("VilaCentral"), "Central builder missing")
local villas, prompts, parts = 0, 0, 0
for _, value in root:GetDescendants() do
	if value.Name == "VilaCentral" then villas += 1 end
	if value:IsA("ProximityPrompt") then
		prompts += 1
		assert(value.ClickablePrompt and value.MaxActivationDistance == 12)
	elseif value:IsA("BasePart") then
		parts += 1
		assert(value.Anchored, "Unanchored generated geometry")
	end
end
assert(villas == 1 and prompts == 10, "No duplicated village or travel prompts")
assert(parts < 2500, "Latunia geometry budget")
local params = RaycastParams.new()
params.FilterType = Enum.RaycastFilterType.Include
params.FilterDescendantsInstances = { islands }
params.RespectCanCollide = true
for _, id in Layout.order do
	local slot = islands[id]
	local def = Layout.islands[id]
	local expected = Vector3.new(Layout.origin[1] + def.x, Layout.origin[2], Layout.origin[3] + def.z)
	assert((slot.BuildAnchor.Position - expected).Magnitude < 0.01, "Incorrect slot identity/geography")
	local arrival = Layout.arrivals[id]
	local p = expected + Vector3.new(arrival[1], arrival[2], arrival[3])
	local hit = workspace:Raycast(p, Vector3.new(0, -16, 0), params)
	assert(hit and hit.Instance.CanCollide, "Arrival missing collidable floor: " .. id)
end
assert(islands.Gelo.Content:FindFirstChild("ReservedLanding"), "Gelo status changed; update contract")
assert(islands.Selva.Content:FindFirstChild("ReservedLanding"), "Selva status changed; update contract")
assert(islands.Deserto.Content.Deserto:FindFirstChild("RuinasSoterradas"))
assert(islands.Vulcanica.Content.Vulcanica:FindFirstChild("CraterLava"))
assert((root.LatuniaTestGate.Position - Vector3.new(24, 4.5, 8)).Magnitude < 0.01)
assert(workspace.MythragonMap.Hub:FindFirstChild("HubSpawn"))
assert(workspace.MythragonMap:FindFirstChild("Varkhion"))
return { mode = "ISOLATED_ENGINE_BOOTSTRAP", parts = parts, prompts = prompts,
	healthy = result.healthy, physics = "NOT_RUN", player_travel = "NOT_RUN" }
