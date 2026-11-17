# DATASTORE-RETRY-001 — falhas prolongadas de gravação

Problema: os dois serviços de progresso encerravam as seis tentativas iniciais e mantinham dados pendentes na memória, mas não tentavam gravá-los novamente enquanto nenhum novo evento acontecesse.

Correção: em servidores Roblox em execução, cada serviço executa uma verificação de pendências a cada 60 segundos e reinicia as tentativas usando a mesma gravação UpdateAsync monotônica. Um identificador de jogador continua pendente depois de sair até a gravação funcionar. A verificação não roda no motor isolado e para quando o serviço é encerrado.

Não modifica esquema, chaves, APIs cliente, recompensas ou salvamento de dados existentes.

### Testes reais ainda necessários
- Simular falha temporária de serviço superior à janela inicial de seis tentativas; depois restabelecer e verificar logs de gravação sem novos eventos.
- Repetir com jogador que desconecta durante falha; verificar que não se perde a pendência enquanto o servidor continuar vivo.
- Verificar saída do servidor e o flush de BindToClose.
- Reentrar em servidor diferente e confirmar os selos e descobertas gravados.

A CI e inspeção do Bootstrap não provam disponibilidade real de DataStore ou a recuperação entre servidores. Não declarar DATASTORE_OK até teste vivo.
