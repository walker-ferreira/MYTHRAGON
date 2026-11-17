# DATASTORE-READ-RECOVERY — recuperar carregamentos após indisponibilidade prolongada

Os serviços `Profile/ProgressStore.luau` e `Profile/ObjectivesStore.luau` antes desistiam permanentemente de `GetAsync` após três tentativas. Se o serviço falhasse no login, um perfil antigo só seria recuperado ao reconectar, mesmo se o DataStore voltasse.

Agora cada serviço faz até três leituras espaçadas e, persistindo o erro, repete a rodada a cada 60 segundos enquanto a sessão do jogador estiver ativa. Cancela leitura ao sair ou parar o serviço e interrompe o ciclo ao receber uma resposta bem-sucedida. Registros com schema inválido continuam rejeitados em vez de serem sobrescritos.

A restauração é aditiva: a conquista feita enquanto o carregamento estava indisponível não é apagada quando o registro antigo chega. O DataStore mantém as chaves e a política UpdateAsync v1.

## QA necessária
- Simular três falhas GetAsync e recuperação após o intervalo de 60 segundos, com jogador ainda na sessão; verificar selo e objetivos restaurados.
- Sair durante a espera, confirmar ausência de atualização de outro jogador.
- Completar uma ilha enquanto leitura está fora e confirmar que o progresso fica unido à recuperação, sem apagar conquistas locais.
- Verificar duas contas, schema inválido, erro de UpdateAsync e o orçamento de requisições.

CI e motor isolado não testam GetAsync real; não declarar DATASTORE_OK até QA em servidor Roblox real.