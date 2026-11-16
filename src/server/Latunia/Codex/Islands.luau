local B = require(script.Parent.Build)
local Layout = require(script.Parent.Layout)
local Islands = {}
local C = B.colors

local function localPart(parent, origin, name, size, p, color, mat, collide, shape, rotation)
    return B.part(parent, name, size, CFrame.new(origin+p) * (rotation or CFrame.identity),
        color, mat, collide, shape)
end

local function ground(parent, origin, kind)
    for x = -192, 192, 24 do
        for z = -168, 168, 24 do
            if Layout.isLand(x, z) then
                local canyon = kind == "Deserto" and Layout.inCanyon(x, z)
                local top = canyon and -18 or (kind == "Vulcanica" and 8 or 0)
                local color = kind == "Deserto" and (canyon and C.rust or C.sand) or C.basalt
                localPart(parent, origin, canyon and "CanyonBed" or "CoastalRock",
                    Vector3.new(24, 22, 24), Vector3.new(x, top-11, z),
                    color, kind == "Deserto" and Enum.Material.Sandstone or Enum.Material.Basalt)
            end
        end
    end
end

local function railway(parent, origin, points)
    for i = 1, #points-1 do
        local a, b = origin+points[i], origin+points[i+1]
        local direction = (b-a).Unit
        local right = direction:Cross(Vector3.yAxis).Unit
        for _, side in ipairs({ -1, 1 }) do
            B.beam(parent, "DuneRail", a+right*side*3, b+right*side*3,
                0.35, 0.35, C.iron, false)
        end
        local count = math.ceil((b-a).Magnitude/5)
        for k = 0, count do
            B.part(parent, "RailSleeper", Vector3.new(9, 0.4, 1.1),
                CFrame.lookAt(a:Lerp(b, k/count)-Vector3.new(0, 0.3, 0), b+direction),
                C.rust, Enum.Material.Metal, false)
        end
    end
end

local function windmill(parent, origin, p)
    local base = origin+p
    localPart(parent, origin, "MetalWindmill", Vector3.new(3, 29, 3),
        p+Vector3.new(0, 14.5, 0), C.iron)
    local center = base+Vector3.new(0, 29, -2)
    B.part(parent, "RotorHub", Vector3.new(3, 3, 2), CFrame.new(center), C.brass, nil, false)
    for i = 0, 7 do
        local angle = i*math.pi/4
        local cf = CFrame.new(center)*CFrame.Angles(0, 0, angle)*CFrame.new(0, 6, 0)
        B.part(parent, "WindBlade", Vector3.new(2.4, 8, 0.5), cf, C.zinc, nil, false)
    end
end

function Islands.desert(parent, origin)
    local m = B.model(parent, "Deserto")
    ground(m, origin, "Deserto")
    -- Walkable iron span over a real 18-stud depression, not a painted canyon.
    B.bridge(m, origin+Vector3.new(-74, 1.4, 0), origin+Vector3.new(61, 1.4, 0), 18)
    B.stairs(m, origin+Vector3.new(0, 1, 6), origin+Vector3.new(0, -17, 110), 10)
    railway(m, origin, {
        Vector3.new(-150, 2.5, 0), Vector3.new(-74, 2.5, 0),
        Vector3.new(61, 2.5, 0), Vector3.new(84, 2.5, -54),
        Vector3.new(124, 2.5, -25), Vector3.new(124, 2.5, 72),
    })
    for _, spec in ipairs({
        { -126, -86, 0.3 }, { 111, -116, -0.4 }, { -87, 108, 0.65 },
    }) do
        localPart(m, origin, "SandDune", Vector3.new(58, 11, 36),
            Vector3.new(spec[1], 4, spec[2]), C.sand, Enum.Material.Sand, true, "Wedge",
            CFrame.Angles(0, spec[3], 0))
    end
    for _, p in ipairs({ Vector3.new(-103, 0, -48), Vector3.new(130, 0, -90),
        Vector3.new(-115, 0, 102) }) do
        windmill(m, origin, p)
    end
    -- Mine facade with an actual open passage, sandstone hill behind it.
    for _, side in ipairs({ -1, 1 }) do
        localPart(m, origin, "IronMinePortal", Vector3.new(4, 20, 8),
            Vector3.new(84+side*10, 10, -63), C.iron)
    end
    local mineSign = localPart(m, origin, "MineLintel", Vector3.new(25, 4, 8),
        Vector3.new(84, 22, -63), C.copper)
    B.label(mineSign, "2 · Mina Ferrugem")
    localPart(m, origin, "FerruginousHill", Vector3.new(56, 28, 24),
        Vector3.new(88, 9, -88), C.rust, Enum.Material.Sandstone, true, "Wedge")
    for _, side in ipairs({ -1, 1 }) do
        localPart(m, origin, "WindingTower", Vector3.new(2, 42, 2),
            Vector3.new(108+side*8, 21, -70), C.iron)
    end
    B.pipe(m, origin+Vector3.new(100, 40, -70), origin+Vector3.new(116, 40, -70), 2.2)
    B.factory(m, origin+Vector3.new(113, 0, 49), "3 · Refinaria de Cobre", false)
    B.pipe(m, origin+Vector3.new(68, 21, 40), origin+Vector3.new(68, 21, -40), 1.5)
    B.pipe(m, origin+Vector3.new(68, 21, 40), origin+Vector3.new(83, 21, 40), 1.5)
    local ruins = B.model(m, "RuinasSoterradas")
    for _, spec in ipairs({ { -116, 7, 82 }, { -86, 4, 81 }, { -105, 2, 109 } }) do
        localPart(ruins, origin, "BuriedPillar", Vector3.new(5, spec[2]*2, 5),
            Vector3.new(spec[1], spec[2], spec[3]), C.brass, Enum.Material.Sandstone)
    end
    local lintel = localPart(ruins, origin, "BrokenAncientArch", Vector3.new(29, 4, 7),
        Vector3.new(-102, 13, 82), C.rust, Enum.Material.Sandstone,
        true, nil, CFrame.Angles(0, 0, 0.14))
    B.label(lintel, "5 · Ruínas Soterradas")
    for _, p in ipairs({ Vector3.new(-135, 0, -9), Vector3.new(-65, 1, 10),
        Vector3.new(63, 1, 10), Vector3.new(124, 0, 83) }) do B.lamp(m, origin+p) end
    local railSign = localPart(m, origin, "RailwayPlaque", Vector3.new(4, 5, 1),
        Vector3.new(-91, 4, 13), C.brass)
    B.label(railSign, "4 · Ferrovia das Dunas\nLinha estática: mina → refinaria")
    return m
end

function Islands.volcanic(parent, origin)
    local m = B.model(parent, "Vulcanica")
    ground(m, origin, "Vulcanica")
    local center = Vector3.new(-25, 0, -25)
    for _, ring in ipairs({ { 94, 16 }, { 78, 28 }, { 63, 40 }, { 47, 53 } }) do
        for i = 0, 23 do
            local angle = i*math.pi/12
            local p = origin+center+Vector3.new(math.cos(angle)*ring[1], ring[2]/2-3,
                math.sin(angle)*ring[1])
            B.part(m, "BasaltTerrace", Vector3.new(2*ring[1]*math.sin(math.pi/24)+1,
                ring[2]+6, 17), CFrame.lookAt(p, Vector3.new(origin.X+center.X, p.Y, origin.Z+center.Z)),
                C.basalt, Enum.Material.Basalt)
        end
    end
    local lavaColor = Color3.fromRGB(255, 108, 30)
    local pool = localPart(m, origin, "CraterLava", Vector3.new(1, 78, 78),
        center+Vector3.new(0, 36, 0), lavaColor, Enum.Material.Neon, false, "Cylinder",
        CFrame.Angles(0, 0, math.pi/2))
    B.label(pool, "Lava cenográfica neste protótipo", Vector3.new(0, 8, 0), 100)
    local rivers = {
        { center+Vector3.new(25, 36, 0), Vector3.new(28, 30, 18),
            Vector3.new(59, 20, 68), Vector3.new(20, 8.7, 121), Vector3.new(2, 8.7, 157) },
        { center+Vector3.new(-25, 36, 0), Vector3.new(-87, 23, 47),
            Vector3.new(-104, 8.7, 100), Vector3.new(-144, 8.7, 127) },
    }
    for _, points in ipairs(rivers) do
        for i = 1, #points-1 do
            B.beam(m, "LavaChannelBed", origin+points[i], origin+points[i+1], 15, 2, C.iron, false)
            local flow = B.beam(m, "LavaRiver", origin+points[i]+Vector3.new(0, 1, 0),
                origin+points[i+1]+Vector3.new(0, 1, 0), 10, 1, lavaColor, false)
            flow.Material = Enum.Material.Neon
        end
    end
    -- Continuous stair itinerary from the NE dock to the forge platform.
    local itinerary = {
        Vector3.new(100, 9, -85), Vector3.new(116, 9, -20),
        Vector3.new(98, 23, 48), Vector3.new(25, 37, 66),
        Vector3.new(-70, 54, 54), Vector3.new(-108, 54, 5),
    }
    for i = 1, #itinerary-1 do
        B.stairs(m, origin+itinerary[i], origin+itinerary[i+1], 16)
    end
    B.bridge(m, origin+Vector3.new(-108, 54, 5), origin+Vector3.new(-108, 54, -35), 16, 65)
    local forgeBase = origin+Vector3.new(-108, 54, -23)
    localPart(m, origin, "ForgePlatform", Vector3.new(82, 3, 70),
        Vector3.new(-108, 52, -23), C.iron)
    B.factory(m, forgeBase, "2 · Forja da Cratera", true)
    B.bridge(m, origin+Vector3.new(25, 37, 66), origin+Vector3.new(115, 37, 38), 16, 48)
    local bridgePlaque = localPart(m, origin, "ObsidianPlaque", Vector3.new(4, 5, 1),
        Vector3.new(30, 40, 75), C.brass)
    B.label(bridgePlaque, "3 · Ponte de Obsidiana\nSuportes e guarda-corpos de ferro")
    localPart(m, origin, "BoilerPlatform", Vector3.new(66, 3, 52),
        Vector3.new(121, 34, 21), C.iron)
    for x = 102, 138, 18 do
        B.tank(m, origin+Vector3.new(x, 36, 15), 7, 22, true)
    end
    local boilerSign = localPart(m, origin, "BoilerPlaque", Vector3.new(4, 5, 1),
        Vector3.new(121, 39, 45), C.brass)
    B.label(boilerSign, "4 · Caldeiras de Lava")
    B.stairs(m, origin+Vector3.new(115, 37, 45), origin+Vector3.new(128, 10, 116), 17)
    localPart(m, origin, "FoundryFoundation", Vector3.new(72, 20, 58),
        Vector3.new(89, -1.2, 117), C.basalt, Enum.Material.Basalt)
    B.factory(m, origin+Vector3.new(89, 8.8, 117), "5 · Fundição do Sul", true)
    B.pipe(m, origin+Vector3.new(137, 40, 27), origin+Vector3.new(137, 40, 110), 1.8)
    B.pipe(m, origin+Vector3.new(137, 40, 110), origin+Vector3.new(111, 40, 110), 1.8)
    for _, p in ipairs({ Vector3.new(100, 8, -96), Vector3.new(111, 23, 42),
        Vector3.new(-91, 54, 38), Vector3.new(128, 10, 126) }) do B.lamp(m, origin+p) end
    return m
end

return Islands
