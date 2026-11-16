-- Manual Studio SERVER spec. ModuleScript only: never runs on startup or grants progress.
-- Command bar while playing:
-- require(game.ServerScriptService.Mythragon.Dragons["Varkhion.engine.spec"])()
local RunService = game:GetService("RunService")
local Varkhion = require(script.Parent.Varkhion)

return function()
    assert(RunService:IsStudio() and RunService:IsServer(), "Run in a Studio server session")
    local fixture = Instance.new("Folder")
    fixture.Name = "VarkhionSpecFixture"
    fixture.Parent = workspace
    local anchor = Instance.new("Part")
    anchor.Name = "VarkhionAnchor"
    anchor.Anchored = true
    anchor.CanCollide = false
    anchor.Transparency = 1
    anchor.CFrame = CFrame.new(300, 200, 300) * CFrame.Angles(0, math.rad(37), 0)
    anchor.Parent = fixture

    local ok, err = xpcall(function()
        local function noProgress()
            error("Engine geometry spec must not interact or grant progress")
        end
        local controller = Varkhion.mount(fixture, anchor, noProgress)
        assert(Varkhion.mount(fixture, anchor, function() end) == controller,
            "Repeated mount must not duplicate or replace callback")
        assert(controller.onInteracted == noProgress)
        assert(#fixture:GetChildren() == 2, "One anchor and one dragon")
        local partCount, eyes, wings, marks = 0, 0, 0, 0
        for _, value in ipairs(controller.model:GetDescendants()) do
            assert(not value:IsA("LuaSourceContainer"), "No executable objects inside model")
            if value:IsA("BasePart") then
                partCount += 1
                assert(value.Anchored and not value.CanCollide and not value.CanTouch
                    and not value.CanQuery, "Presentation geometry must be inert")
                if value.Name == "VioletEye" then eyes += 1 end
                if value.Name == "ShadowWingMembrane" then wings += 1 end
                if value.Name == "EtherChestMark" then marks += 1 end
            end
        end
        assert(partCount >= 20 and partCount <= 120, "Bound the provisional geometry budget")
        assert(eyes == 2 and wings == 2 and marks == 6, "Varkhion identity")
        local _, size = controller.model:GetBoundingBox()
        assert(size.X <= 36 and size.Y <= 18 and size.Z <= 34, "Fit the sanctuary contract")
        local expected = anchor.CFrame:PointToWorldSpace(Vector3.new(0, 3, -10))
        assert((controller.point.Position - expected).Magnitude < 0.01, "Respect rotated anchor")
        local prompt = controller.point:FindFirstChild("HearVarkhion")
        assert(prompt and prompt.ClickablePrompt and prompt.KeyboardKeyCode == Enum.KeyCode.E)
        assert(prompt.MaxActivationDistance == 12 and not prompt.RequiresLineOfSight)
        local otherAnchor = anchor:Clone()
        otherAnchor.Parent = fixture
        assert(not pcall(Varkhion.mount, fixture, otherAnchor, noProgress),
            "Reject another anchor on the same parent")
        otherAnchor:Destroy()
        controller:destroy()
        controller:destroy()
        assert(controller.destroyed and controller.model.Parent == nil)
        local rebuilt = Varkhion.mount(fixture, anchor, noProgress)
        anchor:Destroy()
        -- Explicit destroy is also safe if Destroying signals are deferred.
        rebuilt:destroy()
        assert(rebuilt.destroyed and rebuilt.model.Parent == nil)
    end, debug.traceback)
    fixture:Destroy()
    assert(ok, err)
    print("Varkhion engine geometry/lifecycle: PASS")
end
