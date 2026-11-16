local Hub = {}

function Hub.build(parent, onEnterEmber)
    local model = Instance.new("Model")
    model.Name = "Hub"
    model.Parent = parent

    local platform = Instance.new("Part")
    platform.Name = "HubPlatform"
    platform.Anchored = true
    platform.Size = Vector3.new(66, 2, 52)
    platform.Position = Vector3.new(0, -1, 0)
    platform.Material = Enum.Material.Slate
    platform.Color = Color3.fromRGB(52, 49, 78)
    platform.Parent = model

    local spawn = Instance.new("SpawnLocation")
    spawn.Name = "HubSpawn"
    spawn.Anchored = true
    spawn.Neutral = true
    spawn.Size = Vector3.new(8, 1, 8)
    spawn.Position = Vector3.new(0, 0.5, 14)
    spawn.Parent = model

    local sealColors = {
        Color3.fromRGB(255, 105, 44),
        Color3.fromRGB(75, 145, 255),
        Color3.fromRGB(74, 206, 140),
        Color3.fromRGB(180, 105, 255),
    }
    for index, color in ipairs(sealColors) do
        local seal = Instance.new("Part")
        seal.Name = "Seal" .. index
        seal.Shape = Enum.PartType.Ball
        seal.Anchored = true
        seal.Material = Enum.Material.Neon
        seal.Color = color
        seal.Size = Vector3.new(3, 3, 3)
        seal.Position = Vector3.new((index - 2.5) * 9, 2.5, -7)
        seal.Parent = model
    end

    local portal = Instance.new("Part")
    portal.Name = "EmberPortal"
    portal.Anchored = true
    portal.Material = Enum.Material.Neon
    portal.Color = sealColors[1]
    portal.Size = Vector3.new(7, 8, 1)
    portal.Position = Vector3.new(0, 4, -18)
    portal.Parent = model

    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Entrar"
    prompt.ObjectText = "Reino Ember"
    prompt.Parent = portal
    prompt.Triggered:Connect(onEnterEmber)

    return function(player)
        local character = player.Character
        if character then
            character:PivotTo(CFrame.new(spawn.Position + Vector3.new(0, 4, 0)))
        end
    end
end

return Hub
