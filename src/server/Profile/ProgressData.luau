-- Pure persistent record policy; no Roblox services, networking or player state.
-- Schema v1 only persists server-validated realm seals.
local ProgressData = {}
ProgressData.VERSION = 1

function ProgressData.read(raw)
    if raw == nil then
        return { schema = 1, seals = {} }
    end
    assert(type(raw) == "table", "Saved progress is not a table")
    local version = raw.schema or 1
    assert(version == 1, "Unsupported saved progress schema")
    assert(raw.seals == nil or type(raw.seals) == "table", "Malformed saved seals")
    local seals = raw.seals or {}
    assert(seals.Ember == nil or type(seals.Ember) == "boolean", "Malformed Ember seal")
    -- Older servers could save the verified return before saving the seal.
    -- The return milestone has always required ownership of this seal.
    local objectives = raw.objectives
    local returnedFromEmber = type(objectives) == "table" and objectives.retorno == true
    return { schema = 1, seals = { Ember = seals.Ember == true or returnedFromEmber } }
end

-- UpdateAsync merge: never replace unrelated fields or erase an earned seal.
-- Reject unknown/corrupt schemas instead of resetting user data.
function ProgressData.merge(raw, confirmedSealId)
    assert(confirmedSealId == "Ember", "Unrecognized seal cannot be written")
    ProgressData.read(raw) -- Validate before writing, especially future schemas.
    local out = {}
    if raw then
        for key, value in pairs(raw) do out[key] = value end
    end
    out.schema = 1
    local seals = {}
    if raw and raw.seals then
        for id, owned in pairs(raw.seals) do seals[id] = owned end
    end
    seals[confirmedSealId] = true
    out.seals = seals
    return out
end

return ProgressData
