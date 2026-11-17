local Policy = require("./FlightTravelPolicy")
assert(not Policy.isTeleport(0, 0.016, 45))
assert(not Policy.isTeleport(20, 0.1, 100))
assert(not Policy.isTeleport(150, 1, 100), "Frame hitch should not stop flight")
assert(Policy.isTeleport(650, 0.016, 100), "Island jump must end flight")
assert(Policy.isTeleport(2400, 0.016, 20), "Hub jump must end flight")
for _, bad in ipairs({-1, math.huge, 0/0}) do
    assert(Policy.isTeleport(bad, 0.016, 45), "Invalid displacement fails closed")
end
assert(Policy.isTeleport(1, -1, 45))
print("Owner flight teleport cleanup policy: PASS")
