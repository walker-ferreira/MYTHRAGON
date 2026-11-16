# Registro de trabalho — Codex (GPT‑6.1 Sol)

**Editor exclusivo:** Codex. **Rodada:** Fase 1 — Varkhion funcional.

## Estado atual e inventário

- Base conferida: `origin/main` = `fd188854a8bf9176a636b1c9ec71167c82dfbd72`.
- Branch/pasta próprias: `codex/varkhion-fase1`, `MYTHRAGON-codex-varkhion`.
- Entrega em [PR #6 (rascunho)](https://github.com/walker-ferreira/MYTHRAGON/pull/6), implementação `d923e6f`. [CI da implementação](https://github.com/walker-ferreira/MYTHRAGON/actions/runs/43791170078) PASS (sintaxe/build). Pedidos enviados ao GLM no [PR #4](https://github.com/walker-ferreira/MYTHRAGON/pull/4#issuecomment-6905459521).
- PRs abertos na leitura inicial: [#4 coordenação](https://github.com/walker-ferreira/MYTHRAGON/pull/4), [#5 plano](https://github.com/walker-ferreira/MYTHRAGON/pull/5). Lidos AGENTS, GDD, arquitetura e decisões 0002/0003 da base; plano, PROJECT_STATUS e NEXT_TASKS do PR #5; ambos os registros de agentes do PR #4. Nenhum desses PRs foi integrado por esta rodada.
- Ember reaproveitado **sem alteração**: `Map.luau` (arena, ruínas, plataforma servo 0–12 studs), `Combat.luau` (guardião procedural de obsidiana, ataque E/toque, alcance/cooldown/vida no servidor, derrota/abandono e retorno após vitória), `EncounterState.luau` e spec.
- `Hub/Map.luau`, `Profile/Profile.luau` e `Start.server.luau`: portal e selo individual de sessão existentes; não são meus arquivos nesta rodada.
- Nenhum rig, Animation/AnimationId, catálogo ou pacote de dragões na árvore da base. O guardião é o precedente técnico reaproveitado: Parts ancorados, asas/chifres/olhos e ProximityPrompt com validação servidor. Sua geometria e combate não serão substituídos.
- Publicação anterior: build do SHA da base enviado na [execução 43786254524](https://github.com/walker-ferreira/MYTHRAGON/actions/runs/43786254524); resumo sem número de revisão confirmado. Não inferir que a versão publicada continua sendo a atual. Revisão 5 é evidência do dono para a plataforma, não teste desta fase.
- Caminhos autorizados ao Codex: `src/server/Dragons/`, este registro, `docs/testing/varkhion-fase1.md`, `docs/decisions/0004-varkhion-interacao.md`. Ember preservado. GLM é o único editor de Hub e Start nesta rodada. Workflows, Rojo, AGENTS e documentos do plano sem alterações.
- Implementado nesta sessão: modelo original provisório de Varkhion, montagem idempotente/ciclo de vida, prompt E/toque e resposta individual com validação no servidor; regras puras e spec próprios. Nenhum bootstrap automático ou concessão de selo/posse.
- Verificação local final: sintaxe de 13 fontes, três specs (Ember, Profile, InteractionState), build Rojo e comparação dos caminhos preservados PASS. Acrescentado `Varkhion.engine.spec.luau`, módulo manual de Studio sem autoexecução/concessão: apenas compilado, **não executado no motor**. Integração com santuário, revisão GLM e todos os casos de cliente permanecem pendentes, detalhados em [testing](../testing/varkhion-fase1.md).

## Pedidos e decisões consolidados

### VX-001 — Caminho, montagem e composição

**Estado:** caminho/editor aprovados pelo dono; proposta técnica aguardando resposta do GLM.

- Codex implementa `src/server/Dragons/Varkhion.luau`, `VarkhionModel.luau` e regras/specs de interação. GLM edita exclusivamente `src/server/Start.server.luau` e fornece o santuário em `src/server/Hub/`.
- Contrato proposto: `Varkhion.mount(parent: Instance, anchor: BasePart, onInteracted: (Player, string) -> ()) -> controller`.
- GLM fornece um BasePart **ancorado**, `VarkhionAnchor`, descendente do `parent` no Workspace: centro local no nível do piso, orientação define a frente do dragão (**-Z**), escala fixa em studs. Reservar pelo menos 36 × 34 studs, altura livre de 18 e mais 12 studs de aproximação frontal desobstruída. Anchor invisível, sem colisão. Não usar uma posição global fixa no módulo.
- GLM chama `mount` uma vez, após construir Aetheria; chamadas repetidas com mesmo parent/anchor retornam o mesmo controller e não substituem o callback original. Outro anchor no mesmo parent é erro de configuração.
- `controller:destroy()` desconecta listeners, limpa estado e feedback e destrói o modelo; destruição do anchor/parent também desmonta. Recriação explícita é possível após destruir.
- **Aceite GLM:** responder em `GLM.md` com o mesmo ID, confirmar anchor/orientação/área e chamada única em Start; informar branch/PR para revisão cruzada. Até a resposta, nenhum encaixe é realizado por Codex.

### VX-002 — Interação e objetivo

**Estado:** proposta aguardando GLM; implementação isolada por Codex.

- ProximityPrompt no dragão: “Ouvir Varkhion”, tecla E ou toque. O servidor reconfirma jogador conectado, personagem atual vivo, distância ≤ 12 studs, montagem válida e intervalo de 3 s.
- Resposta individual em PlayerGui com nome, texto legível e orientação ao portal de Ember; nenhuma mudança no texto compartilhado para indicar progresso de um jogador.
- Callback `onInteracted(player, "Varkhion")`, uma emissão bem-sucedida por jogador por montagem/sessão; repetições mostram diálogo sem nova emissão. Callback GLM **síncrono, sem yield e idempotente**, atualiza objetivo inicial próprio, sem conceder selo/posse persistente. Falha do callback não conclui a interação e permite nova tentativa.
- Resposta inicial: “O Éter ainda pulsa em você. Entre no portal de Ember, enfrente o guardião de obsidiana e volte com o primeiro selo.”
- Morte/respawn não apagam a conversa já concluída na sessão; desconexão limpa o estado. Estado de um jogador não se propaga ao outro.
- Ember e `Profile.recordVictory` continuam sendo as únicas autoridades de combate e selo. Conversar não vence encontro, não concede dragão e não altera os quatro selos.
- **Aceite GLM:** confirmar texto/evento, origem do objetivo e retomada após retorno/derrota, usando VX-002 em seu registro. Antes desse acordo, documentação duradoura registra contrato como proposto, não aceito.

### VX-003 — Revisão, QA e publicação

**Estado:** aberto.

- Solicito revisão GLM de modelo, interação, isolamento e ciclo de vida. Codex revisará o PR de Aetheria/Start quando disponível; nenhuma revisão fictícia é registrada.
- Evidências e casos em `docs/testing/varkhion-fase1.md`. Reaproveitar resultados do GLM somente com SHA/ambiente e casos identificados.
- Sem teste jogável aprovado, **não integrar/publicar esta fase**. Destino futuro restrito a Place `135004978091658`, Universe `10777026486`; confirmar e registrar revisão retornada pelo Roblox. Número ausente é bloqueio de observabilidade, não número a inferir.

## Resumo do que GLM está fazendo

Na consulta inicial e na releitura antes de concluir, `GLM.md` do PR #4 continua apenas template: sem branch de Aetheria, pedidos, respostas ou resultados. O PR #5 atribui ao GLM Aetheria, santuário, objetivo inicial, portal, perfil e encaixe em Start. Isso é **plano**, não implementação confirmada. PRs abertos na releitura: #4/#5 (documentação) e #6 (Codex); nenhum PR de Aetheria identificado. Não há revisão cruzada nova a aproveitar nem resposta do parceiro a inventar.

## Próximas tarefas

1. Codex: implementação isolada, specs puras, build e PR #6 concluídos; aguardar GLM sem contornar a responsabilidade de Start.
2. GLM: responder aos mesmos IDs em `GLM.md`, montar santuário/objetivo e integrar Start em sua branch.
3. Ambos: revisão cruzada dos PRs e execução do percurso combinado no cliente (teclado, toque, dois jogadores e falhas).
4. Codex: somente após CI, revisão e QA aprovados, integrar e publicar o artefato validado da main no teste; registrar a revisão real.
