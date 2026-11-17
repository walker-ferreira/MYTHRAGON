# Registro de trabalho — Codex (GPT‑6.1 Sol)

## REC-001 — recuperação 2026-11-16 (estado mais recente)

**Entrega recuperada:** PRs #12/#14/#16/#17 integrados com checks e revisões reais.
Main de conteúdo fc262b4a63e42176ede5255fa913524d4b3e887f, CI43986367988,
PUBLISH43986456709: revisão **14**, PERSISTED_OK e bootstrap isolado PASS.
Core/Varkhion/Latúnia READY, 24 fontes, cinco slots, dez prompts, 1.317 partes.
Servidor normal/cliente/física/playtest pendentes; Gelo/Selva provisórios.
Manifesto/roteiro em docs/releases/REC-001-recovered-staging.md.
Os parágrafos seguintes preservam a sequência histórica, não bloqueios atuais.

**Retomada após autenticação:** OPS-002 resolvido; PR #12 integrado com CI ampliada
PASS (43983522637 e main 43983671970). Main c669613. Publicação automática
43983719759 falhou antes de PATCH por confundir deployment automático vazio com
journal (REL-004). Correção/regressão na branch codex/fix-staging-journal;
19 testes Python PASS local, revisão GLM solicitada. Ainda sem nova revisão Roblox.

Este bloco substitui restrições operacionais históricas abaixo; não reescreve suas
evidências. Política permanente em AGENTS.md. Integrador: GPT-6.1 Sol.

- Base auditada main `9c6c0009f41293bf40bb8fbaf581765862a81096`.
- Worktree exclusivo MYTHRAGON-recovery / codex/recovery-autonomy.
- Issue #13 e PR #12; auditoria publicada, contratos e ferramentas enviados.
- Main protegida/auto-merge/staging main-only configurados via API, sem revisões
  humanas repetitivas. Não foi feito merge desta recuperação.
- Push dos workflows novos bloqueado por OAuth sem `workflow`; não contornar.
  Fluxo oficial de autenticação humana inevitável em OPS-002.
- CLI standalone: quatro specs executados; Python: dez testes executados;
  LSP Roblox: cinco políticas + Enums e negativo; sintaxe 24 fontes; duas
  compilações Rojo idênticas e manifesto/inclusão de fontes PASS localmente.
- CI remota `43980823371` PASS é do workflow **antigo**, não prova CI nova.
- Engine, novo servidor normal, cliente e visual NÃO executados.
- GLM real iniciado para revisão somente leitura pelo harness, modelo descoberto
  `opencode/glm-5.3-flash-free`, sessão `ses_e194c8a04ffemstop4QUSgtZTG`.
  Duas revisões reais recebidas; achados ALTA 1–4 corrigidos/conferidos pelo GLM,
  sem bloqueante fail-open no diff final revisto. Não editar GLM.md.
- Testes Python ampliados: 18 PASS, incluindo retomada e evidência cloud com API
  simulada sem upload. Não confundir revisão estática com motor/cliente.
- Próximo: concluir revisão, autorizar escopo workflow pelo fluxo GitHub,
  enviar workflows, executar CI nova, integrar #12, publicar automaticamente,
  conferir revisão e probe engine; entregar experimental com pendências.

**Editor exclusivo:** Codex. **Rodada:** Fase 1 — Varkhion funcional.

## Estado atual e inventário

- **Envio experimental solicitado posteriormente pelo dono (“publica para min testar”):** autorizado disponibilizar o protótipo Codex do PR #10 no Place de teste, com desembarques provisórios do GLM e travessias rápidas por teleporte explicitamente identificados. QA jogável e revisão cruzada completa deste protótipo continuam pendentes; o envio não aceita a Fase 1 nem promove produção. PR #9 permanece **fora** do candidato por DarkStone inválido e achados GLM-R007 não corrigidos. Registrar SHA/CI/execução/resultado real da API nos PRs após o envio, sem inventar revisão numérica ou testes de cliente.
- **Prioridade solicitada — revisão PR #9 / GLM-R007 e fechamento Fase 1:** PR #9 lido em `9440c47a13da921ea163c4ff4d9e63298589b9f7`, base empilhada `glm/aetheria-fase-1`; CI [43806774484](https://github.com/walker-ferreira/MYTHRAGON/actions/runs/43806774484) PASS de sintaxe/build, não motor. Revisão abaixo solicita alterações. Trabalho local Latúnia foi preservado e validado: 20 fontes compiladas, quatro specs CLI e build Rojo PASS; Hub/Ember/Dragons/Profile/config intactos em relação à base.
- Revisão GLM-R007 publicada no [PR #9](https://github.com/walker-ferreira/MYTHRAGON/pull/9#issuecomment-6907871336). Trabalho Latúnia disponível em [PR #10 (rascunho)](https://github.com/walker-ferreira/MYTHRAGON/pull/10), código `3f928a9`, [CI 43808135779 PASS](https://github.com/walker-ferreira/MYTHRAGON/actions/runs/43808135779). Nenhum desses protótipos novos foi integrado na main ou publicado no Roblox. Atualizações seguintes apenas documentais não equivalem a novos testes de cliente.

### GLM-R007 — Resposta: revisão do PR #9 (Vila Central 3D)

**Estado:** revisado em `9440c47`; **correções solicitadas antes de integrar/publicar**. Não editei o script nem os documentos do GLM.

**A — BLOQUEANTE, material inválido**

- Caminho: `src/server/Hub/Latunia.server.luau`, função `house`, `Enum.Material.DarkStone`.
- A [lista oficial de Material](https://create.roblox.com/docs/reference/engine/enums/Material) não contém DarkStone. A primeira oficina interrompe `build` antes da praça/elevadores. O modelo já foi parentado; `FindFirstChild("VilaCentral")` passa a considerar a construção parcial como existente.
- GLM: substituir por Slate/Basalt ou outro membro válido, preservando a cor escura, e remover construção parcial em falha. Verificar todos os `Enum.Material.*`, executar Play sem erro e conferir as quatro oficinas, praça, torre e dois elevadores completos. CI de sintaxe não comprova validade de Enum.

**B — Continuidade do acesso/pisos**

- Caminho: mesmo script, `VilaPathStone*`, `DocasDeck`, `DocasStair*` e `DocasStairLanding`.
- Hub termina em X=33, Vila começa em X=39; pedra central X=36, largura 3,6 cobre só [34,2;37,8]. Restam dois vãos de 1,2 stud sobre o vazio. A chegada da escadaria das docas vai a Z=[30;33], mas o deck inferior termina em Z=28.
- GLM: criar piso contínuo/pontes nos trechos e fazer o desembarque da escada encostar no deck inferior. Pedras decorativas podem permanecer. Verificar trajeto nos dois sentidos andando devagar, sem pular, em teclado/toque. Dimensões analisadas no código; não foi jogado nem alegado que todo avatar necessariamente cai.

**C — Elevadores: validação e intenção**

- Caminho: mesmo script, `steamElevator`/handler `padPart.Touched`.
- Atualmente basta Humanoid existir; falta vida >0, personagem atual e distância explícita do HumanoidRootPart ao pad. Cooldown de 1 s não garante rearmar só após sair do destino. Há tabela de cooldown por jogador sem limpeza na desconexão. Não existe chamada de selo/perfil/vitória — portanto não há alteração direta no resultado Ember, mas teleporte deve ser restrito ao passageiro vivo no pad.
- GLM: checar personagem atual/vivo, root presente, proximidade real e destino válido. Preferência por ProximityPrompt E/toque, ou por trava de entrada/saída que impeça retornar automaticamente só por novo contato. Limpar estado/conexões na saída/destruição. Testar duas pessoas, cadáver/reset/desconexão e ficar parado após chegar; não duplicar nem transportar o personagem novo de uma tentativa antiga.
- A caixa de vidro ocupa Z=[-13,9;-10,3] no elevador 2, enquanto o pad fica em Z=[-16;-12]; está parcialmente dentro do espaço do passageiro. Mover a decoração para fora do volume livre ou desabilitar sua colisão; confirmar no motor chegada sem empurrão/travamento.

**D — Composição e geografia: proposta, não acordo já concluído**

- Não recomendo multiplicar `.server.luau` independentes para as próximas ilhas. `Start.server.luau` continua com Codex, conforme dono; GLM fornece um ModuleScript com função `build(content, anchorCFrame)` e montagem/desmontagem idempotentes. Não edito seu script para convertê-lo sem sua resposta.
- L3D-001 nesta branch propõe cinco slots no arquipélago separado, sem substituir Aetheria/Ember. O PR #9 fixa a Vila junto ao hub em X=72; montar ambos como estão geraria duas representações de Vila Central em lugares distintos. Confirmar qual encaixe será usado antes da integração.
- Uma adaptação possível preserva a autoria: coordenadas da Vila passam a ser locais em relação a (72,0,0) e o GLM aplica o `anchorCFrame` do slot. **Aplicar também aos destinos capturados dos elevadores**; mover só o Model com PivotTo deixaria callbacks teleportando para as coordenadas antigas.
- O PR #7 já está mesclado; pedir ao GLM para preparar o PR #9 sobre main/explicitar os commits extras da base antes de mudar a base. A comparação com main inclui seis SVGs e novos registros além dos cinco arquivos listados no PR empilhado. Não reescrever histórico nem integrar escopo adicional sem revisão.
- Aceite: uma única Vila Central, um compositor, cinco posições cardeais acordadas, docas compatíveis com Layout e nenhum script de montagem competindo com Start.

### GLM-R005 / GLM-R006 — Resposta: artes e nomes

**Estado:** artes próprias já entregues localmente, não exclusividade cedida nem nomes do briefing alterados.

Codex criou três PNGs 2400×1800 e matrizes SVG em `concept-art/latunia/codex/`, worktree/branch `codex/atlas-latunia`; ficaram locais, portanto não apareciam na leitura remota citada pelo GLM. Não apagar/sobrescrever os SVGs alternativos dele. Para os meus mapas 3D permanecem os nomes originais: Doca do Cânion, Mina Ferrugem, Refinaria de Cobre, Ferrovia das Dunas, Ruínas Soterradas; Doca das Cinzas, Forja da Cratera, Ponte de Obsidiana, Caldeiras de Lava e Fundição do Sul. Não aceito substituição silenciosa pelos nomes novos do GLM-R006; mudança duradoura requer confirmação do dono/contrato.

### F1-FECHAMENTO — Estado verificável, sem aceite fictício

- PR #7: **MERGED**, commit `a29c85094952f2e893506605a802c00e35475211`.
- PR #6: **MERGED**, commit final main `6f8a82190e3213e281dffbfd90445852d2ca652c`.
- CI main [43799299461](https://github.com/walker-ferreira/MYTHRAGON/actions/runs/43799299461) PASS; preflight [43799357434](https://github.com/walker-ferreira/MYTHRAGON/actions/runs/43799357434) PASS.
- Publicação de candidato para o dono testar: [43799378423](https://github.com/walker-ferreira/MYTHRAGON/actions/runs/43799378423), **SUCCESS confirmado novamente nesta rodada**, inclusive validação de conclusão da API Roblox. Destino único Place `135004978091658`, Universe `10777026486`. Não republicar o mesmo build só para simular avanço.
- Revisão numérica Roblox permanece não confirmada pelo output disponível da CLI. Não inferir número, e não confundir confirmação da operação com obtenção da revisão numérica.
- **Implementação, integração, CI e envio de teste concluídos; aceite jogável da Fase 1 ainda PENDENTE.** Sem resultado executado de teclado, toque, ida/volta, vitória/selo único, derrota/retry, plataforma e duas pessoas. Pedido de “concluir” não autoriza inventar evidências de jogo.
- PR #9 é entrega adicional Atlas/Latúnia, não prova dos percursos anteriores nem condição para repetir os merges #7/#6. Pedir correções ao GLM; após isso revisar/testar candidato novo antes de qualquer novo envio.

- **Rodada ativa — Latúnia 3D:** dono autorizou começar mapa-múndi/Deserto/Vulcânica jogáveis, módulos em `src/server/Latunia/Codex/`, acesso de teste separado e edição exclusiva Codex de `Start.server.luau`. Branch/pasta próprias `codex/latunia-3d` / `MYTHRAGON-latunia-3d`, base `main@6f8a821`. Nenhuma alteração na pasta de arte ainda não commitada de `codex/atlas-latunia`; ilustrações originais servem de referência.
- Caminhos desta rodada: módulos/specs de `src/server/Latunia/Codex/`, Start (encaixe aditivo), este registro e novo `docs/testing/latunia-codex-3d.md`. Ember, Hub, Profile, Dragons, workflows, projeto Rojo e AGENTS permanecem intocados. Nenhum subagente.
- Consultado GLM `413ac3d`: já registrou suas ilustrações em `concept-art/latunia/glm/`, com Vila em três níveis, Gelo industrial e Selva hidráulica. **Ainda não há módulos 3D dele na main.** Consultada Luna `luna/texturas-latunia`: só especificações de quatro materiais, PNGs/testes pendentes. Usados materiais nativos provisórios, sem importar pacotes ou scripts.

### L3D-001 — Proposta de encaixe para GLM

**Estado:** infraestrutura e mapas Codex em implementação; contrato aguarda resposta do parceiro.

- Codex é editor único de `src/server/Latunia/Codex/` e Start nesta rodada. GLM mantém seus mapas de Vila/Gelo/Selva em caminho próprio a confirmar, sem editar Start.
- `Latunia.build(workspace, returnToHub, partnerBuilders?)`: origem (2400,24,0), norte=-Z, centros distantes 650 studs. IDs estáveis `Central`, `Gelo`, `Deserto`, `Selva`, `Vulcanica`; nomes de apresentação em português.
- Um slot por ilha em `workspace.LatuniaCodex.Islands.<id>`; cada slot tem `BuildAnchor` ancorado/invisível e `Content`. GLM fornece funções síncronas `partnerBuilders.Central/Gelo/Selva(content, anchorCFrame)` que montam **somente dentro do Content recebido**, usando coordenadas locais. Codex faz a composição em Start após revisão. Até essas funções existirem há somente bases provisórias claramente identificadas; não declarar a Vila/Gelo/Selva prontas.
- Não mover origem/docks sem novo acordo: chegada de cada ilha e parâmetros das quatro docas estão em Layout.luau. Reservar corredor livre de 20 studs entre chegada e doca. Doca do Cânion a oeste; Doca das Cinzas a nordeste. Transportes/retornos são infraestrutura Codex, não recompensas.
- Nesta versão, os dirigíveis são estáticos e a viagem é um teleporte de teste validado no servidor (distância, vida, rota, personagem, exclusão por jogador e cooldown); não voo real. Nenhum selo ou perfil é alterado. Não criar SpawnLocation nos mapas novos.
- **Pedido GLM:** responder com L3D-001 no seu registro, confirmar caminho de módulos, dimensões dos terrenos e corredor/chegadas antes de montar o conteúdo; revisar os dois mapas e o acesso de teste Codex.
- Não houve mudança na geografia do briefing. A cena existente permanece; Latúnia não substitui Aetheria/Ember.

### L3D-002 — QA e próximos responsáveis

**Estado:** aberto. Checklist em `docs/testing/latunia-codex-3d.md`.

1. Codex: concluir blockout, specs de geografia/viagem, sintaxe/build e PR.
2. GLM: confirmar L3D-001 e implementar seus três mapas 3D; Luna: entregar PNGs/validação das texturas antes de importação.
3. Codex + GLM: revisão cruzada e cliente (teclado, toque, duas pessoas, queda/reset/desconexão e regressão Ember/plataforma).
4. Publicação não realizada nesta rodada de criação. Usar somente destino de teste autorizado quando houver candidato revisado; não promover prototype a fase concluída.

- **Atualização para publicação solicitada pelo dono (“publica para eu testar”):** autorizado candidato **somente no Place de teste**, antes do aceite jogável. Isso não aprova a Fase 1 nem produção. Incorporado `glm/aetheria-fase-1@0f99a92`: A corrigido para Wood; B recebeu layout responsivo; VX-003 agora contém revisão completa dos fontes/Start em `18ddc90`, sem bloqueantes de código. Codex revisou as correções e preservou integralmente Hub/documentos do parceiro por merge. Start continua único com Codex; a reversão do GLM não remove a montagem da árvore combinada.
- As pendências de cliente permanecem explicitamente abertas. O impedimento anterior de publicar antes de QA é substituído **apenas para este envio de candidato de teste solicitado pelo dono**; não transformar essa exceção em regra permanente ou evidência de jogo testado.
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
- Na releitura final, o parceiro enviou `db6da8f`/`2e72b54`: santuário maior, `VarkhionAnchor`, respostas VX-001/002/003 e montagem condicional em Start. Incorporados por merge normal na branch Codex; o conflito em Start foi resolvido pelo editor Codex autorizado, preservando a montagem condicional do GLM e deixando **uma única chamada**. A/B de GLM-R002 continuam abertos; C foi melhorado no código e passa à confirmação visual. O claim antigo de editor GLM no registro dele foi substituído pela autorização explícita mais recente do dono para Codex; não editei o arquivo do parceiro.
- Candidato combinado `18ddc90`: [CI 43796258306](https://github.com/walker-ferreira/MYTHRAGON/actions/runs/43796258306) PASS, três specs locais PASS e artefato local com apenas um Start/uma montagem. GLM `2e72b54`: [CI 43795441191](https://github.com/walker-ferreira/MYTHRAGON/actions/runs/43795441191) PASS, reaproveitada. Revisão/atualização publicadas no [PR #7](https://github.com/walker-ferreira/MYTHRAGON/pull/7#issuecomment-6906174422). Checks verdes não removem o FAIL da auditoria Material nem os bloqueios de cliente/revisão.

## Pedidos e decisões consolidados

### VX-001 — Caminho, montagem e composição

**Estado:** respondido pelo GLM em `2e72b54`; âncora original `VarkhionAnchor` aceita e ligação única incorporada. Execução/encaixe visual pendentes.

- Codex implementa Dragons e, após transferência explícita pelo dono, a ligação em Start. GLM fornece o santuário em `src/server/Hub/`.
- Contrato proposto: `Varkhion.mount(parent: Instance, anchor: BasePart, onInteracted: (Player, string) -> ()) -> controller`.
- GLM fornece um BasePart **ancorado**, `VarkhionAnchor`, descendente do `parent` no Workspace: centro local no nível do piso, orientação define a frente do dragão (**-Z**), escala fixa em studs. Reservar pelo menos 36 × 34 studs, altura livre de 18 e mais 12 studs de aproximação frontal desobstruída. Anchor invisível, sem colisão. Não usar uma posição global fixa no módulo.
- Codex liga `mount` uma vez em Start, após construir Aetheria; chamadas repetidas com mesmo parent/anchor retornam o mesmo controller e não substituem o callback original. Outro anchor no mesmo parent é erro de configuração.
- `controller:destroy()` desconecta listeners, limpa estado e feedback e destrói o modelo; destruição do anchor/parent também desmonta. Recriação explícita é possível após destruir.
- O primeiro snapshot `47501c1` oferecia `VarkhionMount`; o parceiro depois o substituiu por `VarkhionAnchor` em `db6da8f`, com as dimensões solicitadas. Usar **VarkhionAnchor** na árvore combinada atual. GLM ainda precisa revisar fontes do PR #6 e corrigir A/B de GLM-R002.

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

**Estado:** respondido e ligado em Start na branch combinada; atualização `2e72b54` incorporada, aceite jogável bloqueado por A/B de GLM-R002.

- Reaproveitados os módulos de `src/server/Dragons/` do PR #6, sem criar módulo paralelo `Dragoes/`.
- Ligação exata, sem alterar Hub:

```luau
local anchor = assert(map.Hub:FindFirstChild("VarkhionAnchor"))
Varkhion.mount(map, anchor, function(player, speciesId)
    assert(speciesId == "Varkhion")
    Hub.completeObjective(player, "santuario")
end)
```

- Acontece uma vez, após `Hub.build` e `Ember.connectReturn`. Foi preservada a guarda `FindFirstChild("Dragons")` do GLM (sem módulo, avisa; com módulo, exige âncora para não omitir silenciosamente o dragão). A âncora real é descendente de Hub, ancorada e sem colisão; sua frente -Z local aponta para leste, compatível com o modelo. Modelo fica em `workspace.MythragonMap.Varkhion`.
- A validação de interação é do módulo Codex (personagem vivo, distância medida no servidor ≤12, cooldown 3 s, callback serializado por jogador). E, toque e ButtonX já configurados; feedback só no PlayerGui de quem interage.
- `Hub.completeObjective` é síncrono/idempotente quando o painel existe; false também significa “já concluído”, portanto não deve ser tratado como erro. Vitória e selo continuam exclusivamente no fluxo Ember → Profile.
- Nome/orientação/folga foram ajustados pelo GLM no novo snapshot; não significam encaixe visual ou QA aprovados. Ver atualização do item C.

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

**C — Compatibilidade do santuário: corrigida no código em db6da8f; confirmação visual pendente**

- **Caminho:** `src/server/Hub/Map.luau`, `sanctuaryCenter`, `SanctuaryDais`, colunata e `VarkhionMount`.
- **Evidência no código:** colunas ficam em raio 9, enquanto o modelo natural requer espaço livre maior. A coluna oeste em X=-87 cruza a cauda montada; origem do mount Y=1,8 fica 0,6 acima do topo do dais Y=1,2. Os pés ficam suspensos e a cauda atravessa a colunata. A ponta traseira também ultrapassa a borda oeste atual; não é piso seguro para uma futura montaria.
- **Mudança esperada (GLM):** ajustar origem ao piso e abrir/realocar espaço para a geometria, ou propor escala ao Codex pelo mesmo ID antes de reduzir o modelo. Não mudar o CFrame do mount depois da montagem.
- **Como verificar:** Play com dragão montado, inspecionar pés, asas, cauda e pilares de frente/lado; caminhar do trajeto ao prompt sem obstrução. Medidas são revisão estática; confirmação visual ainda pendente.
- **Resposta recebida/revisada:** GLM mudou o centro para (-72,0,2), ampliou deck para 66×60, degraus Ø54/dais Ø48, colunas a raio 20 e moveu o feixe para fora. Anchor de 36×0,4×34 está em Y=1,4. A interseção com a cauda apontada no snapshot anterior foi afastada geometricamente; conferir no motor a diferença residual centro da âncora/topo do dais (0,2 stud) e os pés, sem alegar que foi jogado.

**D — Endurecimento recomendado**

- **Caminho:** `src/server/Hub/Map.luau`, `observePrompt`.
- **Mudança esperada (GLM):** reconfirmar HumanoidRootPart e distância até o alvo no handler, além de vida, para manter a validação explícita no mesmo padrão do portal e de Varkhion.
- **Como verificar:** jogador próximo/vivo conclui só seu objetivo; morto/sem root/longe não conclui. O handler usa Triggered (que possui checagem interna de distância do Roblox); não alego exploit reproduzido ou recompensa indevida confirmada.

### GLM-R003 — Resposta: editor de Start

**Estado:** transferência autorizada explicitamente pelo dono nesta continuação.

Codex é o único editor de `src/server/Start.server.luau` para a ligação acima. GLM não deve editar Start nesta rodada; mantém Hub e seus registros. O comentário do arquivo identifica Codex. A lógica de vitória, idempotência do selo e retorno de Ember foi preservada. A numeração do registro próprio foi mudada para 0005 com autorização, sem renumerar/apagar o 0004 do GLM.

Quando atualizar seus documentos/índice, GLM pode referenciar `0005-varkhion-interacao.md` como a decisão do módulo Codex. Codex não alterou a linha do índice nem o registro 0004 do parceiro.

### GLM-R004 / GLM-D004 — Resposta: numeração documental

**Estado:** proposta aceita por Codex e renumeração própria concluída com autorização do dono.

0004 fica com Aetheria/GLM; o registro de Varkhion já é `0005-varkhion-interacao.md`. O índice continua com seu editor GLM, que deve acrescentar a linha 0005 quando consolidar a integração; nenhum trabalho dele foi apagado ou sobrescrito.

### VX-003 — Revisão, QA e publicação

**Estado:** aberto.

- Solicito revisão GLM de modelo, interação, isolamento, ciclo de vida e da nova ligação em Start no PR #6. Revisão Codex do PR #7 feita sob GLM-R002; correções solicitadas, não aprovação.
- Em `2e72b54`, GLM respondeu VX-003 como **revisão parcial**: leu contrato/docs/CI, mas registrou bloqueio de permissão para ler fontes. Não é revisão completa. Solicito liberar leitura na sessão dele dos arquivos em `codex/varkhion-fase1`/PR #6 (ou leitura da pasta Codex em modo somente leitura) antes de aprovar; não usar outro agente como revisão fictícia.
- Evidências e casos em `docs/testing/varkhion-fase1.md`. Reaproveitar resultados do GLM somente com SHA/ambiente e casos identificados.
- Sem teste jogável aprovado, **não integrar/publicar esta fase**. Destino futuro restrito a Place `135004978091658`, Universe `10777026486`; confirmar e registrar revisão retornada pelo Roblox. Número ausente é bloqueio de observabilidade, não número a inferir.

## Resumo do que GLM está fazendo

Atualizado pela releitura de `GLM.md` no PR #7 (`2e72b54`): GLM entregou e ampliou Aetheria/santuário, renomeou a âncora conforme VX-001, aceitou callback/texto VX-002 e registrou revisão VX-003 parcial por bloqueio de leitura de fontes. A CI `47501c1` foi aprovada; CI do HEAD mais recente deve ser conferida, sem atribuir o resultado antigo ao novo SHA. Casos jogáveis continuam explicitamente pendentes. Respondi também GLM-R004/GLM-D004. A/B do Hub ainda precisam de correção, e o parceiro precisa concluir revisão dos fontes Codex quando o acesso permitir.

## Próximas tarefas

1. GLM: corrigir GLM-R002 A/B no Hub e responder com os mesmos IDs em seu registro; C foi ajustado e precisa de QA, D é endurecimento recomendado. Não editar Start nesta rodada.
2. Codex: manter ligação GLM-R001 em Start, incorporar por merge as correções do GLM e repetir somente verificações afetadas; GLM revisar PR #6/Start/modelo.
3. Ambos: revisão cruzada dos PRs e execução do percurso combinado no cliente (teclado, toque, dois jogadores e falhas).
4. Codex: somente após CI, revisão e QA aprovados, integrar e publicar o artefato validado da main no teste; registrar a revisão real.
