# Varkhion — orientação por progresso real da Fase 1

O diálogo do Varkhion consulta exclusivamente Profile.hasSeal(player, "Ember") no servidor por callback opcional, sem depender de dados enviados pelo cliente.

- Antes do primeiro selo: explica portal e Guardião de Ember.
- Depois do selo validado: orienta procurar o portal de Latúnia, chegar à Vila Central e explorar as cinco ilhas.
- Se a leitura falhar: avisa no log e mostra orientação inicial, sem conceder progresso.
- VarkhionGuidance.luau e respectiva spec CLI verificam as duas mensagens.
- Não instala NPCs, não muda o modelo ou arena, não altera UI GLM e não concede selos.

QA necessário: conversar com Varkhion antes/depois da vitória, sair/voltar com DataStore, verificar texto no celular e encontrar o portal sem comando Studio. Motor isolado não é playtest.
