-- Pure per-player exploration UI state. This is not a source of rewards.
local State = {}
State.__index = State

State.order = {
    { id = "latunia", name = "Vila Central" },
    { id = "gelo", name = "Gelo" },
    { id = "deserto", name = "Deserto" },
    { id = "selva", name = "Selva" },
    { id = "vulcanica", name = "Vulcânica" },
}
local valid = {}
for _, entry in ipairs(State.order) do valid[entry.id] = true end

function State.new()
    return setmetatable({ visited = {}, total = 0 }, State)
end

function State:mark(id)
    if not valid[id] or self.visited[id] then return false end
    self.visited[id] = true
    self.total += 1
    return true
end

function State:hydrate(done)
    if type(done) ~= "table" then return end
    for _, entry in ipairs(State.order) do
        if done[entry.id] == true then self:mark(entry.id) end
    end
end

return State
