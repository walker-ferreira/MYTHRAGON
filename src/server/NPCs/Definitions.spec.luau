local Definitions = require("./Definitions")
local characters = Definitions.characters
assert(#characters == 10, "Ten unique NPCs are required")
local seen = {}
local locations = { Central = true, Gelo = true, Deserto = true, Selva = true, Vulcanica = true }

for _, npc in ipairs(characters) do
    assert(type(npc.id) == "string" and #npc.id > 0 and not seen[npc.id], "Unique NPC identifier required")
    seen[npc.id] = true
    
    assert(locations[npc.home], "Home must match an existing Latunia island")
    
    assert(type(npc.name) == "string" and #npc.name > 0, "NPC name must be a non-empty string")
    assert(type(npc.role) == "string" and #npc.role > 0, "NPC role must be a non-empty string")
    
    assert(type(npc.visual) == "table", "Visual characteristics table required")
    assert(type(npc.visual.palette) == "string" and #npc.visual.palette > 0, "Visual palette must be specified")
    assert(type(npc.visual.silhouette) == "string" and #npc.visual.silhouette > 0, "Visual silhouette must be specified")
    
    assert(type(npc.goods) == "table" and #npc.goods >= 3, "At least 3 goods/items are required")
    for _, item in ipairs(npc.goods) do
        assert(type(item) == "string" and #item > 0, "Each item must be a valid non-empty string")
    end
    
    assert(type(npc.lines) == "table" and #npc.lines >= 3, "At least 3 dialogue lines are required")
    for _, line in ipairs(npc.lines) do
        assert(type(line) == "string" and #line > 12, "Dialogue line must be a string longer than 12 characters")
    end
    
    assert(type(npc.greeting) == "string" and #npc.greeting > 0, "Greeting must be a non-empty string")
    assert(type(npc.farewell) == "string" and #npc.farewell > 0, "Farewell must be a non-empty string")
end

print("Latunia NPC library tests: PASS (10 verified, unique IDs, names, islands, dialogues, items, and visual characteristics)")
