local Journey = require("./JourneyGuide")
local done = {}
local title, progress, total = Journey.next(done, false)
assert(total == 10 and progress == 0 and string.find(title, "Guardião"))
for _, id in ipairs({"guardioes", "santuario", "portal"}) do done[id] = true end
title, progress = Journey.next(done, false)
assert(progress == 3 and string.find(title, "selo"))
title, progress = Journey.next(done, true)
assert(progress == 4 and string.find(title, "Aetheria"))
done.retorno = true
title, progress = Journey.next(done, true)
assert(progress == 5 and string.find(title, "Vila"))
-- Later exploration out of order is recorded but does not skip story.
done.selva, done.gelo = true, true
title, progress = Journey.next(done, true)
assert(progress == 5 and string.find(title, "Vila"))
for _, id in ipairs({"latunia", "deserto", "vulcanica"}) do done[id] = true end
title, progress = Journey.next(done, true)
assert(progress == 10 and total == 10 and title == "Jornada de descoberta concluída!")
local other, otherProgress = Journey.next({}, false)
assert(otherProgress == 0, "Player progress must not leak across records")
print("Journey guide sequence: PASS")
