-- NPC definitions for future Mythragon phases. NOT mounted or enabled.
-- No rewards or purchases may occur until economy, dialogue UI and server checks exist.
local Definitions = {}

Definitions.characters = {
    {
        id = "nara", name = "Nara, a Cartógrafa", home = "Central",
        role = "Orientação e mapas", visual = {palette = "cobre e azul", silhouette = "capa curta, luneta, pergaminhos"},
        goods = {"Mapa de Latúnia", "Bússola de viagem", "Roteiro das docas"},
        lines = {
            "As cinco ilhas nunca aparecem iguais em dois mapas antigos.",
            "Comece pela Vila Central; as quatro docas indicam os caminhos.",
            "Ainda estou desenhando as rotas que os dirigíveis podem percorrer.",
        },
        greeting = "Precisa descobrir seu próximo destino?", farewell = "Volte com histórias de outra ilha.",
    },
    {
        id = "breno", name = "Breno, o Mestre das Docas", home = "Central",
        role = "Construção de dirigíveis", visual = {palette = "ferro e âmbar", silhouette = "avental de couro, óculos e ferramentas"},
        goods = {"Peças de dirigível", "Reforço de casco", "Corda de amarração"},
        lines = {
            "Nenhum dirigível está liberado para pilotagem ainda.",
            "A primeira regra de um bom mecânico é conferir as amarras.",
            "O vento do norte mudou desde que o gelo avançou.",
        },
        greeting = "Cuidado com as ferramentas no cais!", farewell = "Que os ventos sejam favoráveis.",
    },
    {
        id = "orik", name = "Orik, o Ferreiro", home = "Central",
        role = "Equipamento e reparos", visual = {palette = "grafite e vermelho", silhouette = "braços largos, avental e martelo"},
        goods = {"Lâmina de treino", "Escudo de ferro", "Kit de reparo"},
        lines = {
            "Ferro bem forjado resiste mais que bravura sem preparo.",
            "Minha forja serve a exploradores, não a saqueadores.",
            "Ouço as montanhas vulcânicas mesmo daqui.",
        },
        greeting = "O que veio consertar?", farewell = "Mantenha suas ferramentas secas.",
    },
    {
        id = "lyria", name = "Lyria, Guardiã dos Arquivos", home = "Central",
        role = "Lore e registros", visual = {palette = "violeta e dourado", silhouette = "manto alto, cadernos e medalhão"},
        goods = {"Crônica dos Selos", "Diário de Aetheria", "Atlas Antigo"},
        lines = {
            "Os quatro selos guardam provas, não apenas poder.",
            "Varkhion reconhece quem escuta antes de lutar.",
            "Uma ilha sem memória logo se torna só pedra.",
        },
        greeting = "Você veio procurar uma história?", farewell = "Não deixe as páginas em branco.",
    },
    {
        id = "maia", name = "Maia, a Herbalista", home = "Selva",
        role = "Plantas e preparação", visual = {palette = "verde musgo e creme", silhouette = "bolsa de folhas, cabelos presos, luvas"},
        goods = {"Sementes raras", "Ervas secas", "Frasco vazio"},
        lines = {
            "A selva revela caminhos a quem não quebra suas raízes.",
            "Nem toda planta brilhante deve ser tocada.",
            "As ruínas guardam marcas de uma civilização cuidadosa.",
        },
        greeting = "Procura uma planta ou uma resposta?", farewell = "Respeite o que cresce.",
    },
    {
        id = "tarek", name = "Tarek, Explorador das Ruínas", home = "Selva",
        role = "Exploração e pistas", visual = {palette = "verde escuro e bronze", silhouette = "chapéu largo, lanterna, cinto de mapas"},
        goods = {"Lanterna de trilha", "Pincel de arqueologia", "Caderno de pistas"},
        lines = {
            "O templo parece vazio, mas suas pedras foram colocadas com intenção.",
            "Uma boa pista vale mais que dez palpites.",
            "O caminho principal é mais seguro que a vegetação fechada.",
        },
        greeting = "Já encontrou as ruínas da Copa Antiga?", farewell = "Deixe as pedras onde as encontrou.",
    },
    {
        id = "isca", name = "Isca, Vigia do Inverno", home = "Gelo",
        role = "Clima e segurança", visual = {palette = "azul-gelo e prata", silhouette = "capa de pele sintética, visor, cajado"},
        goods = {"Manta térmica", "Sinalizador de trilha", "Botas de neve"},
        lines = {
            "O gelo conserva segredos, mas não perdoa passos apressados.",
            "Siga as marcas azuis até o observatório.",
            "O céu muda antes da neve.",
        },
        greeting = "Consegue sentir a direção do vento?", farewell = "Volte antes da nevasca.",
    },
    {
        id = "felix", name = "Félix, Astrônomo do Gelo", home = "Gelo",
        role = "Observatório e pesquisa", visual = {palette = "azul-marinho e branco", silhouette = "casaco longo, monóculo, prancheta"},
        goods = {"Carta das Estrelas", "Lente do Observatório", "Registro do Céu"},
        lines = {
            "Há constelações que só aparecem sobre a Ilha do Gelo.",
            "Um mapa estelar não mostra caminhos no chão.",
            "O observatório foi feito para perguntas maiores que nós.",
        },
        greeting = "Veio observar o céu?", farewell = "Olhe para cima de vez em quando.",
    },
    {
        id = "zira", name = "Zira, Engenheira da Cratera", home = "Vulcanica",
        role = "Máquinas e forja", visual = {palette = "preto vulcânico e laranja", silhouette = "máscara de forja, luvas, ferramenta angular"},
        goods = {"Liga de basalto", "Peça de caldeira", "Martelo de manutenção"},
        lines = {
            "As caldeiras exigem atenção, não coragem.",
            "A lava da cratera é perigosa até quando parece imóvel.",
            "O metal canta antes de ceder.",
        },
        greeting = "Está aqui para ajudar na forja?", farewell = "Fique longe das bordas quentes.",
    },
    {
        id = "doran", name = "Doran, Condutor das Dunas", home = "Deserto",
        role = "Ferrovia e navegação", visual = {palette = "areia e ferrugem", silhouette = "lenço contra areia, casaco curto, apito"},
        goods = {"Passagem de ferrovia futura", "Filtro de poeira", "Kit de trilhos"},
        lines = {
            "A antiga ferrovia ainda aponta para a mina.",
            "Por enquanto os trens não transportam jogadores.",
            "No deserto, o horizonte engana quem não observa o terreno.",
        },
        greeting = "Vai seguir os trilhos?", farewell = "Não se afaste das marcações.",
    },
}

return Definitions
