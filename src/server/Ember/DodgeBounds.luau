-- Pure server dodge landing check. Keep the whole player body on the
-- collidable rectangular arena instead of using a generous spherical radius.
local Bounds = {}
Bounds.EDGE_MARGIN = 3

local function finite(n)
    return type(n) == "number" and n == n
        and n ~= math.huge and n ~= -math.huge
end

function Bounds.inside(centerX, centerZ, targetX, targetZ, halfX, halfZ)
    if not (finite(centerX) and finite(centerZ)
        and finite(targetX) and finite(targetZ)
        and finite(halfX) and finite(halfZ)) then return false end
    if halfX <= Bounds.EDGE_MARGIN or halfZ <= Bounds.EDGE_MARGIN then
        return false
    end
    return math.abs(targetX - centerX) <= halfX - Bounds.EDGE_MARGIN
        and math.abs(targetZ - centerZ) <= halfZ - Bounds.EDGE_MARGIN
end

return Bounds
