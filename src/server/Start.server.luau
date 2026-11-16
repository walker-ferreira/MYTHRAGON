-- Montagem do mapa e ligação dos módulos.
-- Editor desta rodada (Fase 1): GLM 5.3 — registrado em docs/agents/GLM.md
-- (GLM-R003). Nenhuma ligação alterada: contrato Ember (Codex) e perfil
-- permanecem. O comentário da rodada anterior citava 0002 porque o
-- renumeração da decisão só aconteceu depois (registro 0003/0004).

local Players = game:GetService("Players")

local Hub = require(script.Parent.Hub.Map)
local Ember = require(script.Parent.Ember.Map)
local Profile = require(script.Parent.Profile.Profile)

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

Players.PlayerRemoving:Connect(function(player)
	Profile.clearSession(player)
end)
