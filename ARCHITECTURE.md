# MYTHRAGON: REINOS DO ÉTER — arquitetura

## Base verificada e princípio de integração

O Git é a fonte do projeto Roblox em Luau. Rojo monta o Place e GitHub Actions valida sintaxe e gera o artefato. O piloto gera o cenário em runtime e hospeda hub e Ember no mesmo Place. Continue nesse modelo para a fase 1. Só proponha divisão em Places ao medir custo de memória, isolamento ou necessidade de instâncias. Preserve IDs lógicos de reinos e o contrato de entrada e saída nessa transição.

| Módulo ou área | Responsabilidade | Editor inicial |
| --- | --- | --- |
| `src/server/Ember/` | Arena, plataforma, encontro, dano, telegráfico, resultado e retorno | Codex |
| `src/server/Hub/` | Aetheria, spawn, objetivos iniciais, portal e painel individual | GLM |
| `src/server/Profile/` | Fonte de verdade por jogador, selos, persistência e migrações | GLM |
| Módulo de dragões, caminho a confirmar | Catálogo de espécies, Varkhion, interações, companheiros, voo e habilidades | Codex |
| `src/server/Start.server.luau` | Composição, configuração de callbacks e ciclo de vida | GLM é o editor proposto para a rodada. Registre o acordo com Codex. |
| Projeto Rojo, workflows e documentação comum | Composição de build, configuração e evidências | Um editor por arquivo, registrado antes da alteração |

Acrescente módulos e mapeamentos Rojo quando o primeiro consumidor existir. Separe apresentação no cliente, estado autoritativo no servidor e definições públicas compartilhadas. Sistemas de domínio devem poder validar regras sem abrir uma sessão do motor quando viável.

## Contratos

- **Ember → progresso.** Preserve `Ember.build(parent, onVictory)` e o retorno booleano de entrada, além de `Ember.connectReturn(parent, onReturn)`. `Start` associa o callback a Ember e chama `Profile.recordVictory(player, "Ember", encounterId)`. O servidor gera o identificador e decide o resultado antes de conceder a recompensa. A UI consome o estado individual. Vitória repetida, evento reenviado e troca de personagem preservam a regra do selo.
- **Varkhion → Aetheria.** GLM fornece ponto de encontro e fluxo de objetivo. Codex fornece modelo e interação. Definam objeto de montagem, evento de interação validado no servidor, texto e origem do progresso antes de ligar os módulos. A montagem acontece uma vez. A interação transiente da fase 1 não cria posse persistente automaticamente.
- **Cliente → servidor.** O cliente envia intenções de ataque, interação, construção ou uso de habilidade. O servidor confere identidade, estado, dono, distância, alvo, custo e frequência, conforme a ação. Vitória, recompensas, genética, compra, ranking e resultados de partida são calculados e validados no servidor.
- **Transições.** Portal e arena mantêm entrada única por tentativa. Limpe a reserva em saída, morte, desconexão e vitória seguida de retorno. Voo e teleporte precisam de limites de velocidade, fronteiras e um retorno seguro se a transição falhar.

## Dados e expansão

**Fase 2.** Defina schema com versão, chave de jogador e identificadores estáveis para reino, selo, espécie, dragão individual, recursos e construções. Separe o catálogo estático das instâncias do jogador. Implemente migrações tolerantes a campos antigos, gravação condicional, propriedade de sessão, autosave e encerramento. Após uma falha de carregamento, bloqueie gravações até obter um perfil válido. Proteja compras, cruzamento, construção e recompensas com identificadores idempotentes e testes de repetição. Teste orçamento e falhas do DataStore em ambiente de teste. Armazene apenas o histórico necessário para deduplicar, com retenção definida.

**Fase 3.** Catálogos versionados descrevem espécies, encontros, missões, regiões, recursos, clima e tabelas de recompensa. Use estados de NPC para detecção, patrulha, habilidades e retirada. Controle cadência e ativação por proximidade. Montaria separa input e apresentação do cliente das permissões, limites e estado do servidor. Use eventos determinísticos ou seed registrada onde o resultado exigir reprodução. Teste carreiras de progresso e retorno entre regiões.

**Fase 4.** Matchmaking, instâncias de partida e persistência de ranking têm limites claros. Registre ID da partida, participantes e resultado autoritativo. Atualizações assíncronas de rankings, guildas e recompensas lidam com duplicações e falhas parciais. Revisão de moderação cobre convites, visitas, permissões de guilda e texto de usuário. Calendário de eventos e temporadas fica em dados versionados. Defina metas mensuráveis de FPS, memória, tempo de entrada e latência depois de medir o piloto em dispositivos representativos. Teste carregamento progressivo, distância visual, LOD, animações e orçamento de partículas. Registre baseline e regressões em `docs/testing/`.

## QA, coordenação e publicação

1. Cada PR declara caminhos, fase, contratos afetados, licenças de assets e testes. Use specs puras para estado de combate, perfil, transações e balanceamento. Se a CI atual só compilar as specs, execute-as separadamente e registre o comando e a saída.
2. Valide sintaxe e build na CI. Em seguida, valide comportamento no cliente Roblox, distinguindo teclado, toque e multijogador. Guarde SHA, ambiente e resultado de cada caso. Um caso sem execução permanece pendente.
3. Codex e GLM usam branches e pastas separadas. Cada um mantém seu próprio registro em `docs/agents/` conforme [PR #4](https://github.com/walker-ferreira/MYTHRAGON/pull/4) enquanto ele estiver aberto. Decisões duradouras vão para `docs/decisions/` com editor único. Codex trabalha sozinho por padrão e limita subagentes a um por vez, quando autorizados e necessários.
4. O workflow `publish-staging.yml` usa apenas o artefato bem-sucedido da `main`, valida o destino e registra SHA, hash, operação e revisão. Teste autorizado usa Universe `10777026486` e Place `135004978091658`. O secret `ROBLOX_OPEN_CLOUD_API_KEY` fica nos Secrets de Actions. Codex coordena o envio após revisão cruzada e QA. O destino definitivo é separado, com autorização e credencial próprias. Antes de substituir um Place, confira que a cena integral está no build. Em regressão publicada, identifique o último SHA e artefato conhecidos e prepare restauração pelo fluxo aprovado.
