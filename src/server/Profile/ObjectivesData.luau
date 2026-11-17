-- Pure policy for the three existing Hub objectives, stored in the
-- same record as the Ember seal via monotonic UpdateAsync merges.
local ProgressData = require("./ProgressData")
local ObjectivesData = {}
local allowed = { guardioes = true, santuario = true, portal = true }

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

function ObjectivesData.merge(raw, id)
    assert(allowed[id], "Unknown objective")
    ObjectivesData.read(raw) -- Never overwrite invalid or newer data.
    local out = {}
    if raw then for name, value in pairs(raw) do out[name] = value end end
    local objectives = {}
    if raw and raw.objectives then
        for name, done in pairs(raw.objectives) do objectives[name] = done end
    end
    objectives[id] = true
    out.schema = 1
    out.objectives = objectives
    if not out.seals then out.seals = {} end
    return out
end

return ObjectivesData
