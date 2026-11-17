-- Ilha do Gelo (Latúnia): decorações GLM sobre o cenário base do Codex
-- (Expansion.ice, PR #21). Preserva 100% do trabalho existente: o módulo
-- roda o cenário base primeiro e só adiciona camadas por cima.
-- Novidades: conector do observatório (fecha vão de acesso), caverna de
-- cristal, lago congelado, floresta de coníferas, monolito rúnico, posto
-- de NPC e placas de orientação. Coordenadas locais ao anchor do slot;
-- posições vêm de LatuniaIslandsData (fonte única, testada pela CI).
local Build = require(script.Parent.Parent.Latunia.Codex.Build)
local Expansion = require(script.Parent.Parent.Latunia.Codex.Expansion)
local Data = require(script.Parent.LatuniaIslandsData)

local LatuniaGelo = {}

local ICE_WHITE = Color3.fromRGB(225, 238, 244)
local ICE_BLUE = Color3.fromRGB(120, 180, 210)
local ICE_DEEP = Color3.fromRGB(70, 120, 160)
local STONE_GREY = Color3.fromRGB(96, 107, 121)
local WOOD_DARK = Color3.fromRGB(74, 58, 44)
local BRASS = Color3.fromRGB(201, 162, 39)
local FLAME = Color3.fromRGB(122, 200, 255)
local SNOW = Color3.fromRGB(240, 246, 250)

local function block(parent, name, anchor, offset, size, color, material, collide, shape)
	return Build.part(parent, name, size, anchor * CFrame.new(offset), color, material, collide, shape)
end

local function label(parent, text, offset, distance)
	return Build.label(parent, text, offset, distance or 150)
end

local function sparkle(parent, _position, color, rate)
	local emitter = Instance.new("ParticleEmitter")
	emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	emitter.Rate = rate or 2
	emitter.Lifetime = NumberRange.new(1.5, 3)
	emitter.Speed = NumberRange.new(0.5, 1.5)
	emitter.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.6), NumberSequenceKeypoint.new(1, 0.1) })
	emitter.Color = ColorSequence.new(color or FLAME)
	emitter.LightEmission = 0.8
	emitter.Parent = parent
	return emitter
end

local function crystalCluster(parent, name, anchor, x, z, height, color)
	-- Cristal: 3 cunhas de vidro inclinadas com luz fria.
	local base = Vector3.new(x, 0, z)
	for index = 0, 2 do
		local angle = index * 120
		block(parent, name .. index, anchor,
			base + Vector3.new(math.cos(math.rad(angle)) * 2, height * 0.4, math.sin(math.rad(angle)) * 2),
			Vector3.new(2.4, height, 2.4), color, Enum.Material.Glass, true, "Wedge")
	end
	local light = Instance.new("PointLight")
	light.Color = color
	light.Range = 12
	light.Brightness = 0.9
	local core = block(parent, name .. "Core", anchor, base + Vector3.new(0, height * 0.5, 0),
		Vector3.new(1.2, height * 0.8, 1.2), color, Enum.Material.Neon, false)
	light.Parent = core
	sparkle(core, base, color, 1.5)
end

local function conifer(parent, name, anchor, x, z, height)
	-- Conífera congelada: tronco escuro + 3 pisos nevados.
	local trunk = block(parent, name .. "Trunk", anchor, Vector3.new(x, height * 0.25, z),
		Vector3.new(1.6, height * 0.5, 1.6), WOOD_DARK, Enum.Material.Wood)
	for tier = 0, 2 do
		local size = 9 - tier * 2.6
		block(parent, name .. "Tier" .. tier, anchor,
			Vector3.new(x, height * 0.5 + 2 + tier * 3.2, z),
			Vector3.new(size, 3.4, size), tier == 2 and SNOW or Color3.fromRGB(58, 110, 96),
			Enum.Material.Grass, true, "Wedge")
	end
	local cap = block(parent, name .. "Cap", anchor, Vector3.new(x, height + 2.6, z),
		Vector3.new(2.2, 2, 2.2), SNOW, Enum.Material.Snow, false)
	_ = trunk
	return cap
end

local function brazier(parent, name, anchor, x, z, color)
	-- Braseiro de latão com chama fria (gelo) ou quente (selva).
	block(parent, name .. "Base", anchor, Vector3.new(x, 0.6, z),
		Vector3.new(1.6, 1.2, 1.6), BRASS, Enum.Material.Metal)
	local bowl = block(parent, name .. "Bowl", anchor, Vector3.new(x, 1.5, z),
		Vector3.new(2.2, 0.8, 2.2), BRASS, Enum.Material.Metal, false)
	local flame = block(parent, name .. "Flame", anchor, Vector3.new(x, 2.6, z),
		Vector3.new(1.2, 1.8, 1.2), color or FLAME, Enum.Material.Neon, false)
	local light = Instance.new("PointLight")
	light.Color = color or FLAME
	light.Range = 13
	light.Brightness = 1.1
	light.Parent = flame
	sparkle(flame, Vector3.new(x, 2.6, z), color or FLAME, 2)
	_ = bowl
	return flame
end

local function signpost(parent, anchor, x, z, rotation, text)
	local post = block(parent, "Placa" .. x .. "_" .. z, anchor, Vector3.new(x, 2.4, z),
		Vector3.new(0.5, 4.8, 0.5), WOOD_DARK, Enum.Material.Wood)
	local board = block(parent, "PlacaTexto" .. x .. "_" .. z, anchor, Vector3.new(x, 4.2, z),
		Vector3.new(0.3, 1.6, 4), Color3.fromRGB(120, 92, 62), Enum.Material.Wood, false)
	board.CFrame = anchor * CFrame.new(x, 4.2, z) * CFrame.Angles(0, math.rad(rotation), 0)
	label(board, text, Vector3.new(0, 0, 0), 60)
	_ = post
end

function LatuniaGelo.build(content, anchor)
	assert(typeof(anchor) == "CFrame", "Gelo requer o anchor do slot (contrato L3D-001)")

	-- 1. Cenário base do Codex (PR #21), preservado. Se falhar, as
	--    decorações GLM continuam (a montagem por ilha já é pcall no Map).
	local baseOk, baseError = pcall(Expansion.ice, content, anchor)
	if not baseOk then
		warn("[LatuniaGelo] cenário base falhou; aplicando somente decorações GLM: " .. tostring(baseError))
	end

	local world = Build.model(content, "GeloGLM")

	-- 2. Conector do observatório: fecha o vão Z -39..-4 (acessibilidade).
	for _, path in ipairs(Data.Gelo.paths) do
		if not path.base then
			local top = 0.6
			block(world, "TrilhaGLM", anchor,
				Vector3.new(path.x, top - 0.3, path.z),
				Vector3.new(path.dx, 0.6, path.dz), ICE_BLUE, Enum.Material.Ice)
		end
	end
	-- Escadaria de gelo do conector ao deck do observatório (topo Y 4).
	for step = 0, 3 do
		block(world, "FrozenStair" .. step, anchor,
			Vector3.new(0, 0.5 + step, -36 - step),
			Vector3.new(14, 1 + step * 2, 1), ICE_BLUE, Enum.Material.Ice)
	end

	-- 3. Caverna de Cristal (oeste): sala com cristais e luz fria.
	local cavern = Data.find("Gelo", "landmarks", "Caverna de Cristal")
	if cavern then
		local cx, cz = cavern.x, cavern.z
		block(world, "CavernaPiso", anchor, Vector3.new(cx, 0.1, cz),
			Vector3.new(26, 0.6, 22), ICE_WHITE, Enum.Material.Ice)
		block(world, "CavernaFundo", anchor, Vector3.new(cx - 13, 5, cz),
			Vector3.new(2, 10, 22), STONE_GREY, Enum.Material.Rock)
		block(world, "CavernaParedeN", anchor, Vector3.new(cx, 5, cz - 11),
			Vector3.new(26, 10, 2), STONE_GREY, Enum.Material.Rock)
		block(world, "CavernaParedeS", anchor, Vector3.new(cx, 5, cz + 11),
			Vector3.new(26, 10, 2), STONE_GREY, Enum.Material.Rock)
		block(world, "CavernaTeto", anchor, Vector3.new(cx, 10.6, cz),
			Vector3.new(28, 1.4, 24), ICE_WHITE, Enum.Material.Ice)
		crystalCluster(world, "CavernaCristalA", anchor, cx - 6, cz - 5, 9, ICE_BLUE)
		crystalCluster(world, "CavernaCristalB", anchor, cx + 4, cz + 4, 11, ICE_DEEP)
		crystalCluster(world, "CavernaCristalC", anchor, cx - 2, cz + 6, 7, ICE_BLUE)
		brazier(world, "BraseiroCaverna", anchor, cx + 9, cz - 6, FLAME)
	end

	-- 4. Lago congelado (noroeste) com espelho de gelo e borda de pedra.
	local lake = Data.find("Gelo", "landmarks", "Lago Congelado")
	if lake then
		local disc = block(world, "LagoGelo", anchor, Vector3.new(lake.x, 0.2, lake.z),
			Vector3.new(0.5, 30, 30), ICE_BLUE, Enum.Material.Glass)
		disc.CFrame = anchor * CFrame.new(lake.x, 0.2, lake.z) * CFrame.Angles(0, 0, math.rad(90))
		disc.CanCollide = true
		for index = 0, 7 do
			local angle = index * math.pi / 4
			block(world, "LagoBorda" .. index, anchor,
				Vector3.new(lake.x + math.cos(angle) * 15.4, 0.7, lake.z + math.sin(angle) * 15.4),
				Vector3.new(4, 1.6, 4), STONE_GREY, Enum.Material.Rock, false)
		end
	end

	-- 5. Monolito rúnico (marco de orientação ao sul).
	local monolith = Data.find("Gelo", "landmarks", "Monolito Rúnico")
	if monolith then
		local stone = block(world, "Monolito", anchor, Vector3.new(monolith.x, 8, monolith.z),
			Vector3.new(9, 16, 4.5), ICE_WHITE, Enum.Material.Glacier)
		local rune = block(world, "MonolitoRuna", anchor, Vector3.new(monolith.x, 8, monolith.z + 2.4),
			Vector3.new(4.5, 10, 0.3), ICE_BLUE, Enum.Material.Neon, false)
		local light = Instance.new("PointLight")
		light.Color = ICE_BLUE
		light.Range = 18
		light.Brightness = 1
		light.Parent = rune
	end

	-- 6. Floresta de coníferas congeladas nas bordas.
	for _, spec in ipairs({
		{ -40, -90, 14 }, { 30, -80, 12 }, { 75, -45, 15 },
		{ 85, 55, 13 }, { -110, 55, 12 }, { 110, -10, 14 },
	}) do
		conifer(world, "Pinheiro" .. spec[1] .. "_" .. spec[2], anchor, spec[1], spec[2], spec[3])
	end

	-- 7. Posto da Geleira: local preparado para NPC (sem instalar NPC).
	local spot = Data.find("Gelo", "spots", "Posto da Geleira (NPC)")
	if spot then
		local sx, sz = spot.x, spot.z
		block(world, "PostoPiso", anchor, Vector3.new(sx, 0.15, sz),
			Vector3.new(spot.dx, 0.3, spot.dz), STONE_GREY, Enum.Material.WoodPlanks)
		block(world, "PostoParedeFundo", anchor, Vector3.new(sx + spot.dx / 2 - 0.5, 3.5, sz),
			Vector3.new(1, 7, spot.dz), WOOD_DARK, Enum.Material.Wood)
		block(world, "PostoParedeN", anchor, Vector3.new(sx, 3.5, sz - spot.dz / 2 + 0.5),
			Vector3.new(spot.dx, 7, 1), WOOD_DARK, Enum.Material.Wood)
		block(world, "PostoParedeS", anchor, Vector3.new(sx, 3.5, sz + spot.dz / 2 - 0.5),
			Vector3.new(spot.dx, 7, 1), WOOD_DARK, Enum.Material.Wood)
		block(world, "PostoTelhado", anchor, Vector3.new(sx, 7.6, sz),
			Vector3.new(spot.dx + 2, 1, spot.dz + 2), SNOW, Enum.Material.Snow)
		-- Medallion de latão no piso: ponto exato do NPC futuro.
		local medallion = Build.part(world, "PostoNPCPonto", Vector3.new(0.2, 2.6, 2.6),
			anchor * CFrame.new(sx - 2, 0.4, sz) * CFrame.Angles(0, 0, math.rad(90)),
			BRASS, Enum.Material.Neon, false, "Cylinder")
		brazier(world, "BraseiroPosto", anchor, sx + 3, sz + 2, FLAME)
		label(medallion, "Posto da Geleira\ncomerciante chega em breve", Vector3.new(0, 6, 0), 70)
	end

	-- 8. Placas de orientação nos desvios.
	signpost(world, anchor, -9, 20, 90, "Caverna de Cristal ->")
	signpost(world, anchor, -9, 52, 90, "Lago Congelado ->")
	signpost(world, anchor, 0, -6, 180, "Observatório do Inverno")

	-- 9. Cristais avulsos para a ambientação das bordas.
	crystalCluster(world, "CristalBorda1", anchor, -118, -30, 8, ICE_DEEP)
	crystalCluster(world, "CristalBorda2", anchor, 60, 90, 7, ICE_BLUE)

	return world
end

return LatuniaGelo
