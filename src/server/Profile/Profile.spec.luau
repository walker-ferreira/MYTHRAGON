-- Rodar com o CLI Luau standalone a partir desta pasta (mesmo padrão do
-- spec de Ember). Não é executado pelo mapa; a CI apenas compila.
-- O Player aqui é uma chave opaca (tabela com Name para o diagnóstico):
-- o módulo não usa API de runtime do Roblox; `Player` aparece só em
-- anotações de tipo, que são apagadas em tempo de execução.
local Profile = require("./Profile")

local function newPlayer(name)
	return { Name = name }
end

-- Registro do reino -> selo
local ember = Profile.sealForRealm("Ember")
assert(ember and ember.id == "Ember" and ember.index == 1
	and ember.title == "Selo de Ember", "reino Ember registrado")
assert(Profile.sealForRealm("ReinoInexistente") == nil, "reino desconhecido não tem selo")

local a = newPlayer("A")
local b = newPlayer("B")
local c = newPlayer("C")

-- 1) Dois jogadores, mesmo encounterId: sessões independentes.
local statusA, sealA = Profile.recordVictory(a, "Ember", "enc-1")
assert(statusA == "granted" and sealA.id == "Ember", "primeira vitória de A concede")
assert(Profile.hasSeal(a, "Ember"), "A tem o selo")
assert(not Profile.hasSeal(b, "Ember"), "B não herda o selo de A")
assert(Profile.recordVictory(b, "Ember", "enc-1") == "granted",
	"mesmo encounterId em outro jogador concede na sessão dele")
assert(Profile.hasSeal(b, "Ember"), "B tem o próprio selo")

-- 2) Mesmo encounterId reenviado: duplicate, sem segunda concessão.
assert(Profile.recordVictory(a, "Ember", "enc-1") == "duplicate",
	"mesma emissão duas vezes é duplicata")

-- 3) Encontros DIFERENTES do mesmo reino: selo já concedido -> duplicate.
assert(Profile.recordVictory(a, "Ember", "enc-2") == "duplicate",
	"segunda vitória do mesmo reino na sessão é duplicata")
assert(Profile.recordVictory(b, "Ember", "enc-3") == "duplicate",
	"outro encounterId com o selo já concedido é duplicata")

-- 4) Derrota/saída não chamam recordVictory: C nunca concede.
assert(not Profile.hasSeal(c, "Ember"), "derrota/saída não concedem (nenhuma chamada)")
assert(Profile.recordVictory(c, "ReinoInexistente", "enc-x") == "unknown",
	"reino desconhecido devolve unknown")
assert(not Profile.hasSeal(c, "Ember"), "unknown não concede")

-- Invalid encounter identifiers must never grant a seal or create a session reward.
local invalid = newPlayer("Invalid")
assert(Profile.recordVictory(invalid, "Ember", "") == "unknown")
assert(Profile.recordVictory(invalid, "Ember", nil) == "unknown")
assert(Profile.recordVictory(invalid, "Ember", 42) == "unknown")
assert(not Profile.hasSeal(invalid, "Ember"), "invalid victories cannot grant a seal")

-- 5) clearSession: sem persistência; sessão nova pode conquistar de novo.
Profile.clearSession(a)
assert(not Profile.hasSeal(a, "Ember"), "sessão limpa")
assert(Profile.recordVictory(a, "Ember", "enc-4") == "granted",
	"sessão nova pode conquistar de novo")

print("Profile rules: PASS")
