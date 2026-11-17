# COMBAT-DODGE-BOUNDS — esquiva no piso e cooldown após movimento

A arena de Ember mede 58×48 studs (meias dimensões 29×24). A esquiva não deve ser autorizada apenas por um raio circular de 48 studs, pois a borda real é retangular.

- `DodgeBounds.inside` verifica chegada dentro das meias dimensões X/Z, deixando margem de 3 studs para o personagem.
- O servidor mantém a validação de encontro ativo, distância até o Guardião, colisão por raycast e tempo mínimo entre esquivas.
- `DodgeState.canUse` permite verificar cooldown sem consumi-lo; `DodgeState:use` só é chamado depois de a movimentação `PivotTo` concluir sem erro.
- Em caso de teleporte inválido/fora do piso, não há movimentação, invulnerabilidade ou consumo de cooldown.
- Não modifica IA do Guardião, danos, recompensas, selos, DataStore, cenário ou os NPCs desligados.

## QA real ainda obrigatória
1. Aproximar-se das quatro bordas da arena e acionar esquiva Q, B e toque; não cair do piso.
2. Esquivar em posição central e confirmar deslocamento, proteção curta e cooldown de 3 s.
3. Forçar `PivotTo` a falhar em ambiente de teste e confirmar que o cooldown continua disponível.
4. Conferir duas contas e que somente a conta com encontro ativo esquiva.
5. Fazer teste Android de 320×568, console F9 e física em servidor público de staging.

As specs CLI verificam limites; não demonstram câmera, colisões e movimentação real em Roblox.
