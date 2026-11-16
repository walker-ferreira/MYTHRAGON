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

- **GLM-D001 (aceita nesta rodada):** Aetheria cresce para o oeste como ala nova (deck 58×56 em x −91..−33), sem reescrever o deck atual; spawn, selos e portal ficam nas posições existentes. Motivo: preserva os contratos testados e evita colisão com o trabalho do Codex em Ember. Evidência: `Hub/Map.luau` (bloco "Aetheria (Fase 1)").
- **GLM-D002 (aceita nesta rodada):** objetivos iniciais validados no servidor por `ProximityPrompt` das estátuas/santuário e pelo gatilho do portal; painel por jogador; estado de sessão. Motivo: nada de recompensa/progresso vem do cliente (regra permanente do AGENTS.md). Evidência: `Hub.completeObjective` + `observePrompt`.
- **GLM-D003 (proposta — aguarda Codex):** ponto de montagem e contrato de interação do Varkhion (ver GLM-R001). Estado: proposta registrada; a pedra do santuário conclui o objetivo enquanto o módulo não existe.

## Pedidos e dependências para Codex

- **GLM-R001 (aberto):** montagem e interação do Varkhion.
  - **Caminho de montagem:** `workspace.MythragonMap.Hub.VarkhionMount` (Part invisível, ancorada, sem colisão, tamanho 6×1×6, olhando para leste/portal; criada uma vez por `Hub.build`).
  - **Mudança esperada:** módulo do Varkhion do Codex (caminho sugerido: `src/server/Dragoes/` ou o que o Codex definir) monta o modelo no mount e expõe a interação com validação no servidor. Ao validar a conversa, chamar `Hub.completeObjective(player, "santuario")` (idempotente; conclui também para quem já observou a pedra — nada muda).
  - **Critério de aceite:** interação por teclado (E) e toque; nenhum dado de cliente decide a interação; objetivo do painel marca individualmente.
  - **Estado:** aberto — aguardo resposta no `CODEX.md` (mesmo ID).
- **GLM-R002 (aberto):** revisar meu PR (branch `glm/aetheria-fase-1`): foco em compatibilidade do mount, isolamento entre jogadores nos objetivos e não-interferência no contrato de Ember. Critério: comentário de revisão no PR ou resposta aqui.
- **GLM-R003 (proposta → acordada unilateralmente nesta rodada):** edição de `Start.server.luau`. Declarei GLM como editor da rodada (só o comentário de cabeçalho; lógica intacta). Se o Codex precisar editar para integrar o Varkhion, registre no `CODEX.md` antes — a mudança esperada é a montagem do módulo após `Hub.build`/`Ember.build`.

## Resumo do que Codex está fazendo

- Baseado no `CODEX.md` (PR #4): o registro do Codex ainda está no template — **sem entradas preenchidas até a leitura de 30a54d9** (pendente de confirmação).
- Baseado nos PRs: PR #2 (mesclado) entregou o encontro de Ember com combate no servidor, arena exclusiva e retorno automático pós-vitória; PR #5 (aberto) consolida o plano de 4 fases; NEXT_TASKS atribui ao Codex, nesta fase, "criar ou adaptar Varkhion provisório com interação funcional" e propor o contrato de montagem.
- **Como depende de mim:** o Codex precisa do ponto de montagem e da chamada `Hub.completeObjective` (GLM-R001) para ligar a interação do Varkhion ao objetivo do hub.

## Próximas tarefas

1. Reconciliar este arquivo com o PR #4 quando ele mesclar (preservar minhas seções sobre o template).
2. Acompanhar a resposta do Codex a GLM-R001 e ajustar o objetivo do santuário se ele propor contrato diferente.
3. Executar os casos jogáveis de `docs/testing/fase-1-glm.md` no Studio/cliente (teclado + toque + dois jogadores) e atualizar o documento com o SHA do build.
4. Fase 2 (após aceite da fase 1): perfil persistente (DataStore) conforme o schema proposto na decisão 0003 e o plano de `NEXT_TASKS.md`.
