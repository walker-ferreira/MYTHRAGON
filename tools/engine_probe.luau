-- Isolated Open Cloud engine bootstrap; NO physics, players, SavePlaceAsync or DataStore writes.
-- The command UI is a LocalScript template; isolated engine cannot click it.
local playerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
assert(playerScripts:FindFirstChild("CommandPanel"), "Command GUI LocalScript missing")
local app = game:GetService("ServerScriptService").Mythragon
local result = require(app.Diagnostics.Bootstrap).run()
assert(result == require(app.Diagnostics.Bootstrap).run(), "Bootstrap must be idempotent")
assert(result.healthy, "Mandatory component failed: " .. game:GetService("HttpService"):JSONEncode(result.health.failures))
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
-- Regression: procedurally generated village decorations must follow the
-- Latunia island anchor rather than accidentally appearing at Hub (0,0,0).
local central = islands.Central
local village = assert(central.Content:FindFirstChild("VilaCentral"))
for _, name in {"Guindaste1Mast", "DirigivelDocaCabin", "Oficina1Body",
    "LampiaoAtracadouroNPost", "LampiaoPracaPost"} do
    local piece = assert(village:FindFirstChild(name, true), "Village decor missing: " .. name)
    assert((piece.Position - central.BuildAnchor.Position).Magnitude < 180,
        "Village decor outside Latunia island: " .. name)
end

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
assert(islands.Gelo.Content.Gelo:FindFirstChild("ObservatoryDeck"), "Gelo scenery missing")
assert(islands.Selva.Content.Selva:FindFirstChild("TemplePlatform"), "Selva scenery missing")
-- GLM-R009: verify additive builder wiring and base models coexist in staging.
local geloGLM = assert(islands.Gelo.Content:FindFirstChild("GeloGLM"),
    "GLM Gelo overlay was not mounted")
local selvaGLM = assert(islands.Selva.Content:FindFirstChild("SelvaGLM"),
    "GLM Selva overlay was not mounted")
assert(geloGLM:FindFirstChild("CavernaParedao", true)
    or geloGLM:FindFirstChild("MonolitoRuna", true), "Missing Gelo GLM landmark")
assert(selvaGLM:FindFirstChild("CachoeiraParedao", true),
    "Missing Selva GLM waterfall")
assert(village:FindFirstChild("FonteJato", true),
    "Vila Central GLM improvements not mounted")
assert(not islands.Gelo.Content:FindFirstChild("ReservedLanding"), "Gelo should not use placeholder")
assert(not islands.Selva.Content:FindFirstChild("ReservedLanding"), "Selva should not use placeholder")
assert(islands.Deserto.Content.Deserto:FindFirstChild("RuinasSoterradas"))
assert(islands.Vulcanica.Content.Vulcanica:FindFirstChild("CraterLava"))
assert((root.LatuniaTestGate.Position - Vector3.new(24, 4.5, 8)).Magnitude < 0.01)
assert(workspace.MythragonMap.Hub:FindFirstChild("HubSpawn"))
local ember = assert(workspace.MythragonMap:FindFirstChild("Ember"))
local boss = assert(ember:FindFirstChild("BasaltWyrm"))
local body = assert(boss:FindFirstChild("ObsidianBody"))
local board = assert(body:FindFirstChildOfClass("BillboardGui"))
local background = assert(board:FindFirstChild("BossHealthBackground"))
assert(background:FindFirstChild("BossHealthFill"), "Boss HP bar missing")
for index = 1, 6 do
    local rock = assert(ember:FindFirstChild("FloatingBasalt" .. index), "Missing floating rock")
    assert(rock.Anchored and not rock.CanCollide and not rock.CanTouch,
        "Scenic basalt must not change arena physics")
end
assert(workspace.MythragonMap:FindFirstChild("Varkhion"))
return { mode = "ISOLATED_ENGINE_BOOTSTRAP", parts = parts, prompts = prompts,
	healthy = result.healthy, physics = "NOT_RUN", player_travel = "NOT_RUN" }
