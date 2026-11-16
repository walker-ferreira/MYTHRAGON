local Ember = {}
local arenaCenter = Vector3.new(0, 0, 150)

function Ember.build(parent)
    local model = Instance.new("Model")
    model.Name = "Ember"
    model.Parent = parent

    local arena = Instance.new("Part")
    arena.Name = "BasaltArena"
    arena.Anchored = true
    arena.Size = Vector3.new(58, 2, 48)
    arena.Position = arenaCenter - Vector3.new(0, 1, 0)
    arena.Material = Enum.Material.Basalt
    arena.Color = Color3.fromRGB(70, 38, 32)
    arena.Parent = model

    local rim = Instance.new("Part")
    rim.Name = "LavaShelf"
    rim.Anchored = true
    rim.Size = Vector3.new(66, 1, 56)
    rim.Position = arenaCenter - Vector3.new(0, 2.5, 0)
    rim.Material = Enum.Material.Neon
    rim.Color = Color3.fromRGB(245, 72, 24)
    rim.Parent = model

    local pedestal = Instance.new("Part")
    pedestal.Name = "EncounterMarker"
    pedestal.Anchored = true
    pedestal.Size = Vector3.new(8, 1, 8)
    pedestal.Position = arenaCenter + Vector3.new(0, 0.5, 0)
    pedestal.Material = Enum.Material.CrackedLava
    pedestal.Parent = model

    return function(player)
        local character = player.Character
        if character then
            character:PivotTo(CFrame.new(arenaCenter + Vector3.new(0, 4, 12)))
        end
    end
end

function Ember.connectReturn(parent, onReturn)
    local portal = Instance.new("Part")
    portal.Name = "HubReturnPortal"
    portal.Anchored = true
    portal.Material = Enum.Material.Neon
    portal.Color = Color3.fromRGB(164, 114, 255)
    portal.Size = Vector3.new(7, 8, 1)
    portal.Position = arenaCenter + Vector3.new(0, 4, 20)
    portal.Parent = parent.Ember

    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Voltar"
    prompt.ObjectText = "Hub"
    prompt.Parent = portal
    prompt.Triggered:Connect(onReturn)
end

return Ember
