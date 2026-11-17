# EXPLORE-HUD-001 — painel de exploração de Latúnia

Implementação server-side isolada em `src/server/Profile/ExplorationPanel.luau` e política testável em `ExplorationState.luau`. O painel `MythragonExploration` mostra a contagem 0–5 e o estado das cinco ilhas (Central, Gelo, Deserto, Selva e Vulcânica) em uma coluna abaixo dos objetivos de Aetheria, dimensionada para telas pequenas.

O painel é **somente visual**: não concede moedas, itens, selos, objetivos ou viagens. Ele apenas observa `ObjectivesStore`, que recebe dados carregados via `GetAsync` ou eventos de chegada já validados pelo controlador de Latúnia. Na ordem inversa (o jogador descobre uma ilha antes do carregamento), os estados são unidos monotonicamente. Tela pessoal não compartilha as conquistas entre jogadores.

Critérios de validação:
- Compilar Luau e executar `ExplorationState.spec.luau` (duplicidade, carregamento tardio e isolamento).
- Staging: inicialização isolada e presença dos módulos na publicação exata.
- Cliente novo: painel aparece após login, não sobrepõe objetivos superiores, não atravessa o joystick na resolução 320×568; verificar toque e controle.
- Viajar pela primeira vez, observar atualização 1/5..5/5; repetir visita e confirmar nenhuma duplicidade. Desconectar e voltar, comparar estado com DataStore em duas contas.
- DataStore desativado: painel deve mostrar apenas descobertas da sessão, sem alegar que houve gravação permanente.

Não declarar teste visual/cliente, DataStore real ou produção aprovados sem executar essas etapas.
