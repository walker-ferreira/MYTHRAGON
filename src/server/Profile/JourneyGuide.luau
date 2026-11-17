-- Pure, read-only story progression derived from already validated actions.
-- This never grants a seal, travel ticket, reward, currency, or objective.
local Journey = {}
Journey.steps = {
    { id = "guardioes", label = "Observe um Guardião do Éter" },
    { id = "santuario", label = "Converse com Varkhion" },
    { id = "portal", label = "Entre no portal de Ember" },
    { id = "Ember", label = "Derrote o Guardião e conquiste o selo" },
    { id = "latunia", label = "Descubra a Vila Central de Latúnia" },
    { id = "gelo", label = "Explore a Ilha do Gelo" },
    { id = "deserto", label = "Explore a Ilha do Deserto" },
    { id = "selva", label = "Explore a Ilha da Selva" },
    { id = "vulcanica", label = "Explore a Ilha Vulcânica" },
}

function Journey.next(done, hasEmber)
    local completed = 0
    for _, entry in ipairs(Journey.steps) do
        if (entry.id == "Ember" and hasEmber == true)
            or (entry.id ~= "Ember" and type(done) == "table" and done[entry.id] == true) then
            completed += 1
        else
            return entry.label, completed, #Journey.steps
        end
    end
    return "Jornada de descoberta concluída!", completed, #Journey.steps
end

return Journey
