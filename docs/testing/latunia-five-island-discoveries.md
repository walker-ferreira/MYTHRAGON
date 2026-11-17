# JOURNEY-002 — descobertas persistentes das cinco ilhas de Latúnia

Partindo do checkpoint JOURNEY-001, a chegada validada no servidor por `Latunia/Codex/Map.luau` agora registra a primeira visita a Central, Gelo, Deserto, Selva e Vulcânica. Os IDs de persistência são `latunia`, `gelo`, `deserto`, `selva` e `vulcanica`.

Cada descoberta:
- parte exclusivamente do controlador de viagem, após bilhete, personagem e distância válidos;
- salva com `UpdateAsync` monotônico em `Mythragon_Progress_v1` sem apagar selo de Ember ou missões do Hub;
- gera aviso de exploração apenas na primeira visita da sessão. Se o progresso for lido do DataStore, não emite outra recompensa;
- não concede moedas, materiais nem acesso especial, e não instala NPCs;
- comandos `/ir` do Studio não emitem evento de descoberta.

## QA necessário
CI e motor isolado não substituem: testar cinco ilhas com teclado e toque, repetir viagens, duas contas, sair/entrar, verificar IDs e procurar erros de DataStore/console. Falha de DataStore não pode apagar dados históricos.

Sem evidência desses testes, não declarar `DATASTORE_OK`, `RUNTIME_OK` ou `PLAYTEST_OK`.
