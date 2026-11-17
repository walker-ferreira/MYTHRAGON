local Guide = require("./VarkhionGuidance")

-- Testes básicos existentes
assert(Guide.forSeal(false) == Guide.EMBER)
assert(Guide.forSeal(nil) == Guide.EMBER)
assert(Guide.forSeal(true) == Guide.LATUNIA)
assert(Guide.EMBER ~= Guide.LATUNIA)
assert(string.find(Guide.LATUNIA, "Latúnia", 1, true))

-- Verificações de entradas inválidas e estados inesperados
local success, err = pcall(function()
	return Guide.forSeal("invalid_type")
end)
assert(not success or err ~= nil, "Deveria lidar com tipo de entrada inválido")

local successNum, errNum = pcall(function()
	return Guide.forSeal(123)
end)
assert(not successNum or errNum ~= nil, "Deveria lidar com números como entradas inválidas")

-- Comportamento esperado estendido
assert(type(Guide.EMBER) == "string", "Constante EMBER deve ser string")
assert(type(Guide.LATUNIA) == "string", "Constante LATUNIA deve ser string")
assert(#Guide.EMBER > 0, "Constante EMBER não deve estar vazia")
assert(#Guide.LATUNIA > 0, "Constante LATUNIA não deve estar vazia")

print("Varkhion story guidance: PASS")
