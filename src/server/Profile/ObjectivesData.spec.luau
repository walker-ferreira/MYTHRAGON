local D = require("./ObjectivesData")
local seals = require("./ProgressData")
for _, id in ipairs({"guardioes", "santuario", "portal"}) do assert(D.allowed(id)) end
assert(not D.allowed("free_currency"))
local previous = seals.merge(nil, "Ember")
local step1 = D.merge(previous, "guardioes")
assert(step1.seals.Ember and D.read(step1).guardioes)
local step2 = D.merge(step1, "portal")
assert(D.read(step2).guardioes and D.read(step2).portal)
local step3 = seals.merge(step2, "Ember")
assert(step3.objectives.guardioes and step3.objectives.portal, "Seal write must preserve quests")
assert(not D.read(step3).santuario)
local future = { schema = 1, seals = { Ember = true }, objectives = { bonus = true } }
assert(D.merge(future, "santuario").objectives.bonus == true)
for _, bad in ipairs({ "broken", { schema = 5, objectives = {} },
    { schema = 1, objectives = "bad" }, { schema = 1, objectives = { portal = 1 } } }) do
    assert(not pcall(D.read, bad))
    assert(not pcall(D.merge, bad, "portal"))
end
assert(not pcall(D.merge, nil, "invalid"))
print("Hub ObjectivesData: PASS")
