-- Run with the standalone Luau CLI from this directory. Not executed by the map.
local State = require("./EncounterState")
local fight = State.new()
assert(not fight:attack(0, 14), "out of reach")
assert(fight:attack(0, 10))
assert(not fight:attack(0.1, 10), "server cooldown")
assert(not fight:attack(1, -1), "invalid distance")
for i = 1, 4 do
    assert(fight:attack(i, 10))
end
assert(fight.health == 0 and fight.result == "victory")
assert(not fight:attack(10, 1), "no duplicate victory")
assert(not fight:finish("defeat"), "terminal result immutable")
for _, result in ipairs({ "defeat", "abandoned" }) do
    local retry = State.new()
    assert(retry:finish(result))
    assert(not retry:attack(10, 1), "no reward after exit/death")
    assert(not retry:finish(result))
end
assert(State.new():attack(0, 13), "retry starts clean; inclusive reach")
print("Ember rules: PASS")
