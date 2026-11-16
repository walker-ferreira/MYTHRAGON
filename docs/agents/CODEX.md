# Registro de trabalho — Codex (GPT‑6.1 Sol)

**Editor exclusivo:** Codex. **Rodada:** Fase 1 — Varkhion funcional.

## Estado atual e inventário

- Base conferida: `origin/main` = `fd188854a8bf9176a636b1c9ec71167c82dfbd72`.
- Branch/pasta próprias: `codex/varkhion-fase1`, `MYTHRAGON-codex-varkhion`.
- Entrega em [PR #6 (rascunho)](https://github.com/walker-ferreira/MYTHRAGON/pull/6), implementação `d923e6f`. [CI da implementação](https://github.com/walker-ferreira/MYTHRAGON/actions/runs/43791170078) PASS (sintaxe/build). Pedidos enviados ao GLM no [PR #4](https://github.com/walker-ferreira/MYTHRAGON/pull/4#issuecomment-6905459521).
- PRs abertos na leitura inicial: [#4 coordenação](https://github.com/walker-ferreira/MYTHRAGON/pull/4), [#5 plano](https://github.com/walker-ferreira/MYTHRAGON/pull/5). Lidos AGENTS, GDD, arquitetura e decisões 0002/0003 da base; plano, PROJECT_STATUS e NEXT_TASKS do PR #5; ambos os registros de agentes do PR #4. Nenhum desses PRs foi integrado por esta rodada.
- Ember reaproveitado **sem alteração**: `Map.luau` (arena, ruínas, plataforma servo 0–12 studs), `Combat.luau` (guardião procedural de obsidiana, ataque E/toque, alcance/cooldown/vida no servidor, derrota/abandono e retorno após vitória), `EncounterState.luau` e spec.
- `Hub/Map.luau` e `Profile/Profile.luau`: continuam com GLM; Codex não os edita. **Nesta continuação o dono transferiu Start exclusivamente para Codex** para a montagem (GLM-R003); o callback de vitória e o perfil foram preservados.
- Nenhum rig, Animation/AnimationId, catálogo ou pacote de dragões na árvore da base. O guardião é o precedente técnico reaproveitado: Parts ancorados, asas/chifres/olhos e ProximityPrompt com validação servidor. Sua geometria e combate não serão substituídos.
- Publicação anterior: build do SHA da base enviado na [execução 43786254524](https://github.com/walker-ferreira/MYTHRAGON/actions/runs/43786254524); resumo sem número de revisão confirmado. Não inferir que a versão publicada continua sendo a atual. Revisão 5 é evidência do dono para a plataforma, não teste desta fase.
- Caminhos autorizados ao Codex: `src/server/Dragons/`, este registro, `docs/testing/varkhion-fase1.md`, registro próprio de Varkhion renomeado para `docs/decisions/0005-varkhion-interacao.md` e, nesta continuação, `src/server/Start.server.luau`. Ember preservado. GLM segue único editor de Hub e dos seus registros. Workflows, Rojo, AGENTS, índice de decisões e documentos do plano não são editados por Codex.
- Implementado nesta sessão: modelo original provisório de Varkhion, montagem idempotente/ciclo de vida, prompt E/toque e resposta individual com validação no servidor; regras puras e spec próprios. Nenhum bootstrap automático ou concessão de selo/posse.
- Verificação da entrega anterior: sintaxe de 13 fontes, três specs (Ember, Profile, InteractionState), build Rojo e comparação dos caminhos então preservados PASS; [CI 85a5152](https://github.com/walker-ferreira/MYTHRAGON/actions/runs/43791595724) PASS. `Varkhion.engine.spec.luau` só foi compilado, **não executado no motor**. Evidências da continuação e bloqueios em [testing](../testing/varkhion-fase1.md).
- Continuação: lido `GLM.md` do [PR #7](https://github.com/walker-ferreira/MYTHRAGON/pull/7), HEAD `47501c14ec823b0bf19cd7c348918e1678f6a3c4`, implementação `9320b1d`. Reaproveitada a [CI aprovada do GLM](https://github.com/walker-ferreira/MYTHRAGON/actions/runs/43794254570), que comprova sintaxe/build, não execução. A branch do GLM foi combinada por merge normal **apenas na branch Codex**, para entregar a ligação em Start; nenhum merge em main/publicação.
- Continuação verificada localmente: sintaxe de 13 fontes, três specs e build combinado PASS; Ember/Profile/config intactos em relação à main, Hub e documentos GLM idênticos ao PR #7. Auditoria de membros de Material **FAIL em DarkWood (Hub/Map.luau:101)**. Nenhum teste jogável, nem aprovação final, é inferido desses resultados.

## Pedidos e decisões consolidados

### VX-001 — Caminho, montagem e composição

**Estado:** atualizado pela resposta GLM-R001 abaixo. Nome concreto do mount adotado; espaço físico pendente de correção/revisão.

- Codex implementa Dragons e, após transferência explícita pelo dono, a ligação em Start. GLM fornece o santuário em `src/server/Hub/`.
- Contrato proposto: `Varkhion.mount(parent: Instance, anchor: BasePart, onInteracted: (Player, string) -> ()) -> controller`.
- GLM fornece um BasePart **ancorado**, `VarkhionAnchor`, descendente do `parent` no Workspace: centro local no nível do piso, orientação define a frente do dragão (**-Z**), escala fixa em studs. Reservar pelo menos 36 × 34 studs, altura livre de 18 e mais 12 studs de aproximação frontal desobstruída. Anchor invisível, sem colisão. Não usar uma posição global fixa no módulo.
- Codex liga `mount` uma vez em Start, após construir Aetheria; chamadas repetidas com mesmo parent/anchor retornam o mesmo controller e não substituem o callback original. Outro anchor no mesmo parent é erro de configuração.
- `controller:destroy()` desconecta listeners, limpa estado e feedback e destrói o modelo; destruição do anchor/parent também desmonta. Recriação explícita é possível após destruir.
- A proposta inicial de nome `VarkhionAnchor` foi substituída por `VarkhionMount` do PR #7; a área originalmente solicitada permanece pendente. GLM deve revisar a ligação do PR #6 e responder aos achados GLM-R002 abaixo.

### VX-002 — Interação e objetivo

**Estado:** callback conectado conforme GLM-R001; interação no módulo pronta para teclado/toque, execução jogável ainda pendente.

- ProximityPrompt no dragão: “Ouvir Varkhion”, tecla E ou toque. O servidor reconfirma jogador conectado, personagem atual vivo, distância ≤ 12 studs, montagem válida e intervalo de 3 s.
- Resposta individual em PlayerGui com nome, texto legível e orientação ao portal de Ember; nenhuma mudança no texto compartilhado para indicar progresso de um jogador.
- Callback `onInteracted(player, "Varkhion")`, uma emissão bem-sucedida por jogador por montagem/sessão; repetições mostram diálogo sem nova emissão. Callback GLM **síncrono, sem yield e idempotente**, atualiza objetivo inicial próprio, sem conceder selo/posse persistente. Falha do callback não conclui a interação e permite nova tentativa.
- Resposta inicial: “O Éter ainda pulsa em você. Entre no portal de Ember, enfrente o guardião de obsidiana e volte com o primeiro selo.”
- Morte/respawn não apagam a conversa já concluída na sessão; desconexão limpa o estado. Estado de um jogador não se propaga ao outro.
- Ember e `Profile.recordVictory` continuam sendo as únicas autoridades de combate e selo. Conversar não vence encontro, não concede dragão e não altera os quatro selos.
- A origem do objetivo passa a ser `Hub.completeObjective(player, "santuario")`, como pedido pelo GLM. A pedra pode já ter marcado esse objetivo; nesse caso o retorno false é duplicata legítima e a conversa continua com resposta individual.

### GLM-R001 — Resposta: montagem e conversa

**Estado:** respondido e ligado em Start na branch combinada; aceite jogável bloqueado pelos achados GLM-R002.

- Reaproveitados os módulos de `src/server/Dragons/` do PR #6, sem criar módulo paralelo `Dragoes/`.
- Ligação exata, sem alterar Hub:

```luau
local mount = assert(map.Hub:FindFirstChild("VarkhionMount"))
Varkhion.mount(map.Hub, mount, function(player, speciesId)
    assert(speciesId == "Varkhion")
    Hub.completeObjective(player, "santuario")
end)
```

- Acontece uma vez, após `Hub.build` e `Ember.connectReturn`. O mount real é descendente de Hub, ancorado e sem colisão; sua frente -Z local aponta para leste, compatível com o modelo.
- A validação de interação é do módulo Codex (personagem vivo, distância medida no servidor ≤12, cooldown 3 s, callback serializado por jogador). E, toque e ButtonX já configurados; feedback só no PlayerGui de quem interage.
- `Hub.completeObjective` é síncrono/idempotente quando o painel existe; false também significa “já concluído”, portanto não deve ser tratado como erro. Vitória e selo continuam exclusivamente no fluxo Ember → Profile.
- Nome/orientação compatíveis **não** significam encaixe visual aprovado: piso e colunata requerem resolução do item C abaixo.

### GLM-R002 — Resposta: revisão do PR #7

**Estado:** revisão de código concluída; **solicito correções antes de aprovação**. Nenhuma alteração no Hub feita por Codex.

**Preservações conferidas:** `HubSpawn` em (0,0.5,14); deck oeste [-91,-33] encostado ao deck original, ambos com topo Y=0; trajeto contínuo sobre piso; pedras/estátuas fora do spawn. Portal e validação vivo/distância/inTransit mantidos. `objectivePanels[player]` e `panels[player]` são individuais, `ResetOnSpawn=false`; limpeza em PlayerRemoving. Retorno/respawn liberam trânsito. Objetivo "portal" só é marcado após aceitação de entrada de Ember. Sem mudança em Profile, Ember ou resultado de vitória.

**A — BLOQUEANTE de inicialização**

- **Caminho:** `src/server/Hub/Map.luau`, `createTree`, `Enum.Material.DarkWood`.
- **Evidência:** [enum oficial Material](https://create.roblox.com/docs/reference/engine/enums/Material) tem Wood/WoodPlanks e não DarkWood. A primeira árvore é criada dentro de `Hub.build`, antes do mount e antes de retornar a função de volta; a resolução desse membro inválido interrompe a construção. Sintaxe/build verdes não verificam membros de Enum.
- **Mudança esperada (GLM):** usar `Enum.Material.Wood` ou `WoodPlanks`, mantendo a cor escura. Não remover a árvore em runtime nem criar alias de Enum.
- **Como verificar:** revisar enum/material, executar Play no Studio sem erro de Material; confirmar que Hub.build termina, `Hub.VarkhionMount` e `Hub.Varkhion` existem e o retorno Ember foi conectado.

**B — BLOQUEANTE do aceite mobile (inferência de layout, não observação no cliente)**

- **Caminho:** `src/server/Hub/Map.luau`, `ensureObjectives` + `ensurePanel`/`Hub.notify`.
- **Evidência:** objetivos têm largura 250, X=16; selos largura 230, alinhados à direita com margem 16; ambos Y=16. Em viewport de 320 px, objetivos ocupam X=[16,266], selos X=[74,304]: sobreposição de 192 px. Textos longos dos objetivos/toasts não têm quebra de linha/escalonamento.
- **Mudança esperada (GLM):** layout responsivo sem sobreposição e texto legível, sem perder estado individual ou controles de toque.
- **Como verificar:** 320×568 e 640×360 no emulador e cliente de toque; objetivos/selos/dialogue/toast legíveis, prompts e movimento acionáveis. Não registrar esses testes como feitos até executar.

**C — Compatibilidade do santuário: corrigir antes de aprovar aparência**

- **Caminho:** `src/server/Hub/Map.luau`, `sanctuaryCenter`, `SanctuaryDais`, colunata e `VarkhionMount`.
- **Evidência no código:** colunas ficam em raio 9, enquanto o modelo natural requer espaço livre maior. A coluna oeste em X=-87 cruza a cauda montada; origem do mount Y=1,8 fica 0,6 acima do topo do dais Y=1,2. Os pés ficam suspensos e a cauda atravessa a colunata. A ponta traseira também ultrapassa a borda oeste atual; não é piso seguro para uma futura montaria.
- **Mudança esperada (GLM):** ajustar origem ao piso e abrir/realocar espaço para a geometria, ou propor escala ao Codex pelo mesmo ID antes de reduzir o modelo. Não mudar o CFrame do mount depois da montagem.
- **Como verificar:** Play com dragão montado, inspecionar pés, asas, cauda e pilares de frente/lado; caminhar do trajeto ao prompt sem obstrução. Medidas são revisão estática; confirmação visual ainda pendente.

**D — Endurecimento recomendado**

- **Caminho:** `src/server/Hub/Map.luau`, `observePrompt`.
- **Mudança esperada (GLM):** reconfirmar HumanoidRootPart e distância até o alvo no handler, além de vida, para manter a validação explícita no mesmo padrão do portal e de Varkhion.
- **Como verificar:** jogador próximo/vivo conclui só seu objetivo; morto/sem root/longe não conclui. O handler usa Triggered (que possui checagem interna de distância do Roblox); não alego exploit reproduzido ou recompensa indevida confirmada.

### GLM-R003 — Resposta: editor de Start

**Estado:** transferência autorizada explicitamente pelo dono nesta continuação.

Codex é o único editor de `src/server/Start.server.luau` para a ligação acima. GLM não deve editar Start nesta rodada; mantém Hub e seus registros. O comentário do arquivo identifica Codex. A lógica de vitória, idempotência do selo e retorno de Ember foi preservada. A numeração do registro próprio foi mudada para 0005 com autorização, sem renumerar/apagar o 0004 do GLM.

Quando atualizar seus documentos/índice, GLM pode referenciar `0005-varkhion-interacao.md` como a decisão do módulo Codex. Codex não alterou a linha do índice nem o registro 0004 do parceiro.

### VX-003 — Revisão, QA e publicação

**Estado:** aberto.

- Solicito revisão GLM de modelo, interação, isolamento, ciclo de vida e da nova ligação em Start no PR #6. Revisão Codex do PR #7 feita sob GLM-R002; correções solicitadas, não aprovação.
- Evidências e casos em `docs/testing/varkhion-fase1.md`. Reaproveitar resultados do GLM somente com SHA/ambiente e casos identificados.
- Sem teste jogável aprovado, **não integrar/publicar esta fase**. Destino futuro restrito a Place `135004978091658`, Universe `10777026486`; confirmar e registrar revisão retornada pelo Roblox. Número ausente é bloqueio de observabilidade, não número a inferir.

## Resumo do que GLM está fazendo

Atualizado pela leitura de `GLM.md` no PR #7 (`47501c1`): GLM entregou a ala oeste de Aetheria, vegetação/ruínas/cristais, estátuas, santuário/mount e objetivos individuais, preservando spawn, portal, selos e Profile. CI do GLM aprovada; casos jogáveis explicitamente pendentes no registro dele. Respondi a GLM-R001/002 e defini GLM-R003 com o dono. Próxima ação do GLM é corrigir os itens de revisão no Hub e revisar a ligação Codex; não há confirmação de testes de cliente ou revisão do PR #6 pelo parceiro.

## Próximas tarefas

1. GLM: corrigir GLM-R002 A/B/C no Hub e responder com os mesmos IDs em seu registro; D é endurecimento recomendado. Não editar Start nesta rodada.
2. Codex: manter ligação GLM-R001 em Start, incorporar por merge as correções do GLM e repetir somente verificações afetadas; GLM revisar PR #6/Start/modelo.
3. Ambos: revisão cruzada dos PRs e execução do percurso combinado no cliente (teclado, toque, dois jogadores e falhas).
4. Codex: somente após CI, revisão e QA aprovados, integrar e publicar o artefato validado da main no teste; registrar a revisão real.
