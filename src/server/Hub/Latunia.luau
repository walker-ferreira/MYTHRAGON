-- Vila Central (Latúnia, Fase Atlas): primeira ilha do arquipélago em 3D,
-- construída seguindo o concept art concept-art/latunia/glm/vila-central.svg
-- e as decisões docs/decisions/0006-latunia-vila-central-3d.md e o review
-- GLM-R007 do Codex (docs/agents/CODEX.md).
-- Responsável nesta rodada: GLM 5.3 (branch glm/latunia-vila-central).
--
-- Contrato (GLM-R007/D, aceito): ModuleScript composto UMA VEZ no
-- Start.server.luau pelo Codex — sem bootstrap automático próprio:
--   local Latunia = require(script.Parent.Hub.Latunia)
--   Latunia.build(parent, anchorCFrame)  -- anchorCFrame opcional
--
-- Âncora: todas as posições são LOCAIS à Vila Central (deck principal
-- centrado em (0,-1,0), topo Y = 0). A âncora posiciona a ilha no mundo.
-- Default CFrame.new(72, 0, 0) reproduz o posicionamento histórico a leste
-- do hub; no layout L3D-001 (docs/agents/CODEX.md) a âncora vem do slot
-- Central do arquipélago (Layout.origin {2400,24,0}, slot {0,0,0}) —
-- aplicada também aos destinos dos elevadores.
--
-- Conteúdo (marcadores do concept art):
--   (1) Docas da Vila: deck inferior ao sul, escadaria contínua, 2
--       guindastes, amarras de latão e 2 dirigíveis atracados.
--   (2) Mercado de Ferro e Vidro: pilares de ferro, cobertura de vidro
--       âmbar em dois águas, bancas.
--   (3) Praça da Torre-Relógio: terraço superior com pilares, rosa-dos-
--       ventos e torre com relógio dourado iluminado.
--   (4) Elevador a Vapor: dois elevadores com teleporte validado no
--       servidor (Touched: personagem vivo, HumanoidRootPart presente e a
--       até 8 studs do pad; cooldown 1 s por jogador, limpo no
--       PlayerRemoving). Vidro decorativo sem colisão.
--   (5) Bairro das Oficinas: 4 casas com telhado de zinco e vapor.
--   Trajeto hub -> Vila: pedras contínuas de 6 studs sem vãos (GLM-R007/B).
--
-- Sem objetivos/selos aqui: progresso de Fase 1 permanece no Hub (Aetheria)
-- e no portal. Nenhum asset de terceiros: 100% procedural.

local Players = game:GetService("Players")

local Latunia = {}

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
	-- Coluna de vapor: esferas translúcidas subindo da chaminé.
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
		CFrame.new(position + Vector3.new(0, 1.5, depth / 2)), Enum.Material.Slate, STONE_DARK)
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
-- jogador para o pad oposto. Validação (GLM-R007/C): personagem atual do
-- jogador, Humanoid vivo, HumanoidRootPart presente e a até 8 studs do
-- pad. Cooldown por jogador, limpo no PlayerRemoving.
local function steamElevator(model, name, bottomCFrame, topCFrame)
	local shaftHeight = topCFrame.Position.Y - bottomCFrame.Position.Y
	local shaftCenter = (bottomCFrame.Position + topCFrame.Position) / 2
	for _, offset in ipairs({ Vector3.new(-2.4, 0, 0), Vector3.new(2.4, 0, 0) }) do
		part(model, name .. "Rail" .. offset.X,
			Vector3.new(0.5, shaftHeight + 3, 0.5),
			CFrame.new(shaftCenter + offset), Enum.Material.Metal, BRASS)
	end
	local glass = part(model, name .. "Glass", Vector3.new(4.4, shaftHeight + 2, 3.6),
		CFrame.new(shaftCenter + Vector3.new(0, 0, 2.8)), Enum.Material.Glass, GLASS_AMBER)
	glass.Transparency = 0.72
	-- Decorativo: fora do volume do pad e sem colisão (GLM-R007/C).
	glass.CanCollide = false
	glass.CanQuery = false

	local cooldown = {}
	Players.PlayerRemoving:Connect(function(player)
		cooldown[player] = nil
	end)

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
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			if not humanoid or humanoid.Health <= 0 then
				return
			end
			local player = Players:GetPlayerFromCharacter(character)
			if not player or player.Character ~= character then
				return
			end
			local root = character:FindFirstChild("HumanoidRootPart")
			if not root then
				return
			end
			if (root.Position - padPart.Position).Magnitude > 8 then
				return
			end
			local now = os.clock()
			if cooldown[player] and now - cooldown[player] < ELEVATOR_COOLDOWN then
				return
			end
			cooldown[player] = now
			character:PivotTo(destinationCFrame + Vector3.new(0, 3, 0))
		end)
		return padPart
	end
	pad("PadBaixo", bottomCFrame, topCFrame)
	pad("PadTopo", topCFrame, bottomCFrame)
end

-- Constrói a Vila Central sob `parent` (o modelo/folder do mapa), aplicada
-- pela âncora. Toda a construção é feita sem pai e o modelo só é parentado
-- ao FINAL (GLM-R007/A): se qualquer parte falhar, não sobra build parcial
-- para a checagem de idempotência considerar pronto.
function Latunia.build(parent, anchorCFrame)
	if not parent or parent:FindFirstChild("VilaCentral") then
		return nil
	end
	local anchor = anchorCFrame or CFrame.new(72, 0, 0)
	-- Atalho: transforma um CFrame local da ilha em CFrame do mundo.
	local function A(localCFrame)
		return anchor * localCFrame
	end

	local model = Instance.new("Model")
	model.Name = "VilaCentral"

	-- ===== Deck principal (topo Y = 0 relativo à âncora) =====
	part(model, "VilaDeck", Vector3.new(66, 2, 52), A(CFrame.new(0, -1, 0)),
		Enum.Material.Slate, STONE)
	local deckRocks = {
		{ Vector3.new(16, 9, 12), A(CFrame.new(4, -6, 16) * CFrame.Angles(0, 0, math.rad(5))) },
		{ Vector3.new(14, 8, 11), A(CFrame.new(18, -6.5, -16) * CFrame.Angles(0, 0, math.rad(-6))) },
		{ Vector3.new(12, 7, 10), A(CFrame.new(-14, -6, -12) * CFrame.Angles(0, 0, math.rad(7))) },
	}
	for index, spec in ipairs(deckRocks) do
		part(model, "VilaRock" .. index, spec[1], spec[2], Enum.Material.Rock, STONE_DARK)
	end

	-- ===== Trajeto contínuo hub -> Vila Central (GLM-R007/B) =====
	-- Pedras de 6 studs em X -36/-30/-24 cobrem sem vãos a faixa
	-- X -39..-21 (a borda do hub está em X -39 relativo).
	for index = 1, 3 do
		part(model, "VilaPathStone" .. index, Vector3.new(6, 0.4, 4),
			A(CFrame.new(-12 - (3 - index) * 6, 0.2, 14)), Enum.Material.Slate, STONE_DARK)
	end

	-- ===== (1) Docas da Vila: deck inferior ao sul + escadaria =====
	-- Deck de Z 12..34: a plataforma de pouso (Z 30..33) fica sobre ele.
	part(model, "DocasDeck", Vector3.new(46, 1, 22), A(CFrame.new(0, -6, 23)),
		Enum.Material.WoodPlanks, Color3.fromRGB(90, 68, 46))
	for index = 1, 5 do
		part(model, "DocasStair" .. index, Vector3.new(4, 1, 1.2),
			A(CFrame.new(-12, -0.5 - (index - 1), 26 + index - 0.5)), Enum.Material.Slate, STONE_DARK)
	end
	part(model, "DocasStairLanding", Vector3.new(4, 1, 3),
		A(CFrame.new(-12, -5, 31.5)), Enum.Material.Slate, STONE_DARK)

	crane(model, "Guindaste1", Vector3.new(-20, -5, 26))
	crane(model, "Guindaste2", Vector3.new(18, -5, 26))
	for index = 1, 6 do
		part(model, "DocasPost" .. index, Vector3.new(0.8, 2.2, 0.8),
			A(CFrame.new(-22 + (index - 1) * 8, -4.4, 27.2)), Enum.Material.Metal, BRASS)
	end
	dirigible(model, "DirigivelDoca", Vector3.new(-14, 7, 25))
	dirigible(model, "DirigivelDoca2", Vector3.new(12, 8.5, 25))
	lamp(model, "LampiaoDoca1", Vector3.new(-22, -5, 24))
	lamp(model, "LampiaoDoca2", Vector3.new(22, -5, 24))

	-- ===== (2) Mercado de Ferro e Vidro =====
	part(model, "MercadoBase", Vector3.new(20, 0.6, 13), A(CFrame.new(-14, 0.3, -6)),
		Enum.Material.Slate, STONE_DARK)
	for _, offset in ipairs({ -9, -3, 3, 9 }) do
		part(model, "MercadoPilar" .. offset, Vector3.new(0.9, 8, 0.9),
			A(CFrame.new(-14 + offset, 4.6, -11.6)), Enum.Material.Metal, IRON)
		part(model, "MercadoPilarF" .. offset, Vector3.new(0.9, 8, 0.9),
			A(CFrame.new(-14 + offset, 4.6, -0.4)), Enum.Material.Metal, IRON)
	end
	for index = 0, 3 do
		local lean = (index % 2 == 0) and math.rad(14) or math.rad(-14)
		local roof = part(model, "MercadoTelhado" .. index, Vector3.new(4.8, 0.4, 14.4),
			A(CFrame.new(-22.6 + index * 5.8, 9.4 + (index % 2) * 0.8, -6) * CFrame.Angles(0, 0, lean)),
			Enum.Material.Glass, GLASS_AMBER)
		roof.Transparency = 0.45
	end
	for index = 1, 3 do
		part(model, "MercadoBanca" .. index, Vector3.new(4, 1.2, 2),
			A(CFrame.new(-20 + (index - 1) * 6, 1.2, -6)), Enum.Material.Wood, Color3.fromRGB(120, 92, 62))
		part(model, "MercadoBem" .. index, Vector3.new(1, 1, 1),
			A(CFrame.new(-20 + (index - 1) * 6, 2.4, -6)), Enum.Material.Neon, EMBER_GLOW)
	end
	lamp(model, "LampiaoMercado", Vector3.new(-14, 0, 1))

	-- ===== (5) Bairro das Oficinas =====
	house(model, "Oficina1", Vector3.new(10, 0, -10), 7, 6)
	house(model, "Oficina2", Vector3.new(20, 0, -10), 7, 6)
	house(model, "Oficina3", Vector3.new(15, 0, 2), 7, 6)
	house(model, "Oficina4", Vector3.new(26, 0, 2), 6, 6)
	for index = 0, 4 do
		part(model, "TuboLatao" .. index, Vector3.new(0.8, 0.8, 3.4),
			A(CFrame.new(-5 + index * 4.4, 0.9, -16) * CFrame.Angles(0, index % 2 == 0 and 0 or math.rad(4), 0)),
			Enum.Material.Metal, BRASS)
	end
	lamp(model, "LampiaoOficinas", Vector3.new(16, 0, -5))

	-- ===== (3) Praça da Torre-Relógio: terraço superior + pilares =====
	part(model, "PracaDeck", Vector3.new(30, 1, 22), A(CFrame.new(4, 7.5, -14)),
		Enum.Material.Slate, STONE)
	part(model, "PracaDeckLanding", Vector3.new(8, 1, 8), A(CFrame.new(23, 7.5, -14)),
		Enum.Material.Slate, STONE)
	for _, spec in ipairs({ { -9, -23 }, { 17, -23 }, { -9, -5 }, { 17, -5 } }) do
		part(model, "PracaPilar" .. spec[1] .. "_" .. spec[2], Vector3.new(1.6, 7, 1.6),
			A(CFrame.new(spec[1], 3.5, spec[2])), Enum.Material.Metal, IRON)
	end
	part(model, "PracaRosa", Vector3.new(6, 0.25, 6), A(CFrame.new(4, 8.1, -12)),
		Enum.Material.Neon, BRASS)
	part(model, "PracaRosaNorte", Vector3.new(1, 0.3, 4.6), A(CFrame.new(4, 8.15, -12)),
		Enum.Material.Neon, GLASS_AMBER)
	for index = 1, 8 do
		part(model, "PracaStair" .. index, Vector3.new(1.2, 1, 4),
			A(CFrame.new(-18.6 + index, index - 0.5, -8)), Enum.Material.Slate, STONE_DARK)
	end

	-- Torre-Relógio: corpo, coroa, face dourada, ponteiros e luz.
	part(model, "TorreCorpo", Vector3.new(6, 16, 6), A(CFrame.new(4, 16, -19)),
		Enum.Material.Brick, STONE_DARK)
	part(model, "TorreCoroa", Vector3.new(7.4, 1.2, 7.4), A(CFrame.new(4, 24.4, -19)),
		Enum.Material.CorrodedMetal, ZINC_ROOF)
	part(model, "TorrePinaculo", Vector3.new(1.2, 3, 1.2), A(CFrame.new(4, 26.4, -19)),
		Enum.Material.Metal, BRASS)
	local face = part(model, "TorreRelogioFace", Vector3.new(3.4, 3.4, 0.5),
		A(CFrame.new(4, 21.6, -15.55)), Enum.Material.Neon, GLASS_AMBER)
	part(model, "TorrePonteiroMin", Vector3.new(0.4, 2.6, 0.2), A(CFrame.new(4, 22.1, -15.35)),
		Enum.Material.Metal, IRON)
	part(model, "TorrePonteiroHora", Vector3.new(2, 0.4, 0.2), A(CFrame.new(4.8, 21.6, -15.35)),
		Enum.Material.Metal, IRON)
	local faceLight = Instance.new("PointLight")
	faceLight.Color = GLASS_AMBER
	faceLight.Range = 22
	faceLight.Brightness = 1.4
	faceLight.Parent = face

	-- ===== (4) Elevadores a Vapor (destinos também pela âncora) =====
	-- Elevador 1: docas (topo Y -5,5) -> deck principal (topo Y 0).
	steamElevator(model, "Elevador1",
		A(CFrame.new(-2, -5.25, 24)),
		A(CFrame.new(-2, 0.25, 24)))
	-- Elevador 2: deck principal (topo Y 0) -> praça (topo Y 8, pouso leste).
	steamElevator(model, "Elevador2",
		A(CFrame.new(23, 0.25, -14)),
		A(CFrame.new(23, 8.25, -14)))

	-- Lampiões do trajeto principal.
	lamp(model, "LampiaoTrj1", Vector3.new(-24, 0, 10))
	lamp(model, "LampiaoTrj2", Vector3.new(-6, 0, 8))
	lamp(model, "LampiaoTrj3", Vector3.new(2, 0, 2))
	lamp(model, "LampiaoPraca", Vector3.new(-2, 8, -8))

	model.Parent = parent
	return model
end

return Latunia
