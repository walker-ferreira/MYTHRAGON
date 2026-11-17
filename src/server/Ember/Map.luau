local Ember = {}
local Combat = require(script.Parent.Combat)
local arenaCenter = Vector3.new(0, 0, 150)
local encounters = setmetatable({}, { __mode = "k" })

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

-- Floating rock layers reinforce the island silhouette without changing arena physics.
local function buildIslandRock(parent)
    local rockLayers = {
        { Vector3.new(0, -10, 0), Vector3.new(55, 12, 43), 4 },
        { Vector3.new(-5, -14, 3), Vector3.new(40, 10, 34), -10 },
        { Vector3.new(4, -20, -3), Vector3.new(29, 10, 24), 14 },
        { Vector3.new(-1, -26, 2), Vector3.new(17, 9, 15), -12 },
        { Vector3.new(-20, -15, 7), Vector3.new(16, 14, 18), 26 },
        { Vector3.new(19, -14, -11), Vector3.new(16, 12, 19), -26 },
    }
    for index, layer in ipairs(rockLayers) do
        local rock = Instance.new("Part")
        rock.Name = "FloatingBasalt" .. index
        rock.Size = layer[2]
        rock.CFrame = CFrame.new(arenaCenter + layer[1])
            * CFrame.Angles(math.rad(layer[3] / 2), math.rad(layer[3]), math.rad(layer[3]))
        rock.Anchored = true
        rock.CanCollide = false
        rock.CanTouch = false
        rock.CanQuery = false
        rock.Material = Enum.Material.Basalt
        rock.Color = Color3.fromRGB(43 + index * 2, 37 + index, 41 + index)
        rock.Parent = parent
    end
end

function Ember.build(parent, onVictory)
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
    buildIslandRock(model)

    local pedestal = Instance.new("Part")
    pedestal.Name = "EncounterMarker"
    pedestal.Anchored = true
    pedestal.Size = Vector3.new(8, 1, 8)
    pedestal.Position = arenaCenter + Vector3.new(0, 0.5, 0)
    pedestal.Material = Enum.Material.CrackedLava
    pedestal.Parent = model

    addFloatingPlatform(model)

    -- Original basalt colonnade and broken arch; no imported assets or scripts.
    for index = 0, 9 do
        local angle = index * math.pi * 2 / 10
        local column = Instance.new("Part")
        column.Name = "RuinedBasaltColumn"
        column.Anchored = true
        column.Size = Vector3.new(3, 5 + index % 3 * 2, 3)
        column.Position = arenaCenter + Vector3.new(math.cos(angle) * 25,
            column.Size.Y / 2, math.sin(angle) * 21)
        column.Material = Enum.Material.Basalt
        column.Color = Color3.fromRGB(47, 43, 48)
        column.Parent = model
    end
    for _, side in ipairs({ -1, 1 }) do
        local lintel = Instance.new("Part")
        lintel.Name = "BrokenArch"
        lintel.Anchored = true
        lintel.Size = Vector3.new(7, 2, 3)
        lintel.CFrame = CFrame.new(arenaCenter + Vector3.new(side * 4, 8, -21))
            * CFrame.Angles(0, 0, math.rad(side * 12))
        lintel.Material = Enum.Material.Basalt
        lintel.Color = Color3.fromRGB(47, 43, 48)
        lintel.Parent = model
    end
    local encounter = Combat.new(model, arenaCenter, arena.Size / 2, onVictory)
    encounters[parent] = encounter
    local function enter(player)
        return encounter:enter(player)
    end
    local function leave(player)
        if encounter.session and encounter.session.player == player then
            encounter:close("abandoned")
        end
    end
    return enter, leave
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
    prompt.RequiresLineOfSight = false
    prompt.MaxActivationDistance = 10
    prompt.Parent = portal
    local encounter = assert(encounters[parent], "Build Ember before connecting return")
    encounter.onReturn = onReturn
    prompt.Triggered:Connect(function(player)
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if root and (root.Position - portal.Position).Magnitude <= 10 then
            encounter:returnPlayer(player)
        end
    end)
end

return Ember
