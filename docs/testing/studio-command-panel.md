# Comandos na tela — Roblox Studio

O botão **⚙ Comandos** fica no canto inferior direito durante testes no Roblox Studio. Ao tocar/clicar, abre o painel com seis destinos: Aetheria, Vila Central, Deserto, Vulcânica, Gelo e Selva. O botão `×` fecha a janela.

- Cliente: `src/client/CommandPanel.client.luau`, compilado para StarterPlayerScripts via `default.project.json`; usa `Activated`, compatível com mouse, toque e controle.
- Servidor: `Hub/LatuniaCommands.server.luau` cria RemoteEvent somente no Studio, valida origem, destino e intervalo mínimo de 0,75s, chamando o `Latunia/Codex/Map.debugWarp` autoritativo que atualiza o controlador.
- No Roblox publicado os comandos continuam inacessíveis; somente portais normais podem conceder descobertas e avanço da jornada.
- A entrada `/ir` do chat continua disponível no Studio, sem necessidade de reescrever o mapa.

## Verificação
1. CI Luau e build Rojo: confirmar LocalScript em StarterPlayerScripts e servidor sem erros de inicialização.
2. Roblox Studio Play: conferir botão, abrir/fechar, seis destinos, atraso de requisições e retorno ao hub.
3. Confirmar no Studio que nenhum desses teletransportes concede selo, descoberta ou missão.
4. Abrir servidor de staging normal e confirmar que comandos e RemoteEvent não ficam disponíveis a jogadores.

Esse controle é uma ferramenta de desenvolvimento, não um comando liberado para o público. Não declarar PLAYTEST_OK por aprovação da CI.