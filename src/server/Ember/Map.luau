local Ember = {}
local arenaCenter = Vector3.new(0, 0, 150)

local function addFloatingPlatform(parent)
    local origin = arenaCenter + Vector3.new(17, 1, -5)

    local guide = Instance.new("Part")
    guide.Name = "LiftGuide"
    guide.Size = Vector3.one
    guide.Position = origin
    guide.Transparency = 1
    guide.CanCollide = false
    guide.CanTouch = false
    guide.CanQuery = false
    guide.Anchored = true
    guide.Parent = parent

    local platform = Instance.new("Part")
    platform.Name = "EmberFloatingPlatform"
    platform.Size = Vector3.new(10, 1.5, 10)
    platform.Position = origin
    platform.Material = Enum.Material.Neon
    platform.Color = Color3.fromRGB(255, 160, 58)
    platform.Parent = parent

    local railAttachment = Instance.new("Attachment")
    railAttachment.Axis = Vector3.yAxis
    railAttachment.SecondaryAxis = Vector3.xAxis
    railAttachment.Parent = guide

    local platformAttachment = railAttachment:Clone()
    platformAttachment.Parent = platform

    local lift = Instance.new("PrismaticConstraint")
    lift.Attachment0 = railAttachment
    lift.Attachment1 = platformAttachment
    lift.ActuatorType = Enum.ActuatorType.Servo
    lift.LimitsEnabled = true
    lift.LowerLimit = 0
    lift.UpperLimit = 12
    lift.Speed = 3
    lift.ServoMaxForce = 100000
    lift.Parent = guide
    platform:SetNetworkOwner(nil)

    task.spawn(function()
        while platform.Parent do
            lift.TargetPosition = 12
            task.wait(6)
            if not platform.Parent then
                break
            end
            lift.TargetPosition = 0
            task.wait(7)
        end
    end)
end

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

    addFloatingPlatform(model)

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
