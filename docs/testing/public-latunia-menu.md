# TRAVEL-UI-002 — menu público de viagem seguro

O menu **VIAGEM** usa os rótulos e a direção de arte propostos pelo GLM-R012, sem integrar as chamadas inseguras de teleporte do PR #45. A interface oferece seis destinos: Aetheria, Vila Central e quatro ilhas. O jogador precisa estar fisicamente próximo ao portal/cais oficial da rota. Na tentativa distante ou em rota proibida, recebe uma mensagem, sem mudar de ilha.

No servidor, `TravelMenu.server.luau` aceita apenas IDs da lista `TravelMenuPolicy`, possui cooldown de requisições e repassa ao `Map.requestTravel`. O mapa revalida estado, rota, personagem, proximidade e bilhete antes de mover o jogador. Nenhum cliente envia origem, posição, recompensa ou progresso. Só o callback oficial de chegada registra a descoberta. A ferramenta de comandos do proprietário segue independente, com debugWarp, sem marcar exploração.

## QA antes de certificar
- No Hub, tentar ir para Gelo, Selva, Deserto e Vulcânica sem entrar na Vila: **negar**.
- Aproximar-se do portão Latúnia e selecionar Vila Central; confirmar chegada e estado.
- Na Vila, caminhar até cada cais e escolher a ilha correspondente; tentar seleção estando longe de todos os cais: negar.
- Em cada ilha, voltar pela doca oficial à Vila; da Vila, usar saída de Aetheria.
- Duas contas com rotas diferentes e várias solicitações seguidas; confirmar ausência de teleporte indevido e duplicidade de descoberta.
- Testar toque, teclado, controle, tela pequena, respawn, retorno de Ember e erros F9.
- Falhas de DataStore não podem marcar salvos falsos. Nunca permitir menu público de teleporte livre.

**Nota de colaboração:** o PR GLM #45 permanece não integrado por ter `PivotTo` direto e RemoteEvent sem autorização; o visual pode ser adaptado a este gateway. Não substituir o cenário do GLM, nem instalar os dez NPCs. CI e motor isolado não são testes reais de cliente.
