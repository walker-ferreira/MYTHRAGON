-- Pure combat dodge policy; tests run under standalone Luau.
local DodgeState = {}
DodgeState.__index = DodgeState
DodgeState.COOLDOWN = 3
DodgeState.EVASION_WINDOW = 0.45

function DodgeState.new()
    return setmetatable({ nextAllowed = -math.huge, lastDodge = -math.huge }, DodgeState)
end

function DodgeState:canUse(now)
    return type(now) == "number" and now == now and now ~= math.huge
        and now ~= -math.huge and now >= self.nextAllowed
end

function DodgeState:use(now)
    if not self:canUse(now) then return false end
    self.lastDodge = now
    self.nextAllowed = now + DodgeState.COOLDOWN
    return true
end

function DodgeState:isEvading(now)
    return now >= self.lastDodge and now < self.lastDodge + DodgeState.EVASION_WINDOW
end

return DodgeState
