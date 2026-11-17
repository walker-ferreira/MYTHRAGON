-- Pure targeting policy for the Ember breath telegraph.
-- Positions are measured by the server. Invalid coordinates fail closed.
local Pattern = {}
Pattern.MAX_OFFSET = 28
Pattern.HALF_WIDTH = 11

local function finite(v)
    return type(v) == "number" and v == v
        and v ~= math.huge and v ~= -math.huge
end

function Pattern.target(centerX, centerZ, playerX, playerZ)
    if not (finite(centerX) and finite(centerZ)
        and finite(playerX) and finite(playerZ)) then
        return nil
    end
    return math.clamp(playerX, centerX - Pattern.MAX_OFFSET, centerX + Pattern.MAX_OFFSET),
        math.clamp(playerZ, centerZ - Pattern.MAX_OFFSET, centerZ + Pattern.MAX_OFFSET)
end

function Pattern.hits(targetX, targetZ, playerX, playerZ, height)
    if not (finite(targetX) and finite(targetZ)
        and finite(playerX) and finite(playerZ) and finite(height)) then
        return false
    end
    return math.abs(playerX - targetX) <= Pattern.HALF_WIDTH
        and math.abs(playerZ - targetZ) <= Pattern.HALF_WIDTH
        and math.abs(height) <= 8
end

return Pattern
