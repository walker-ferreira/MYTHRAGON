# Testes — Fase 1 (GLM 5.3): Aetheria, objetivos, portal e selos

**Branch:** `glm/aetheria-fase-1` · **Base analisada:** `main@fd18885` · **Build:** artefato `mythragon-pilot` da CI do PR (sintaxe Luau + build Rojo; conferir o SHA no relatório do PR).

Ambientes: esta rodada **não** executou o jogo no cliente Roblox (sem Studio aqui). O que está registrado abaixo separa o que foi verificado no código/CI do que continua **pendente de execução jogável**, conforme o princípio da decisão 0001 e do plano de QA do PR #5.

## Verificado nesta rodada

- **CI do PR (build job):** aprovada — sintaxe Luau de todos os `.luau` de `src` e `rojo build default.project.json` com `$path src/server` incluindo os módulos alterados. (Confirmar link da execução no PR.)
- **Revisão de código do fluxo completo:** spawn → objetivos (Guardiões/santuário) → portal → Ember → retorno → painel de selos; contração e limpeza dos estados por jogador (`inTransit`, `panels`, `objectivePanels`, sessões do `Profile`).
- **Preservação dos contratos:** `Ember.build(parent, onVictory) -> enter(player): boolean`, `connectReturn(parent, onReturn)`, `Profile.recordVictory(player, "Ember", encounterId)` e chamadas em `Start` intactas.

## Casos jogáveis (pendentes — executar no Studio/cliente)

Marque cada caso quando executado, com ambiente (teclado/toque/multiplayer) e SHA do build.

| # | Caso | Status |
| --- | --- | --- |
| 1 | Jogador novo nasce em local seguro (HubSpawn) e vê painéis de objetivos e selos | Pendente |
| 2 | Observar um Guardião do Éter marca o objetivo 1 no painel deste jogador | Pendente |
| 3 | Observar a pedra do santuário marca o objetivo 2 (com/sem Varkhion montado) | Pendente |
| 4 | Entrar no portal de Ember marca o objetivo 3 e leva à arena | Pendente |
| 5 | Objetivos fora de ordem; toast final só após os três | Pendente |
| 6 | Derrota no guardião: respawn no hub, arena liberada, nova tentativa possível | Pendente |
| 7 | Saída antecipada/desconexão liberam a arena; retorno automático pós-vitória (~30s) devolve ao spawn | Pendente |
| 8 | Vitória: selo de Ember concedido **uma única vez**; segunda vitória devolve `duplicate` | Pendente |
| 9 | Segundo jogador: painéis próprios (objetivos e selos) sem herdar progresso de A | Pendente |
| 10 | Plataforma flutuante de Ember sobe/desce e carrega o personagem | Pendente |
| 11 | Toque (mobile): prompts de observar e do portal acionáveis | Pendente |
| 12 | Varkhion montado no `VarkhionMount` (após integração do Codex): interação por E/toque conclui o objetivo 2 via `Hub.completeObjective` | Pendente (depende de GLM-R001) |

## Specs puros

- `src/server/Profile/Profile.spec.luau` e `src/server/Ember/EncounterState.spec.luau` — sem alterações nesta rodada; CI atual apenas os compila. Execução local pendente de confirmar (a execução prévia registrada no PR #3 permanece válida para os arquivos não alterados).
