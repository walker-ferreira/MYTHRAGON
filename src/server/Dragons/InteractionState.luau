-- Pure rules. Distances/times are measured by the server adapter.
local State = {}
State.__index = State
State.MAX_DISTANCE = 12
State.COOLDOWN = 3

local function finite(value)
    return type(value) == "number" and value == value
        and value > -math.huge and value < math.huge
end

function State.new()
    return setmetatable({ players = {} }, State)
end

function State:begin(player, now, distance, alive)
    if not player or alive ~= true or not finite(now) or not finite(distance)
        or distance < 0 or distance > self.MAX_DISTANCE then
        return nil
    end
    local entry = self.players[player]
    if entry and (entry.pending or now - entry.last < self.COOLDOWN) then
        return nil
    end
    entry = { completed = entry and entry.completed or false, last = now, pending = true }
    self.players[player] = entry
    return entry, not entry.completed
end

function State:finish(player, ticket, success)
    -- A stale/yielding callback cannot revive disconnected-player state.
    if self.players[player] ~= ticket or not ticket.pending then
        return false
    end
    ticket.pending = false
    if success then ticket.completed = true end
    return true
end

function State:remove(player)
    self.players[player] = nil
end

function State:clear()
    table.clear(self.players)
end

return State
