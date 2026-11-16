# MYTHRAGON — arquitetura

## Composição e propriedade

Rojo 7.6.1 inclui `src/server` em `ServerScriptService.Mythragon`.
`Start.server.luau` chama `Diagnostics.Bootstrap.run()` uma vez por servidor.
Bootstrap é idempotente, registra etapas Core (Ember/Profile/Hub), Varkhion e
Latunia; falha de qualquer componente obrigatório deixa saúde FAILED, mesmo quando
o restante do mundo continua disponível. Sem Core, dependentes são BLOCKED.
Não tentar hot-rebuild de Core após erro: iniciar servidor novo evita callbacks
de sessão duplicados. Montagem/rollback de Latúnia continuam no controller existente.

| Caminho | Papel | Responsável |
| --- | --- | --- |
| src/server/Hub/ | Aetheria, portais, interfaces, Vila Central | GLM |
| src/server/Profile/ | Selos e perfil de sessão; DataStore pendente | GLM |
| src/server/Ember/ | Arena, combate, vitória e retorno | CODEX |
| src/server/Dragons/ | Varkhion e interação de santuário | CODEX |
| src/server/Latunia/Codex/ | Layout, viagens, Deserto e Vulcânica | CODEX |
| Start, Diagnostics, Rojo, workflows, tools, tests | Integração/qualidade/releases | CODEX |

Ember é autoridade de vitória. Profile deduplica recompensa por jogador/selo;
Hub reflete estado individual. Conversar com Varkhion e viajar não concedem selo.
Partner builders recebem Content/anchorCFrame e não montam bootstrap concorrente.

## Geometria

Mundo gerado no servidor; abrir rbxlx sem Play mostra scripts, não prova mapa.
Latúnia separada em (2400,24,0), cinco slots, três detalhados; Gelo e Selva são
desembarques provisórios. Gate de teste em (24,4.5,8), dez prompts de viagem.
Geometria estática determinística atual mantida; bake só com medição/benefício,
sem reescrever arquitetura por semelhança com referência externa.

## Qualidade, identidade e release

CI executa sintaxe, quatro specs CLI, contratos Python, LSP com definições Roblox
em cinco módulos puros e todas as referências Enum; engine adapters ainda têm
tipagem incremental. Testes negativos provam rejeição de sintaxe/tipos/artefato/
destino incorretos. Dependências fixadas e downloads Luau/LSP com checksum.

BuildInfo é substituído no CI com SHA completo/build run. Duas compilações Rojo
devem ser idênticas. Manifesto confere Source de todos os scripts incluídos,
hash SHA-256, módulos/asset refs e testes. PREVIEW não publica.

Push integrado na main → CI aprovado → PUBLISH staging experimental.
Seleção automática do artefato exato, validação de origem/SHA/destino, rejeição de
main obsoleta, concurrency por Place e journal GitHub Deployments antes do PATCH.
Não repetir PATCH em timeout; consultar operação. Exigir destino, revisão e
isPublished; guardar resposta/recibo/evidência como artefato.

Staging único: Universe 10777026486 / Place 135004978091658. Environment GitHub
staging deve restringir branch main, sem revisão humana rotineira.
Produção não configurada nem publicável por estes scripts.

Inspeção Luau Execution Open Cloud: revisão específica, comparação Source persistida,
bootstrap explícito e raios de piso/contratos de cena. Essa API não executa física,
servidor/cliente automaticamente. Não equivale a servidor normal nem playtest.
Sem acesso registrar PENDING_ACCESS; engine FAIL gera falha de verificação, embora
o candidato já esteja publicado. Corrigir por PR/release nova, sem esconder o fato.

Saúde em ReplicatedStorage.MythragonHealth; logs estruturados incluem SHA, IDs,
PlaceVersion, JobId e erros. UI discreta somente staging mostra SHA/revisão/estado.
Segredos nunca entram no build ou interface.

Ver [contrato operacional](AGENTS.md), [fila](docs/agents/TASK_QUEUE.md),
[orquestração](docs/engineering/ORCHESTRATION.md) e [releases](docs/releases/README.md).
