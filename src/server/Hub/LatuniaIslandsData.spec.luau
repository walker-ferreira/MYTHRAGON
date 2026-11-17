-- Contrato geométrico das melhorias GLM nas ilhas de Latúnia.
-- Spec PURO (sem APIs do Roblox): valida que todo caminho novo conecta à
-- rede da doca de chegada, que nada novo sai do disco da ilha e que os
-- locais de NPC não invadem os caminhos. Executado pela CI via luau VM.
local Data = require("./LatuniaIslandsData")

local CONNECT_TOLERANCE = 2
local WALK_MARGIN = 1

local function box(item)
	return {
		minX = item.x - item.dx / 2, maxX = item.x + item.dx / 2,
		minZ = item.z - item.dz / 2, maxZ = item.z + item.dz / 2,
	}
end

local function boxesTouch(a, b, tolerance)
	-- Sobreposição ou contato dentro da tolerância (projetado no plano XZ).
	local gapX = math.max(a.minX - b.maxX, b.minX - a.maxX)
	local gapZ = math.max(a.minZ - b.maxZ, b.minZ - a.maxZ)
	return gapX <= tolerance and gapZ <= tolerance
end

local function cornerRadius(item)
	return math.max(
		math.sqrt(item.x ^ 2 + item.z ^ 2),
		math.sqrt((item.x + item.dx / 2) ^ 2 + item.z ^ 2),
		math.sqrt(item.x ^ 2 + (item.z + item.dz / 2) ^ 2)
	)
end

local function checkIsland(name, island)
	assert(island.radius ~= nil, name .. " precisa de radius")
	assert(island.arrival ~= nil, name .. " precisa de arrival")
	assert(#island.paths > 0, name .. " precisa de paths")

	local boxes = {}
	for index, path in ipairs(island.paths) do
		boxes[index] = box(path)
	end

	-- 1. Chegada dentro da rede base (a doca do arquipélago conecta).
	local arrivalOk = false
	for index, path in ipairs(island.paths) do
		if path.base and boxesTouch({ minX = island.arrival.x, maxX = island.arrival.x,
			minZ = island.arrival.z, maxZ = island.arrival.z }, boxes[index], CONNECT_TOLERANCE) then
			arrivalOk = true
		end
	end
	assert(arrivalOk, name .. ": chegada não toca a rede base")

	-- 2. Conectividade: todo caminho (incluindo novos GLM) alcança a chegada.
	local reached = {}
	reached[1] = true
	local changed = true
	while changed do
		changed = false
		for index = 1, #boxes do
			if not reached[index] then
				for other = 1, #boxes do
					if reached[other] and boxesTouch(boxes[index], boxes[other], CONNECT_TOLERANCE) then
						reached[index] = true
						changed = true
					end
				end
			end
		end
	end
	for index, path in ipairs(island.paths) do
		assert(reached[index], name .. ": caminho desconectado em " .. tostring(path.x) .. "," .. tostring(path.z))
	end

	-- 3. Tudo que é novo (sem `base`) fica dentro do disco da ilha.
	for _, path in ipairs(island.paths) do
		if not path.base then
			assert(cornerRadius(path) <= island.radius,
				name .. ": caminho fora do disco em " .. tostring(path.x) .. "," .. tostring(path.z))
		end
	end
	for _, spot in ipairs(island.spots) do
		assert(cornerRadius(spot) <= island.radius, name .. ": spot fora do disco (" .. spot.name .. ")")
	end
	for _, landmark in ipairs(island.landmarks) do
		local r = math.sqrt(landmark.x ^ 2 + landmark.z ^ 2)
		assert(r <= island.radius, name .. ": marco fora do disco (" .. landmark.name .. ")")
	end

	-- 4. Spots (NPC/missão) não invadem caminhos: exigem margem livre.
	for _, spot in ipairs(island.spots) do
		local spotBox = box(spot)
		for index, path in ipairs(island.paths) do
			local gapX = math.max(spotBox.minX - boxes[index].maxX, boxes[index].minX - spotBox.maxX)
			local gapZ = math.max(spotBox.minZ - boxes[index].maxZ, boxes[index].minZ - spotBox.maxZ)
			local free = gapX >= WALK_MARGIN or gapZ >= WALK_MARGIN
			assert(free,
				name .. ": spot '" .. spot.name .. "' invade caminho em " .. tostring(path.x) .. "," .. tostring(path.z))
		end
	end
end

checkIsland("Gelo", Data.Gelo)
checkIsland("Selva", Data.Selva)

-- Vila Central: ilha retangular (bounds) + locais de NPC em três níveis.
local Vila = Data.Vila
assert(Vila.bounds ~= nil)
local levels = {}
for _, spot in ipairs(Vila.spots) do
	assert(spot.level == "docas" or spot.level == "deck" or spot.level == "praca",
		"nível desconhecido no spot '" .. spot.name .. "'")
	levels[spot.level] = (levels[spot.level] or 0) + 1
	local inX = spot.x - spot.dx / 2 >= Vila.bounds.minX and spot.x + spot.dx / 2 <= Vila.bounds.maxX
	local inZ = spot.z - spot.dz / 2 >= Vila.bounds.minZ and spot.z + spot.dz / 2 <= Vila.bounds.maxZ
	assert(inX and inZ, "spot fora dos limites: " .. spot.name)
end
assert(levels.docas and levels.deck and levels.praca, "faltam spots de NPC por nível")
for _, path in ipairs(Vila.paths) do
	assert(path.x - path.dx / 2 >= Vila.bounds.minX and path.x + path.dx / 2 <= Vila.bounds.maxX,
		"rua fora dos limites: " .. path.name)
	assert(path.z - path.dz / 2 >= Vila.bounds.minZ and path.z + path.dz / 2 <= Vila.bounds.maxZ,
		"rua fora dos limites: " .. path.name)
end
for _, landmark in ipairs(Vila.landmarks) do
	assert(landmark.x >= Vila.bounds.minX and landmark.x <= Vila.bounds.maxX
		and landmark.z >= Vila.bounds.minZ and landmark.z <= Vila.bounds.maxZ,
		"marco fora dos limites: " .. landmark.name)
end

print("LatuniaIslandsData.spec: geometria OK (Gelo, Selva e Vila Central)")
