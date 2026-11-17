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
local Workspace = game:GetService("Workspace")

local Layout = require(script.Parent.Parent.Latunia.Codex.Layout)

local function pos(t)
	return Vector3.new(t[1], t[2], t[3])
end

local origin = pos(Layout.origin)

local DESTINOS = {
	hub = CFrame.new(0, 5, 14),
}
for id, def in pairs(Layout.islands) do
	local islandOrigin = origin + Vector3.new(def.x, 0, def.z)
	local p = islandOrigin + pos(Layout.arrivals[id])
	DESTINOS[id:lower()] = CFrame.lookAt(p, Vector3.new(islandOrigin.X, p.Y, islandOrigin.Z))
end
DESTINOS.vila = DESTINOS.central

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
	if key ~= "hub" and not Workspace:FindFirstChild("LatuniaCodex") then
		notify(player, "Latúnia não está montada neste servidor.")
		return
	end
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root or not humanoid or humanoid.Health <= 0 or player.Character ~= character then
		return
	end
	character:PivotTo(destino + Vector3.new(0, 3, 0))
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
