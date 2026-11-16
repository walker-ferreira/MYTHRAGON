-- Original native geometry. No meshes, textures, animations or executable assets imported.
local Model = {}
local BLACK = Color3.fromRGB(16, 16, 24)
local SCALE = Color3.fromRGB(36, 32, 48)
local MEMBRANE = Color3.fromRGB(39, 19, 57)
local HORN = Color3.fromRGB(77, 65, 91)
local ETHER = Color3.fromRGB(166, 83, 255)

function Model.build(parent, origin)
    assert(not parent:FindFirstChild("Varkhion"), "Varkhion model already exists")
    local dragon = Instance.new("Model")
    dragon.Name = "Varkhion"
    dragon:SetAttribute("SpeciesId", "Varkhion")
    dragon:SetAttribute("Elements", "Ether,Darkness")
    dragon:SetAttribute("ProvisionalModel", true)

    local function make(name, size, pose, color, shape)
        local p = Instance.new(shape == "Wedge" and "WedgePart" or "Part")
        p.Name = name
        p.Size = size
        p.CFrame = origin * pose
        p.Color = color
        p.Material = color == ETHER and Enum.Material.Neon or Enum.Material.Slate
        p.Anchored = true
        p.CanCollide = false
        p.CanTouch = false
        p.CanQuery = false
        if shape == "Ball" then p.Shape = Enum.PartType.Ball end
        p.Parent = dragon
        return p
    end

    local function bone(name, a, b, width, color)
        return make(name, Vector3.new(width, width, (b - a).Magnitude),
            CFrame.lookAt((a + b) / 2, b), color)
    end

    local body = make("BlackScaleTorso", Vector3.new(6, 6, 10),
        CFrame.new(0, 4, 1), BLACK, "Ball")
    dragon.PrimaryPart = body
    make("RaisedNeck", Vector3.new(3.8, 5.5, 4),
        CFrame.new(0, 6, -3.5) * CFrame.Angles(math.rad(25), 0, 0), BLACK, "Ball")
    make("CrownedHead", Vector3.new(4.2, 3.5, 5), CFrame.new(0, 7, -6), BLACK, "Ball")
    make("Muzzle", Vector3.new(3.1, 1.8, 3), CFrame.new(0, 6.5, -8.4), SCALE, "Ball")
    make("LowerJaw", Vector3.new(2.8, 0.45, 2.8), CFrame.new(0, 5.75, -8.3), HORN)

    for _, side in ipairs({ -1, 1 }) do
        make("VioletEye", Vector3.new(0.65, 0.5, 0.3),
            CFrame.new(side * 1.25, 7.3, -8.22), ETHER, "Ball")
        -- Split crescent crown: two swept horns and an inner Ether prong on each side.
        bone("AncientHornBase", Vector3.new(side * 1.3, 8, -5.7),
            Vector3.new(side * 2.3, 10.8, -4.3), 0.75, HORN)
        bone("AncientHornTip", Vector3.new(side * 2.3, 10.8, -4.3),
            Vector3.new(side * 2.8, 12, -5.6), 0.4, SCALE)
        bone("CrownEtherProng", Vector3.new(side * 1.1, 8.6, -5),
            Vector3.new(side * 1.3, 10.3, -5.2), 0.22, ETHER)

        for _, z in ipairs({ -1.7, 4 }) do
            make("Haunch", Vector3.new(2, 3.2, 2.7),
                CFrame.new(side * 2.8, 2.4, z), BLACK, "Ball")
            make("PlantedFoot", Vector3.new(2.4, 1, 3),
                CFrame.new(side * 3, 0.6, z - 0.5), SCALE)
            for toe = -1, 1 do
                make("Claw", Vector3.new(0.35, 0.35, 1.1),
                    CFrame.new(side * 3 + toe * 0.65, 0.35, z - 2), HORN, "Wedge")
            end
        end

        -- Two native wedge membranes plus readable leading-edge bones per wing.
        make("ShadowWingMembrane", Vector3.new(0.35, 8, 10),
            CFrame.new(side * 8, 7.3, 1) * CFrame.Angles(0, 0, math.rad(side * 68)),
            MEMBRANE, "Wedge")
        make("ShadowWingTip", Vector3.new(0.3, 5, 7),
            CFrame.new(side * 13, 8.2, 2.4) * CFrame.Angles(0, math.rad(side * 15),
                math.rad(side * 76)), MEMBRANE, "Wedge")
        local shoulder = Vector3.new(side * 2.3, 6.2, -1)
        local elbow = Vector3.new(side * 9, 10, -2)
        local tip = Vector3.new(side * 15, 9, 0.5)
        bone("WingArm", shoulder, elbow, 0.7, SCALE)
        bone("WingLeadingEdge", elbow, tip, 0.5, HORN)
        bone("WingFinger", elbow, Vector3.new(side * 11, 5.5, 6), 0.3, SCALE)
        bone("EtherWingVein", shoulder, Vector3.new(side * 12, 8.9, 1), 0.18, ETHER)
        for row = 0, 3 do
            make("LayeredBlackScale", Vector3.new(1.3, 0.5, 1.8),
                CFrame.new(side * 2.65, 5.2, -1 + row * 1.7)
                    * CFrame.Angles(0, 0, math.rad(side * 40)), SCALE, "Wedge")
        end
        for mark = 0, 2 do
            make("EtherChestMark", Vector3.new(0.18, 1.4, 0.22),
                CFrame.new(side * (0.65 + mark * 0.45), 5.3 + mark * 0.3, -3.3)
                    * CFrame.Angles(0, 0, math.rad(side * -30)), ETHER)
        end
    end

    for segment = 0, 5 do
        local width = 2.2 - segment * 0.3
        make("TaperedTail", Vector3.new(width, width, 2.5),
            CFrame.new(math.sin(segment * 0.5) * 2, 2.7 - segment * 0.32, 6 + segment * 1.7)
                * CFrame.Angles(0, math.rad(segment * 5), 0), BLACK, "Ball")
    end
    for plate = 0, 5 do
        make("DorsalScale", Vector3.new(0.7, 1.2, 1.3),
            CFrame.new(0, 7.1 - plate * 0.17, -1 + plate * 1.6), SCALE, "Wedge")
        make("EtherSpineRune", Vector3.new(0.2, 0.25, 0.8),
            CFrame.new(0, 7.7 - plate * 0.17, -1 + plate * 1.6), ETHER)
    end

    local light = Instance.new("PointLight")
    light.Name = "EtherAura"
    light.Color = ETHER
    light.Range = 13
    light.Brightness = 0.7
    light.Shadows = false
    light.Parent = body

    local interaction = make("InteractionPoint", Vector3.one, CFrame.new(0, 3, -10), BLACK)
    interaction.Transparency = 1
    local label = Instance.new("BillboardGui")
    label.Name = "Identity"
    label.Size = UDim2.fromOffset(270, 64)
    label.StudsOffsetWorldSpace = Vector3.new(0, 10, 0)
    label.MaxDistance = 70
    label.Parent = body
    local text = Instance.new("TextLabel")
    text.Size = UDim2.fromScale(1, 1)
    text.BackgroundTransparency = 0.25
    text.BackgroundColor3 = BLACK
    text.TextColor3 = Color3.fromRGB(223, 201, 255)
    text.TextScaled = true
    text.TextWrapped = true
    text.Text = "VARKHION\nLendário · Éter e Trevas"
    text.Parent = label

    dragon.Parent = parent
    return dragon, interaction
end
