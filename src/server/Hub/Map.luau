-- Hub (Aetheria): ilha flutuante explorável com spawn seguro, ala oeste com
-- trajeto, vegetação, ruínas, cristais, Guardiões do Éter, santuário de
-- Varkhion e entrada clara do Reino de Ember por um portal rúnico.
-- Responsável nesta rodada: GLM 5.3 (Fase 1, branch glm/aetheria-fase-1).
-- O portal só aceita o jogador no servidor: personagem vivo e dentro da
-- distância máxima do portal. O progresso de conquista é INDIVIDUAL: painel
-- persistente no PlayerGui de cada jogador (ResetOnSpawn=false); os selos
-- no mundo são apenas identificação, iguais para todos.
-- Direção 3D desta rodada: builds procedurais próprios; nenhuma referência
-- auditable foi reutilizada sem licença confirmada. Fontes e regras em
-- docs/decisions/0003-selos-perfil-e-visual-do-hub.md e
-- docs/decisions/0004-aetheria-fase-1.md.

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

-- Paleta Aetheria (GDD, Fase 1): roxo profundo, azul etéreo, dourado
-- ancestral e obsidiana.
local AETHER_STONE = Color3.fromRGB(43, 40, 63)
local ETHER_BLUE = Color3.fromRGB(96, 168, 255)
local AETHER_GOLD = Color3.fromRGB(255, 214, 90)
local OBSIDIAN_COLOR = Color3.fromRGB(18, 16, 24)
local VIOLET_CANOPY = Color3.fromRGB(72, 52, 110)

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

-- Prompt de observação validado no servidor: só o disparo do prompt no
-- servidor conclui o objetivo vinculado (nada vem do cliente).
local function observePrompt(anchorPart, objectText, objectiveId)
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "ObservePrompt"
	prompt.ActionText = "Observar"
	prompt.ObjectText = objectText
	prompt.MaxActivationDistance = 8
	prompt.RequiresLineOfSight = false
	prompt.Parent = anchorPart
	prompt.Triggered:Connect(function(player)
		if player.Parent ~= Players or not anchorPart:IsDescendantOf(workspace) then return end
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if not (character and humanoid and root) or humanoid.Health <= 0
			or (root.Position - anchorPart.Position).Magnitude > 11 then
			return
		end
		Hub.completeObjective(player, objectiveId)
	end)
	return prompt
end

-- Vegetação de Aetheria: tronco escuro e copa violeta com tintura etérea.
local function createTree(parent, name, base, trunkHeight)
	local trunk = part(parent, name .. "Trunk", Vector3.new(trunkHeight, 1.4, 1.4),
		CFrame.new(base + Vector3.new(0, trunkHeight / 2, 0)) * CFrame.Angles(0, 0, math.rad(90)),
		Enum.Material.Wood, Color3.fromRGB(46, 36, 58))
	trunk.Shape = Enum.PartType.Cylinder
	local canopyA = part(parent, name .. "CanopyA", Vector3.new(6.5, 6.5, 6.5),
		CFrame.new(base + Vector3.new(0, trunkHeight + 2.2, 0)),
		Enum.Material.Grass, VIOLET_CANOPY)
	canopyA.Shape = Enum.PartType.Ball
	local canopyB = part(parent, name .. "CanopyB", Vector3.new(4.4, 4.4, 4.4),
		CFrame.new(base + Vector3.new(1.1, trunkHeight + 4.4, 0.7)),
		Enum.Material.Grass, VIOLET_CANOPY:Lerp(ETHER_BLUE, 0.22))
	canopyB.Shape = Enum.PartType.Ball
	local canopyC = part(parent, name .. "CanopyC", Vector3.new(3.2, 3.2, 3.2),
		CFrame.new(base + Vector3.new(-0.9, trunkHeight + 5.9, -0.6)),
		Enum.Material.Grass, VIOLET_CANOPY:Lerp(ETHER_BLUE, 0.4))
	canopyC.Shape = Enum.PartType.Ball
end

-- Cristais do Éter: lascas de vidro em azul etéreo ou violeta, inclinadas,
-- com luz fraca. Apenas as duas lascas maiores recebem PointLight para
-- conter o orçamento de iluminação.
local function createCrystalCluster(parent, name, base, color)
	local shards = {
		{ Vector3.new(1.6, 7, 1.6), Vector3.new(0, 3.5, 0), CFrame.Angles(0, 0, math.rad(8)), true },
		{ Vector3.new(1.2, 5, 1.2), Vector3.new(1.8, 2.5, 0.6), CFrame.Angles(0, 0, math.rad(24)), true },
		{ Vector3.new(1.1, 4.2, 1.1), Vector3.new(-1.6, 2.1, -0.8), CFrame.Angles(0, 0, math.rad(-22)), false },
		{ Vector3.new(0.9, 3, 0.9), Vector3.new(0.6, 1.5, 1.8), CFrame.Angles(0, 0, math.rad(14)), false },
	}
	for index, spec in ipairs(shards) do
		local shard = part(parent, name .. "Shard" .. index, spec[1],
			CFrame.new(base + spec[2]) * spec[3], Enum.Material.Glass, color)
		shard.Transparency = 0.35
		if spec[4] then
			local light = Instance.new("PointLight")
			light.Name = "CrystalLight"
			light.Range = 9
			light.Brightness = 0.8
			light.Color = color
			light.Parent = shard
		end
	end
end

-- Guardiões do Éter: estátuas de obsidiana com visor e runa dourados;
-- observar qualquer uma conclui o primeiro objetivo.
local function createGuardianStatue(parent, name, position, facing)
	local base = CFrame.new(position) * CFrame.Angles(0, math.rad(facing), 0)
	part(parent, name .. "Pedestal", Vector3.new(3.4, 1, 3.4),
		base * CFrame.new(0, 0.5, 0), Enum.Material.Slate, AETHER_STONE)
	local body = part(parent, name .. "Body", Vector3.new(2, 4.8, 1.7),
		base * CFrame.new(0, 3.4, 0), Enum.Material.Basalt, OBSIDIAN_COLOR)
	local head = part(parent, name .. "Head", Vector3.new(1.7, 1.7, 1.7),
		base * CFrame.new(0, 6.6, 0), Enum.Material.Basalt, OBSIDIAN_COLOR)
	head.Shape = Enum.PartType.Ball
	part(parent, name .. "Visor", Vector3.new(1.2, 0.35, 0.2),
		base * CFrame.new(0, 6.7, -0.9), Enum.Material.Neon, AETHER_GOLD)
	part(parent, name .. "ChestRune", Vector3.new(0.9, 1.6, 0.2),
		base * CFrame.new(0, 4.2, -0.95), Enum.Material.Neon, ETHER_BLUE)
	observePrompt(body, "Guardião do Éter", "guardioes")
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
	frame.Position = UDim2.new(1, -12, 0, 60)
	-- GLM-R002.B: largura responsiva com piso de 145 studs-pixel; em
	-- 320×568 os dois painéis (12..157 e 163..308) não se sobrepõem.
	frame.Size = UDim2.new(0.34, 0, 0, 136)
	local frameSize = Instance.new("UISizeConstraint")
	frameSize.MinSize = Vector2.new(145, 136)
	frameSize.MaxSize = Vector2.new(230, 136)
	frameSize.Parent = frame
	frame.BackgroundColor3 = Color3.fromRGB(20, 16, 28)
	frame.BackgroundTransparency = 0.2
	frame.BorderSizePixel = 0
	frame.Parent = gui

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, 0, 0, 28)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBold
	title.TextScaled = true
	title.TextWrapped = true
	local titleSize = Instance.new("UITextSizeConstraint")
	titleSize.MaxTextSize = 14
	titleSize.Parent = title
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
		row.TextScaled = true
		row.TextWrapped = true
		local rowSize = Instance.new("UITextSizeConstraint")
		rowSize.MaxTextSize = 14
		rowSize.Parent = row
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
	-- GLM-R002.B: aviso no rodapé central, fora dos painéis (topo) e fora
	-- do botão de pulo (canto inferior direito); em 640×360 fica em y 256..304.
	label.Size = UDim2.new(0, 300, 0, 44)
	label.Position = UDim2.new(0.5, -150, 1, -60)
	label.BackgroundColor3 = Color3.fromRGB(20, 16, 28)
	label.BackgroundTransparency = 0.25
	label.TextColor3 = Color3.fromRGB(255, 214, 90)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 17
	label.TextWrapped = true
	label.Text = text
	label.Parent = gui

	task.delay(4, function()
		gui:Destroy()
	end)
end

-- ===== Objetivos iniciais da Fase 1 (Guardião do Éter) =====
-- Estado por jogador, apenas sessão; concluído no servidor via prompts e
-- no gatilho do portal. O painel mostra somente o progresso do próprio
-- jogador. Codex pode concluir um objetivo validado chamando
-- Hub.completeObjective(player, id) após a interação do Varkhion.

local OBJECTIVES = {
	{ id = "guardioes", text = "Reúna-se com os Guardiões do Éter" },
	{ id = "santuario", text = "Alcance o santuário de Varkhion" },
	{ id = "portal", text = "Entre no portal de Ember" },
}

local objectivePanels = {}
local objectivesInitialized = false

local function ensureObjectives(player)
	local state = objectivePanels[player]
	if state then
		return state
	end
	local playerGui = player:FindFirstChildOfClass("PlayerGui")
	if not playerGui then
		return nil
	end

	local gui = Instance.new("ScreenGui")
	gui.Name = "ObjectivePanel"
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 5
	gui.Parent = playerGui

	local frame = Instance.new("Frame")
	frame.Name = "Panel"
	frame.AnchorPoint = Vector2.new(0, 0)
	frame.Position = UDim2.new(0, 12, 0, 60)
	-- GLM-R002.B: largura responsiva com piso de 145 studs-pixel; em
	-- 320×568 os dois painéis (12..157 e 163..308) não se sobrepõem.
	frame.Size = UDim2.new(0.34, 0, 0, 110)
	local frameSize = Instance.new("UISizeConstraint")
	frameSize.MinSize = Vector2.new(145, 110)
	frameSize.MaxSize = Vector2.new(250, 110)
	frameSize.Parent = frame
	frame.BackgroundColor3 = Color3.fromRGB(20, 16, 28)
	frame.BackgroundTransparency = 0.2
	frame.BorderSizePixel = 0
	frame.Parent = gui

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, 0, 0, 28)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBold
	title.TextScaled = true
	title.TextWrapped = true
	local titleSize = Instance.new("UITextSizeConstraint")
	titleSize.MaxTextSize = 14
	titleSize.Parent = title
	title.TextColor3 = Color3.fromRGB(235, 226, 245)
	title.Text = "Guardião do Éter · objetivos"
	title.Parent = frame

	local rows = {}
	for index, objective in ipairs(OBJECTIVES) do
		local row = Instance.new("TextLabel")
		row.Name = "Objective" .. index
		row.Position = UDim2.new(0, 10, 0, 28 + (index - 1) * 26)
		row.Size = UDim2.new(1, -20, 0, 24)
		row.BackgroundTransparency = 1
		row.Font = Enum.Font.Gotham
		row.TextScaled = true
		row.TextWrapped = true
		local rowSize = Instance.new("UITextSizeConstraint")
		rowSize.MaxTextSize = 14
		rowSize.Parent = row
		row.TextXAlignment = Enum.TextXAlignment.Left
		row.TextColor3 = Color3.fromRGB(150, 142, 168)
		row.Text = "○ " .. objective.text
		row.Parent = frame
		rows[objective.id] = row
	end

	state = { gui = gui, rows = rows, done = {} }
	objectivePanels[player] = state
	return state
end

local function setupObjectives(player)
	if objectivePanels[player] then
		return
	end
	task.spawn(function()
		local playerGui = player:FindFirstChildOfClass("PlayerGui")
			or player:WaitForChild("PlayerGui", 30)
		if playerGui and player.Parent and not objectivePanels[player] then
			ensureObjectives(player)
		end
	end)
end

local function initObjectives()
	if objectivesInitialized then
		return
	end
	objectivesInitialized = true
	Players.PlayerAdded:Connect(setupObjectives)
	Players.PlayerRemoving:Connect(function(player)
		local state = objectivePanels[player]
		if state then
			state.gui:Destroy()
			objectivePanels[player] = nil
		end
	end)
	for _, player in ipairs(Players:GetPlayers()) do
		setupObjectives(player)
	end
end

-- Persistence hook is provided by the server's composition root.
-- Restoring old progress must not emit duplicate quest events or rewards.
local onObjectiveCompleted

function Hub.setObjectiveCompletionHandler(callback)
    assert(callback == nil or type(callback) == "function")
    onObjectiveCompleted = callback
end

function Hub.restoreObjective(player, id)
    local objective
    for _, item in ipairs(OBJECTIVES) do
        if item.id == id then objective = item break end
    end
    if not objective then return false end
    local state = ensureObjectives(player)
    if not state then
        task.spawn(function()
            local gui = player:WaitForChild("PlayerGui", 30)
            if gui and player.Parent == Players then Hub.restoreObjective(player, id) end
        end)
        return false
    end
    if state.done[id] then return true end
    state.done[id] = true
    state.rows[id].TextColor3 = AETHER_GOLD
    state.rows[id].Text = "✓ " .. objective.text
    return true
end

-- Marca um objetivo como concluído para este jogador. Idempotente.
-- Chamado pelos prompts do hub, pelo portal e (proposta GLM-R001) pelo
-- módulo do Varkhion do Codex após interação validada no servidor.
function Hub.completeObjective(player, id)
	local objective = nil
	for _, item in ipairs(OBJECTIVES) do
		if item.id == id then
			objective = item
		end
	end
	if not objective then
		warn("[Hub] objetivo desconhecido: " .. tostring(id))
		return false
	end
	local state = ensureObjectives(player)
	if not state then
		task.spawn(function()
			local playerGui = player:WaitForChild("PlayerGui", 30)
			if playerGui and player.Parent then
				Hub.completeObjective(player, id)
			end
		end)
		return false
	end
	if state.done[id] then
		return false
	end
	state.done[id] = true
	state.rows[id].TextColor3 = AETHER_GOLD
	state.rows[id].Text = "✓ " .. objective.text
	Hub.notify(player, objective.text .. " · concluído")
	if onObjectiveCompleted then
		local ok, err = pcall(onObjectiveCompleted, player, id)
		if not ok then warn("[Hub] objective persistence callback failed: " .. tostring(err)) end
	end

	local completed = 0
	for _, item in ipairs(OBJECTIVES) do
		if state.done[item.id] then
			completed += 1
		end
	end
	if completed == #OBJECTIVES then
		task.delay(4.6, function()
			if player.Parent then
				Hub.notify(player, "Objetivos iniciais concluídos · Ember aguarda")
			end
		end)
	end
	return true
end

function Hub.build(parent, onEnterEmber)
	initPanels()
	initObjectives()

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
	sign.MaxDistance = 32
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

	-- ===== Aetheria (Fase 1) =====
	-- Ala oeste explorável: deck, trajeto de pedras, vegetação, ruínas,
	-- cristais, Guardiões do Éter e santuário de Varkhion. Builds
	-- procedurais próprios; referências em docs/decisions/0004-aetheria-fase-1.md.
	part(model, "AetheriaWestDeck", Vector3.new(66, 2, 60),
		CFrame.new(-66, -1, 2), Enum.Material.Slate, Color3.fromRGB(48, 45, 72))

	local wingRocks = {
		{ Vector3.new(16, 9, 12), CFrame.new(-70, -6, 16) * CFrame.Angles(0, 0, math.rad(5)) },
		{ Vector3.new(14, 8, 11), CFrame.new(-78, -6.5, -16) * CFrame.Angles(0, 0, math.rad(-6)) },
		{ Vector3.new(12, 7, 10), CFrame.new(-92, -6, 8) * CFrame.Angles(0, 0, math.rad(7)) },
	}
	for index, spec in ipairs(wingRocks) do
		part(model, "AetheriaRock" .. index, spec[1], spec[2],
			Enum.Material.Rock, Color3.fromRGB(36, 33, 52))
	end

	-- Trajeto claro do spawn à ala oeste (os Guardiões ficam às margens;
	-- o trajeto termina na borda dos degraus do santuário).
	for index = 1, 10 do
		local offset = (index % 2 == 0) and 0.6 or -0.6
		part(model, "AetherPathStone" .. index, Vector3.new(3.6, 0.4, 3),
			CFrame.new(-4 - (index - 1) * 5, 0.2, 14 + offset),
			Enum.Material.Slate, Color3.fromRGB(52, 49, 76))
	end

	createTree(model, "AetherTree1", Vector3.new(18, 0, 21), 7)
	createTree(model, "AetherTree2", Vector3.new(-14, 0, 22), 6)
	createTree(model, "AetherTree3", Vector3.new(-70, 0, 30), 8)
	createTree(model, "AetherTree4", Vector3.new(-50, 0, 24), 6)
	createTree(model, "AetherTree5", Vector3.new(-90, 0, -20), 7)
	createTree(model, "AetherTree6", Vector3.new(-44, 0, -18), 7)

	createCrystalCluster(model, "AetherCrystals1", Vector3.new(24, 0, 18), ETHER_BLUE)
	createCrystalCluster(model, "AetherCrystals2", Vector3.new(-46, 0, -10), VIOLET_CANOPY)
	createCrystalCluster(model, "AetherCrystals3", Vector3.new(-58, 0, 28), ETHER_BLUE)
	createCrystalCluster(model, "AetherCrystals4", Vector3.new(-94, 0, 24), VIOLET_CANOPY)
	createCrystalCluster(model, "AetherCrystals5", Vector3.new(8, 0, -21), ETHER_BLUE)
	createCrystalCluster(model, "AetherCrystals6", Vector3.new(-8, 0, -21), VIOLET_CANOPY)

	-- Ruínas do Éter: arco quebrado, coluna tombada e pedras soltas
	-- (mesma linguagem da colunata basáltica de Ember, decisão 0002).
	local ruinBase = Vector3.new(-30, 0, -8)
	part(model, "RuinArchPillarA", Vector3.new(2.6, 8, 2.6),
		CFrame.new(ruinBase + Vector3.new(-4, 4, 0)) * CFrame.Angles(0, math.rad(12), 0),
		Enum.Material.Basalt, OBSIDIAN_COLOR)
	part(model, "RuinArchPillarB", Vector3.new(2.6, 6.5, 2.6),
		CFrame.new(ruinBase + Vector3.new(4, 3.25, 0)) * CFrame.Angles(0, math.rad(-8), 0),
		Enum.Material.Basalt, OBSIDIAN_COLOR)
	part(model, "RuinArchLintel", Vector3.new(9, 1.8, 2.8),
		CFrame.new(ruinBase + Vector3.new(0.5, 7.6, 0)) * CFrame.Angles(0, 0, math.rad(10)),
		Enum.Material.Basalt, OBSIDIAN_COLOR)
	part(model, "RuinArchGold", Vector3.new(7.5, 0.4, 0.3),
		CFrame.new(ruinBase + Vector3.new(0.5, 7.6, 1.5)) * CFrame.Angles(0, 0, math.rad(10)),
		Enum.Material.Neon, AETHER_GOLD)
	local fallen = part(model, "RuinFallenColumn", Vector3.new(7, 2, 2),
		CFrame.new(ruinBase + Vector3.new(-6, 1, 4)) * CFrame.Angles(0, math.rad(30), math.rad(90)),
		Enum.Material.Basalt, OBSIDIAN_COLOR)
	fallen.Shape = Enum.PartType.Cylinder
	part(model, "RuinRubble1", Vector3.new(2.4, 1.6, 2),
		CFrame.new(ruinBase + Vector3.new(2, 0.8, 3.2)) * CFrame.Angles(math.rad(14), math.rad(40), 0),
		Enum.Material.Rock, Color3.fromRGB(34, 31, 50))
	part(model, "RuinRubble2", Vector3.new(1.8, 1.2, 1.6),
		CFrame.new(ruinBase + Vector3.new(6, 0.6, -2.6)) * CFrame.Angles(math.rad(-10), math.rad(15), math.rad(8)),
		Enum.Material.Rock, Color3.fromRGB(34, 31, 50))

	-- Guardiões do Éter: três estátuas ladeando o trajeto oeste.
	local guardians = {
		{ Vector3.new(-16, 0, 10), -90 },
		{ Vector3.new(-38, 0, 18), -90 },
		{ Vector3.new(-42, 0, 10), -90 },
	}
	for index, spec in ipairs(guardians) do
		createGuardianStatue(model, "AetherGuardian" .. index, spec[1], spec[2])
	end

	-- Santuário de Varkhion (oeste): dais de mármore, anel de pilares de
	-- obsidiana com faixas douradas, runas etéreas, feixe de luz e âncora
	-- de montagem para o módulo do Codex. Dimensões conforme VX-001:
	-- folga ≥ 36×34 studs, 18 de altura livre e 12 de aproximação frontal.
	local sanctuaryCenter = Vector3.new(-72, 0, 2)

	local steps = part(model, "SanctuarySteps", Vector3.new(0.6, 54, 54),
		CFrame.new(sanctuaryCenter + Vector3.new(0, 0.3, 0)) * CFrame.Angles(0, 0, math.rad(90)),
		Enum.Material.Slate, AETHER_STONE)
	steps.Shape = Enum.PartType.Cylinder
	local dais = part(model, "SanctuaryDais", Vector3.new(1.2, 48, 48),
		CFrame.new(sanctuaryCenter + Vector3.new(0, 0.6, 0)) * CFrame.Angles(0, 0, math.rad(90)),
		Enum.Material.Marble, Color3.fromRGB(64, 60, 94))
	dais.Shape = Enum.PartType.Cylinder

	for index = 0, 5 do
		local angle = index * math.pi / 3
		local radial = Vector3.new(math.cos(angle), 0, math.sin(angle))
		local pillarPos = sanctuaryCenter + radial * 20
		part(model, "SanctuaryPillar" .. index, Vector3.new(2.2, 7, 2.2),
			CFrame.new(pillarPos + Vector3.new(0, 1.2 + 3.5, 0)),
			Enum.Material.Basalt, OBSIDIAN_COLOR)
		part(model, "SanctuaryPillarBand" .. index, Vector3.new(2.4, 0.5, 2.4),
			CFrame.new(pillarPos + Vector3.new(0, 1.2 + 4.6, 0)),
			Enum.Material.Neon, AETHER_GOLD)
		part(model, "SanctuaryPillarRune" .. index, Vector3.new(0.3, 2.6, 0.3),
			CFrame.new(pillarPos - radial * 1.15 + Vector3.new(0, 1.2 + 3.2, 0)),
			Enum.Material.Neon, ETHER_BLUE)
	end

	for index = 0, 11 do
		local angle = index * math.pi / 6
		local radial = Vector3.new(math.cos(angle), 0, math.sin(angle))
		part(model, "SanctuaryGoldMark" .. index, Vector3.new(1.6, 0.3, 0.8),
			CFrame.new(sanctuaryCenter + radial * 22.5 + Vector3.new(0, 1.35, 0))
				* CFrame.Angles(0, -angle + math.rad(90), 0),
			Enum.Material.Neon, AETHER_GOLD)
	end

	-- Contrato VX-001 (resposta GLM em docs/agents/GLM.md): âncora do
	-- Varkhion. Caminho: workspace.MythragonMap.Hub.VarkhionAnchor —
	-- Part ancorada, invisível, sem colisão, piso do dais, marca de 36×34,
	-- frente (-Z) para leste (em direção ao portal) com aproximação livre.
	local mount = Instance.new("Part")
	mount.Name = "VarkhionAnchor"
	mount.Anchored = true
	mount.CanCollide = false
	mount.Transparency = 1
	mount.Size = Vector3.new(36, 0.4, 34)
	mount.CFrame = CFrame.lookAt(sanctuaryCenter + Vector3.new(0, 1.4, 0),
		sanctuaryCenter + Vector3.new(10, 1.4, 0))
	mount.Parent = model

	local sanctuaryLight = Instance.new("PointLight")
	sanctuaryLight.Name = "SanctuaryLight"
	sanctuaryLight.Range = 20
	sanctuaryLight.Brightness = 1.2
	sanctuaryLight.Color = AETHER_GOLD
	sanctuaryLight.Parent = mount

	local beam = part(model, "SanctuaryBeam", Vector3.new(0.7, 26, 0.7),
		CFrame.new(sanctuaryCenter + Vector3.new(-15.9, 1.2 + 13, -15.9)),
		Enum.Material.Neon, ETHER_BLUE)
	beam.Transparency = 0.5
	beam.CanCollide = false

	local sanctuaryStone = part(model, "SanctuaryRuneStone", Vector3.new(2, 3.8, 1.5),
		CFrame.new(sanctuaryCenter + Vector3.new(22.5, 3.1, 0)),
		Enum.Material.Slate, Color3.fromRGB(50, 47, 72))
	part(model, "SanctuaryRuneMark", Vector3.new(0.4, 2.2, 0.15),
		CFrame.new(sanctuaryCenter + Vector3.new(22.5, 3.1, 0.85)),
		Enum.Material.Neon, AETHER_GOLD)
	-- VX-002: a conversa validada com o Varkhion (callback em Start) também
	-- conclui o objetivo; a pedra fica como marco da entrada e rota de
	-- fallback enquanto o módulo Dragons não estiver na árvore integrada.
	observePrompt(sanctuaryStone, "Santuário de Varkhion", "santuario")

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
		local ok, accepted = pcall(function()
			return onEnterEmber and onEnterEmber(player)
		end)
		if not ok or accepted ~= true then
			releaseTransit(player)
			if not ok then
				warn("[Hub] Ember entry failed: " .. tostring(accepted))
				Hub.notify(player, "Não foi possível entrar em Ember. Tente novamente.")
			else
				Hub.notify(player, "Guardião de Ember já está em combate · aguarde")
			end
		else
			-- Entrada aceita pelo servidor de Ember: objetivo do portal concluído.
			Hub.completeObjective(player, "portal")
		end
	end)

	-- Retorno ao hub (ligado pelo Sol em Ember.connectReturn): libera o
	-- jogador para novas tentativas e devolve o corpo ao spawn.
	local function returnToHub(player)
		-- Explicit acknowledgment: a missing/dead character or failed PivotTo
		-- must NOT clear an Ember encounter or Latunia travel state.
		if not player or player.Parent ~= Players then return false end
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if not root or not humanoid or humanoid.Health <= 0 then return false end
		local destination = CFrame.new(spawn.Position + Vector3.new(0, 4, 0))
		local ok, err = pcall(function()
			character:PivotTo(destination)
		end)
		if not ok then
			warn("[Hub] return teleport failed: " .. tostring(err))
			return false
		end
		if player.Character ~= character or not root.Parent
			or (root.Position - destination.Position).Magnitude > 12 then
			warn("[Hub] return teleport did not reach the hub spawn")
			return false
		end
		releaseTransit(player)
		return true
	end
	return returnToHub, releaseTransit
end

return Hub
