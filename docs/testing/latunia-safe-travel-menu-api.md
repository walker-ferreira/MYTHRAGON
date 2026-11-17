# TRAVEL-UI-API-001 — integração segura do menu de viagem de Latúnia

Este checkpoint cria `Map.requestTravel(workspace, player, destinationId)`, uma API **somente para scripts do servidor**. Ela encaminha uma solicitação de menu ao **mesmo portal físico** da viagem normal: verifica a ilha atual do controlador, a rota real, a distância máxima de 12 studs, personagem vivo, a trava de viagem e o bilhete de viagem. A travessia só acontece após o atraso e a segunda validação da proximidade e identidade do personagem.

Rotas oficiais: Hub → Vila Central; Vila Central → Hub/Gelo/Selva/Deserto/Vulcânica; cada outra ilha → Vila Central. Não permite Hub → Gelo, Selva → Deserto ou travessia a distância sem estar perto do portal. Viagens válidas preservam descoberta de ilha e objetivos no servidor. Viagens de debug do proprietário continuam usando `Map.debugWarp` e **não** concedem descobertas.

## Contrato para GLM PR #45

- Preservar a aparência dos botões, mas **não** usar `character:PivotTo` dentro de `LatuniaCommands.server.luau` para viagens públicas.
- O RemoteEvent do menu recebe **somente** o ID do destino, com whitelist e cooldown, e chama `Map.requestTravel(workspace, player, destinationId)` no servidor.
- Se retornar false, informar que é necessário estar perto do portal/cais oficial ou que a rota é indisponível; não conceder recompensas.
- Os terminais físicos devem passar pelo mesmo controlador, sem teleporte direto ou falsificação de origem.
- A raiz oficial é `workspace.LatuniaCodex`; a ilha atual não é inferida de dados fornecidos pelo cliente.
- A API retorna true quando uma solicitação é aceita/iniciada, não quando a viagem assíncrona foi completada.

## Validação pendente

CI e engine probe verificam o registro das dez rotas físicas, mas testes com jogadores ainda precisam cobrir: duas contas, tentativa fora do cais, personagem morto, cliques repetidos, teleporte normal vs. debug, reconexão, mobile e portal de retorno. Não declarar PLAYTEST_OK por aprovação da CI.

Este PR **não ativa um novo menu** nem modifica o PR do GLM; apenas prepara a integração segura para preservar seu trabalho.

## Falha durante a travessia

Em um servidor de teste, injete um erro no ponto de chamada de `PivotTo` durante uma viagem válida. Confirme que o personagem continua na origem, o destino não é registrado como descoberta e a interface orienta a tentar novamente. Restaure o teleporte e repita pelo mesmo portal após o intervalo normal de 3 segundos. Teste tanto o trajeto Aetheria → Vila Central quanto a volta de uma ilha à Vila Central. Confira também que a recuperação de uma queda pode ser tentada novamente após uma falha.

## Cancelamento antes do embarque

Solicite uma viagem pelo portal ou pelo menu **VIAGEM** e afaste-se imediatamente antes de completar 1,2 segundo. O aviso deve mudar para **Travessia cancelada**. Confira que o personagem fica na origem e que nenhuma descoberta é concedida. Volte ao portal e tente novamente após o intervalo normal. Se o personagem morrer ou for substituído durante a preparação, o bilhete antigo deve ser encerrado sem mover o novo personagem.
