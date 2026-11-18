# Fila oficial — MYTHRAGON

Campos obrigatórios por tarefa: ID, objetivo, responsável, base completa, branch,
caminhos, dependências, aceite, estado, próximo checkpoint e evidências.
Claim por branch/PR, nunca dois escritores no mesmo worktree.
Estados de trabalho: AVAILABLE, ASSIGNED, IMPLEMENTING, REVIEW, BLOCKED, INTEGRATED,
AWAITING_OWNER. Estados de certificação são separados (AGENTS.md).

## MOBILE-MENU-002 — alternar VIAGEM e Comandos por toque

- Responsável: CODEX. Base: `3064e0c2e6147a7b30044d75008bb817191c1e4e`. Branch: `codex/mobile-menu-switching`.
- Caminhos: `src/client/CommandPanel.client.luau`, `src/client/LatuniaTravelUi.client.luau` e roteiro final.
- Aceite: abrir um painel fecha o outro, restaura o texto do botão anterior e reabre a lista no topo. Usa estado local no PlayerGui em dispositivos com toque.
- Próximo checkpoint: CI, staging e conferência da alternância em partida real.

## MOBILE-HUD-001 — liberar controles nativos e mostrar a lista completa

- Responsável: CODEX. Base: `f007ea62ab0e36c1e77e1df61ebd19c841d7b271`. Branch: `codex/mobile-hud-clear-controls`.
- Caminhos: `src/client/{CommandPanel,OwnerFlight,LatuniaTravelUi}.client.luau`, `src/server/Profile/ExplorationPanel.luau` e roteiro final.
- Aceite: controles por toque abaixo da faixa de revisão, selos e pulo desobstruídos e listas roláveis em paisagem.
- Próximo checkpoint: CI, staging e confirmação do HUD no cliente móvel.

## LATUNIA-CANCEL-NOTICE-001 — indicar cancelamento da travessia

- Responsável: CODEX. Base: `e985890e35052ef7669233ec703ab610fec20246`. Branch: `codex/latunia-travel-cancel-notice`.
- Caminhos: `src/server/Latunia/Codex/Map.luau` e `docs/testing/latunia-safe-travel-menu-api.md`.
- Aceite: avisar cancelamento ao sair do alcance, encerrar o bilhete e não creditar descoberta. Falha no aviso inicial não impede a conclusão do bilhete.
- Próximo checkpoint: CI e inspeção de staging. Validar cancelamento e nova tentativa em partida real.

## EMBER-LEGACY-SEAL-001 — restaurar o selo com evidência do retorno anterior

- Responsável: CODEX. Base: `9133f1eff4a7b906673862bc83d5ee8a971fc1c9`. Branch: `codex/recover-legacy-ember-seal`.
- Caminhos: `src/server/Profile/ProgressData.luau` e `ProgressData.spec.luau`.
- Aceite: restaurar selo de perfil v1 com retorno confirmado e gravação do selo ausente. Entrada no portal, descoberta e valores inválidos não restauram o selo.
- Próximo checkpoint: CI e publicação experimental, seguidas de reconexão num cliente Roblox.

## EMBER-RETURN-ATOMIC-001 — gravar retorno e selo juntos

- Responsável: CODEX. Base: `5e87e2a575143b39af082ae50c151cab31007f14`. Branch: `codex/persist-ember-return-with-seal`.
- Caminhos: `src/server/Profile/ObjectivesData.luau` e `ObjectivesData.spec.luau`.
- Dependências: retorno validado pelo servidor exige vitória, selo concedido e viagem concluída.
- Aceite: gravação do marco de retorno inclui o selo de Ember na mesma atualização. Descobertas de ilhas preservam selos existentes.
- Estado: INTEGRATED (PR #72), revisão 58 experimental confirmada no GitHub Actions `44104982300`. A reconexão no cliente Roblox faz parte do teste de aceitação.

## QUEST-SAVE-BATCH-001 — consolidar gravação dos marcos da jornada

- Responsável: CODEX. Base: `ca70154aec58b50b2aa53c20fed95cbf54cd5159`. Branch: `codex/objective-save-batches`.
- Caminhos: `src/server/Profile/ObjectivesData.luau`, `ObjectivesData.spec.luau` e `ObjectivesStore.luau`.
- Aceite: uma gravação por lote, preservando selo, marcos salvos e novos objetivos concluídos durante a gravação. Falhas mantêm o lote pendente para nova tentativa.
- Estado: INTEGRATED (PR #68), aguardando confirmação de persistência entre servidores no playtest da Fase 1.

## GATE FINAL — Fase 1 candidata, revisão 57 (PENDING PLAYTEST)

- Responsável: CODEX/integrador. Base `d82cc87f267c92c6d8fe53a0a512590f3652ed4f`; PRs #57–#70 integrados; código de dez marcos, menu VIAGEM seguro, mural de missões e quatro selos narrativos.
- Evidência: GitHub Actions CI `44103144825` e staging `44103219262` concluídos; revisão **57**, `PERSISTED_OK + isolated engine bootstrap PASS`. A revisão 50 havia sido publicada, mas a inspeção falhou; corrigido pelos PRs #61/#62 e verificado na 51.
- **Não certificado:** testes reais de servidor/cliente, 2 jogadores, joystick mobile, desempenho e DataStore entre servidores. Estado `AWAITING_OWNER` para evidência, **não** `PLAYTEST_OK`, `RUNTIME_OK`, `DATASTORE_OK` ou produção.
- Próximo checkpoint: executar [gate de aceitação](../testing/phase1-final-acceptance.md) em servidor novo e registrar revisão, logs F9 e evidências (sem dados pessoais). Corrigir problemas reproduzidos em PR separado.
- Coordenação: GLM PR #45 continua bloqueado por teleporte direto e não deve substituir o menu seguro PR #58. Substituto seguro aberto pela GLM: **PR #91** (GLM-R013, terminais físicos via `Map.requestTravel`, CI verde, aguardando revisão); #45 pode ser fechado sem merge. Os 10 NPCs permanecem desativados. Histórico abaixo é preservado, mesmo quando marcado como REVIEW no passado.


## EMBER-RETURN-PERSIST-001 — validar vitória no retorno e enfileirar salvamento antes da interface

- Responsável: CODEX. Base: `b0699ba0b05636a96975049a491a7f9f94f95e5f`. Branch: `codex/ember-seal-save-order`.
- Caminhos: `src/server/{Diagnostics/Bootstrap,Ember/Combat,Profile/ProgressStore,Profile/ObjectivesStore}.luau` e `docs/testing/ember-return-milestone.md`.
- Dependências: resultado de encontro emitido pelo controlador Ember e DataStore monotônico existente.
- Aceite: saída de encontro abandonado não registra retorno, mesmo com selo antigo. Selos e marcos entram na fila de gravação antes da atualização visual. Erro no marco após o deslocamento não invalida o retorno físico.
- Estado: REVIEW. Próximo checkpoint: inspecionar staging e validar o fluxo de vitória e reconexão com um cliente Roblox.

## LATUNIA-TRAVEL-RECOVERY-001 — confirmar chegada antes de atualizar a viagem

- Responsável: CODEX. Base: `600316ca927aa5c0c10765db3605964ce661865e`. Branch: `codex/latunia-travel-recovery`.
- Caminhos: `src/server/Latunia/Codex/Map.luau` e `docs/testing/latunia-safe-travel-menu-api.md`. Depende das rotas e bilhetes existentes no controlador de Latúnia.
- Aceite: falha de teleporte preserva a origem e a descoberta pode ser concedida somente após uma travessia bem-sucedida. O resgate após queda pode tentar novamente.
- Estado: REVIEW. Próximo checkpoint: conferir a revisão após a publicação experimental e testar o fluxo no cliente.

## COMBAT-003 — sopro direcionado e esquiva no impacto

- Responsável: CODEX. Base da main: `e6cd00352d29b089e4320da1f06a1d66ad523e4e` (PR #54). Branch: `codex/ember-breath-dodge-fix`.
- Caminhos: `src/server/Ember/` e `docs/testing/ember-targeted-breath.md`. Dependências: combate de Ember, dimensões do piso e relógio do servidor.
- Aceite: quadrado permanece imóvel e sobre o piso. O servidor concede 0,45 segundo de proteção contra o sopro após uma esquiva aceita, com cooldown de 3 segundos.
- Estado: REVIEW. Próximo checkpoint: verificar publicação e testar o impacto com teclado, controle e toque em cliente real.

## EMBER-TRAVEL-001 — sincronizar saída de Ember pelo painel Comandos

- Responsável: CODEX. Base: `c41c35b75dd8777890453d30ff3c81c563856a4a`. Branch: `codex/ember-command-travel-sync`.
- Caminhos: `src/server/{Diagnostics/Bootstrap,Ember/Map,Hub/Map,Latunia/Codex/Map}.luau` e `docs/testing/studio-command-panel.md`.
- Dependências: autorização existente de Comandos em Studio/staging e os controladores de Ember, Hub e Latúnia da main.
- Aceite: após um teleporte de teste bem-sucedido, liberar a arena e a trava de entrada do jogador. Destino recusado ou teleporte com erro deve manter a tentativa disponível para continuar. A viagem de teste não concede selo nem descoberta.
- Estado: REVIEW. Evidências de compilação, testes e staging no PR e nos workflows associados.
- Próximo checkpoint: executar a regressão do painel em uma sessão Roblox com duas contas e registrar a revisão exibida.

## CHECKPOINT DE INTEGRAÇÃO — GLM-R009 e DATASTORE-RETRY-001

- **PR #34:** melhorias GLM em Gelo, Selva e Vila Central integradas após correção `Enum.Material.Terracotta` → `ClayRoofTiles` e CI aprovada. A implantação visual foi integrada sem descartar a geometria base Codex.
- **PR #39:** Bootstrap usa `Vila.partnerBuilders` (Central, Gelo e Selva). O engine probe exige cenários-base e overlays GLM simultaneamente; staging **revisão 33** confirmou `PERSISTED_OK` e inicialização isolada PASS no commit `c814eb29bb031c8aabce4ef2ca6ac791df4087c8`.
- **PR #40:** repete periodicamente gravações pendentes de selo/objetivos após esgotar a janela inicial de tentativas de DataStore. O estado do código foi integrado; verificar a revisão publicada específica no workflow antes de declarar `PUBLISHED` para essa correção.
- **Limites:** motor isolado não comprova câmera, física, experiência mobile, movimento real, salvamento de conta e multiplayer. DATASTORE_OK, RUNTIME_OK e PLAYTEST_OK continuam pendentes.
- **Próximo checkpoint:** entrar em servidor Roblox novo; conferir versão e READY, visitar Gelo/Selva/Vila, confirmar marcos GLM e pisos, testar combate, retorno, salvamento e reconexão em duas contas. Guardar screenshots e logs F9 para corrigir apenas falhas comprovadas. NPCs permanecem na biblioteca, não montados.

## CHECKPOINT INTEGRADOR — JOURNEY-001/002 e COMBAT-002

- **Integrados:** #32 registra primeira viagem validada do Hub à Vila Central como descoberta persistente; #33 adiciona esquiva no combate de Ember (Q/controle B/toque) com cooldown de 3 segundos, verificação de obstáculos e dano alinhado ao quadrado de aviso; #35 expande descoberta persistente para cinco ilhas. Base de referência: commit `2b396acfe98ba38307525781c32ba1506b04181e`.
- **Evidência:** CI de PRs #32, #33 e #35 aprovada. Revisão 28 de staging publicou #33 com engine isolado PASS; verificar publicação do #35 pelo pipeline oficial antes de declarar sua revisão publicada. Dados de jogadores reais, navegação física, multijogador e cliente mobile permanecem **PENDING**.
- **GLM PR #34:** CI inicial reprovada no LSP por `Enum.Material.Terracotta` inexistente nas definições do projeto; comentário técnico registrado no PR do GLM. Não integrar reprovado nem editar sua branch sem coordenação.
- **Próximo checkpoint:** PLAYTEST-001 (viajar pelas cinco ilhas e voltar), DATASTORE-QA-001 (retorno após sair, duas contas e falha), COMBAT-QA-002 (esquiva Q/B/toque, cooldown, área laranja e obstáculos), MOBILE-001 (UI/responsividade). NPCs continuam não montados.
- **Regra:** preservar trabalho histórico e diferenciar CI, publicação, motor isolado e partida real.

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
