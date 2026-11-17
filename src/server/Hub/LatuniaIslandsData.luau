-- Dados de geometria das melhorias GLM nas ilhas de Latúnia.
-- Módulo 100% PURO (sem APIs do Roblox): é executado pela CI (spec
-- LatuniaIslandsData.spec.luau) e consumido pelos construtores
-- LatuniaGelo/LatuniaSelva e pelas melhorias da Vila Central.
-- Fonte única de verdade: posições não podem divergir entre construtor e
-- teste. Coordenadas LOCAIS ao anchor do slot (contrato L3D-001).
--
-- Estrutura:
--   paths     = lajes de caminho { x, z, dx, dz, top?, base? } — centros e
--               meia-área; `base` = construído pelo cenário base do Codex
--               (referência de conectividade, não construído aqui).
--   spots     = locais preparados para NPC/missão { x, z, dx, dz, level? }.
--   landmarks = marcos de orientação { x, z }.
--   radius    = raio útil do disco da ilha (nada novo fora dele).
--   arrival   = ponto de chegada da doca do arquipélago (x, z).
--   bounds    = ilha retangular (Vila Central).

local Data = {}

Data.Gelo = {
	radius = 145,
	arrival = { x = 0, z = 100 },
	paths = {
		-- Base do Expansion (não reconstruída aqui).
		{ x = 0, z = 152, dx = 22, dz = 118, base = true },
		{ x = 0, z = 54, dx = 14, dz = 116, base = true },
		-- GLM: conector do observatório (fecha o vão Z -39..-4 do cenário base).
		{ x = 0, z = -21.5, dx = 14, dz = 35 },
		-- GLM: caminho da caverna de cristal (oeste).
		{ x = -28, z = 20, dx = 42, dz = 14 },
		{ x = -63, z = 6, dx = 28, dz = 14 },
		{ x = -84, z = -8, dx = 26, dz = 14 },
		-- GLM: caminho do lago congelado.
		{ x = -25.5, z = 52, dx = 37, dz = 12 },
	},
	spots = {
		{ name = "Posto da Geleira (NPC)", x = 18, z = 36, dx = 12, dz = 10 },
	},
	landmarks = {
		{ name = "Lago Congelado", x = -58, z = 52 },
		{ name = "Caverna de Cristal", x = -97, z = -15 },
		{ name = "Monolito Rúnico", x = -40, z = -60 },
	},
}

Data.Selva = {
	radius = 145,
	arrival = { x = 100, z = 0 },
	paths = {
		-- Base do Expansion (não reconstruída aqui).
		{ x = 155, z = 0, dx = 120, dz = 20, base = true },
		{ x = 38, z = 0, dx = 125, dz = 12, base = true },
		-- GLM: caminho da cachoeira Esmeralda (sul).
		{ x = -2, z = -25, dx = 10, dz = 40 },
		{ x = -32, z = -50, dx = 52, dz = 10 },
		{ x = -30, z = -56, dx = 10, dz = 14 },
		-- GLM: caminho do mirante das copas (sudoeste).
		{ x = -52, z = -50, dx = 20, dz = 10 },
	},
	spots = {
		{ name = "Mercador das Vinhas (NPC)", x = 70, z = 18, dx = 10, dz = 8 },
	},
	landmarks = {
		{ name = "Cachoeira Esmeralda", x = -30, z = -75 },
		{ name = "Mirante das Copas", x = -75, z = -60 },
		{ name = "Totem da Copa", x = -20, z = 60 },
	},
}

Data.Vila = {
	-- Ilha retangular: deck principal topo Y 0; docas topo Y -5,5;
	-- praça elevada topo Y 8.
	bounds = { minX = -33, maxX = 33, minZ = -26, maxZ = 26 },
	paths = {
		{ name = "Rua do Mercado", x = -3, z = 6, dx = 54, dz = 6 },
		{ name = "Rua das Oficinas", x = 24, z = -5, dx = 8, dz = 28 },
		{ name = "Rua da Praça", x = 4, z = 0, dx = 30, dz = 6 },
	},
	spots = {
		{ name = "Mestre de Docas (NPC)", x = 8, z = 16, dx = 4, dz = 4, level = "docas" },
		{ name = "Mercador (NPC)", x = -9, z = 0, dx = 3, dz = 3, level = "deck" },
		{ name = "Cartógrafo (NPC)", x = 10, z = -8, dx = 3, dz = 3, level = "praca" },
	},
	landmarks = {
		{ name = "Torre-Relógio", x = 4, z = -19 },
		{ name = "Fonte da Praça", x = -3, z = -17 },
		{ name = "Mural de Avisos", x = -30, z = 10 },
	},
}

-- Busca um marco/spot pelo nome dentro de uma ilha (para os construtores).
function Data.find(island, kind, name)
	for _, item in ipairs(Data[island][kind] or {}) do
		if item.name == name then
			return item
		end
	end
	return nil
end

return Data
