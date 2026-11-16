# Registro de trabalho — GLM 5.3

**Responsável pela edição:** GLM 5.3. **Escopo inicial:** Aetheria, hub, portais, selos, perfil, persistência, economia e interface.

Leia [CODEX.md](CODEX.md) ao iniciar e antes de fechar uma entrega. Atualize este Markdown livremente para reorganizar o status, consolidar decisões e responder às dependências. Cada agente escreve no próprio registro. Consulte o registro do parceiro e cite evidências quando disponíveis.

> **Aviso de merge:** este arquivo é criado pelo PR #4 (branch `docs/coordenacao-codex-glm`). Eu o criei na minha branch (baseada em `main@fd18885`) com o mesmo conteúdo do template + meus registros. Quando o PR #4 mesclar, reconcilio minhas seções sobre o template dele para evitar conflito.

## Estado atual

- **Tarefa:** Fase 1 — correções da revisão do Codex no PR #7 (bloqueios A e B) + revisão cruzada dos fontes do PR #6.
- **Branch:** `glm/aetheria-fase-1` (base `main@fd18885`). **PR:** #7.
- **Caminos desta rodada:** `src/server/Hub/Map.luau` (correção do material + painéis responsivos); `src/server/Start.server.luau` **revertido para a versão da base** (dono transferiu o arquivo ao Codex — GLM-R003; diff zero na minha branch evita conflito em qualquer ordem de merge); índice de decisões (linha 0005 adicionada como editor do índice); `docs/agents/GLM.md` e `docs/testing/fase-1-glm.md`.
- **Verificado:** leitura dos fontes do PR #6 liberada — revisão completa registrada em VX-003 abaixo. CI aprovada no SHA `47501c1`; resultado do head novo a confirmar.
- **Pendente:** execução jogável no cliente (teclado/toque/multijogador) — casos em `docs/testing/fase-1-glm.md`. Inspeção visual do santuário no cliente (item C).

## Inventário da base (Fase 1, reaproveitamento)

| Elemento | Estado em `main@fd18885` | Reaproveitado nesta rodada |
| --- | --- | --- |
| Spawn seguro (`HubSpawn` em 0,0.5,14) | Presente | Sim, intocado |
| Portal rúnico de Ember + validação no servidor (vivo, ≤16 studs, anti-reentrada) | Presente | Sim, intocado; gatilho também conclui o objetivo "portal" |
| Plaza dos quatro selos (orbes neutros no mundo) | Presente | Sim, intocado |
| Painel de selos individual (`SealPanel` no PlayerGui, ResetOnSpawn=false) | Presente (PR #3) | Sim, como modelo para o painel de objetivos |
| `Profile.recordVictory(player, reino, encounterId)` idempotente + contador de duplicatas | Presente | Sim, sem alteração |
| Ligação vitória→painel em `Start.server.luau` | Presente | Sim, sem alteração de lógica |
| Plataforma flutuante de Ember e arena | Presente (Codex) | Não é do meu escopo; preservada |

## Decisões consolidadas

- **GLM-D001 (aceita nesta rodada):** Aetheria cresce para o oeste como ala nova (deck 66×60 em x −99..−33), sem reescrever o deck atual; spawn, selos e portal ficam nas posições existentes. Motivo: preserva os contratos testados e evita colisão com o trabalho do Codex em Ember. Evidência: `Hub/Map.luau` (bloco "Aetheria (Fase 1)").
- **GLM-D002 (aceita nesta rodada):** objetivos iniciais validados no servidor por `ProximityPrompt` das estátuas/santuário e pelo gatilho do portal; painel por jogador; estado de sessão. Motivo: nada de recompensa/progresso vem do cliente (regra permanente do AGENTS.md). Evidência: `Hub.completeObjective` + `observePrompt`.
- **GLM-D003 (resolvida — ver VX-001):** ponto de montagem do Varkhion entregue como `workspace.MythragonMap.Hub.VarkhionAnchor` conforme o contrato do Codex; a proposta original (`VarkhionMount`, 6×1×6) foi substituída.
- **GLM-D004 (proposta — aguarda Codex):** colisão de numeração de decisões. Meu PR #7 traz `0004-aetheria-fase-1.md`; o PR #6 traz `0004-varkhion-interacao.md`. Proposta: **0004 = Aetheria (PR #7), 0005 = Varkhion (renumerar na integração do PR #6)** — a integração do Varkhion depende do meu PR (âncora + objetivo), então ele entra depois. O índice de decisões recebe a linha 0005 no merge, com editor único definido antes. Critério: Codex confirma o mesmo ID no `CODEX.md`.

## Respostas aos pedidos do Codex (rodada 2 — revisão do PR #7)

- **GLM-R002.A (resolvido):** `Enum.Material.DarkWood` era inválido e abortava o `Hub.build` na primeira árvore. Substituído por `Enum.Material.Wood` com a cor escura preservada (`Color3.fromRGB(46, 36, 58)`); `VarkhionAnchor` e o retorno de `Hub.build` tornam a ser criados. Commit desta correção informado no PR #7. Verificação: auditoria dos `Enum.Material.*` usados no arquivo (restantes todos válidos: Slate, Rock, Granite, Neon, ForceField, Basalt, Grass, Glass, Wood, Marble); CI de sintaxe/build não captura esse erro — correção confirmada por inspeção + CI.
- **GLM-R002.B (resolvido):** painéis refeitos com largura responsiva (`UDim2` em escala + `UISizeConstraint` com piso de 145 e teto 250/230) e posições recalculadas: objetivos no canto superior esquerdo (0,12,0,60), selos no superior direito (1,-12,0,60), toast no rodapé central (0,5,-150;1,-60). Verificação por aritmética de layout (análise de código, **não é teste jogável**): em 320×568, objetivos 12..157 e selos 163..308 — sem sobreposição (folga de 6px); em 640×360, objetivos ~12..218 e selos ~410..628 — sem sobreposição; toast fora dos dois painéis e fora do botão de pulo nos dois viewports. Textos com `TextScaled` + `TextWrapped` + `UITextSizeConstraint` (máx. 14) para legibilidade na largura mínima. Validação visual no cliente permanece pendente (casos 1/11 de `docs/testing/fase-1-glm.md`).
- **GLM-R003 (atualizado — acato a transferência):** registrado que o dono transferiu a edição única de `Start.server.luau` ao Codex nesta rodada. Minha integração de montagem em `Start` (commit `db6da8f`) foi revertida para a versão da base `fd18885` — diff zero na minha branch, sem conflito com o `Start` do PR #6 em qualquer ordem de merge. Não voltarei a editar `Start` sem novo acordo registrado.
- **GLM-R004 (resolvido):** linha da decisão 0005 adicionada ao índice `docs/decisions/README.md` nesta branch, como editor do índice. Cópia do Codex da decisão 0005 no PR #6 fica como fonte do registro; renumeração confirmada.
- **VX-003 (revisão completa dos fontes do PR #6 — liberada nesta sessão):** li `Varkhion.luau`, `InteractionState.luau`, `VarkhionModel.luau`, `InteractionState.spec.luau` e o `Start.server.luau` do PR #6 (head `18ddc90`/FETCH_HEAD). Verificado:
  - Contrato VX-001 honrado: `mount` valida parent no Workspace, âncora ancorada/dentro do parent e callback; idempotente por parent (mesmo anchor → mesmo controller; anchor diferente → assert); teardown por `destroy()` e por `Destroying` de parent/anchor/model; `mounted` com chaves fracas.
  - VX-002 honrado: prompt E/gamepad/toque (`ClickablePrompt`), distância ≤12 e cooldown 3s medidos no servidor (`InteractionState`), resposta individual no PlayerGui (DisplayOrder 20, limpeza em PlayerRemoving e substituição antes de nova exibição), callback em `pcall` — falha do callback não conclui a interação e permite nova tentativa; emissão única por jogador (repetições exibem diálogo sem reemitir).
  - `Start` do PR #6: detecção condicional da pasta `Dragons` preservada, assert de âncora, verificação de espécie no callback e chamada `Hub.completeObjective(player, "santuario")` — síncrona, idempotente, sem selo/posse. ✔
  - Modelo: 100% procedural, tudo `CanCollide/CanTouch/CanQuery = false` e ancorado; atributos `SpeciesId/Elements/ProvisionalModel` corretos. Folga do santuário confirmada por geometria: envergadura ~±15 studs, cauda até ~14,7 do centro — dentro do dais Ø48 com pilares a raio 20 (item C). ✔
  - Observações menores (não bloqueantes): (1) diálogo do Varkhion (rodapé-centro, até 132px de altura) pode sobrepor por ~20px o toast do hub em telas de 360px de altura quando os dois aparecem juntos — sugiro ao Codex reduzir/elevar o diálogo ou aceitar o efeito transitório; (2) dragão sem colisão permite atravessá-lo — aceitável na fase 1; (3) o PR #6 carrega cópias desatualizadas dos meus `docs/agents/GLM.md` e `docs/testing/fase-1-glm.md` — pedir que o Codex remova essas cópias antes do merge (são de edição exclusiva minha; a cópia da decisão 0004 está idêntica e pode ficar).
- **GLM-R001 (resposta do Codex registrada):** montagem única via `map.Hub.VarkhionAnchor` com verificação de espécie; `false` do `completeObjective` em objetivo já concluído é duplicata legítima, não erro — de acordo.

## Pedidos e dependências para Codex

- **GLM-R006 (proposta — Latúnia, concept art):** a pedido do dono, a GLM assumiu **temporariamente** a parte do Codex no atlas: `concept-art/latunia/glm/mapa-mundo.svg`, `ilha-do-deserto.svg` e `ilha-vulcanica.svg` (mesmo padrão das três entregas anteriores: 1600×1200, 4:3, norte no alto, legenda numerada na margem, sem pessoas/animais/interface). Legendas propostas para essas duas ilhas (nomes novos, precisam da confirmação do Codex ou podem ser substituídos pelos dele): **Deserto:** Doca do Deserto · Mina a Céu Aberto · Espelhos Solares · Aqueduto de Latão · Posto das Dunas. **Vulcânica:** Doca Vulcânica · Fundição Principal · Caldeiras de Magma · Ponte de Ferro · Posto da Fenda. O mapa-múndi usa numeração 1–5 para as ilhas (Vila Central 1, Gelo 2, Deserto 3, Selva 4, Vulcânica 5) + 6 para as rotas de dirigível. O Codex fica livre para: (a) confirmar/adotar, (b) recriar com os nomes dele e substituir os arquivos, ou (c) reivindicar a autoria — se (b)/(c), os arquivos em `concept-art/latunia/glm/` são dele para mexer.
- **GLM-R005 (proposta — Latúnia, concept art):** parte do Codex no briefing do atlas (mapa-múndi + Ilha do Deserto + Ilha Vulcânica) ainda **não aparece registrada** no `CODEX.md` (última leitura: FETCH_HEAD `cc7f807`) — pendente de confirmação. Nada foi proposto por mim: mantive nomes e posições do briefing (Vila Central centro; Gelo norte; Deserto leste; Selva oeste; Vulcânica sul; rotas de dirigível partem da Vila Central).
- **GLM-R002 (resolvido na rodada anterior — ver seção abaixo).**
- **GLM-R003 (resolvido):** `Start` é do Codex; minha branch não altera mais o arquivo.
- **GLM-R004 (resolvido):** linha 0005 no índice registrada.

## Entrega — atlas de Latúnia (concept art GLM)

- **Caminos:** `concept-art/latunia/glm/vila-central.svg`, `concept-art/latunia/glm/ilha-do-gelo.svg`, `concept-art/latunia/glm/ilha-da-selva.svg` (1600×1200, 4:3, legendas numeradas na margem, sem pessoas/criaturas/interface).
- **Identidade por ilha:** Vila Central = vila densa em três níveis (docas → oficinas → praça da Torre-Relógio) ligados por escadarias e dois elevadores a vapor; Ilha do Gelo = fiordes, tundra, fábricas de gelo e perfuradoras geotérmicas, ponte congelada; Ilha da Selva = cachoeiras, Grande Estufa de vidro e cobre, elevador hidráulico das copas, passarela de cobre e ruínas hidráulicas com raízes.
- **Padrão compartilhado:** cobre/bronze/ferrugem/carvão/latão/vidro âmbar, neblina leve, luz quente de lampiões a gás, marcadores numerados discretos e legenda impressa na margem; rotas internas legíveis (escadas, elevadores, pontes, tubulações).
- **Nada importado:** todos os elementos são vetoriais originais (sem assets de terceiros; sem licenças a registrar).

## Resumo do que Codex está fazendo

- **PR #6 (aberto, rascunho):** Varkhion fase 1 — modelo procedural original (escamas negras, olhos violeta, chifres, asas, marcas de Éter), prompt E/toque "Ouvir Varkhion", diálogo individual no PlayerGui, validação no servidor (distância ≤12, cooldown 3s), callback único por jogador, montagem idempotente e teardown; specs puros de interação. Nenhum asset importado; referências registradas como direção. CI da implementação aprovada; **cliente não testado**.
- **Pedidos VX-001/002/003** registrados no `CODEX.md` e respondidos por mim nesta rodada (ver acima).
- **Como depende de mim:** o Codex espera a âncora + chamada de montagem em `Start` (entregue) e a revisão cruzada; a publicação continua bloqueada até QA jogável combinado.

## Próximas tarefas

1. Codex revisa o PR #7 (GLM-R002); eu reviso os fontes do PR #6 quando o acesso de leitura estiver liberado (VX-003, revisão parcial registrada).
2. Percuso combinado no cliente (teclado, toque, dois jogadores, falhas) com os casos de `docs/testing/fase-1-glm.md` + `docs/testing/varkhion-fase1.md`.
3. Renumeração da decisão do Varkhion para 0005 no merge (GLM-D004/GLM-R004).
4. Após CI + revisão + QA: Codex publica o artefato validado da `main` no Place de teste e registra a revisão retornada.
5. Fase 2: perfil persistente (eu) e catálogo de dragões (Codex), conforme `NEXT_TASKS.md`.
