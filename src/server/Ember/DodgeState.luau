-- Pure combat cooldown policy; tests run under standalone Luau.
local DodgeState = {}
DodgeState.__index = DodgeState
DodgeState.COOLDOWN = 3

function DodgeState.new()
    return setmetatable({ nextAllowed = -math.huge }, DodgeState)
end

function DodgeState:use(now)
    if type(now) ~= "number" or now ~= now or now == math.huge
        or now == -math.huge or now < self.nextAllowed then
        return false
    end
    self.nextAllowed = now + DodgeState.COOLDOWN
    return true
end

return DodgeState
