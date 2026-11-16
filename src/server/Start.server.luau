-- Composição da Fase 1. Editor exclusivo desta rodada: Codex.
-- Transferência autorizada pelo dono; resposta GLM-R003 em docs/agents/CODEX.md.
-- Hub continua com GLM. Preservar o contrato de vitória/retorno de Ember.

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

-- Varkhion (respostas VX-001/VX-002 em docs/agents/GLM.md): montagem
-- única, após a construção de Aetheria. O módulo do Codex vive em
-- src/server/Dragons (PR #6); enquanto a pasta não existir na árvore
-- integrada, o hub segue funcional sem o dragão.
local dragonsFolder = script.Parent:FindFirstChild("Dragons")
local hubModel = map:FindFirstChild("Hub")
local anchor = hubModel and hubModel:FindFirstChild("VarkhionAnchor")
if dragonsFolder then
	assert(anchor, "Aetheria must create Hub.VarkhionAnchor before mounting Varkhion")
	local Varkhion = require(dragonsFolder.Varkhion)
	Varkhion.mount(map, anchor, function(player, speciesId)
		assert(speciesId == "Varkhion", "Unexpected sanctuary species")
		-- VX-002: callback síncrono, sem yield e idempotente; conclui
		-- apenas o objetivo inicial do santuário. Nenhum selo ou posse.
		Hub.completeObjective(player, "santuario")
	end)
elseif not dragonsFolder then
	warn("[Start] pasta Dragons ausente: Varkhion nao montado (aguardando integracao do PR #6)")
end

Players.PlayerRemoving:Connect(function(player)
	Profile.clearSession(player)
end)

-- Latúnia: protótipo separado, sem substituir Hub, Ember, spawn ou selos.
-- Editor desta integração: Codex, autorizado pelo dono para esta rodada.
local Latunia = require(script.Parent.Latunia.Codex.Map)
local latuniaOk, latuniaError = pcall(Latunia.build, workspace, returnToHub)
if not latuniaOk then
	warn("Latúnia não iniciou; Hub/Ember preservados: " .. tostring(latuniaError))
end
