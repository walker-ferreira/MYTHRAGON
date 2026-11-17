# COMBAT-003 — Sopro direcionado de Ember

No início de cada sopro, o servidor fixa um aviso laranja de 22×22 studs na posição do jogador. Perto das bordas, o quadrado é deslocado para permanecer inteiro sobre o piso. O aviso dura 1,2 segundo. Saia da área andando ou esquive perto do impacto com Q, botão B ou toque. Uma esquiva aceita pelo servidor protege contra o sopro por 0,45 segundo. O dano é de 25 PV se o participante estiver dentro do quadrado e da faixa vertical no impacto, fora da janela de esquiva.

- `BreathPattern.luau` é uma política numérica pura (alvo, limites e hitbox).
- `BreathPattern.spec.luau` cobre centro, limite de arena, borda da área e valores inválidos.
- Permanece um encontro por arena; nenhum cliente informa alvo, dano, resultado ou recompensa.
- Nenhuma mudança nas ilhas GLM, NPCs, DataStore, selos ou teleporte.

## QA em cliente real obrigatória

1. Entre na arena com dois clientes; só o participante ativo deve ser alvo.
2. Permaneça parado no aviso e confirme o dano anunciado.
3. Afaste-se durante o aviso e confirme que sai ileso. Repita com esquiva perto do impacto em PC, celular e controle. Teste uma esquiva antecipada que termine dentro do quadrado e uma durante os últimos 0,45 segundo. Confirme o cooldown de 3 segundos.
4. Confira se todo o aviso fica no piso perto das bordas da arena. Confira o comportamento ao vencer, perder, retornar ao Hub e reconectar.
5. Medir performance mobile e erros F9 na revisão publicada.

CI e Bootstrap isolado **não** comprovam a experiência física do combate.
