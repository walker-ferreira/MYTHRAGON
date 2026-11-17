local D = require("./ObjectivesData")
local seals = require("./ProgressData")
for _, id in ipairs({"guardioes", "santuario", "portal"}) do assert(D.allowed(id)) end
assert(D.allowed("latunia"), "First Central arrival must have a persistable objective ID")
assert(D.allowed("retorno") and not D.isExploration("retorno"),
    "Ember return must save without being counted as an island")
for _, island in ipairs({ "Central", "Gelo", "Deserto", "Selva", "Vulcanica" }) do
    local id = D.arrivalId(island)
    assert(D.allowed(id) and D.isExploration(id), "Island must use a valid exploration objective")
end
assert(D.arrivalId("Unknown") == nil and not D.isExploration("portal"))
assert(not D.allowed("free_currency"))
local previous = seals.merge(nil, "Ember")
local step1 = D.merge(previous, "guardioes")
assert(step1.seals.Ember and D.read(step1).guardioes)
local step2 = D.merge(step1, "portal")
assert(D.read(step2).guardioes and D.read(step2).portal)
local step3 = seals.merge(step2, "Ember")
assert(step3.objectives.guardioes and step3.objectives.portal, "Seal write must preserve quests")
assert(not D.read(step3).santuario)
local returned = D.merge(step3, "retorno")
assert(D.read(returned).retorno and returned.seals.Ember, "Ember return persists with seal")
assert(D.read(D.merge(returned, "retorno")).retorno, "Return must be idempotent")
local arrived = D.merge(returned, "latunia")
assert(D.read(arrived).latunia and arrived.seals.Ember == true)
assert(D.read(D.merge(arrived, "latunia")).latunia, "Return visit must remain idempotent")
assert(D.read(arrived).portal and D.read(arrived).guardioes, "Arrival cannot erase Hub objectives")
local explored = arrived
for _, island in ipairs({ "Gelo", "Deserto", "Selva", "Vulcanica" }) do
    explored = D.merge(explored, D.arrivalId(island))
end
for _, island in ipairs({ "Central", "Gelo", "Deserto", "Selva", "Vulcanica" }) do
    assert(D.read(explored)[D.arrivalId(island)], "Island discovery persisted")
end
assert(explored.seals.Ember and D.read(explored).portal, "Exploration must preserve earlier progress")
local future = { schema = 1, seals = { Ember = true }, objectives = { bonus = true } }
assert(D.merge(future, "santuario").objectives.bonus == true)
for _, bad in ipairs({ "broken", { schema = 5, objectives = {} },
    { schema = 1, objectives = "bad" }, { schema = 1, objectives = { portal = 1 } } }) do
    assert(not pcall(D.read, bad))
    assert(not pcall(D.merge, bad, "portal"))
end
assert(not pcall(D.merge, nil, "invalid"))
local batch = { gelo = true, retorno = true, portal = true }
local merged = D.mergeMany(future, batch)
assert(merged.seals.Ember and merged.objectives.bonus)
assert(merged.objectives.gelo and merged.objectives.retorno and merged.objectives.portal)
assert(future.objectives.gelo == nil and future.objectives.portal == nil)
assert(not pcall(D.mergeMany, future, { portal = true, invalid = true }))
local beforeSealWrite = { schema = 1, seals = { Legacy = true }, objectives = { gelo = true } }
local returnFirst = D.mergeMany(beforeSealWrite, { retorno = true, latunia = true })
assert(returnFirst.seals.Ember, "Return write must persist Ember before a separate seal write")
assert(returnFirst.seals.Legacy and returnFirst.objectives.retorno)
assert(returnFirst.objectives.gelo and returnFirst.objectives.latunia)
assert(beforeSealWrite.seals.Ember == nil and beforeSealWrite.objectives.retorno == nil)
assert(D.merge(nil, "gelo").seals.Ember == nil, "Island discovery cannot persist the Ember seal")
print("Journey ObjectivesData: PASS")
