-- Vila Central (Latúnia, Fase Atlas): primeira ilha do arquipélago em 3D,
-- construída a leste do hub de Aetheria seguindo o concept art
-- concept-art/latunia/glm/vila-central.svg e a decisão
-- docs/decisions/0006-latunia-vila-central-3d.md.
-- Responsável nesta rodada: GLM 5.3 (branch glm/latunia-vila-central).
--
-- Auto-montagem: este script é um .server.luau em src/server, então o Rojo
-- o carrega em ServerScriptService.Mythragon sem qualquer alteração em
-- Start.server.luau (arquivo do Codex nesta rodada). Ele aguarda o mapa
-- base (workspace.MythragonMap.Hub) e anexa o modelo VilaCentral como
-- IRMÃO de Hub. Montagem única e idempotente.
--
-- Layout (coordenadas do mundo; hub ocupa X -33..33, Aetheria X -99..-33):
--   * Deck principal 66x52 em X 39..105 (mesma altura do hub, topo Y = 0).
--   * Docas da Vila (1): deck inferior ao sul (topo Y -5,5), escadaria,
--     guindastes e dirigível atracado.
--   * Mercado de Ferro e Vidro (2) e Bairro das Oficinas (5) no deck
--     principal.
--   * Praça da Torre-Relógio (3): terraço superior (topo Y 8) sustentado
--     por pilares, com escadaria e a torre com relógio dourado.
--   * Elevador a Vapor (4): dois elevadores com teleporte validado no
--     servidor (Touched + cooldown por jogador) ligando docas -> deck
--     principal -> praça.
--   * Escadarias, tubos de latão e lampiões a gás guiam o trajeto.
--
-- Sem objetivos/selos aqui: progresso de Fase 1 permanece no Hub (Aetheria)
-- e no portal. Nenhum asset de terceiros: 100% procedural.

local Workspace = game:GetService("Workspace")

-- Paleta Latúnia (concept art): arenito cobre, ferro escuro, latão, vidro
-- âmbar e telhados de zinco envelhecido.
local STONE = Color3.fromRGB(96, 78, 60)
local STONE_DARK = Color3.fromRGB(64, 52, 40)
local IRON = Color3.fromRGB(46, 42, 48)
local BRASS = Color3.fromRGB(201, 162, 39)
local GLASS_AMBER = Color3.fromRGB(242, 178, 92)
local ZINC_ROOF = Color3.fromRGB(125, 138, 140)
local EMBER_GLOW = Color3.fromRGB(255, 157, 77)

local ELEVATOR_COOLDOWN = 1

local function part(parent, name, size, cframe, material, color)
	local value = Instance.new("Part")
	value.Name = name
	value.Anchored = true
	value.Size = size
	value.CFrame = cframe
	value.Material = material or Enum.Material.Slate
	value.Color = color or STONE
	value.Parent = parent
	return value
end

local function lamp(parent, name, position)
	local root = part(parent, name .. "Post", Vector3.new(0.7, 5, 0.7),
		CFrame.new(position + Vector3.new(0, 2.5, 0)), Enum.Material.Metal, IRON)
	local bulb = part(parent, name .. "Bulb", Vector3.new(1.4, 1.8, 1.4),
		CFrame.new(position + Vector3.new(0, 5.2, 0)), Enum.Material.Neon, GLASS_AMBER)
	local light = Instance.new("PointLight")
	light.Color = GLASS_AMBER
	light.Range = 14
	light.Brightness = 1.1
	light.Parent = bulb
	return root
end

local function smoke(parent, name, position)
	-- Coluna de fumaça: esferas translúcidas subindo da chaminé.
	for index = 1, 3 do
		local puff = part(parent, name .. index,
			Vector3.new(1.6 + index * 0.5, 1.2 + index * 0.4, 1.6 + index * 0.5),
			CFrame.new(position + Vector3.new(index * 0.4, index * 1.7, 0)),
			Enum.Material.Neon, Color3.fromRGB(190, 186, 182))
		puff.Transparency = 0.35 + index * 0.15
		puff.CanCollide = false
		puff.CanQuery = false
	end
end

local function house(parent, name, position, width, depth)
	part(parent, name .. "Body", Vector3.new(width, 6, depth),
		CFrame.new(position + Vector3.new(0, 3, 0)), Enum.Material.Brick, STONE)
	part(parent, name .. "Roof", Vector3.new(width + 1.4, 1.2, depth + 1.4),
		CFrame.new(position + Vector3.new(0, 6.6, 0)), Enum.Material.CorrodedMetal, ZINC_ROOF)
	part(parent, name .. "Door", Vector3.new(1.6, 3, 0.3),
		CFrame.new(position + Vector3.new(0, 1.5, depth / 2)), Enum.Material.DarkStone, STONE_DARK)
	part(parent, name .. "Window", Vector3.new(1.4, 1.4, 0.25),
		CFrame.new(position + Vector3.new(width * 0.28, 3.4, depth / 2)),
		Enum.Material.Neon, GLASS_AMBER)
	-- Chaminé com vapor de oficina.
	part(parent, name .. "Chimney", Vector3.new(1, 2.6, 1),
		CFrame.new(position + Vector3.new(width * 0.32, 7.6, -depth * 0.2)),
		Enum.Material.Brick, STONE_DARK)
	smoke(parent, name .. "Smoke", position + Vector3.new(width * 0.32, 9, -depth * 0.2))
end

local function crane(parent, name, position)
	-- Guindaste de doca: torre, braço e gancho.
	part(parent, name .. "Mast", Vector3.new(1.2, 11, 1.2),
		CFrame.new(position + Vector3.new(0, 5.5, 0)), Enum.Material.Metal, IRON)
	part(parent, name .. "Arm", Vector3.new(1, 0.8, 9),
		CFrame.new(position + Vector3.new(0, 10.6, 3.4)), Enum.Material.Metal, IRON)
	part(parent, name .. "Weight", Vector3.new(1.6, 1.4, 1.6),
		CFrame.new(position + Vector3.new(0, 10.2, -1.4)), Enum.Material.CorrodedMetal, IRON)
	part(parent, name .. "Cable", Vector3.new(0.25, 3.4, 0.25),
		CFrame.new(position + Vector3.new(0, 8.4, 7.4)), Enum.Material.Metal, BRASS)
	part(parent, name .. "Hook", Vector3.new(0.9, 0.9, 0.9),
		CFrame.new(position + Vector3.new(0, 6.4, 7.4)), Enum.Material.Metal, BRASS)
end

local function dirigible(parent, name, position)
	-- Dirigível atracado: envelope de esferas, cabine e amarras de latão.
	for index = 0, 4 do
		local offset = (index - 2) * 3.4
		local radius = (index == 0 or index == 4) and 2.4 or 3
		part(parent, name .. "Envelope" .. index,
			Vector3.new(radius * 2, radius * 1.8, radius * 2),
			CFrame.new(position + Vector3.new(offset, 0, 0)),
			Enum.Material.Fabric, Color3.fromRGB(122, 90, 67))
	end
	part(parent, name .. "Cabin", Vector3.new(4, 1.8, 2.4),
		CFrame.new(position + Vector3.new(0, -3.6, 0)), Enum.Material.Wood, Color3.fromRGB(78, 61, 42))
	part(parent, name .. "FinTop", Vector3.new(2.2, 1.4, 0.3),
		CFrame.new(position + Vector3.new(-7.6, 1.2, 0)), Enum.Material.Metal, BRASS)
	part(parent, name .. "FinSide", Vector3.new(2.2, 0.3, 1.4),
		CFrame.new(position + Vector3.new(-7.6, 0, 1.2)), Enum.Material.Metal, BRASS)
	-- Amarras até a doca.
	for _, offset in ipairs({ -4, 4 }) do
		local rope = part(parent, name .. "Mooring" .. offset,
			Vector3.new(0.25, 9, 0.25),
			CFrame.new(position + Vector3.new(offset, -4.6, 0)) * CFrame.Angles(math.rad(24), 0, 0),
			Enum.Material.Metal, BRASS)
		rope.CanCollide = false
		rope.CanQuery = false
	end
end

-- Elevador a vapor: dois pads; Touched no servidor teletransporta o
-- jogador para o pad oposto. Cooldown por jogador evita vaivém.
local function steamElevator(model, name, bottomCFrame, topCFrame)
	local shaftHeight = topCFrame.Position.Y - bottomCFrame.Position.Y
	local shaftCenter = (bottomCFrame.Position + topCFrame.Position) / 2
	for _, offset in ipairs({ Vector3.new(-2.4, 0, 0), Vector3.new(2.4, 0, 0) }) do
		part(model, name .. "Rail" .. offset.X,
			Vector3.new(0.5, shaftHeight + 3, 0.5),
			CFrame.new(shaftCenter + offset), Enum.Material.Metal, BRASS)
	end
	part(model, name .. "Glass", Vector3.new(4.4, shaftHeight + 2, 3.6),
		CFrame.new(shaftCenter + Vector3.new(0, 0, 1.9)), Enum.Material.Glass, GLASS_AMBER).Transparency = 0.72

	local cooldown = {}
	local function pad(padName, cframe, destinationCFrame)
		local padPart = part(model, name .. padName, Vector3.new(4, 0.5, 4), cframe,
			Enum.Material.Metal, BRASS)
		local steam = part(model, name .. padName .. "Steam",
			Vector3.new(2.6, 1.4, 2.6), cframe + Vector3.new(0, 1.6, 0),
			Enum.Material.Neon, Color3.fromRGB(210, 200, 196))
		steam.Transparency = 0.6
		steam.CanCollide = false
		steam.CanQuery = false
		padPart.Touched:Connect(function(hit)
			local character = hit.Parent
			if not character or not character:FindFirstChildOfClass("Humanoid") then
				return
			end
			local player = game:GetService("Players"):GetPlayerFromCharacter(character)
			if not player then
				return
			end
			local now = os.clock()
			if cooldown[player] and now - cooldown[player] < ELEVATOR_COOLDOWN then
				return
			end
			cooldown[player] = now
			local root = character:FindFirstChild("HumanoidRootPart")
			if root then
				character:PivotTo(destinationCFrame + Vector3.new(0, 3, 0))
			end
		end)
		return padPart
	end
	pad("PadBaixo", bottomCFrame, topCFrame)
	pad("PadTopo", topCFrame, bottomCFrame)
end

local function build(parent)
	if parent:FindFirstChild("VilaCentral") then
		return nil
	end

	local model = Instance.new("Model")
	model.Name = "VilaCentral"
	model.Parent = parent

	-- ===== Deck principal (mesma altura do hub de Aetheria) =====
	part(model, "VilaDeck", Vector3.new(66, 2, 52), CFrame.new(72, -1, 0),
		Enum.Material.Slate, STONE)
	local deckRocks = {
		{ Vector3.new(16, 9, 12), CFrame.new(76, -6, 16) * CFrame.Angles(0, 0, math.rad(5)) },
		{ Vector3.new(14, 8, 11), CFrame.new(90, -6.5, -16) * CFrame.Angles(0, 0, math.rad(-6)) },
		{ Vector3.new(12, 7, 10), CFrame.new(58, -6, -12) * CFrame.Angles(0, 0, math.rad(7)) },
	}
	for index, spec in ipairs(deckRocks) do
		part(model, "VilaRock" .. index, spec[1], spec[2], Enum.Material.Rock, STONE_DARK)
	end

	-- ===== Trajeto hub -> Vila Central (pedras ao leste, como na ala oeste) =====
	for index = 1, 3 do
		part(model, "VilaPathStone" .. index, Vector3.new(3.6, 0.4, 3),
			CFrame.new(36 + (index - 1) * 6, 0.2, 14), Enum.Material.Slate, STONE_DARK)
	end

	-- ===== (1) Docas da Vila: deck inferior ao sul + escadaria =====
	part(model, "DocasDeck", Vector3.new(46, 1, 16), CFrame.new(72, -6, 20),
		Enum.Material.WoodPlanks, Color3.fromRGB(90, 68, 46))
	-- Escadaria do deck principal (Z 26) descendo à doca (topo Y -5,5).
	for index = 1, 5 do
		part(model, "DocasStair" .. index, Vector3.new(4, 1, 1.2),
			CFrame.new(60, -0.5 - (index - 1), 26 + index - 0.5), Enum.Material.Slate, STONE_DARK)
	end
	part(model, "DocasStairLanding", Vector3.new(4, 1, 3),
		CFrame.new(60, -5, 31.5), Enum.Material.Slate, STONE_DARK)

	crane(model, "Guindaste1", Vector3.new(52, -5, 26))
	crane(model, "Guindaste2", Vector3.new(90, -5, 26))
	-- Amarras de latão na borda da doca.
	for index = 1, 6 do
		part(model, "DocasPost" .. index, Vector3.new(0.8, 2.2, 0.8),
			CFrame.new(50 + (index - 1) * 8, -4.4, 27.2), Enum.Material.Metal, BRASS)
	end
	dirigible(model, "DirigivelDoca", Vector3.new(58, 7, 25))
	dirigible(model, "DirigivelDoca2", Vector3.new(84, 8.5, 25))
	lamp(model, "LampiaoDoca1", Vector3.new(50, -5, 24))
	lamp(model, "LampiaoDoca2", Vector3.new(94, -5, 24))

	-- ===== (2) Mercado de Ferro e Vidro =====
	part(model, "MercadoBase", Vector3.new(20, 0.6, 13), CFrame.new(58, 0.3, -6),
		Enum.Material.Slate, STONE_DARK)
	for _, offset in ipairs({ -9, -3, 3, 9 }) do
		part(model, "MercadoPilar" .. offset, Vector3.new(0.9, 8, 0.9),
			CFrame.new(58 + offset, 4.6, -11.6), Enum.Material.Metal, IRON)
		part(model, "MercadoPilarF" .. offset, Vector3.new(0.9, 8, 0.9),
			CFrame.new(58 + offset, 4.6, -0.4), Enum.Material.Metal, IRON)
	end
	-- Cobertura de vidro âmbar em dois águas.
	for index = 0, 3 do
		local lean = (index % 2 == 0) and math.rad(14) or math.rad(-14)
		part(model, "MercadoTelhado" .. index, Vector3.new(4.8, 0.4, 14.4),
			CFrame.new(49.4 + index * 5.8, 9.4 + (index % 2) * 0.8, -6) * CFrame.Angles(0, 0, lean),
			Enum.Material.Glass, GLASS_AMBER).Transparency = 0.45
	end
	-- Bancas e mercadorias sob a cobertura.
	for index = 1, 3 do
		part(model, "MercadoBanca" .. index, Vector3.new(4, 1.2, 2),
			CFrame.new(52 + (index - 1) * 6, 1.2, -6), Enum.Material.Wood, Color3.fromRGB(120, 92, 62))
		part(model, "MercadoBem" .. index, Vector3.new(1, 1, 1),
			CFrame.new(52 + (index - 1) * 6, 2.4, -6), Enum.Material.Neon, EMBER_GLOW)
	end
	lamp(model, "LampiaoMercado", Vector3.new(58, 0, 1))

	-- ===== (5) Bairro das Oficinas =====
	house(model, "Oficina1", Vector3.new(82, 0, -10), 7, 6)
	house(model, "Oficina2", Vector3.new(92, 0, -10), 7, 6)
	house(model, "Oficina3", Vector3.new(87, 0, 2), 7, 6)
	house(model, "Oficina4", Vector3.new(98, 0, 2), 6, 6)
	-- Tubo de latão ligando as oficinas ao mercado.
	for index = 0, 4 do
		part(model, "TuboLatão" .. index, Vector3.new(0.8, 0.8, 3.4),
			CFrame.new(67 + index * 4.4, 0.9, -16) * CFrame.Angles(0, index % 2 == 0 and 0 or math.rad(4), 0),
			Enum.Material.Metal, BRASS)
	end
	lamp(model, "LampiaoOficinas", Vector3.new(88, 0, -5))

	-- ===== (3) Praça da Torre-Relógio: terraço superior + pilares =====
	part(model, "PracaDeck", Vector3.new(30, 1, 22), CFrame.new(76, 7.5, -14),
		Enum.Material.Slate, STONE)
	part(model, "PracaDeckLanding", Vector3.new(8, 1, 8), CFrame.new(95, 7.5, -14),
		Enum.Material.Slate, STONE)
	for _, spec in ipairs({ Vector3.new(63, -23), Vector3.new(89, -23), Vector3.new(63, -5), Vector3.new(89, -5) }) do
		part(model, "PracaPilar" .. spec.X .. spec.Y, Vector3.new(1.6, 7, 1.6),
			CFrame.new(spec.X, 3.5, spec.Y), Enum.Material.Metal, IRON)
	end
	-- Rosa-dos-ventos de latão no piso.
	part(model, "PracaRosa", Vector3.new(6, 0.25, 6), CFrame.new(76, 8.1, -12),
		Enum.Material.Neon, BRASS)
	part(model, "PracaRosaNorte", Vector3.new(1, 0.3, 4.6), CFrame.new(76, 8.15, -12),
		Enum.Material.Neon, GLASS_AMBER)

	-- Escadaria deck -> praça (subindo para leste a partir de X 54).
	for index = 1, 8 do
		part(model, "PracaStair" .. index, Vector3.new(1.2, 1, 4),
			CFrame.new(53.4 + index, index - 0.5, -8), Enum.Material.Slate, STONE_DARK)
	end

	-- Torre-Relógio: corpo, coroa, face dourada, ponteiros e relógio iluminado.
	part(model, "TorreCorpo", Vector3.new(6, 16, 6), CFrame.new(76, 16, -19),
		Enum.Material.Brick, STONE_DARK)
	part(model, "TorreCoroa", Vector3.new(7.4, 1.2, 7.4), CFrame.new(76, 24.4, -19),
		Enum.Material.CorrodedMetal, ZINC_ROOF)
	part(model, "TorrePinaculo", Vector3.new(1.2, 3, 1.2), CFrame.new(76, 26.4, -19),
		Enum.Material.Metal, BRASS)
	local face = part(model, "TorreRelogioFace", Vector3.new(3.4, 3.4, 0.5),
		CFrame.new(76, 21.6, -15.55), Enum.Material.Neon, GLASS_AMBER)
	part(model, "TorrePonteiroMin", Vector3.new(0.4, 2.6, 0.2), CFrame.new(76, 22.1, -15.35),
		Enum.Material.Metal, IRON)
	part(model, "TorrePonteiroHora", Vector3.new(2, 0.4, 0.2), CFrame.new(76.8, 21.6, -15.35),
		Enum.Material.Metal, IRON)
	local faceLight = Instance.new("PointLight")
	faceLight.Color = GLASS_AMBER
	faceLight.Range = 22
	faceLight.Brightness = 1.4
	faceLight.Parent = face

	-- ===== (4) Elevadores a Vapor =====
	-- Elevador 1: docas (topo Y -5,5) -> deck principal (topo Y 0).
	steamElevator(model, "Elevador1",
		CFrame.new(70, -5.25, 24),
		CFrame.new(70, 0.25, 24))
	-- Elevador 2: deck principal (topo Y 0) -> praça (topo Y 8, área de pouso).
	steamElevator(model, "Elevador2",
		CFrame.new(95, 0.25, -14),
		CFrame.new(95, 8.25, -14))

	-- Lampiões do trajeto principal.
	lamp(model, "LampiaoTrj1", Vector3.new(48, 0, 10))
	lamp(model, "LampiaoTrj2", Vector3.new(66, 0, 8))
	lamp(model, "LampiaoTrj3", Vector3.new(74, 0, 2))
	lamp(model, "LampiaoPraca", Vector3.new(70, 8, -8))

	return model
end

local function mount()
	-- O Start.server.luau (do Codex nesta rodada) cria MythragonMap e o Hub.
	local map = Workspace:FindFirstChild("MythragonMap")
	if not map then
		map = Workspace:WaitForChild("MythragonMap", 120)
	end
	if not map then
		warn("[Latunia] MythragonMap não apareceu em 120s; Vila Central não montada")
		return
	end
	if not map:FindFirstChild("Hub") then
		map:WaitForChild("Hub", 60)
	end
	build(map)
end

task.spawn(mount)
