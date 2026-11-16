-- Hub: plataforma inicial, quatro selos visuais e portal seguro para Ember.
-- O portal só aceita o jogador no servidor: personagem vivo e dentro da
-- distância máxima do portal. O feedback de selo é por jogador (aviso no
-- PlayerGui) e o estado do selo no mundo é atualizado por sessão.

local Players = game:GetService("Players")

local Hub = {}

-- O ProximityPrompt já limita o gatilho a ~10 studs; o servidor reconfirma
-- com tolerância maior para absorver latência e movimento.
local PORTAL_MAX_DISTANCE = 16

local SEAL_TITLES = {
	"Selo de Ember",
	"Selo 2",
	"Selo 3",
	"Selo 4",
}

-- Marca o selo visual do hub como conquistado nesta sessão (uma única vez).
-- hubModel é o Model retornado por Hub.build dentro do parent informado.
function Hub.setSealEarned(hubModel, sealIndex)
	if not hubModel or hubModel.Parent == nil then
		return
	end
	local seal = hubModel:FindFirstChild("Seal" .. tostring(sealIndex))
	if not (seal and seal:IsA("BasePart")) then
		return
	end
	if seal:GetAttribute("Earned") then
		return
	end
	seal:SetAttribute("Earned", true)

	local tag = Instance.new("BillboardGui")
	tag.Name = "EarnedTag"
	tag.Size = UDim2.new(6, 0, 1.5, 0)
	tag.StudsOffsetWorldSpace = Vector3.new(0, 2.6, 0)
	tag.AlwaysOnTop = true
	tag.Parent = seal

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.TextSize = 18
	label.TextColor3 = Color3.fromRGB(255, 214, 90)
	label.TextStrokeTransparency = 0.4
	label.Text = "✓ " .. (SEAL_TITLES[sealIndex] or "Selo") .. " conquistado"
	label.Parent = tag
end

-- Feedback por jogador: aviso exclusivo no PlayerGui, sem tocar no cliente.
function Hub.notifySealEarned(player, title)
	Hub.notify(player, title .. " conquistado!")
end

-- Aviso genérico por jogador (PlayerGui é exclusivo de quem o recebe).
function Hub.notify(player, text)
	local playerGui = player:FindFirstChildOfClass("PlayerGui")
	if not playerGui then
		return
	end
	local gui = Instance.new("ScreenGui")
	gui.Name = "HubToast"
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 10
	gui.Parent = playerGui

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0, 300, 0, 44)
	label.Position = UDim2.new(0.5, -150, 0, 24)
	label.BackgroundColor3 = Color3.fromRGB(20, 16, 28)
	label.BackgroundTransparency = 0.25
	label.TextColor3 = Color3.fromRGB(255, 214, 90)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 17
	label.Text = text
	label.Parent = gui

	task.delay(4, function()
		gui:Destroy()
	end)
end

function Hub.build(parent, onEnterEmber)
	local model = Instance.new("Model")
	model.Name = "Hub"
	model.Parent = parent

	local platform = Instance.new("Part")
	platform.Name = "HubPlatform"
	platform.Anchored = true
	platform.Size = Vector3.new(66, 2, 52)
	platform.Position = Vector3.new(0, -1, 0)
	platform.Material = Enum.Material.Slate
	platform.Color = Color3.fromRGB(52, 49, 78)
	platform.Parent = model

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "HubSpawn"
	spawn.Anchored = true
	spawn.Neutral = true
	spawn.Size = Vector3.new(8, 1, 8)
	spawn.Position = Vector3.new(0, 0.5, 14)
	spawn.Parent = model

	local sealColors = {
		Color3.fromRGB(255, 105, 44),
		Color3.fromRGB(75, 145, 255),
		Color3.fromRGB(74, 206, 140),
		Color3.fromRGB(180, 105, 255),
	}
	for index, color in ipairs(sealColors) do
		local seal = Instance.new("Part")
		seal.Name = "Seal" .. index
		seal.Shape = Enum.PartType.Ball
		seal.Anchored = true
		seal.Material = Enum.Material.Neon
		seal.Color = color
		seal.Size = Vector3.new(3, 3, 3)
		seal.Position = Vector3.new((index - 2.5) * 9, 2.5, -7)
		seal.Parent = model
	end

	local portal = Instance.new("Part")
	portal.Name = "EmberPortal"
	portal.Anchored = true
	portal.Material = Enum.Material.Neon
	portal.Color = sealColors[1]
	portal.Size = Vector3.new(7, 8, 1)
	portal.Position = Vector3.new(0, 4, -18)
	portal.Parent = model

	-- Travessia por jogador: evita reentrada durante a viagem e limpa ao
	-- retornar ou renascer (morte dentro de Ember volta ao spawn do hub).
	local inTransit = {}
	local transitConns = {}

	local function releaseTransit(player)
		inTransit[player] = nil
		local conn = transitConns[player]
		if conn then
			conn:Disconnect()
			transitConns[player] = nil
		end
	end

	Players.PlayerRemoving:Connect(function(player)
		releaseTransit(player)
	end)

	local function markInTransit(player)
		inTransit[player] = true
		local conn = player.CharacterAdded:Connect(function()
			releaseTransit(player)
		end)
		transitConns[player] = conn
	end

	local function canEnter(player)
		if inTransit[player] then
			return false
		end
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if not (character and humanoid and root) or humanoid.Health <= 0 then
			return false
		end
		return (root.Position - portal.Position).Magnitude <= PORTAL_MAX_DISTANCE
	end

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Entrar"
	prompt.ObjectText = "Reino Ember"
	prompt.Parent = portal
	prompt.Triggered:Connect(function(player)
		if not canEnter(player) then
			return
		end
		markInTransit(player)
		-- Contrato Ember (Sol): enter(player): boolean. false = recusado no
		-- servidor (arena ocupada, personagem inválido). Sem recusa, o
		-- jogador está a caminho de Ember e só volta pelo retorno do reino.
		local accepted = onEnterEmber and onEnterEmber(player)
		if accepted == false then
			releaseTransit(player)
			Hub.notify(player, "Guardião de Ember já está em combate · aguarde")
		end
	end)

	-- Retorno ao hub (ligado pelo Sol em Ember.connectReturn): libera o
	-- jogador para novas tentativas e devolve o corpo ao spawn.
	return function(player)
		releaseTransit(player)
		local character = player.Character
		if character then
			character:PivotTo(CFrame.new(spawn.Position + Vector3.new(0, 4, 0)))
		end
	end
end

return Hub
