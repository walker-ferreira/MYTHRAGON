# EMBER-ENTRY-001 — recuperar arena se teleporte de entrada falhar

O controlador de Ember reserva exclusivamente a arena após validar jogador, Humanoid e HumanoidRootPart. A entrada agora:
1. Rejeita jogador que não pertence mais a `Players`.
2. Salva o pivot original e executa o teleporte de arena em `pcall`.
3. Se o `PivotTo` falhar, registra o erro, tenta restaurar a posição original e chama `Combat:close("abandoned")` para remover sessão e conexões, devolvendo `false`.
4. O controlador de Hub já trata `enter == false`, libera `inTransit` e informa ao jogador. Uma nova tentativa não é bloqueada por sessão fantasma.

**Não muda** dano, cooldown, vitórias, selos, recompensas ou DataStore. Mantém a arena exclusiva contra entrada simultânea.

### QA necessária em servidor real ou teste de motor com falhas injetadas

- Forçar erro controlado no `PivotTo` durante a entrada: nenhuma sessão persistente, sem selo, retry válido após erro.
- Verificar liberação de `inTransit` em Hub e que a posição original é mantida quando possível.
- Entrada normal de uma conta seguida de tentativa simultânea de segunda conta: arena exclusiva.
- Matar/desconectar personagem, entrar novamente, concluir combate e retornar.
- Registrar console F9 e verificar ausência de conexões Died/CharacterRemoving antigas após falhas.

O motor isolado que apenas constrói a arena não injeta falhas reais de teleporte. Não declarar PLAYTEST_OK.
