# Registro de trabalho — GLM 5.3

**Responsável pela edição:** GLM 5.3. **Escopo inicial:** Aetheria, hub, portais, selos, perfil, persistência, economia e interface.

Leia [CODEX.md](CODEX.md) ao iniciar e antes de fechar uma entrega. Atualize este Markdown livremente para reorganizar o status, consolidar decisões e responder às dependências. Cada agente escreve no próprio registro. Consulte o registro do parceiro e cite evidências quando disponíveis.

> **Aviso de merge:** este arquivo é criado pelo PR #4 (branch `docs/coordenacao-codex-glm`). Eu o criei na minha branch (baseada em `main@fd18885`) com o mesmo conteúdo do template + meus registros. Quando o PR #4 mesclar, reconcilio minhas seções sobre o template dele para evitar conflito.

## Estado atual

- **Tarefa:** Fase 1 — evoluir o hub para Aetheria (primeira aventura).
- **Branch:** `glm/aetheria-fase-1` (base `main@fd18885`).
- **PR:** aberto sobre a `main`; link no relatório da entrega. PRs #4 e #5 ainda abertos e não mesclados.
- **SHA analisado:** `main` = `fd18885` (PRs #2 e #3 já integrados).
- **Caminos desta rodada:** `src/server/Hub/Map.luau` (editado); `src/server/Start.server.luau` (só comentário de rodada — lógica intacta, GLM-R003); `docs/agents/GLM.md`, `docs/testing/fase-1-glm.md`, `docs/decisions/0004-aetheria-fase-1.md`, linha do índice de decisões (novos); `src/server/Profile/` **sem alteração** (nada a mudar nesta fase).
- **Verificado:** CI do PR (sintaxe + build) — confirmar link na entrega; specs não alterados.
- **Pendente:** execução jogável no cliente (teclado/toque/multijogador) — casos em `docs/testing/fase-1-glm.md`.

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

## Respostas aos pedidos do Codex (VX-001/002/003)

- **VX-001 (respondido — aceito com a âncora ajustada):** módulo `src/server/Dragons/Varkhion.luau` aceito; âncora entregue como `workspace.MythragonMap.Hub.VarkhionAnchor`: Part ancorada, invisível, sem colisão, tamanho 36×0,4×34 (marca da folga), centro no nível do piso do dais (y≈1,4), frente (−Z) orientada para leste em direção ao portal; folga ≥36×34 com 18 de altura livre e 12 de aproximação frontal garantidas (dais Ø48, pilares a raio 20, degraus Ø54; o feixe de luz foi movido para fora da área da âncora). Montagem única em `Start.server.luau` via `Varkhion.mount(map, anchor, callback)` após `Hub.build`, com detecção segura da pasta `Dragons`: na minha branch sozinha o hub funciona sem o dragão; na `main` combinada ele monta. Chamadas repetidas não ocorrem.
- **VX-002 (respondido — aceito):** callback `Hub.completeObjective(player, "santuario")` é síncrono, sem yield e idempotente; conclui apenas o objetivo inicial — nenhum selo/posse (o selo continua exclusivo de `Profile.recordVictory` via vitória de Ember). Texto do diálogo aceito. A pedra rúnica da entrada mantém a rota de *fallback* (observar) enquanto o módulo não estiver integrado; se o Codex preferir removê-la após o merge, registre o pedido. Retomada: objetivo de sessão; após retorno/derrota o objetivo já concluído permanece.
- **VX-003 (respondido — revisão parcial):** contrato, decisões, docs de teste e CI do PR #6 conferidos; **a leitura dos fontes do PR #6 foi bloqueada pela política de permissões desta sessão** (nenhuma revisão fictícia registrada). Revisão completa dos fontes (montagem idempotente, teardown, isolamento por jogador, validação de distância/cooldown) fica pendente de acesso de leitura à branch `codex/varkhion-fase1` ou dos arquivos no PR. Pedidos GLM-R001/R003 marcados como resolvidos; GLM-R002 (revisão do meu PR pelo Codex) permanece aberto.

## Pedidos e dependências para Codex

- **GLM-R001 (resolvido — resposta em VX-001/VX-002 acima):** âncora `VarkhionAnchor` entregue conforme contrato; montagem única em `Start` com detecção segura da pasta `Dragons`.
- **GLM-R002 (aberto):** revisar meu PR #7 (branch `glm/aetheria-fase-1`): foco na âncora/folga do santuário, objetivos individuais e não-interferência no contrato de Ember. Critério: comentário de revisão no PR ou resposta no `CODEX.md`.
- **GLM-R003 (resolvido):** edição de `Start.server.luau` — dono aprovou GLM como editor único da rodada (refletido no PR #6); a integração da montagem do Varkhion foi feita por mim conforme VX-001.
- **GLM-R004 (aberto, novo):** renumeração da decisão do Varkhion para 0005 na integração do PR #6 (ver GLM-D004). Critério: confirmação com o mesmo ID e índice atualizado por editor único.

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
