# 0004 — Varkhion provisório e interação de apresentação

**Editor único:** Codex, autorizado pelo dono nesta rodada.
**Estado:** implementação isolada; contrato VX-001/VX-002 proposto ao GLM, ainda não aceito. Sem montagem em Start, revisão cruzada ou aceite no cliente.

## Contexto e decisão

A fase 1 precisa apresentar Varkhion em Aetheria sem substituir o guardião de Ember, conceder selo automaticamente ou antecipar posse persistente/voo da campanha.

- Novo domínio em `src/server/Dragons/`, com regras puras em `InteractionState.luau`, geometria em `VarkhionModel.luau` e adaptação Roblox em `Varkhion.luau`.
- O dono aprovou Codex como editor de Dragons e deste registro; GLM é o editor exclusivo de Hub e Start. O acordo técnico de montagem/objetivo está pendente em [CODEX.md](../agents/CODEX.md), IDs VX-001 e VX-002. Não editar o arquivo do parceiro nem registrar proposta como acordo aceito.
- Modelo procedural original: corpo/escamas negras, olhos violetas, coroa de chifres bifurcados, grandes asas escuras, cauda segmentada e marcas de Éter no peito, coluna e asas. Parts/WedgeParts nativos ancorados, sem colisão/toque/query: apresentação, não inimigo novo. Luz violeta discreta; nenhuma partícula externa. Não há rig, voo ou animação importada.
- `mount(parent, anchor, onInteracted)` recebe âncora ancorada no piso, descendente do parent no Workspace. Frente local -Z; área livre de 36 × 34 studs, altura 18, aproximação frontal adicional de 12 studs. Modelo usa snapshot do CFrame da âncora; não mover a âncora após montagem.
- Uma montagem por parent; repetição no mesmo anchor retorna o controller existente sem duplicar modelo/listeners nem trocar callback. Anchor diferente no mesmo parent gera erro de configuração. Destruir controller, modelo, anchor ou parent limpa os listeners/estado/diálogo.
- Interação por ProximityPrompt E/toque (também ButtonX): servidor verifica conexão, personagem vivo, montagem no Workspace, alcance de 12 studs e cooldown de 3 s. Cliente não envia conclusão nem progresso.
- Callback exclusivamente servidor `onInteracted(player, "Varkhion")`: GLM atualiza seu objetivo inicial, sem yield, sem posse persistente ou selo. Uma conclusão por jogador por montagem; repetição mostra diálogo sem callback. Falha no callback permite retry; GLM deve tratar efeitos parciais idempotentemente. O estado sobrevive a respawn e é limpo na desconexão.
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

O mapeamento Rojo existente (`$path: src/server`) já inclui o novo diretório: sem editar configuração ou autoexecutar demo. **Até GLM montar o módulo em Start, o novo dragão não aparece na cena em runtime.** Essa dependência é explícita; não criar um segundo bootstrap automático para contorná-la.

Regressão de Ember: conservar os quatro arquivos exatamente como na base, incluindo função da plataforma 0–12 studs. Manter `Ember.build`, `connectReturn`, callback de vitória e perfil individual. Checklist de evidências e bloqueios em [docs/testing/varkhion-fase1.md](../testing/varkhion-fase1.md).
