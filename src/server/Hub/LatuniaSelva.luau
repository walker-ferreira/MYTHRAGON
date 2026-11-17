-- Ilha da Selva (Latúnia): decorações GLM sobre o cenário base do Codex
-- (Expansion.jungle, PR #21). Preserva 100% do trabalho existente: o
-- módulo roda o cenário base primeiro e só adiciona camadas por cima.
-- Novidades: cachoeira Esmeralda com poço, mirante das copas, templo
-- interior com altar, totem, cipós, tochas e posto de NPC. Coordenadas
-- locais ao anchor; posições de LatuniaIslandsData (fonte única).
local Build = require(script.Parent.Parent.Latunia.Codex.Build)
local Expansion = require(script.Parent.Parent.Latunia.Codex.Expansion)
local Data = require(script.Parent.LatuniaIslandsData)

local LatuniaSelva = {}

local GREEN = Color3.fromRGB(69, 122, 75)
local GREEN_DARK = Color3.fromRGB(37, 78, 52)
local BARK = Color3.fromRGB(83, 66, 48)
local STONE = Color3.fromRGB(115, 124, 104)
local MOSS = Color3.fromRGB(70, 130, 80)
local BRASS = Color3.fromRGB(201, 162, 39)
local FLAME = Color3.fromRGB(255, 150, 60)
local VINE = Color3.fromRGB(52, 110, 60)
local WATER = Color3.fromRGB(110, 190, 180)
local TORCH = Color3.fromRGB(150, 240, 170)

local function block(parent, name, anchor, offset, size, color, material, collide, shape)
	return Build.part(parent, name, size, anchor * CFrame.new(offset), color, material, collide, shape)
end

local function label(parent, text, offset, distance)
	return Build.label(parent, text, offset, distance or 150)
end

local function sparkle(parent, color, rate)
	local emitter = Instance.new("ParticleEmitter")
	emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	emitter.Rate = rate or 2
	emitter.Lifetime = NumberRange.new(1.5, 3)
	emitter.Speed = NumberRange.new(0.5, 1.5)
	emitter.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.6), NumberSequenceKeypoint.new(1, 0.1) })
	emitter.Color = ColorSequence.new(color)
	emitter.LightEmission = 0.8
	emitter.Parent = parent
	return emitter
end

local function torch(parent, name, anchor, x, z, color)
	block(parent, name .. "Poste", anchor, Vector3.new(x, 2.2, z),
		Vector3.new(0.6, 4.4, 0.6), BARK, Enum.Material.Wood)
	local flame = block(parent, name .. "Chama", anchor, Vector3.new(x, 5, z),
		Vector3.new(1, 1.6, 1), color or FLAME, Enum.Material.Neon, false)
	local light = Instance.new("PointLight")
	light.Color = color or FLAME
	light.Range = 13
	light.Brightness = 1
	light.Parent = flame
	sparkle(flame, color or FLAME, 1.5)
	return flame
end

local function vine(parent, name, anchor, x, yTop, z, length)
	-- Cipó pendurado: fio verde fino com folha na ponta.
	local rope = block(parent, name, anchor, Vector3.new(x, yTop - length / 2, z),
		Vector3.new(0.4, length, 0.4), VINE, Enum.Material.Grass, false)
	rope.CanQuery = false
	block(parent, name .. "Folha", anchor, Vector3.new(x, yTop - length, z),
		Vector3.new(1.6, 0.5, 1.6), GREEN, Enum.Material.Grass, false)
	return rope
end

function LatuniaSelva.build(content, anchor)
	assert(typeof(anchor) == "CFrame", "Selva requer o anchor do slot (contrato L3D-001)")

	-- 1. Cenário base do Codex (PR #21), preservado.
	local baseOk, baseError = pcall(Expansion.jungle, content, anchor)
	if not baseOk then
		warn("[LatuniaSelva] cenário base falhou; aplicando somente decorações GLM: " .. tostring(baseError))
	end

	local world = Build.model(content, "SelvaGLM")

	-- 2. Lajes de caminho novas (dados testados pela CI).
	for _, path in ipairs(Data.Selva.paths) do
		if not path.base then
			block(world, "TrilhaGLM", anchor,
				Vector3.new(path.x, 0.3, path.z),
				Vector3.new(path.dx, 0.6, path.dz), MOSS, Enum.Material.Slate)
		end
	end

	-- 3. Cachoeira Esmeralda: paredão, cortina de vidro, poço e névoa leve.
	local fall = Data.find("Selva", "landmarks", "Cachoeira Esmeralda")
	if fall then
		local fx, fz = fall.x, fall.z
		block(world, "CachoeiraParedao", anchor, Vector3.new(fx, 11, fz - 4),
			Vector3.new(30, 22, 8), STONE, Enum.Material.Rock)
		local sheet = block(world, "CachoeiraAgua", anchor, Vector3.new(fx, 10, fz + 1),
			Vector3.new(14, 20, 0.8), WATER, Enum.Material.Glass, false)
		sheet.Transparency = 0.35
		sheet.CFrame = anchor * CFrame.new(fx, 10, fz + 1) * CFrame.Angles(math.rad(-8), 0, 0)
		-- Poço raso: vidro caminhável circundado por pedras com musgo.
		local pool = Build.part(world, "CachoeiraPoco", Vector3.new(0.5, 26, 26),
			anchor * CFrame.new(fx, 0.25, fz + 14) * CFrame.Angles(0, 0, math.rad(90)),
			WATER, Enum.Material.Glass, true, "Cylinder")
		pool.Transparency = 0.25
		for index = 0, 7 do
			local angle = index * math.pi / 4
			block(world, "PocoPedra" .. index, anchor,
				Vector3.new(fx + math.cos(angle) * 13.6, 0.6, fz + 14 + math.sin(angle) * 13.6),
				Vector3.new(3.6, 1.4, 3.6), STONE, Enum.Material.Rock, false)
		end
		local mist = block(world, "CachoeiraNevoa", anchor, Vector3.new(fx, 2.2, fz + 9),
			Vector3.new(10, 3, 10), WATER, Enum.Material.Neon, false)
		mist.Transparency = 0.85
		mist.CanQuery = false
		sparkle(mist, WATER, 2.5)
	end

	-- 4. Mirante das Copas: clareira com pedra talhada, tochas e cipós.
	local lookout = Data.find("Selva", "landmarks", "Mirante das Copas")
	if lookout then
		local lx, lz = lookout.x, lookout.z
		block(world, "MirantePiso", anchor, Vector3.new(lx, 0.15, lz),
			Vector3.new(20, 0.3, 18), MOSS, Enum.Material.Slate)
		block(world, "MirantePedra", anchor, Vector3.new(lx, 4, lz),
			Vector3.new(6, 8, 5), STONE, Enum.Material.Slate)
		local eyes = block(world, "MiranteOlhos", anchor, Vector3.new(lx, 5.4, lz + 2.7),
			Vector3.new(3.4, 0.8, 0.3), TORCH, Enum.Material.Neon, false)
		sparkle(eyes, TORCH, 1)
		label(eyes, "Mirante das Copas\nexploração · sem missão", Vector3.new(0, 6, 0), 90)
		torch(world, "TochaMiranteA", anchor, lx - 7, lz + 6)
		torch(world, "TochaMiranteB", anchor, lx + 7, lz + 6)
	end

	-- 5. Totem da Copa: marco no caminho leste.
	local totem = Data.find("Selva", "landmarks", "Totem da Copa")
	if totem then
		local tx, tz = totem.x, totem.z
		for level = 0, 2 do
			block(world, "TotemBloco" .. level, anchor, Vector3.new(tx, 1.6 + level * 2.8, tz),
				Vector3.new(3 - level * 0.4, 2.8, 3 - level * 0.4),
				level % 2 == 0 and STONE or MOSS, Enum.Material.Slate)
		end
		local face = block(world, "TotemFace", anchor, Vector3.new(tx, 6.6, tz + 1.3),
			Vector3.new(1.8, 0.7, 0.3), FLAME, Enum.Material.Neon, false)
		local light = Instance.new("PointLight")
		light.Color = FLAME
		light.Range = 14
		light.Brightness = 0.9
		light.Parent = face
	end

	-- 6. Interior do templo: altar, braseiros verdes e arcos em ruína.
	local altar = block(world, "AltarAntigo", anchor, Vector3.new(-75, 5, 0),
		Vector3.new(5, 2.4, 5), STONE, Enum.Material.Slate)
	local altarTop = block(world, "AltarBrilho", anchor, Vector3.new(-75, 6.4, 0),
		Vector3.new(3.4, 0.4, 3.4), TORCH, Enum.Material.Neon, false)
	sparkle(altarTop, TORCH, 1.5)
	torch(world, "BraseiroTemploA", anchor, -88, -14, TORCH)
	torch(world, "BraseiroTemploB", anchor, -62, 14, TORCH)
	for _, spec in ipairs({
		{ -96, -34 }, { -96, 34 }, { -54, -34 }, { -54, 34 },
	}) do
		-- Arco em ruína: duas colunas quebradas + verga caída.
		block(world, "ArcoColunaA", anchor, Vector3.new(spec[1], 4.5, spec[2]),
			Vector3.new(3, 9, 3), STONE, Enum.Material.Slate)
		block(world, "ArcoColunaB", anchor, Vector3.new(spec[1] + 7, 3, spec[2] + 3),
			Vector3.new(3, 6, 3), STONE, Enum.Material.Slate)
		block(world, "ArcoVerga", anchor, Vector3.new(spec[1] + 3.5, 8.2, spec[2] + 1.5),
			Vector3.new(11, 2, 3), STONE, Enum.Material.Slate, false)
	end

	-- 7. Cipós pendurados nas copas existentes do Codex.
	for _, spec in ipairs({
		{ -105, -85, 22 }, { -91, 62, 18 }, { -64, -40, 21 },
		{ 30, -87, 20 }, { 61, 89, 23 }, { 9, 58, 20 },
	}) do
		vine(world, "Cipo" .. spec[1] .. "_" .. spec[2], anchor, spec[1] + 3, spec[3] + 8, spec[2] + 2, spec[3] * 0.5)
	end

	-- 8. Posto do Mercador das Vinhas: local preparado para NPC.
	local spot = Data.find("Selva", "spots", "Mercador das Vinhas (NPC)")
	if spot then
		local sx, sz = spot.x, spot.z
		block(world, "MercadorPiso", anchor, Vector3.new(sx, 0.15, sz),
			Vector3.new(spot.dx, 0.3, spot.dz), BARK, Enum.Material.WoodPlanks)
		-- Barraca: quatro esteios + toldo de folhas + banca.
		for _, offset in ipairs({ { -1, -1 }, { 1, -1 }, { -1, 1 }, { 1, 1 } }) do
			block(world, "MercadorEsteio" .. offset[1] .. offset[2], anchor,
				Vector3.new(sx + offset[1] * (spot.dx / 2 - 1), 3, sz + offset[2] * (spot.dz / 2 - 1)),
				Vector3.new(0.7, 6, 0.7), BARK, Enum.Material.Wood)
		end
		local canopy = block(world, "MercadorToldo", anchor, Vector3.new(sx, 6.4, sz),
			Vector3.new(spot.dx + 2, 0.8, spot.dz + 2), GREEN, Enum.Material.Grass)
		canopy.CFrame = anchor * CFrame.new(sx, 6.4, sz) * CFrame.Angles(0, 0, math.rad(4))
		block(world, "MercadorBanca", anchor, Vector3.new(sx, 1.4, sz + 2),
			Vector3.new(6, 1, 2.4), BARK, Enum.Material.Wood)
		for index = 1, 3 do
			block(world, "MercadorBem" .. index, anchor,
				Vector3.new(sx - 1.6 + index * 1.6, 2.4, sz + 2),
				Vector3.new(0.9, 0.9, 0.9), TORCH, Enum.Material.Neon, false)
		end
		local medallion = Build.part(world, "MercadorNPCPonto", Vector3.new(0.2, 2.6, 2.6),
			anchor * CFrame.new(sx - 1, 0.42, sz - 1) * CFrame.Angles(0, 0, math.rad(90)),
			BRASS, Enum.Material.Neon, false, "Cylinder")
		label(medallion, "Mercador das Vinhas\nchega em breve", Vector3.new(0, 5, 0), 70)
	end

	-- 9. Tochas ao longo do caminho principal (iluminação quente).
	torch(world, "TochaTrilhaA", anchor, 60, 8)
	torch(world, "TochaTrilhaB", anchor, 20, -8)
	torch(world, "TochaTrilhaC", anchor, -14, 8)

	return world
end

return LatuniaSelva
