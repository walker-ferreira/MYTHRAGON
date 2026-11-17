-- Pure destination allowlist shared by all public travel entry points.
-- No client may specify a source or teleport position.
local Policy = {}
local destinations = {
    hub = "Hub", vila = "Central", central = "Central",
    gelo = "Gelo", deserto = "Deserto", selva = "Selva", vulcanica = "Vulcanica",
}
function Policy.destination(input)
    if type(input) ~= "string" or #input > 16 then return nil end
    return destinations[input]
end
return Policy
