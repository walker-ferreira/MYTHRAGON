# COMBAT-003 — Sopro direcionado de Ember

O Guardião agora aponta o aviso laranja de 22×22 studs para a posição **observada pelo servidor** no início de cada ataque, limitada a 28 studs do centro da arena. O aviso permanece parado por 1,2 segundo: fugir andando ou usar a esquiva Q / botão B / toque permite escapar da área. O dano de 25 PV ocorre somente quando o personagem do participante continua dentro do quadrado e da faixa vertical no fim do aviso.

- `BreathPattern.luau` é uma política numérica pura (alvo, limites e hitbox).
- `BreathPattern.spec.luau` cobre centro, limite de arena, borda da área e valores inválidos.
- Permanece um encontro por arena; nenhum cliente informa alvo, dano, resultado ou recompensa.
- Nenhuma mudança nas ilhas GLM, NPCs, DataStore, selos ou teleporte.

## QA em cliente real obrigatória

1. Entre na arena com dois clientes; só o participante ativo deve ser alvo.
2. Permaneça parado no aviso e confirme o dano anunciado.
3. Afaste-se durante os 1,2 s e confirme ausência de dano; repita com esquiva em PC/mobile/controle.
4. Teste perto das bordas da arena e durante vitória/derrota/retorno, inclusive tentativa de reconexão.
5. Medir performance mobile e erros F9 na revisão publicada.

CI e Bootstrap isolado **não** comprovam a experiência física do combate.
