-- Phase 1 exploratory scenery for the reserved Gelo/Selva slots.
-- Server-owned procedural builds. No quests, rewards, third-party assets or client trust.
-- Coordinates are LOCAL to the Layout island BuildAnchor supplied by Map.build.
local Build = require(script.Parent.Build)
local Expansion = {}

local function block(parent, name, anchor, offset, size, color, material, collide, shape)
    return Build.part(parent, name, size, anchor * CFrame.new(offset),
        color, material, collide, shape)
end

local function terrain(parent, anchor, name, tint, material)
    local land = Build.model(parent, name .. "Terrain")
    -- Solid contiguous squares: a safe collidable landing and walking surface.
    for x = -144, 144, 24 do
        for z = -144, 144, 24 do
            if x*x + z*z <= 150*150 then
                block(land, "Ground", anchor, Vector3.new(x, -9, z),
                    Vector3.new(24.2, 18, 24.2), tint, material)
            end
        end
    end
    -- Dock points are beyond the main disk; connect to the existing return prompts.
    return land
end

local function marker(parent, anchor, name, offset, caption, color)
    local sign = block(parent, name, anchor, offset, Vector3.new(4, 9, 3),
        color, Enum.Material.Slate)
    Build.label(sign, caption, Vector3.new(0, 9, 0), 155)
end

function Expansion.ice(parent, anchor)
    assert(typeof(anchor) == "CFrame", "Gelo requires layout anchor")
    local world = Build.model(parent, "Gelo")
    world:SetAttribute("ExplorationPhase", 1)
    local ice = Color3.fromRGB(184, 220, 233)
    local blue = Color3.fromRGB(92, 157, 196)
    terrain(world, anchor, "Frozen", ice, Enum.Material.Glacier)
    -- Arrival: (0,4,100). Trail reaches a visible glacier observatory.
    block(world, "FrozenDockApproach", anchor, Vector3.new(0, -1, 152),
        Vector3.new(22, 2, 118), ice, Enum.Material.Ice)
    block(world, "FrozenPier", anchor, Vector3.new(0, -1, 205),
        Vector3.new(24, 2, 26), Color3.fromRGB(91, 107, 121), Enum.Material.Slate)
    block(world, "IceTrail", anchor, Vector3.new(0, 0.3, 54),
        Vector3.new(14, 0.6, 116), blue, Enum.Material.Ice)
    for _, spec in ipairs({
        { -76, -41, 24 }, { -42, -68, 33 }, { 56, -70, 27 },
        { 94, 30, 19 }, { -102, 34, 22 }, { 70, 82, 18 },
    }) do
        block(world, "CrystalSpire", anchor,
            Vector3.new(spec[1], spec[3]/2, spec[2]),
            Vector3.new(10, spec[3], 10), blue, Enum.Material.Glass, true, "Wedge")
    end
    local lookout = block(world, "ObservatoryDeck", anchor, Vector3.new(0, 2, -60),
        Vector3.new(42, 4, 42), Color3.fromRGB(96, 117, 135), Enum.Material.Slate)
    for _, x in ipairs({-17,17}) do
        for _, z in ipairs({-17,17}) do
            block(world, "ObservatoryPillar", anchor, Vector3.new(x, 11, z),
                Vector3.new(3, 18, 3), blue, Enum.Material.Marble)
        end
    end
    block(world, "ObservatoryRoof", anchor, Vector3.new(0, 20, -60),
        Vector3.new(46, 3, 46), ice, Enum.Material.Ice)
    Build.label(lookout, "Observatório do Inverno\nExploração inicial · sem missão", Vector3.new(0, 18, 0), 170)
    marker(world, anchor, "FrozenDockMarker", Vector3.new(22, 4.5, 107),
        "ILHA DO GELO · siga até o observatório", blue)
    return world
end

function Expansion.jungle(parent, anchor)
    assert(typeof(anchor) == "CFrame", "Selva requires layout anchor")
    local world = Build.model(parent, "Selva")
    world:SetAttribute("ExplorationPhase", 1)
    local green = Color3.fromRGB(69, 122, 75)
    local dark = Color3.fromRGB(37, 78, 52)
    local bark = Color3.fromRGB(83, 66, 48)
    terrain(world, anchor, "Canopy", green, Enum.Material.Grass)
    -- Arrival: (100,4,0). East dock leads into the forest.
    block(world, "JunglePier", anchor, Vector3.new(205, -1, 0),
        Vector3.new(26, 2, 24), bark, Enum.Material.WoodPlanks)
    block(world, "JungleDockApproach", anchor, Vector3.new(155, -1, 0),
        Vector3.new(120, 2, 20), bark, Enum.Material.WoodPlanks)
    block(world, "CanopyPath", anchor, Vector3.new(38, 0.3, 0),
        Vector3.new(125, 0.6, 12), bark, Enum.Material.WoodPlanks)
    for _, row in ipairs({
        { -105,-85,23 }, { -91,62,19 }, { -64,-40,22 },
        { -26,102,23 }, { 30,-87,21 }, { 61,89,24 },
        { 101,51,18 }, { -123,12,20 }, { 9,58,21 },
    }) do
        local x,z,h = row[1],row[2],row[3]
        block(world, "AncientTrunk", anchor, Vector3.new(x, h/2, z),
            Vector3.new(5, h, 5), bark, Enum.Material.Wood)
        local top = block(world, "CanopyCrown", anchor, Vector3.new(x, h+4, z),
            Vector3.new(18, 13, 18), dark, Enum.Material.Grass, false, "Ball")
        top.Transparency = 0.1
    end
    local ruins = block(world, "TemplePlatform", anchor, Vector3.new(-75, 2, 0),
        Vector3.new(42, 4, 44), Color3.fromRGB(115, 124, 104), Enum.Material.Slate)
    for _, x in ipairs({-91,-59}) do
        for _, z in ipairs({-15,15}) do
            block(world, "TempleColumn", anchor, Vector3.new(x, 12, z),
                Vector3.new(4, 20, 4), Color3.fromRGB(133, 140, 109), Enum.Material.Slate)
        end
    end
    block(world, "TempleLintel", anchor, Vector3.new(-75, 22, 0),
        Vector3.new(41, 3, 7), Color3.fromRGB(133, 140, 109), Enum.Material.Slate)
    Build.label(ruins, "Ruínas da Copa Antiga\nExploração inicial · sem missão", Vector3.new(0, 19, 0), 170)
    marker(world, anchor, "JungleDockMarker", Vector3.new(107, 4.5, 19),
        "ILHA DA SELVA · siga até as ruínas", green)
    return world
end

return Expansion
