# Comandos na tela — Roblox Studio

O botão **⚙ Comandos** fica no canto inferior direito durante testes no Roblox Studio e para o proprietário individual do Place publicado em staging. Ao tocar/clicar, abre o painel com seis destinos: Aetheria, Vila Central, Deserto, Vulcânica, Gelo e Selva. O botão `×` fecha a janela.

- Cliente: `src/client/CommandPanel.client.luau`, compilado para StarterPlayerScripts via `default.project.json`; usa `Activated`, compatível com mouse, toque e controle.
- Servidor: `Hub/LatuniaCommands.server.luau` cria RemoteEvent, valida a permissão no servidor (Studio ou `CreatorType=User` + `CreatorId=UserId` + Place staging), destino e intervalo mínimo de 0,75s, chamando o `Latunia/Codex/Map.debugWarp` autoritativo que atualiza o controlador.
- No Roblox publicado, somente o proprietário individual do Place em staging pode abrir e utilizar comandos. Visitantes comuns continuam usando portais normais; comandos administrativos nunca concedem descobertas ou avanço da jornada.
- A entrada `/ir` do chat continua disponível no Studio, sem necessidade de reescrever o mapa.

## Verificação
1. CI Luau e build Rojo: confirmar LocalScript em StarterPlayerScripts e servidor sem erros de inicialização.
2. Roblox Studio Play: conferir botão, abrir/fechar, seis destinos, atraso de requisições e retorno ao hub.
3. Confirmar no Studio que nenhum desses teletransportes concede selo, descoberta ou missão.
4. Abrir servidor de staging normal e confirmar que o proprietário individual consegue usar o botão, enquanto usuários comuns não conseguem executar teleporte, mesmo enviando RemoteEvent manualmente.

Esse controle é uma ferramenta de desenvolvimento para Studio e para o criador individual do Place experimental. Em experiências pertencentes a grupos, a autorização publicada falha de modo seguro e fica somente no Studio. Não declarar PLAYTEST_OK por aprovação da CI.