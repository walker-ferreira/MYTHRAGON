# 0002 — Encontro de Ember e contrato de vitória

**Estado:** implementado; testes locais de regras, sintaxe e build aprovados. Revisão cruzada, CI e teste no cliente são registrados no PR; não estão implícitos neste documento.

## Responsáveis e contrato

- Sol: `src/server/Ember/` e este registro. GLM: `src/server/Hub/`, `src/server/Profile/` e `src/server/Start.server.luau`. O dono aprovou estes editores nesta rodada.
- `Ember.build(parent, onVictory)` devolve `enterEmber(player): boolean`. `false` indica personagem inválido ou arena ocupada; o jogador não é movido.
- `onVictory(player, encounterId: string)` é chamado exclusivamente pelo servidor, após cinco ataques válidos de 20 de dano contra 100 PV. O identificador é gerado pelo servidor por tentativa. Não existe RemoteEvent de vitória.
- Ember fixa o resultado terminal antes do callback, que é emitido uma vez por encontro. GLM registra progresso e garante selo idempotente por jogador, inclusive entre vitórias diferentes. Este piloto não promete persistência entre servidores.
- `Ember.connectReturn(parent, onReturn)` continua compatível. Saída antecipada cancela o encontro; vitória permanece terminal. Morte libera a arena e o jogador renasce no `HubSpawn`. Remoção do personagem ou desconexão libera a arena.

## Regras e limites do piloto

Uma arena atende um jogador de cada vez para evitar atribuição ambígua de dano/recompensa. Ataque pelo ProximityPrompt (E ou toque); servidor confere dono, personagem atual, vida, distância de até 13 studs e intervalo mínimo de 0,65 s. O inimigo sinaliza uma área antes de causar 25 de dano; distância é medida novamente no servidor. O portal roxo verifica distância e só aceita o participante. Nenhum ataque, morte ou abandono altera uma vitória já determinada.

O feedback usa texto sobre o guardião e área laranja no chão. A plataforma laranja preserva integralmente a função `addFloatingPlatform` da base `81c1b72` e da branch `release/teste-plataforma-81c1b72`: curso 0–12 studs, tamanho, cor, origem, força, velocidade e tempos sem alterações.

**Correção na revisão cruzada:** GLM identificou que o monitor originalmente encerrava na vitória, deixando a arena reservada se o vencedor não usasse o portal. O monitor agora continua após a vitória, resgata quem sai dos limites e retorna automaticamente ao hub após 30 s (na próxima verificação periódica de até 2 s). Não há mais dano após vitória. Verificado por revisão do controle de fluxo e compilação; confirmação no cliente pendente. `Humanoid:TakeDamage` respeita ForceField; considerar a proteção inicial no teste de derrota.

## Direção visual e referências

Referências consultadas em 15/11/2026, somente como direção; **nenhum asset, mesh, textura ou script foi importado**:

- [Volcanic Basalt Columns Cliffs Lava Iceland B — Pers Scans](https://sketchfab.com/3d-models/volcanic-basalt-columns-cliffs-lava-iceland-b-343266623e0844b384d55cf44c493b7b): ritmo vertical e silhueta de colunas basálticas. Licença de reutilização não confirmada.
- [Dragons Maw Arena — OrioniX Services](https://sketchfab.com/3d-models/dragons-maw-arena-8a247d7cdb954f76aa639336b4b3bf8d): referência de arena de fantasia. Licença de reutilização não confirmada.
- [Map — Dragon Ruins Arena](https://builtbybit.com/resources/map-dragon-ruins-arena-roblox.133702/): referência de ruínas antigas para arena; página bloqueou leitura automatizada (403), sem inspeção do pacote/licença e sem reutilização.
- [Fantasy Dragon — Stylized Creature](https://sketchfab.com/3d-models/fantasy-dragon-stylized-creature-52f69503c527466d88fdf1ec9d073a51): direção de silhueta com asas e chifres; sem reutilização/licença confirmada.
- [Roblox: criar erupções vulcânicas](https://create.roblox.com/docs/tutorials/use-case-tutorials/vfx/create-volcanoes): contraste visual da lava e rocha.

Interpretação original: colunata fragmentada, arco quebrado e guardião de obsidiana construídos com Parts, materiais e cores nativos. Este é um blockout jogável, não um dragão realista final. Se houver futura importação, confirmar licença e inspecionar Scripts, LocalScripts e ModuleScripts antes de integrá-la.

## Verificação reproduzível

- Luau 0.744: compilar todos os `.luau` de `src` com `luau-compile --null`.
- Executar `luau src/server/Ember/EncounterState.spec.luau`: alcance, cooldown, cinco acertos, vitória única, resultado terminal, derrota, abandono e tentativa limpa.
- Rojo 7.6.1: `rojo build default.project.json -o mythragon.rbxlx`.
- Cliente Roblox **pendente**: hub → Ember → vitória → portal → selo; repetir vitória; morrer e renascer; sair antes de vencer e tentar novamente; resetar personagem; desconectar; dois jogadores disputando entrada; teclado e mobile. Conferir também o curso da plataforma e legibilidade da área de dano. Testes puros e build não substituem esses percursos.
- Publicação somente no Place `135004978091658`, Universe `10777026486`, usando o artefato da CI bem-sucedida do commit integrado na `main`. Registrar execução, commit e resposta/revisão real da API; não inferir sucesso de um simples disparo do workflow.
