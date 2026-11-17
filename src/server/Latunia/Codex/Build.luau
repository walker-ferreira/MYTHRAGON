-- Native original geometry: no toolbox packages, imported scripts or external textures.
local B = {}
B.colors = {
    copper = Color3.fromRGB(151, 100, 59), brass = Color3.fromRGB(184, 145, 79),
    iron = Color3.fromRGB(45, 49, 47), zinc = Color3.fromRGB(106, 124, 122),
    amber = Color3.fromRGB(222, 169, 77), basalt = Color3.fromRGB(56, 56, 51),
    sand = Color3.fromRGB(198, 159, 103), rust = Color3.fromRGB(140, 79, 48),
}

function B.part(parent, name, size, cf, color, material, collide, shape)
    local p = Instance.new(shape == "Wedge" and "WedgePart" or "Part")
    p.Name, p.Size, p.CFrame = name, size, cf
    p.Color, p.Material = color, material or Enum.Material.Metal
    p.Anchored = true
    p.CanCollide = collide ~= false
    p.CanTouch = false
    if not p.CanCollide then p.CanQuery = false end
    if shape == "Ball" then p.Shape = Enum.PartType.Ball end
    if shape == "Cylinder" then p.Shape = Enum.PartType.Cylinder end
    p.Parent = parent
    return p
end

function B.model(parent, name)
    local m = Instance.new("Model")
    m.Name, m.Parent = name, parent
    return m
end

function B.label(parent, text, offset, distance)
    local gui = Instance.new("BillboardGui")
    gui.Name = "LandmarkSign"
    gui.Size = UDim2.fromOffset(190, 52)
    gui.StudsOffsetWorldSpace = offset or Vector3.new(0, 6, 0)
    gui.MaxDistance = math.min(distance or 130, 18)
    gui.Parent = parent
    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundColor3 = B.colors.iron
    label.BackgroundTransparency = 0.15
    label.TextColor3 = Color3.fromRGB(246, 225, 176)
    label.TextScaled, label.TextWrapped = true, true
    label.Font = Enum.Font.Garamond
    label.Text = text
    label.Parent = gui
    return gui
end

function B.beam(parent, name, a, b, width, height, color, collide)
    local length = (b - a).Magnitude
    assert(length > 0.01)
    return B.part(parent, name, Vector3.new(width, height, length),
        CFrame.lookAt((a + b) / 2, b), color, Enum.Material.Metal, collide)
end

function B.pipe(parent, a, b, radius, color)
    return B.part(parent, "CopperPipe", Vector3.new((b-a).Magnitude, radius*2, radius*2),
        CFrame.lookAt((a+b)/2, b) * CFrame.Angles(0, math.pi/2, 0),
        color or B.colors.copper, Enum.Material.Metal, false, "Cylinder")
end

function B.lamp(parent, position)
    B.part(parent, "GasLampPost", Vector3.new(0.6, 11, 0.6),
        CFrame.new(position + Vector3.new(0, 5.5, 0)), B.colors.iron)
    local glass = B.part(parent, "AmberLantern", Vector3.new(2, 2.8, 2),
        CFrame.new(position + Vector3.new(0, 11.8, 0)), B.colors.amber, Enum.Material.Glass, false)
    glass.Transparency = 0.25
    B.part(parent, "LanternCap", Vector3.new(2.7, 0.6, 2.7),
        CFrame.new(position + Vector3.new(0, 13.4, 0)), B.colors.brass, nil, false)
    local light = Instance.new("PointLight")
    light.Color, light.Range, light.Brightness = B.colors.amber, 19, 1.2
    light.Parent = glass
end

function B.tank(parent, position, radius, height, hot)
    local body = B.part(parent, "RivetedBoiler", Vector3.new(height, radius*2, radius*2),
        CFrame.new(position + Vector3.new(0, height/2, 0)) * CFrame.Angles(0, 0, math.pi/2),
        B.colors.copper, Enum.Material.Metal, true, "Cylinder")
    for _, y in ipairs({ 2, height-2 }) do
        B.part(parent, "BoilerBand", Vector3.new(1.2, radius*2+0.5, radius*2+0.5),
            CFrame.new(position + Vector3.new(0, y, 0)) * CFrame.Angles(0, 0, math.pi/2),
            B.colors.iron, Enum.Material.Metal, false, "Cylinder")
    end
    B.part(parent, "AmberGauge", Vector3.new(1.4, height*0.5, 0.7),
        CFrame.new(position + Vector3.new(0, height/2, -radius-0.3)),
        B.colors.amber, hot and Enum.Material.Neon or Enum.Material.Glass, false)
    return body
end

function B.chimney(parent, position, height)
    B.part(parent, "FactoryChimney", Vector3.new(5, height, 5),
        CFrame.new(position + Vector3.new(0, height/2, 0)), B.colors.iron, Enum.Material.CorrodedMetal)
    local top = B.part(parent, "ChimneyCap", Vector3.new(6, 1, 6),
        CFrame.new(position + Vector3.new(0, height, 0)), B.colors.brass)
    local smoke = Instance.new("ParticleEmitter")
    smoke.Texture = "rbxasset://textures/particles/smoke_main.dds"
    smoke.Rate, smoke.Lifetime, smoke.Speed = 2, NumberRange.new(3, 4), NumberRange.new(3, 5)
    smoke.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 3), NumberSequenceKeypoint.new(1, 10) })
    smoke.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.85), NumberSequenceKeypoint.new(1, 1) })
    smoke.Color = ColorSequence.new(Color3.fromRGB(150, 151, 139))
    smoke.Parent = top
end

function B.factory(parent, origin, name, hot)
    local m = B.model(parent, name)
    local function block(n, size, p, color, mat)
        return B.part(m, n, size, CFrame.new(origin+p), color, mat)
    end
    -- Hollow hall: front doorway remains 14 studs wide, not an opaque block.
    block("FactoryFloor", Vector3.new(64, 0.8, 48), Vector3.new(0, 0.4, 0), B.colors.basalt)
    block("BackWall", Vector3.new(64, 26, 2), Vector3.new(0, 13, -24), B.colors.copper)
    for _, side in ipairs({ -1, 1 }) do
        block("SideWall", Vector3.new(2, 26, 48), Vector3.new(side*32, 13, 0), B.colors.copper)
        block("DoorSide", Vector3.new(25, 26, 2), Vector3.new(side*19.5, 13, 24), B.colors.copper)
    end
    block("DoorLintel", Vector3.new(14, 7, 2), Vector3.new(0, 22.5, 24), B.colors.brass)
    block("ZincRoof", Vector3.new(68, 2, 53), Vector3.new(0, 27, 0), B.colors.zinc)
    for x = -28, 28, 7 do
        block("RoofSeam", Vector3.new(0.4, 0.4, 53), Vector3.new(x, 28.2, 0), B.colors.brass)
    end
    local sign = block("EntrancePlaque", Vector3.new(18, 2, 1), Vector3.new(0, 17.5, 25.2), B.colors.iron)
    B.label(sign, name, Vector3.new(0, 4, 0))
    B.tank(m, origin+Vector3.new(-20, 0.8, -10), 6, 14, hot)
    B.tank(m, origin+Vector3.new(-43, 0, -10), 8, 26, hot)
    B.chimney(m, origin+Vector3.new(20, 0, -30), hot and 64 or 48)
    B.pipe(m, origin+Vector3.new(-43, 20, -10), origin+Vector3.new(-20, 20, -10), 1.5)
    if hot then
        local forge = B.part(m, "ForgeHeat", Vector3.new(12, 8, 1),
            CFrame.new(origin+Vector3.new(16, 5, -22)), Color3.fromRGB(255, 133, 41), Enum.Material.Neon, false)
        local light = Instance.new("PointLight")
        light.Color, light.Range, light.Brightness = forge.Color, 24, 1.5
        light.Parent = forge
    end
    return m
end

function B.bridge(parent, a, b, width, supportDepth)
    local deck = B.beam(parent, "ObsidianWalkway", a, b, width or 14, 1.5, B.colors.iron, true)
    local direction = (b-a).Unit
    local right = direction:Cross(Vector3.yAxis).Unit
    for _, side in ipairs({ -1, 1 }) do
        B.beam(parent, "IronGuardRail", a+right*side*7+Vector3.new(0, 4, 0),
            b+right*side*7+Vector3.new(0, 4, 0), 0.6, 0.6, B.colors.brass, true)
    end
    for _, t in ipairs({ 0.1, 0.5, 0.9 }) do
        local p = a:Lerp(b, t)
        local depth = supportDepth or 20
        B.part(parent, "IronSupport", Vector3.new(2, depth, 2),
            CFrame.new(p-Vector3.new(0, depth/2, 0)), B.colors.iron)
    end
    return deck
end

function B.stairs(parent, a, b, width)
    local horizontal = Vector3.new(b.X-a.X, 0, b.Z-a.Z)
    assert(horizontal.Magnitude > 0)
    local count = math.max(1, math.ceil(math.abs(b.Y-a.Y)/0.8), math.ceil(horizontal.Magnitude/4))
    for i = 0, count do
        local p = a:Lerp(b, i/count)
        B.part(parent, "TerraceStep", Vector3.new(width, 1, horizontal.Magnitude/count+1),
            CFrame.lookAt(p, p+horizontal), B.colors.basalt, Enum.Material.Basalt)
    end
end

function B.dock(parent, a, b, text)
    B.bridge(parent, a, b, 16)
    local mast = B.part(parent, "AirshipMooring", Vector3.new(1.5, 25, 1.5),
        CFrame.new(b+Vector3.new(0, 12, 0)), B.colors.copper)
    B.label(mast, text.."\nE / toque · travessia rápida de teste", Vector3.new(0, 15, 0), 160)
    return B.part(parent, "BoardingPoint", Vector3.new(3, 3, 3),
        CFrame.new(b+Vector3.new(0, 3, 0)), B.colors.amber, Enum.Material.Neon, false)
end

return B
