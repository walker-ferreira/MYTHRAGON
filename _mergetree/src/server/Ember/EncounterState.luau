-- Pure server rules: callers supply server-measured time and distance, never client results.
local State = {}
State.__index = State

function State.new()
    return setmetatable({ result = "active", health = 100, lastAttack = -math.huge }, State)
end

function State:attack(now, distance)
    if self.result ~= "active" or distance > 13 or distance < 0
        or now - self.lastAttack < 0.65 then
        return false
    end
    self.lastAttack = now
    self.health = math.max(0, self.health - 20)
    if self.health == 0 then
        self.result = "victory"
    end
    return true
end

function State:finish(result)
    if self.result ~= "active" then
        return false
    end
    assert(result == "defeat" or result == "abandoned")
    self.result = result
    return true
end

return State
