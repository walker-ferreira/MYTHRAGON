-- Hub: ilha flutuante, quatro selos de identificação neutra e entrada clara
-- do Reino de Ember por um portal rúnico. Responsável nesta rodada: GLM 5.3.
-- O portal só aceita o jogador no servidor: personagem vivo e dentro da
-- distância máxima do portal. O progresso de conquista é INDIVIDUAL: painel
-- persistente no PlayerGui de cada jogador (ResetOnSpawn=false); os selos
-- no mundo são apenas identificação, iguais para todos.
-- Direção 3D desta rodada: builds procedurais próprios inspirados em
-- referências de portal rúnico, pedras entalhadas e ilha flutuante;
-- nenhum modelo externo importado. Fontes e regras em
-- docs/decisions/0002-selos-perfil-e-visual-do-hub.md.

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

-- Cores na mesma ordem dos selos do hub (1 = Ember). Fonte única também
-- usada pelo portal e pelas pedras rúnicas.
local SEAL_COLORS = {
	Color3.fromRGB(255, 105, 44),
	Color3.fromRGB(75, 145, 255),
	Color3.fromRGB(74, 206, 140),
	Color3.fromRGB(180, 105, 255),
}

local LOCKED_COLOR = Color3.fromRGB(14, 13, 24)

local function part(parent, name, size, cframe, material, color)
	local value = Instance.new("Part")
	value.Name = name
	value.Anchored = true
	value.Size = size
	value.CFrame = cframe
	value.Material = material
	value.Color = color
	value.Parent = parent
	return value
end

local function createSparks(parent, color)
	local sparks = Instance.new("ParticleEmitter")
	sparks.Name = "Sparks"
	sparks.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	sparks.Color = ColorSequence.new(color)
	sparks.LightEmission = 1
	sparks.Size = NumberSequence.new(0.35)
	sparks.Lifetime = NumberRange.new(0.6, 1.2)
	sparks.Rate = 14
	sparks.Speed = NumberRange.new(0.5, 1.5)
	sparks.SpreadAngle = Vector2.new(180, 180)
	sparks.Enabled = false
	sparks.Parent = parent
	return sparks
end

-- Aparência neutra dos selos no mundo: orbe de basalto apagado e runa
-- fraca, igual para todos — identificação do reino, não estado de
-- conquista. O progresso individual vive no painel por jogador (PlayerGui).
local function applySealState(seal)
	local color = seal:GetAttribute("Color") or Color3.fromRGB(255, 255, 255)
	local rune = seal.Parent and seal.Parent:FindFirstChild(seal.Name .. "Rune")
	local light = seal:FindFirstChild("SealLight")
	local sparks = seal:FindFirstChild("Sparks")
	seal.Material = Enum.Material.Basalt
	seal.Color = color:Lerp(LOCKED_COLOR, 0.78)
	seal.Transparency = 0.15
	if light then
		light.Enabled = false
	end
	if sparks then
		sparks.Enabled = false
	end
	if rune then
		rune.Transparency = 0.65
	end
end

-- Painel de progresso INDIVIDUAL (PlayerGui é exclusivo de quem o recebe).
-- Fonte de verdade é o Profile; o Start chama Hub.setSealEarned(player, index)
-- após a concessão. Painéis: criados para PlayerAdded e para quem já está no
-- servidor, com dedup; limpos no PlayerRemoving.
local panels = {}
local panelsInitialized = false

local function applyEarned(panel, index)
	if not panel or panel.earned[index] then
		return
	end
	panel.earned[index] = true
	panel.labels[index].TextColor3 = Color3.fromRGB(255, 214, 90)
	panel.labels[index].Text = "✓ " .. SEAL_TITLES[index] .. " · conquistado"
end

local function ensurePanel(player)
	if panels[player] then
		return panels[player]
	end
	local playerGui = player:FindFirstChildOfClass("PlayerGui")
	if not playerGui then
		return nil
	end

	local gui = Instance.new("ScreenGui")
	gui.Name = "SealPanel"
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 5
	gui.Parent = playerGui

	local frame = Instance.new("Frame")
	frame.Name = "Panel"
	frame.AnchorPoint = Vector2.new(1, 0)
	frame.Position = UDim2.new(1, -16, 0, 16)
	frame.Size = UDim2.new(0, 230, 0, 136)
	frame.BackgroundColor3 = Color3.fromRGB(20, 16, 28)
	frame.BackgroundTransparency = 0.2
	frame.BorderSizePixel = 0
	frame.Parent = gui

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, 0, 0, 28)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBold
	title.TextSize = 14
	title.TextColor3 = Color3.fromRGB(235, 226, 245)
	title.Text = "Selos · sessão"
	title.Parent = frame

	local labels = {}
	for index, sealTitle in ipairs(SEAL_TITLES) do
		local row = Instance.new("TextLabel")
		row.Name = "Seal" .. index
		row.Position = UDim2.new(0, 10, 0, 28 + (index - 1) * 26)
		row.Size = UDim2.new(1, -20, 0, 24)
		row.BackgroundTransparency = 1
		row.Font = Enum.Font.Gotham
		row.TextSize = 14
		row.TextXAlignment = Enum.TextXAlignment.Left
		row.TextColor3 = Color3.fromRGB(150, 142, 168)
		row.Text = "○ " .. sealTitle .. " · bloqueado"
		row.Parent = frame
		labels[index] = row
	end

	local panel = { gui = gui, labels = labels, earned = {} }
	panels[player] = panel
	return panel
end

local function setupPanel(player)
	if panels[player] then
		return
	end
	task.spawn(function()
		local playerGui = player:FindFirstChildOfClass("PlayerGui")
			or player:WaitForChild("PlayerGui", 30)
		if playerGui and player.Parent and not panels[player] then
			ensurePanel(player)
		end
	end)
end

local function initPanels()
	if panelsInitialized then
		return
	end
	panelsInitialized = true
	Players.PlayerAdded:Connect(setupPanel)
	Players.PlayerRemoving:Connect(function(player)
		local panel = panels[player]
		if panel then
			panel.gui:Destroy()
			panels[player] = nil
		end
	end)
	for _, player in ipairs(Players:GetPlayers()) do
		setupPanel(player)
	end
end

-- Marca o selo conquistado APENAS no painel deste jogador. Idempotente.
function Hub.setSealEarned(player, index)
	local panel = ensurePanel(player)
	if not panel then
		-- PlayerGui ainda indisponível (raro): cria quando chegar e aplica.
		task.spawn(function()
			local playerGui = player:WaitForChild("PlayerGui", 30)
			if playerGui and player.Parent then
				applyEarned(ensurePanel(player), index)
			end
		end)
		return
	end
	applyEarned(panel, index)
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
	initPanels()

	local model = Instance.new("Model")
	model.Name = "Hub"
	model.Parent = parent

	-- Ilha flutuante: plataforma e maciço rochoso de sustentação.
	part(model, "HubPlatform", Vector3.new(66, 2, 52),
		CFrame.new(0, -1, 0), Enum.Material.Slate, Color3.fromRGB(52, 49, 78))

	local undersides = {
		{ Vector3.new(18, 10, 14), CFrame.new(0, -6.5, -2) },
		{ Vector3.new(12, 8, 11), CFrame.new(21, -5.5, 12) * CFrame.Angles(0, 0, math.rad(6)) },
		{ Vector3.new(12, 8, 11), CFrame.new(-21, -5.5, 12) * CFrame.Angles(0, 0, math.rad(-6)) },
		{ Vector3.new(11, 7, 10), CFrame.new(21, -5.5, -12) * CFrame.Angles(0, 0, math.rad(-7)) },
		{ Vector3.new(11, 7, 10), CFrame.new(-21, -5.5, -12) * CFrame.Angles(0, 0, math.rad(7)) },
	}
	for index, spec in ipairs(undersides) do
		part(model, "IslandRock" .. index, spec[1], spec[2],
			Enum.Material.Rock, Color3.fromRGB(38, 35, 55))
	end

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "HubSpawn"
	spawn.Anchored = true
	spawn.Neutral = true
	spawn.Size = Vector3.new(8, 1, 8)
	spawn.Position = Vector3.new(0, 0.5, 14)
	spawn.Parent = model

	-- Caminho de pedras do spawn ao portal: a entrada de Ember fica evidente.
	for index = 1, 5 do
		local offset = (index % 2 == 0) and 0.7 or -0.7
		part(model, "PathStone" .. index, Vector3.new(3.4, 0.4, 2.8),
			CFrame.new(offset, 0.2, 10 - (index - 1) * 4),
			Enum.Material.Slate, Color3.fromRGB(56, 53, 82))
	end

	-- Quatro selos: pedestal de pedra, runa frontal e orbe com estado.
	for index, color in ipairs(SEAL_COLORS) do
		local x = (index - 2.5) * 9
		part(model, "Seal" .. index .. "Pedestal", Vector3.new(2.8, 1.2, 2.8),
			CFrame.new(x, 0.6, -7), Enum.Material.Slate, Color3.fromRGB(43, 40, 63))
		part(model, "Seal" .. index .. "Rune", Vector3.new(2, 0.3, 0.15),
			CFrame.new(x, 0.75, -5.53), Enum.Material.Neon, color)

		local seal = Instance.new("Part")
		seal.Name = "Seal" .. index
		seal.Shape = Enum.PartType.Ball
		seal.Anchored = true
		seal.Size = Vector3.new(2.6, 2.6, 2.6)
		seal.Position = Vector3.new(x, 2.7, -7)
		seal:SetAttribute("Color", color)
		seal.Parent = model

		local light = Instance.new("PointLight")
		light.Name = "SealLight"
		light.Range = 9
		light.Brightness = 1.4
		light.Color = color
		light.Enabled = false
		light.Parent = seal

		createSparks(seal, color)
		applySealState(seal)
	end

	-- Portal rúnico de Ember: base, batentes, verga com runa e superfície.
	part(model, "PortalBase", Vector3.new(11, 1, 5),
		CFrame.new(0, 0.5, -18), Enum.Material.Granite, Color3.fromRGB(60, 56, 84))
	part(model, "PortalPillarLeft", Vector3.new(2, 9.5, 2),
		CFrame.new(-4.2, 5.75, -18), Enum.Material.Slate, Color3.fromRGB(70, 66, 96))
	part(model, "PortalPillarRight", Vector3.new(2, 9.5, 2),
		CFrame.new(4.2, 5.75, -18), Enum.Material.Slate, Color3.fromRGB(70, 66, 96))
	part(model, "PortalLintel", Vector3.new(12, 1.6, 2.6),
		CFrame.new(0, 11.3, -18), Enum.Material.Slate, Color3.fromRGB(70, 66, 96))
	part(model, "PortalLintelRune", Vector3.new(10, 0.55, 0.2),
		CFrame.new(0, 11.3, -16.6), Enum.Material.Neon, SEAL_COLORS[1])
	part(model, "PortalPillarRuneLeft", Vector3.new(0.3, 2.4, 0.6),
		CFrame.new(-3.15, 6, -18), Enum.Material.Neon, SEAL_COLORS[1])
	part(model, "PortalPillarRuneRight", Vector3.new(0.3, 2.4, 0.6),
		CFrame.new(3.15, 6, -18), Enum.Material.Neon, SEAL_COLORS[1])

	local portal = Instance.new("Part")
	portal.Name = "EmberPortal"
	portal.Anchored = true
	portal.Material = Enum.Material.ForceField
	portal.Color = SEAL_COLORS[1]
	portal.Transparency = 0.1
	portal.Size = Vector3.new(6.4, 7.6, 0.5)
	portal.Position = Vector3.new(0, 5.3, -18)
	portal.Parent = model

	local portalLight = Instance.new("PointLight")
	portalLight.Name = "PortalLight"
	portalLight.Range = 16
	portalLight.Brightness = 1.2
	portalLight.Color = SEAL_COLORS[1]
	portalLight.Parent = portal

	local sign = Instance.new("BillboardGui")
	sign.Name = "PortalSign"
	sign.Size = UDim2.fromOffset(260, 70)
	sign.StudsOffset = Vector3.new(0, 7.2, 0)
	sign.MaxDistance = 100
	sign.Parent = portal

	local signText = Instance.new("TextLabel")
	signText.Name = "Title"
	signText.Size = UDim2.fromScale(1, 1)
	signText.BackgroundTransparency = 1
	signText.Font = Enum.Font.GothamBold
	signText.TextScaled = true
	signText.TextWrapped = true
	signText.TextColor3 = Color3.fromRGB(255, 214, 90)
	signText.TextStrokeTransparency = 0.4
	signText.Text = "Reino de Ember\nConquiste o primeiro selo"
	signText.Parent = sign

	-- Pedras entalhadas ladeando o caminho, com marcas na cor de Ember.
	for _, side in ipairs({ -1, 1 }) do
		part(model, "EmberRuneStone" .. tostring(side), Vector3.new(1.8, 3.4, 1.4),
			CFrame.new(side * 7, 1.7, -12.5) * CFrame.Angles(0, math.rad(side * 6), 0),
			Enum.Material.Slate, Color3.fromRGB(50, 47, 72))
		for level = 0, 1 do
			part(model, "EmberRuneMark" .. tostring(side) .. tostring(level),
				Vector3.new(0.35, 0.55, 0.12),
				CFrame.new(side * 7, 1.5 + level * 0.95, -11.7),
				Enum.Material.Neon, SEAL_COLORS[1])
		end
	end

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
	prompt.ObjectText = "Reino de Ember"
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
