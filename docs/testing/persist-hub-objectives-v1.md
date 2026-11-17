# Persistência dos objetivos de Aetheria — Fase 1

Checkpoint MISSION-PERSIST-001 (branch `codex/persist-hub-objectives-v1`).

Escopo: **somente** os três objetivos já existentes em Aetheria:
`guardioes` (observar Guardiões do Éter), `santuario` (interação validada no Varkhion) e `portal` (entrada no portal de Ember).

- `Hub.completeObjective` é a autoridade no servidor; o callback de salvamento não recebe ações de cliente.
- `Hub.restoreObjective` apenas reconstitui estado e painel, sem emitir notificação, recompensa ou segunda gravação.
- Registro compartilhado com o selo de Ember: `Mythragon_Progress_v1/player_<UserId>`. `UpdateAsync` une objetivos válidos preservando selos e campos já existentes. Falhas de DataStore não zeram progresso.
- Verificações puras CLI cobrem preservação de selo, progresso monotônico, rejeição de esquema inválido e objetivos desconhecidos.
- Não altera mapas, NPCs, recompensas, comércio ou publicação de produção.

## Ainda obrigatório antes de declarar jogável

1. CI, build, publicação de staging e engine bootstrap isolado (sem falsos testes).
2. Em servidor novo: completar cada um dos três objetivos; sair/entrar e verificar painel restaurado.
3. Duas contas independentes, incluindo entrada simultânea e objetivos em ordem diferente.
4. Simular erro de GetAsync/UpdateAsync sem eliminar progresso anterior; coletar logs F9.
5. Verificar versão exibida no topo e ausência de concessões duplicadas.

**Limites:** ainda faltam as etapas 4–10 da narrativa completa, persistência integral de missões, provas de runtime/física, testes mobile, multiplayer e produção. Não declarar DATASTORE_OK sem teste real.
