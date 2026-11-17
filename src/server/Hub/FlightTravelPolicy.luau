-- Pure policy for cancelling developer flight after an external teleport.
-- A long-distance island transition should never leave PlatformStand active.
local Policy = {}

function Policy.isTeleport(distance, elapsed, speed)
    if type(distance) ~= "number" or type(elapsed) ~= "number"
        or type(speed) ~= "number" then return true end
    if distance ~= distance or elapsed ~= elapsed or speed ~= speed
        or distance == math.huge or elapsed == math.huge or speed == math.huge
        or distance < 0 or elapsed < 0 or speed < 0 then
        return true
    end
    -- Accommodate frame hitches and regular owner-controlled movement.
    -- Island portals move the character hundreds of studs instantaneously.
    return distance > 100 + (elapsed * speed * 2)
end

return Policy
