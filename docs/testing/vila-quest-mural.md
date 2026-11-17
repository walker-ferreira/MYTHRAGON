# STORY-MURAL-001 — explicação dos quatro selos e mural da Vila Central

A lore da primeira fase agora esclarece no diálogo de Varkhion que existem **quatro Selos do Éter**: Ember é o primeiro reino jogável, e os demais não são anunciados como disponíveis.

Em Latúnia, o jogador pode interagir com o **Mural de Avisos** já construído pelo GLM na Vila Central. O `LatuniaQuestBoard` usa teclado E, controle X e toque por ProximityPrompt. A interação só funciona para jogador vivo com `Controller.current = Central`, a menos de 14 studs do mural. O servidor consulta o próximo marco real de `JourneyGuide` no painel individual e envia orientação contextual; não altera progresso, inventário, moedas ou selos.

**Preservação:** nenhum objeto duplicado na Vila; usa `MuralQuadro` existente em `VilaCentral`, não instala os 10 NPCs e não altera posicionamento dos modelos GLM. A montagem degrada com aviso caso o GLM mural não exista. Engine probe e inspeção manual esperam 10 prompts de viagem e 1 prompt de mural.

## Testes reais

1. Após vencer Ember e voltar, falar com Varkhion e confirmar a explicação dos quatro selos.
2. Entrar na Vila pelos portais oficiais, localizar o mural e consultar o próximo passo (Gelo, depois demais ilhas).
3. Visitar uma ilha, retornar ao mural e confirmar mudança da orientação pessoal; jogador B sem progresso recebe seu próprio próximo passo.
4. Testar mural longe do personagem, personagem morto, teclado, toque e controle.
5. Confirmar que mural não entrega selos, NPCs, recompensas ou objetivos duplicados.
6. Verificar se o texto e sinalização cabem no celular e se não há erros F9.

CI, Rojo e motor isolado são necessários, mas não comprovam experiência real de cliente.
