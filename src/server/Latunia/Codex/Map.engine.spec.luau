-- Manual, read-only SERVER inspection after Play. No automatic travel or rewards.
-- require(game.ServerScriptService.Mythragon.Latunia.Codex["Map.engine.spec"])()
local RunService = game:GetService("RunService")
local Layout = require(script.Parent.Layout)

return function()
    assert(RunService:IsStudio() and RunService:IsServer(), "Use the Studio server Command Bar")
    local root = assert(workspace:FindFirstChild("LatuniaCodex"), "Latunia did not initialize")
    local islands = assert(root:FindFirstChild("Islands"))
    local parts, prompts = 0, 0
    for _, value in ipairs(root:GetDescendants()) do
        assert(not value:IsA("LuaSourceContainer"), "No executable imported content")
        assert(not value:IsA("SpawnLocation"), "Do not change MYTHRAGON spawn selection")
        if value:IsA("BasePart") then
            parts += 1
            assert(value.Anchored, "Prototype geometry remains anchored")
        elseif value:IsA("ProximityPrompt") then
            prompts += 1
            assert(value.ClickablePrompt and value.KeyboardKeyCode == Enum.KeyCode.E)
        end
    end
    assert(parts < 2500, "Geometry budget exceeded")
    assert(prompts == 11, "Ten travel prompts plus the GLM village quest mural")
    local mural = assert(islands.Central.Content:FindFirstChild("MuralQuadro", true))
    assert(mural:FindFirstChild("LatuniaQuestBoard"), "Village quest interaction missing")
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Include
    params.FilterDescendantsInstances = { islands }
    for _, id in ipairs(Layout.order) do
        local def = Layout.islands[id]
        local slot = assert(islands:FindFirstChild(id))
        local anchor = assert(slot:FindFirstChild("BuildAnchor"))
        assert(anchor.Anchored and not anchor.CanCollide)
        local expected = Vector3.new(Layout.origin[1]+def.x, Layout.origin[2], Layout.origin[3]+def.z)
        assert((anchor.Position-expected).Magnitude < 0.01, "Cardinal geography")
        local arrival = Layout.arrivals[id]
        local p = expected+Vector3.new(arrival[1], arrival[2], arrival[3])
        assert(workspace:Raycast(p, Vector3.new(0, -16, 0), params), "Arrival needs floor: "..id)
    end

    local vila = assert(islands.Central.Content:FindFirstChild("VilaCentral"))
    for _, name in {"Guindaste1Mast", "DirigivelDocaCabin", "Oficina1Body",
        "LampiaoAtracadouroNPost", "LampiaoPracaPost"} do
        local p = assert(vila:FindFirstChild(name, true), "Missing anchored village decor: " .. name)
        assert((p.Position - islands.Central.BuildAnchor.Position).Magnitude < 180,
            "Village decor not anchored to Latunia: " .. name)
    end
    assert(islands.Gelo.Content.Gelo:FindFirstChild("ObservatoryDeck"))
    assert(islands.Selva.Content.Selva:FindFirstChild("TemplePlatform"))
    assert(islands.Deserto.Content.Deserto:FindFirstChild("RuinasSoterradas"))
    assert(islands.Vulcanica.Content.Vulcanica:FindFirstChild("CraterLava"))
    assert(root:GetAttribute("TravelMode") == "ServerTeleportPrototype")
    print("Latunia engine inspection: PASS · "..parts.." parts. Playable QA is separate.")
end
