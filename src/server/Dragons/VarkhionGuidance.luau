-- Pure story milestone selection, based on server-confirmed Ember seal.
local Guidance = {}
Guidance.EMBER = "Os quatro Selos do Éter mantêm Aetheria protegida. Ember guarda o primeiro; os outros três ainda aguardam seus reinos. Atravesse o portal de Ember, derrote o Guardião e volte com seu selo."
Guidance.LATUNIA = "O primeiro dos quatro Selos do Éter responde a você! Volte a Aetheria pelo portal roxo, procure o portal dourado de Latúnia e consulte o Mural de Avisos da Vila Central. Os outros três selos virão nas próximas jornadas."
function Guidance.forSeal(hasEmber)
    return hasEmber == true and Guidance.LATUNIA or Guidance.EMBER
end
return Guidance
