# Próximas tarefas — começar pela fase 1

## 1. Fazer um inventário curto do Git e aproveitar a base

Cada agente atualiza suas referências, identifica o SHA de `origin/main`, verifica branches e PRs abertos e lê `AGENTS.md`, `GDD.md`, `ARCHITECTURE.md` e decisões 0002/0003. Inspecione apenas os caminhos do seu escopo, os contratos e os testes relevantes. Preserve trabalho local. Abra branch e pasta próprias a partir da mesma base.

| Ordem | Codex | GLM |
| --- | --- | --- |
| Primeiro, conferir e reaproveitar | Inspecionar Ember, guardião, plataforma, arena e retorno. Localizar quaisquer modelos, animações ou módulos de dragões reaproveitáveis, verificando origem. | Inspecionar o hub, spawn, portal, painel, perfil e a ligação em Start. Localizar elementos já úteis para Aetheria e as regras que precisam ser preservadas. |
| Em seguida, implementar | Criar ou adaptar Varkhion provisório, com uma interação funcional e resposta no cliente. Manter o encontro e os retornos existentes. Propor ao GLM o contrato e um encaixe de montagem. | Evoluir o hub existente em Aetheria. Manter spawn seguro, adicionar trajeto de exploração, santuário e objetivo curto que leva a Varkhion e depois a Ember. Preservar portal e selo individual. |
| Integrar e revisar | Revisar o fluxo do hub, conferir retomada após derrota e avaliar referências 3D. | Revisar interação de Varkhion, isolamento entre jogadores e compatibilidade com o callback de vitória. Integrar Start depois de confirmar a responsabilidade pelo arquivo. |

Depois de registrar o inventário, comece a implementação da sua coluna na mesma sessão. Quando houver uma dependência de integração aberta, avance na parte independente e registre o pedido no seu arquivo. Informe caminhos preservados, reaproveitados e alterados, com links. Use os registros [do Codex e do GLM](https://github.com/walker-ferreira/MYTHRAGON/pull/4) para pedidos e decisões. A cada entrega, resuma o que o parceiro está fazendo e termine com as próximas tarefas, responsáveis e dependências.

## 2. Aceitar a entrega na prática

- Jogador novo nasce em local seguro, encontra Varkhion, interage e identifica o portal de Ember.
- Teclado e toque conseguem iniciar a interação, entrar e atacar. O sopro só atinge dentro da área marcada. A plataforma mantém a subida e a descida e carrega o personagem.
- Derrota, saída antecipada e desconexão liberam a arena. Vitória sem usar a saída retorna ao hub. A segunda vitória não concede outro selo. Um segundo jogador não herda o selo.
- Revise ambos os PRs, rode specs disponíveis, confira build e registre testes jogáveis. Marque casos indisponíveis como pendentes. Com a fase aprovada, Codex coordena o envio ao Place de teste autorizado e registra a revisão.
- Depois do aceite, GLM começa o perfil persistente e Codex o catálogo de dragões da fase 2, conforme o [GDD](GDD.md).
