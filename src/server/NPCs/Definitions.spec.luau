local Definitions = require("./Definitions")
local characters = Definitions.characters
assert(#characters == 10, "Ten unique NPCs are required")
local seen = {}
local locations = { Central = true, Gelo = true, Deserto = true, Selva = true, Vulcanica = true }
for _, npc in ipairs(characters) do
    assert(type(npc.id) == "string" and not seen[npc.id], "Unique NPC identifier")
    seen[npc.id] = true
    assert(locations[npc.home], "Home must match an existing Latunia island")
    assert(type(npc.name) == "string" and #npc.name > 0)
    assert(type(npc.role) == "string" and #npc.role > 0)
    assert(type(npc.visual) == "table" and type(npc.visual.palette) == "string"
        and type(npc.visual.silhouette) == "string")
    assert(type(npc.goods) == "table" and #npc.goods >= 3)
    assert(type(npc.lines) == "table" and #npc.lines >= 3)
    for _, line in ipairs(npc.lines) do
        assert(type(line) == "string" and #line > 12)
    end
    assert(type(npc.greeting) == "string" and type(npc.farewell) == "string")
end
print("Latunia NPC library: PASS (10 prepared, not spawned)")
