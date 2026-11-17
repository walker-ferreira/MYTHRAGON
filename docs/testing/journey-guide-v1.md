# STORY-GUIDE-001 — Próxima missão da Fase 1

O painel existente de exploração exibe uma linha de orientação e a contagem de nove marcos verificáveis: observar Guardiões, conversar com Varkhion, entrar no portal de Ember, vencer o Guardião e receber o selo, chegar à Vila Central e visitar Gelo, Deserto, Selva e Vulcânica.

Cada passo depende exclusivamente de eventos do servidor ou do estado restaurado do DataStore. Visitas fora de ordem contam como descobertas, mas não pulam os passos anteriores da orientação. O sistema não cria missões fictícias, não entrega recompensas e não instala NPCs.

A posição da linha de orientação é logo abaixo do painel de cinco ilhas; validar sobreposição com o joystick e outros painéis no celular antes de certificar UI.

## QA
- Conferir orientação inicial e avanço após cada interação.
- Confirmar selo carregado e objetivos carregados em servidor novo, inclusive após atraso de GetAsync.
- Repetir atividades e visitas fora de ordem; sem duplicar conquistas.
- Duas contas simultâneas não podem compartilhar texto ou progresso.
- Verificar texto e sobreposição em 320×568, teclado, toque e controle.

Build, CI e inspeção isolada não comprovam testes de cliente, DataStore real ou desempenho.