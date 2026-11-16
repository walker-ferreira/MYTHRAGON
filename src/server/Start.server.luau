-- Composição da Fase 1. Editor exclusivo desta rodada: Codex.
-- Transferência autorizada pelo dono; resposta GLM-R003 em docs/agents/CODEX.md.
-- Hub continua com GLM. Preservar o contrato de vitória/retorno de Ember.

local Players = game:GetService("Players")

local Hub = require(script.Parent.Hub.Map)
local Ember = require(script.Parent.Ember.Map)
local Profile = require(script.Parent.Profile.Profile)
local Varkhion = require(script.Parent.Dragons.Varkhion)

local map = Instance.new("Folder")
map.Name = "MythragonMap"
map.Parent = workspace

-- Contrato confirmado com Ember (Sol, sol/ember-combate):
--   Ember.build(parent, onVictory(player, encounterId: string)) -> enter(player): boolean
--   connectReturn(parent, onReturn) permanece; Sol valida o fim do encontro.
-- onVictory é chamado apenas no servidor, uma emissão por vitória. O reino
-- é o escopo deste callback (Start liga um callback por reino), então o
-- perfil recebe "Ember" explicitamente e usa o encounterId para deduplicar.
local function onVictory(player, encounterId)
	local status, seal = Profile.recordVictory(player, "Ember", encounterId)
	if status == "granted" and seal then
		-- Painel individual: só este jogador vê o selo conquistado.
		Hub.setSealEarned(player, seal.index)
		Hub.notify(player, seal.title .. " conquistado!")
	elseif status == "duplicate" and seal and Profile.hasSeal(player, seal.id) then
		-- Selo já existe na sessão: painel segue a fonte de verdade (Profile).
		Hub.setSealEarned(player, seal.index)
	end
end

local enterEmber = Ember.build(map, onVictory)
local returnToHub = Hub.build(map, enterEmber)
Ember.connectReturn(map, returnToHub)

-- GLM-R001: o Hub cria o mount uma vez, orientado para leste (-Z local).
-- Completar santuario novamente retorna false: duplicata legítima, não erro.
local mount = assert(map.Hub:FindFirstChild("VarkhionMount"),
	"Aetheria must create Hub.VarkhionMount before mounting Varkhion")
Varkhion.mount(map.Hub, mount, function(player, speciesId)
	assert(speciesId == "Varkhion", "Unexpected sanctuary species")
	Hub.completeObjective(player, "santuario")
end)

Players.PlayerRemoving:Connect(function(player)
	Profile.clearSession(player)
end)
