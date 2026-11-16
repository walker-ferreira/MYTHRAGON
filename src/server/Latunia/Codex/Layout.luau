-- Pure geography contract. Roblox north is -Z; no runtime dependencies.
local Layout = {}
Layout.origin = { 2400, 24, 0 }
Layout.spacing = 650
Layout.islands = {
    Central = { name = "Vila Central", x = 0, z = 0, floor = 0, editor = "GLM" },
    Gelo = { name = "Ilha do Gelo", x = 0, z = -650, floor = 0, editor = "GLM" },
    Deserto = { name = "Ilha do Deserto", x = 650, z = 0, floor = 0, editor = "Codex" },
    Selva = { name = "Ilha da Selva", x = -650, z = 0, floor = 0, editor = "GLM" },
    Vulcanica = { name = "Ilha Vulcânica", x = 0, z = 650, floor = 8, editor = "Codex" },
}
Layout.order = { "Central", "Gelo", "Deserto", "Selva", "Vulcanica" }
Layout.arrivals = {
    Central = { 0, 4, 44 }, Gelo = { 0, 4, 100 },
    Deserto = { -140, 4, 0 }, Selva = { 100, 4, 0 },
    Vulcanica = { 100, 12, -85 },
}
Layout.docks = {
    -- Central shore/end; island inner landing/outer mooring. All local X,Z.
    { id = "Gelo", central = { 0, -100, 0, -140 }, island = { 0, 105, 0, 205 } },
    { id = "Deserto", central = { 100, 0, 140, 0 }, island = { -140, 0, -220, 0 } },
    { id = "Selva", central = { -100, 0, -140, 0 }, island = { 105, 0, 205, 0 } },
    { id = "Vulcanica", central = { 0, 100, 0, 140 }, island = { 100, -85, 180, -175 } },
}

function Layout.isLand(x, z)
    local angle = math.atan2(z, x)
    return (x / 190) ^ 2 + (z / 175) ^ 2 <= 1 + 0.06 * math.sin(angle * 5)
end

function Layout.canyonX(z)
    return -10 + math.sin(z / 55) * 18
end

function Layout.inCanyon(x, z)
    return math.abs(x - Layout.canyonX(z)) < 24
end

function Layout.canTravel(from, to)
    if not Layout.islands[to] or not Layout.islands[from] then return false end
    return from ~= to and (from == "Central" or to == "Central")
end

return Layout
