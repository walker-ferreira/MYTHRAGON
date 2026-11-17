-- Pure story milestone selection, based on server-confirmed Ember seal.
local Guidance = {}
Guidance.EMBER = "O Éter ainda pulsa em você. Entre no portal de Ember, enfrente o guardião de obsidiana e volte com o primeiro selo."
Guidance.LATUNIA = "O primeiro selo de Ember já responde a você! Procure o portal dourado de Latúnia em Aetheria, conheça a Vila Central e explore as cinco ilhas."
function Guidance.forSeal(hasEmber)
    return hasEmber == true and Guidance.LATUNIA or Guidance.EMBER
end
return Guidance
