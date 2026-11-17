# MOBILE-COMBAT-001 — botões de ataque e esquiva de Ember

O Guardião tem dois controles diferentes: **ataque** (`E`/controle `X`) e **esquiva** (`Q`/controle `B`). Ambos são `ProximityPrompt` clicáveis e marcados com `ProximityPromptExclusivity.AlwaysShow`; assim, a interface de proximidade do Roblox não oculta automaticamente um por causa do outro.

A esquiva está montada num `Attachment` discretamente deslocado em relação ao corpo do Guardião para ajudar a separar os prompts na tela. O servidor continua validando o jogador exclusivo, distância, cooldown, invulnerabilidade, colisão e piso; a UI não concede dano nem esquiva.

Referência oficial: https://create.roblox.com/docs/ui/proximity-prompts — a visibilidade de prompts depende de `Exclusivity` e dos botões atribuídos.

## QA real necessária
- Android/iPhone: aproximar do Guardião, observar **dois comandos tocáveis** e verificar que cada toque aciona só sua ação.
- Teclado E e Q acionam ataque/esquiva respectivamente; controle X e B mantêm ações distintas.
- Testar câmera girando, resolução 320×568, HUD de jornada e texto do Guardião.
- Confirmar que jogador B que não possui encontro não pode atacar/esquivar mesmo com prompt visível.
- Verificar se o motor exibe os dois prompts sem sobreposição; ajustar ancoragem/client UI se houver conflito.

CI e Bootstrap isolado confirmam propriedades e módulos, mas **não** comprovam o layout visual no celular.
