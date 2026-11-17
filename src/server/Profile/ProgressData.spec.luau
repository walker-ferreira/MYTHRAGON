local Data = require("./ProgressData")

local empty = Data.read(nil)
assert(empty.schema == 1 and empty.seals.Ember == nil)
local first = Data.merge(nil, "Ember")
assert(first.schema == 1 and first.seals.Ember == true)
local nextSave = Data.merge(first, "Ember")
assert(nextSave.seals.Ember, "Repeated wins stay idempotent")
local old = { schema = 1, seals = { Ember = true, Future = true }, inventory = { coins = 7 } }
local preserved = Data.merge(old, "Ember")
assert(preserved.inventory.coins == 7 and preserved.seals.Future, "Unknown future fields preserved")
assert(Data.read(preserved).seals.Ember, "Saved seal can be loaded")
assert(old.inventory.coins == 7, "No mutation of input record")
for _, bad in ipairs({ "bad", 6, { schema = 2, seals = {} },
    { schema = 1, seals = false }, { schema = 1, seals = { Ember = "true" } } }) do
    assert(not pcall(Data.read, bad), "Corrupt or newer schema must be rejected")
    assert(not pcall(Data.merge, bad, "Ember"), "Corrupt data must never be overwritten")
end
assert(not pcall(Data.merge, nil, "Unknown"), "Unknown seal not writable")
local legacyReturn = { schema = 1, objectives = { retorno = true, gelo = true } }
assert(Data.read(legacyReturn).seals.Ember, "A verified legacy return proves seal ownership")
assert(legacyReturn.seals == nil, "Reading old progress must not mutate the stored record")
assert(Data.read({ schema = 1, seals = { Ember = false }, objectives = { retorno = true } }).seals.Ember)
for _, objectives in ipairs({ { portal = true }, { gelo = true }, { retorno = false },
    { retorno = "true" }, { retorno = 1 }, "invalid" }) do
    assert(not Data.read({ schema = 1, objectives = objectives }).seals.Ember,
        "Unrelated or malformed progress cannot prove Ember seal ownership")
end
print("ProgressData merge/load policy: PASS")
