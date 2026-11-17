# Fila oficial — MYTHRAGON

Campos obrigatórios por tarefa: ID, objetivo, responsável, base completa, branch,
caminhos, dependências, aceite, estado, próximo checkpoint e evidências.
Claim por branch/PR, nunca dois escritores no mesmo worktree.
Estados de trabalho: AVAILABLE, ASSIGNED, IMPLEMENTING, REVIEW, BLOCKED, INTEGRATED,
AWAITING_OWNER. Estados de certificação são separados (AGENTS.md).

## CHECKPOINT TÉCNICO — integrados PRs #26–#30

- **Integrados:** #26 validação estrita de identidade de encontro; #27 DataStore v1 do selo Ember; #28 DataStore v1 dos três objetivos existentes do Hub; #29 validação de distância dos Guardiões e liberação de trânsito em falha do portal Ember; #30 barra de vida do Guardião e seis rochas cenográficas não colidíveis.
- **Base publicada confirmada:** PR28 revisão **24**, CI e inspeção isolada `PERSISTED_OK + engine_bootstrap PASS`; dados de jogador/cliente não foram testados. Inspecionar as publicações seguintes pelo run oficial.
- **Estado real:** implementação integrada `BUILD_OK`; DataStore programado com `UpdateAsync`, mas **DATASTORE_OK não comprovado**. Ainda sem `RUNTIME_OK`, `PLAYTEST_OK` ou aprovação de produção.
- **Próximos IDs:** PLAYTEST-001 (servidor real, jornada Aetheria→Ember→selo→Latúnia e volta, duas contas, teclado/toque); DATASTORE-QA-001 (sair/voltar, falha serviço, concorrência, logs); MISSION-002 (etapas restantes da sequência de 10 missões); COMBAT-002 (esquiva/ataques animados com controle de servidor); MOBILE-001 (interface/performance). Não declarar prontos nem instalar NPCs.
- **Coordenação:** alterações em `Hub/Map.luau` foram incrementais e mantiveram o layout GLM; futuros agentes devem usar `main` mais recente, não reintroduzir branches antigos ou alterar o mesmo worktree.
- **Evidência:** `docs/testing/persist-ember-v1.md`, `docs/testing/persist-hub-objectives-v1.md` e PRs #26–#30.

## STATUS ATUAL — Fase 1 após PRs #18 a #24

- **Integrados em main:** recuperação/staging (18), retorno Ember (19), retorno Latúnia (20), Gelo/Selva inicial (21), comandos de Studio sincronizados (22), biblioteca de 10 NPCs não montada (23), correção de coordenadas de Vila Central (24).
- **Evidência:** revisão 18 (PR21) PUBLISHED/PERSISTED_OK e engine isolado PASS. PR24 integrado com CI PASS, inspeção/staging da correção de coordenadas ainda deve ter resultado confirmado em run posterior.
- **Não concluído:** RUNTIME_OK, PLAYTEST_OK, mobilidade/combate em cliente real, multiplayer, desempenho mobile, persistência de perfil, NPCs instalados, mecânica real de dirigíveis e ferrovias, economia.
- **Regra:** não voltar a implementar Gelo/Selva como desembarques vazios; são cenários iniciais. Conservar os sistemas existentes e o trabalho dos outros agentes.
- **Próximo checkpoint:** inspeção de motor para verificar deslocamento de Vila Central; teste visual/físico de jogador e toque em servidor novo; aceitar correções reais por branch/PR. Biblioteca de NPCs permanece desligada até autorização do proprietário.
- **Coordenação:** registros históricos abaixo preservados, inclusive estados passados que já não são o estado atual.

## REC-001 — recuperar autonomia e releases

- Responsável: CODEX/integrador GPT-6.1 Sol.
- Base: 9c6c0009f41293bf40bb8fbaf581765862a81096.
- Branch/worktree: codex/recovery-autonomy / MYTHRAGON-recovery.
- Caminhos: AGENTS.md, ARCHITECTURE.md, .github/, tools/, tests/,
  docs/engineering/, docs/releases/, docs/agents/CODEX.md e esta fila,
  src/server/Start.server.luau, src/server/Diagnostics/, identidade gerada de build.
- Dependências: GitHub autenticado; secret Roblox existente; acesso Luau Execution
  ainda precisa ser testado; não presume executor externo GLM/Codex instalado.
- Aceite: sem publicação fantasma, build/SHA/destino/revisão rastreáveis,
  testes disponíveis executados, saúde do mundo e pendências verdadeiras.
- Estado: AWAITING_OWNER para playtest, implementação integrada e publicada.
  Checkpoints A–E aplicados; F engine isolado PASS, física/servidor normal/cliente
  pendentes; G candidato experimental revisão14 publicado; H fila preparada.
- Certificação: BUILD_OK, PREVIEW_OK, PUBLISHED, PERSISTED_OK; engine_bootstrap PASS.
  Não RUNTIME_OK/PLAYTEST_OK/PRODUCTION_APPROVED.
- Release: main integrado fc262b4a63e42176ede5255fa913524d4b3e887f,
  CI43986367988, PUBLISH43986456709, revisão14.
- Próximo checkpoint: proprietário avaliar versão14 em servidor novo; agentes
  corrigirem problemas por PR/pipeline. Conteúdo GLM-R008/PR15 e Gelo/Selva seguem
  tarefas separadas, sem merge automático de escopo ainda não revisado.
- Evidência: docs/releases/REC-001-fc262b4.json e REC-001-recovered-staging.md.

## LAT-GLM-001 — Gelo/Selva e revisão independente da recuperação

- Responsável: GLM. Revisão REC-001 recebida pela sessão real
  `ses_e194c8a04ffemstop4QUSgtZTG`; correções enviadas à segunda revisão.
  Segunda revisão recebida sem bloqueante fail-open; engine/playtest não aprovados.
  Conteúdo Gelo/Selva **não atribuído a um executor nesta sessão**. Estado: REVIEW
  para recuperação; AVAILABLE para conteúdo futuro.
- Base/branch: selecionar main atual ao claim, registrar SHA completo no PR.
- Caminhos: módulos próprios Gelo/Selva em src/server/Hub/ ou caminho acordado;
  docs/agents/GLM.md e testes próprios; revisão somente leitura de REC-001.
- Dependências: contrato L3D-001 e pipeline recuperado. Não editar Start/workflows.
- Aceite: geometria/piso/chegadas seguros, sem recompensas não autorizadas,
  contrato partnerBuilders, tests/evidências de engine e cliente separados.
- Próximo checkpoint: confirmar recebimento e escopo; não iniciar conteúdo em paralelo
  no worktree do integrador.
