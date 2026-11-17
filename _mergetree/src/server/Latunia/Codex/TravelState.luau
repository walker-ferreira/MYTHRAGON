-- Intent throttling only. Adapter must measure distance/alive/character on server.
local State = {}
State.__index = State

local function finite(n)
    return type(n) == "number" and n == n and math.abs(n) < math.huge
end

function State.new()
    return setmetatable({ entries = {} }, State)
end

function State:begin(player, now, distance, alive)
    if not player or not finite(now) or not finite(distance) or distance < 0
        or distance > 12 or not alive then return nil end
    local old = self.entries[player]
    if old and (old.busy or now - old.time < 3) then return nil end
    local ticket = { time = now, busy = true }
    self.entries[player] = ticket
    return ticket
end

function State:finish(player, ticket)
    if self.entries[player] ~= ticket or not ticket.busy then return false end
    ticket.busy = false
    return true
end

function State:remove(player)
    self.entries[player] = nil
end

function State:clear()
    table.clear(self.entries)
end

return State
