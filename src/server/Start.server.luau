-- Montagem do mapa piloto e ligação dos módulos.
-- Editor desta rodada: GLM 5.3 (autorizado pelo usuário para a integração
-- vitória -> perfil). Sol edita src/server/Ember/ e docs/decisions/0002.

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
		Hub.setSealEarned(map.Hub, seal.index)
		Hub.notifySealEarned(player, seal.title)
	end
end

local enterEmber = Ember.build(map, onVictory)
local returnToHub = Hub.build(map, enterEmber)
Ember.connectReturn(map, returnToHub)

Players.PlayerRemoving:Connect(function(player)
	Profile.clearSession(player)
end)
