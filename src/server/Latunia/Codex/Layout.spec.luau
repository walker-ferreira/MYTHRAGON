local Layout = require("./Layout")
local Travel = require("./TravelState")
assert(Layout.islands.Gelo.z < 0 and Layout.islands.Vulcanica.z > 0)
assert(Layout.islands.Deserto.x > 0 and Layout.islands.Selva.x < 0)
assert(Layout.islands.Central.x == 0 and Layout.islands.Central.z == 0)
assert(#Layout.docks == 4)
local found = {}
for _, route in ipairs(Layout.docks) do
    assert(not found[route.id])
    found[route.id] = true
    assert(Layout.canTravel("Central", route.id))
    assert(Layout.canTravel(route.id, "Central"))
end
assert(not Layout.canTravel("Deserto", "Gelo"))
assert(not Layout.canTravel("Central", "Central"))
assert(not Layout.canTravel("Central", "unknown"))
assert(Layout.docks[2].island[3] < 0, "Desert dock west")
assert(Layout.docks[4].island[3] > 0 and Layout.docks[4].island[4] < 0, "Volcanic dock NE")
for _, id in ipairs(Layout.order) do
    local p = Layout.arrivals[id]
    assert(Layout.isLand(p[1], p[3]), "Arrival inside land envelope")
    if id == "Deserto" then assert(not Layout.inCanyon(p[1], p[3])) end
end
local state = Travel.new()
local a, b = {}, {}
assert(not state:begin(a, 0, 13, true))
assert(not state:begin(a, 0, 1, false))
assert(not state:begin(a, 0, 0/0, true))
local ticket = assert(state:begin(a, 0, 12, true))
assert(not state:begin(a, 9, 1, true), "No overlapping transitions")
assert(state:begin(b, 0, 1, true), "Players independent")
assert(state:finish(a, ticket))
assert(not state:begin(a, 2, 1, true))
local nextTicket = assert(state:begin(a, 3, 1, true))
assert(not state:finish(a, ticket), "Stale transition cannot finish a newer one")
state:remove(a)
assert(not state:finish(a, nextTicket), "Disconnect invalidates transition")
state:clear()
assert(next(state.entries) == nil)
print("Latunia geography and travel: PASS")
