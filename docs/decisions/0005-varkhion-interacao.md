# 0005 — Varkhion provisório e interação de apresentação

**Editor único:** Codex, autorizado pelo dono nesta rodada.
**Estado:** módulo e ligação em Start implementados na branch combinada do PR #6. GLM-R001 respondido; revisão GLM e aceite no cliente pendentes. Há correções bloqueantes no Hub do PR #7, registradas no CODEX.md.

## Contexto e decisão

A fase 1 precisa apresentar Varkhion em Aetheria sem substituir o guardião de Ember, conceder selo automaticamente ou antecipar posse persistente/voo da campanha.

- Novo domínio em `src/server/Dragons/`, com regras puras em `InteractionState.luau`, geometria em `VarkhionModel.luau` e adaptação Roblox em `Varkhion.luau`.
- O dono aprovou Codex como editor de Dragons e deste registro; nesta continuação transferiu exclusivamente Start para Codex, mantendo Hub com GLM (resposta GLM-R003). O registro próprio foi renumerado de 0004 para 0005, preservando `0004-aetheria-fase-1.md` e o índice do GLM, sem editar os documentos dele.
- Modelo procedural original: corpo/escamas negras, olhos violetas, coroa de chifres bifurcados, grandes asas escuras, cauda segmentada e marcas de Éter no peito, coluna e asas. Parts/WedgeParts nativos ancorados, sem colisão/toque/query: apresentação, não inimigo novo. Luz violeta discreta; nenhuma partícula externa. Não há rig, voo ou animação importada.
- `mount(parent, anchor, onInteracted)` recebe âncora ancorada no piso, descendente do parent no Workspace. Frente local -Z; área livre de 36 × 34 studs, altura 18, aproximação frontal adicional de 12 studs. Modelo usa snapshot do CFrame da âncora; não mover a âncora após montagem.
- Uma montagem por parent; repetição no mesmo anchor retorna o controller existente sem duplicar modelo/listeners nem trocar callback. Anchor diferente no mesmo parent gera erro de configuração. Destruir controller, modelo, anchor ou parent limpa os listeners/estado/diálogo.
- Interação por ProximityPrompt E/toque (também ButtonX): servidor verifica conexão, personagem vivo, montagem no Workspace, alcance de 12 studs e cooldown de 3 s. Cliente não envia conclusão nem progresso.
- Callback exclusivamente servidor `onInteracted(player, "Varkhion")`: GLM atualiza seu objetivo inicial, sem yield, sem posse persistente ou selo. Uma conclusão por jogador por montagem; repetição mostra diálogo sem callback. Falha no callback permite retry; GLM deve tratar efeitos parciais idempotentemente. O estado sobrevive a respawn e é limpo na desconexão.
- **Resposta GLM-R001:** `Start` monta uma vez com `Varkhion.mount(map.Hub, map.Hub.VarkhionMount, callback)` após construir Hub/Ember e conectar o retorno. O callback confere a espécie e chama `Hub.completeObjective(player, "santuario")`. O retorno false dessa API para duplicata é aceito, pois a pedra rúnica já pode ter concluído o mesmo objetivo; não é erro da conversa nem concede selo.
- A proposta inicial de nome `VarkhionAnchor` foi substituída pelo nome concreto `VarkhionMount` do GLM; a API aceita qualquer BasePart válido. `CFrame.lookAt(..., ... + Vector3.new(10, 0, 0))` mantém a frente -Z local apontando para leste. O espaço livre e a altura do piso do santuário atual ainda precisam de ajuste pelo GLM: a colunata de raio 9 intercepta a cauda do modelo em tamanho natural, e a origem em Y=1,8 não corresponde ao topo do dais Y=1,2. Não declarar compatibilidade visual aprovada sem corrigir e testar no motor.
- Resposta individual no PlayerGui, texto escalável/quebra de linha e duração de 10 s: identifica Varkhion e orienta o portal de Ember. Não depende só da cor e não transforma texto mundial em progresso compartilhado.

## Referências e auditoria de assets

Páginas consultadas nesta rodada; nenhuma transferência/importação de pacote:

| Referência existente | Uso na direção | Licença observada / reutilização |
| --- | --- | --- |
| [Fantasy Dragon — Stylized Creature, ARTEL_3D_STUDIO](https://sketchfab.com/3d-models/fantasy-dragon-stylized-creature-52f69503c527466d88fdf1ec9d073a51) | Leitura de asas, escamas e chifres como elementos da silhueta | Página informa CC Attribution 4.0; **não reutilizado**. Quase 499 mil triângulos descritos: não importar esse orçamento para o piloto. |
| [Red Dragon, Sam McLaughlin](https://sketchfab.com/3d-models/red-dragon-d839a351b20a47f893e58378bd09e827) | Cauda longa e asas legíveis em modelo estilizado, referência existente com animação de voo | Permissão de uso não confirmada; **não reutilizado**, nem sua animação. |
| `src/server/Ember/Combat.luau` da base `fd18885` | Precedente do próprio projeto: corpo/asa/chifre/olhos em Parts e interação validada no servidor | Reaproveitado o padrão técnico, sem modificar/substituir o guardião existente. |

Como não há incorporação de modelo externo, nenhum Script, LocalScript ou ModuleScript de terceiro foi incluído ou executado. Futura importação exige nova verificação de origem/licença e auditoria de todos os scripts antes da inclusão. A interpretação de Varkhion é original; não é cópia de malha/textura dos exemplos.

## Evidências e consequências

Specs puras cobrem alcance, cooldown, vida, entradas não finitas, callback pendente, repetição, falha/retry, dois jogadores e desconexão/destruição. Elas não testam o motor, geometria na tela ou controles reais.

O módulo manual `Varkhion.engine.spec.luau` oferece verificações de geometria/montagem/ciclo de vida para o servidor do Studio, sem autoexecução ou concessão. Está compilado, mas ainda não foi executado no motor; instruções no checklist.

O mapeamento Rojo existente (`$path: src/server`) já inclui o novo diretório: sem editar configuração ou autoexecutar demo. O Start foi ligado pelo editor Codex autorizado, na branch combinada com `glm/aetheria-fase-1@47501c1`. **Isso não comprova execução no motor:** `Enum.Material.DarkWood` no Hub interrompe sua construção antes de criar o mount. Corrigir no arquivo do GLM; não contornar com segundo bootstrap, remoção de árvores em runtime ou alias de Enum.

Regressão de Ember: conservar os quatro arquivos exatamente como na base, incluindo função da plataforma 0–12 studs. Manter `Ember.build`, `connectReturn`, callback de vitória e perfil individual. Checklist de evidências e bloqueios em [docs/testing/varkhion-fase1.md](../testing/varkhion-fase1.md).
