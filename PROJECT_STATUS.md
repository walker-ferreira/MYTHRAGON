# Estado do MYTHRAGON

**Fase ativa: 1 — Primeira aventura.** Consulte [NEXT_TASKS.md](NEXT_TASKS.md).

| Área | Estado na linha de base |
| --- | --- |
| Hub e portal | Presentes no Git. O fluxo atual inclui portal de Ember e painel de selos individual. Aetheria ampliada e o santuário de Varkhion são entregas da fase 1. |
| Ember | Guardião, combate no servidor, controle de arena, plataforma flutuante e retorno estão na base. Veja [registro 0002](docs/decisions/0002-combate-ember.md). |
| Perfil | Selo idempotente por sessão. A persistência DataStore pertence à fase 2. Veja [registro 0003](docs/decisions/0003-selos-perfil-e-visual-do-hub.md). |
| Integração | O callback de vitória é ligado em `Start.server.luau` e atualiza apenas o vencedor. |
| Testes | O dono confirmou a plataforma na revisão 5. Execute novamente os fluxos no build combinado. Registre testes de lógica, CI e cliente separadamente. |
| Publicação | Workflow de teste existente. Revisão 5 confirmada no Place de teste. A revisão atual do repositório deve ser comparada à versão publicada antes de qualquer novo envio. |
| Coordenação | Registros separados no [PR #4](https://github.com/walker-ferreira/MYTHRAGON/pull/4). Cada agente mantém o seu. |

Atualize este arquivo com o SHA analisado, evidências, pendências e destino confirmado quando a próxima entrega sair.
