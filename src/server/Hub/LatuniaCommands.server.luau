-- Comandos de teleporte de teste (Latúnia <-> Aetheria), pedidos pelo dono
-- ("tem algum comando de teleporte") e autorizados nesta sessão.
-- GLM 5.3, branch glm/latunia-commands · registro GLM-R008.
--
-- Uso no chat do jogo:
--   /ir hub        -> spawn do hub de Aetheria
--   /ir vila       -> Vila Central (chegada pelo cais sul)
--   /ir deserto    -> Ilha do Deserto
--   /ir vulcanica  -> Ilha Vulcânica
--   /ir gelo       -> Ilha do Gelo (landing provisório)
--   /ir selva      -> Ilha da Selva (landing provisório)
--   "!" no lugar de "/" também funciona (!ir vila), pois o chat do Roblox
--   pode interpretar comandos com barra antes de chegarem ao servidor.
--
-- Validação no servidor: personagem atual vivo, HumanoidRootPart presente.
-- Os destinos de Latúnia só funcionam se o arquipélago do Codex montou
-- (LatuniaCodex no workspace); os pontos vêm do próprio Layout dele
-- (Layout.origin + Layout.arrivals), então não duplicam geografia.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Map = require(script.Parent.Parent.Latunia.Codex.Map)

-- This command is for Studio tests only; published servers use validated
-- ProximityPrompt travel instead of free teleports.
if not RunService:IsStudio() then return end

local DESTINOS = {
    hub = "Hub", vila = "Central", central = "Central",
    gelo = "Gelo", selva = "Selva", deserto = "Deserto",
    vulcanica = "Vulcanica",
}

local function notify(player, message)
	local playerGui = player:FindFirstChildOfClass("PlayerGui")
	if not playerGui then
		return
	end
	local gui = Instance.new("ScreenGui")
	gui.Name = "LatuniaCommandNotice"
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 30
	local text = Instance.new("TextLabel")
	text.AnchorPoint = Vector2.new(0.5, 1)
	text.Position = UDim2.fromScale(0.5, 0.9)
	text.Size = UDim2.new(0.7, 0, 0, 34)
	text.BackgroundColor3 = Color3.fromRGB(24, 20, 24)
	text.BackgroundTransparency = 0.15
	text.TextColor3 = Color3.fromRGB(246, 225, 176)
	text.Font = Enum.Font.Garamond
	text.TextScaled = true
	text.TextWrapped = true
	text.Text = message
	text.Parent = gui
	local limit = Instance.new("UITextSizeConstraint")
	limit.MaxTextSize = 20
	limit.Parent = text
	gui.Parent = playerGui
	task.delay(4, function()
		gui:Destroy()
	end)
end

local function viajar(player, key)
    local destino = DESTINOS[key]
    if not destino then
        notify(player, "Destino desconhecido. Use: /ir hub · vila · deserto · vulcanica · gelo · selva")
        return
    end
    if not Map.debugWarp(workspace, player, destino) then
        notify(player, "Comando indisponível: confirme Latúnia READY e personagem vivo.")
    end
end

local function onChatted(player, message)
	local key = message:match("^/ir%s+([%a]+)") or message:match("^!ir%s+([%a]+)")
	if key then
		viajar(player, key:lower())
	end
end

Players.PlayerAdded:Connect(function(player)
	player.Chatted:Connect(function(message)
		onChatted(player, message)
	end)
end)
for _, player in ipairs(Players:GetPlayers()) do
	player.Chatted:Connect(function(message)
		onChatted(player, message)
	end)
end
