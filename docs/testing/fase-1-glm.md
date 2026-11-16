# Testes — Fase 1 (GLM 5.3): Aetheria, objetivos, portal e selos

**Branch:** `glm/aetheria-fase-1` · **Base analisada:** `main@fd18885` · **Build:** artefato `mythragon-pilot` da CI do PR (sintaxe Luau + build Rojo; conferir o SHA no relatório do PR).

Ambientes: esta rodada **não** executou o jogo no cliente Roblox (sem Studio aqui). O que está registrado abaixo separa o que foi verificado no código/CI do que continua **pendente de execução jogável**, conforme o princípio da decisão 0001 e do plano de QA do PR #5.

## Verificado nesta rodada

- **CI do PR #7 (build job):** aprovada no SHA `47501c1` — sintaxe Luau de todos os `.luau` de `src` e `rojo build default.project.json` com `$path src/server` incluindo os módulos alterados.
- **Integração do Varkhion (PR #6 do Codex):** resposta aos pedidos VX-001/002/003 registrada em `docs/agents/GLM.md`; âncora `VarkhionAnchor` entregue conforme contrato; montagem única em `Start` com detecção segura da pasta `Dragons` (a branch funciona sozinha e completa após o merge do PR #6).
- **Revisão de código do fluxo completo:** spawn → objetivos (Guardiões/Varkhion) → portal → Ember → retorno → painel de selos; limpeza dos estados por jogador (`inTransit`, `panels`, `objectivePanels`, sessões do `Profile`).
- **Preservação dos contratos:** `Ember.build(parent, onVictory) -> enter(player): boolean`, `connectReturn(parent, onReturn)`, `Profile.recordVictory(player, "Ember", encounterId)` e chamadas em `Start` intactas.
- **Revisão parcial do PR #6:** contrato, docs, CI e estrutura conferidos; leitura dos fontes bloqueada pela política local (registrada em VX-003 — nenhuma revisão fictícia).

## Casos jogáveis (pendentes — executar no Studio/cliente)

Marque cada caso quando executado, com ambiente (teclado/toque/multiplayer) e SHA do build.

| # | Caso | Status |
| --- | --- | --- |
| 1 | Jogador novo nasce em local seguro (HubSpawn) e vê painéis de objetivos e selos | Pendente |
| 2 | Observar um Guardião do Éter marca o objetivo 1 no painel deste jogador | Pendente |
| 3 | Conversar com o Varkhion marca o objetivo 2 (callback VX-002); observar a pedra da entrada é a rota de fallback | Pendente |
| 4 | Entrar no portal de Ember marca o objetivo 3 e leva à arena | Pendente |
| 5 | Objetivos fora de ordem; toast final só após os três | Pendente |
| 6 | Derrota no guardião: respawn no hub, arena liberada, nova tentativa possível | Pendente |
| 7 | Saída antecipada/desconexão liberam a arena; retorno automático pós-vitória (~30s) devolve ao spawn | Pendente |
| 8 | Vitória: selo de Ember concedido **uma única vez**; segunda vitória devolve `duplicate` | Pendente |
| 9 | Segundo jogador: painéis próprios (objetivos e selos) sem herdar progresso de A | Pendente |
| 10 | Plataforma flutuante de Ember sobe/desce e carrega o personagem | Pendente |
| 11 | Toque (mobile): prompts de observar, do Varkhion e do portal acionáveis | Pendente |
| 12 | Varkhion montado no `VarkhionAnchor`: aparece uma vez, sem sobrepor pilares (folga VX-001); diálogo individual; repetição mostra diálogo sem nova emissão | Pendente (após merge do PR #6) |

## Specs puros

- `src/server/Profile/Profile.spec.luau` e `src/server/Ember/EncounterState.spec.luau` — sem alterações nesta rodada; CI atual apenas os compila. Execução local pendente de confirmar (a execução prévia registrada no PR #3 permanece válida para os arquivos não alterados).
