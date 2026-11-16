-- SOMENTE STUDIO: progresso de teste desta rodada. Enquanto a concessão real
-- vem da vitória validada de Ember (sol/ember-combate), este script simula a
-- vitória alguns segundos após o jogador entrar para exercitar no Studio o
-- caminho inteiro: recordVictory idempotente -> Hub.setSealEarned(player) ->
-- painel individual + aviso por jogador. Não roda no jogo publicado
-- (RunService:IsStudio()); remover depois do piloto é seguro.

local RunService = game:GetService("RunService")
if not RunService:IsStudio() then
	return
end

local Players = game:GetService("Players")

local Profile = require(script.Parent.Profile)
local Hub = require(script.Parent.Parent.Hub.Map)

local DEMO_DELAY = 4

local function applyGranted(player, seal)
	if not seal then
		return
	end
	Hub.setSealEarned(player, seal.index)
	Hub.notify(player, seal.title .. " conquistado!")
end

local function runDemo(player)
	task.delay(DEMO_DELAY, function()
		if not player.Parent then
			return
		end
		local attemptId = "studio-demo-victory"
		print(("[StudioSealDemo] vitória simulada para %s"):format(player.Name))
		local status, seal = Profile.recordVictory(player, "Ember", attemptId)
		print(("[StudioSealDemo] 1ª concessão (esperado granted): %s"):format(status))
		if status == "granted" and seal then
			applyGranted(player, seal)
		end

		-- Repetição da mesma vitória/evento deve ser ignorada (idempotência).
		local repeatStatus, repeatSeal = Profile.recordVictory(player, "Ember", attemptId)
		print(("[StudioSealDemo] repetição (esperado duplicate): %s / %s")
			:format(repeatStatus, repeatSeal and repeatSeal.title or "-"))
	end)
end

Players.PlayerAdded:Connect(runDemo)
for _, player in Players:GetPlayers() do
	runDemo(player)
end
