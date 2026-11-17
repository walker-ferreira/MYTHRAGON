local Policy = require("./TravelMenuPolicy")
assert(Policy.destination("hub") == "Hub")
assert(Policy.destination("vila") == "Central")
assert(Policy.destination("central") == "Central")
for _, name in ipairs({ "gelo", "deserto", "selva", "vulcanica" }) do
    assert(Policy.destination(name) ~= nil)
end
for _, invalid in ipairs({ "Hub", "teleport", "Ember", "admin", "gelo;hub", "", string.rep("a", 100), 3, false }) do
    assert(Policy.destination(invalid) == nil)
end
print("Latunia public menu destination policy: PASS")
