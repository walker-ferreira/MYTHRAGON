local Guide = require("./VarkhionGuidance")

-- Guidance is selected only for a server-confirmed boolean seal.
assert(Guide.forSeal(false) == Guide.EMBER)
assert(Guide.forSeal(nil) == Guide.EMBER)
assert(Guide.forSeal(true) == Guide.LATUNIA)
assert(Guide.EMBER ~= Guide.LATUNIA)
assert(string.find(Guide.LATUNIA, "Latúnia", 1, true))

-- Invalid and unexpected values must never grant the Latunia guidance.
for _, invalid in ipairs({ "true", "invalid_type", 1, 0, -1, {}, { hasEmber = true }, function() end }) do
    assert(Guide.forSeal(invalid) == Guide.EMBER, "Only boolean true may unlock Latunia guidance")
end

assert(type(Guide.EMBER) == "string" and #Guide.EMBER > 0, "EMBER guidance must be nonempty text")
assert(type(Guide.LATUNIA) == "string" and #Guide.LATUNIA > 0, "LATUNIA guidance must be nonempty text")

print("Varkhion story guidance: PASS")
