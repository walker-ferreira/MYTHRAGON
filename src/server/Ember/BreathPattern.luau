-- Pure targeting policy for the Ember breath telegraph.
-- Positions are measured by the server. Invalid coordinates fail closed.
local Pattern = {}
Pattern.HALF_WIDTH = 11

local function finite(v)
    return type(v) == "number" and v == v
        and v ~= math.huge and v ~= -math.huge
end

function Pattern.target(centerX, centerZ, playerX, playerZ, arenaHalfX, arenaHalfZ)
    if not (finite(centerX) and finite(centerZ)
        and finite(playerX) and finite(playerZ)
        and finite(arenaHalfX) and finite(arenaHalfZ))
        or arenaHalfX < Pattern.HALF_WIDTH or arenaHalfZ < Pattern.HALF_WIDTH then
        return nil
    end
    local offsetX = arenaHalfX - Pattern.HALF_WIDTH
    local offsetZ = arenaHalfZ - Pattern.HALF_WIDTH
    return math.clamp(playerX, centerX - offsetX, centerX + offsetX),
        math.clamp(playerZ, centerZ - offsetZ, centerZ + offsetZ)
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
