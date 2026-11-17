# JOURNEY-001 — descoberta persistente da Vila Central

**Escopo:** Primeira etapa da jornada após Aetheria e Ember; reconhecer a chegada a Latúnia, sem alterar ilhas/portais de GLM, comércio ou NPCs.

- O evento é emitido **somente** pelo controlador oficial da viagem, depois que o bilhete, distância, personagem vivo e o destino foram validados no servidor e o personagem foi movido ao ponto de chegada.
- A callback registra a descoberta de `Central` com ID `latunia` via `ObjectivesStore`, uma vez por jogador/sessão. Registros já salvos são recuperados sem repetir conclusão.
- O registro utiliza a chave existente `Mythragon_Progress_v1/player_<UserId>` e `UpdateAsync` monotônico, preservando o selo Ember e outros objetivos. Falhas de escrita geram logs e tentativas limitadas; não há compras ou recompensas.
- `Hub.notify` mostra a descoberta na primeira chegada da sessão. Os outros quatro destinos não concedem este objetivo.
- Não altera o contrato de três objetivos mostrado no painel do Hub. Esta descoberta é uma nova etapa **de jornada**, não um quarto requisito para concluir o painel inicial.

## Testes pendentes em Roblox normal

1. Iniciar um servidor novo e confirmar READY, entrada Hub → Vila Central e mensagem de descoberta.
2. Viajar Central → Gelo → Central e verificar nenhuma segunda concessão/notificação no mesmo servidor.
3. Sair e entrar em servidor novo; verificar que a chave armazenada possui `objectives.latunia=true` sem perder selo Ember e demais campos.
4. Testar duas contas sem compartilhar estado; garantir que usar `/ir` no Studio não concede a descoberta.
5. Simular indisponibilidade de DataStore sem apagar registros anteriores.

CI, Rojo e inspeção isolada são necessários, mas **não** bastam para declarar testes de player, DataStore real ou produção aprovados.

**Estado:** implementação candidata; completar evidência de CI, publicação e playtest antes de marcar etapa finalizada.
