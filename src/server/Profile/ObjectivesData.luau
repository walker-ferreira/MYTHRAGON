-- Pure policy for journey objectives, stored in the
-- same record as the Ember seal via monotonic UpdateAsync merges.
local ProgressData = require("./ProgressData")
local ObjectivesData = {}
local arrivals = {
    Central = "latunia",
    Gelo = "gelo",
    Deserto = "deserto",
    Selva = "selva",
    Vulcanica = "vulcanica",
}
local allowed = {
    guardioes = true, santuario = true, portal = true, retorno = true,
    latunia = true, gelo = true, deserto = true, selva = true, vulcanica = true,
}

function ObjectivesData.arrivalId(islandId)
    return arrivals[islandId]
end

function ObjectivesData.isExploration(id)
    return id == "latunia" or id == "gelo" or id == "deserto"
        or id == "selva" or id == "vulcanica"
end

function ObjectivesData.allowed(id)
    return allowed[id] == true
end

function ObjectivesData.read(raw)
    ProgressData.read(raw) -- Validate schema/seals before reading a shared record.
    local done = if raw then raw.objectives else nil
    assert(done == nil or type(done) == "table", "Invalid objective record")
    local result = {}
    for id in pairs(allowed) do
        assert(done == nil or done[id] == nil or type(done[id]) == "boolean",
            "Invalid objective value " .. id)
        result[id] = done ~= nil and done[id] == true
    end
    return result
end

function ObjectivesData.mergeMany(raw, completed)
    ObjectivesData.read(raw) -- Never overwrite invalid or newer data.
    local out = {}
    if raw then for name, value in pairs(raw) do out[name] = value end end
    local objectives = {}
    if raw and raw.objectives then
        for name, done in pairs(raw.objectives) do objectives[name] = done end
    end
    for id in pairs(completed) do
        assert(allowed[id], "Unknown objective")
        objectives[id] = true
    end
    out.schema = 1
    out.objectives = objectives
    -- A server-validated Ember return proves that the player owns the seal.
    -- Persist both together even if the independent seal write has not finished.
    if completed.retorno then
        return ProgressData.merge(out, "Ember")
    end
    if not out.seals then out.seals = {} end
    return out
end

function ObjectivesData.merge(raw, id)
    return ObjectivesData.mergeMany(raw, { [id] = true })
end

return ObjectivesData
