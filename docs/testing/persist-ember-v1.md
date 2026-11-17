# PERSIST-001 — primeiro selo de Ember via DataStore

Branch: `codex/persist-ember-seal-v1`. Base: main após PR #26. Proprietário autorizou desenvolvimento em staging. Arquivos: `Profile/ProgressData.luau`, `ProgressData.spec.luau`, `ProgressStore.luau` e `Diagnostics/Bootstrap.luau`.

## Contrato implementado

- Apenas vitórias do servidor com `encounterId` válido geram um selo de Ember na sessão e solicitam salvamento.
- `Mythragon_Progress_v1`, chave `player_<UserId>`; `UpdateAsync` faz união monotônica, nunca substitui dados antigos ou outros campos.
- `GetAsync` carrega o selo e restaura seu estado visual individual no Hub; erros ou esquema incompatível não fazem reset de progresso antigo.
- Repetição de vitórias não gera novo selo. Escrita tem tentativas limitadas, aviso de falha no servidor e flush no encerramento do servidor.
- Sem solicitação de escrita do cliente e sem gravação de inventário, moedas, NPCs ou objetivos.
- APIs de DataStore podem estar desabilitadas no Studio; isso deve ser reportado como falha de persistência, jamais como sucesso.

## Verificações obrigatórias

1. CI Luau/CLI, incluindo política de dados malformados, idempotência e preservação dos campos desconhecidos.
2. Staging: confirmar `PUBLISHED`, `PERSISTED_OK`, `engine_bootstrap PASS` para a revisão exata; motor isolado não pode comprovar operações de DataStore.
3. **Teste real com duas contas em servidor novo:** conquistar o selo em A, sair, entrar novamente e conferir o selo existente; B não pode herdar o progresso de A.
4. Simular indisponibilidade do DataStore em ambiente de teste, validar que o servidor não apaga dados e registra erro, e que tentativa posterior consegue salvar.
5. Testar várias vitórias e sessões simultâneas. Conferir ausência de selos duplicados.

Se apenas 1 e 2 passarem: declarar `BUILD_OK/PUBLISHED/PERSISTED_OK` (do Place), **não** `DATASTORE_OK`, `RUNTIME_OK` ou `PLAYTEST_OK`.

A persistência de **objetivos/missões ainda não está implementada**. Evoluir em PR separado depois do teste de dados, sem assumir que `ObjectivePanel` já salva.

Nenhum reset/migração destrutiva, nenhum write no ambiente de produção.
