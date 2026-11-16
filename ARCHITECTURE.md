# MYTHRAGON — arquitetura

## Estrutura atual

| Caminho | Papel | Responsável |
| --- | --- | --- |
| `src/server/Hub/` | Hub, portal de entrada e selos visuais | GLM 5.3 |
| `src/server/Ember/` | Arena, chegada e retorno de Ember | GPT‑6.1 Sol |
| `src/server/Profile/` | Caminho previsto para perfil e persistência | GLM 5.3 |
| `src/server/Start.server.luau` | Montagem do mapa e ligação dos módulos | Editor único por tarefa |
| `default.project.json` e `rokit.toml` | Montagem Rojo e versão da ferramenta | Editor único por tarefa |
| `.github/workflows/` | Validação, build e futuro envio | Editor único por tarefa |

Rojo inclui os scripts no Place. O servidor cria a cena de hub e Ember no mesmo Place ao iniciar. Para inspecionar o cenário atual no Studio, abra o `.rbxlx` e pressione Play.

## Contrato de jogo a implementar

Ember determina no servidor se o encontro foi concluído. O módulo de perfil e selos recebe o resultado validado e garante que a concessão seja idempotente. Dados vindos do cliente podem expressar ações do jogador. A confirmação de vitória e a recompensa pertencem ao servidor. Antes de editar a interface compartilhada, os agentes registram os caminhos envolvidos e combinam quem fará a alteração.

## Build e publicação

1. A CI verifica a sintaxe dos scripts e gera o artefato `mythragon-pilot`.
2. A validação jogável confirma que os portais e os sistemas funcionam no cliente Roblox.
3. A publicação Open Cloud ainda precisa de um workflow e dos destinos. Planeje enviar o artefato validado a uma experiência privada de teste antes de habilitar produção.
4. Registre o Universe ID e o Place ID de cada destino em configuração versionada após conferir os valores no Creator Dashboard. Os IDs identificam o alvo. A credencial é armazenada nos GitHub Actions Secrets como `ROBLOX_OPEN_CLOUD_API_KEY`.
5. Na primeira fase, dê à chave acesso de escrita somente à experiência de teste. Para o endpoint Place Publishing, confira a permissão `universe-places` com a operação Write nessa experiência. Reserve produção para uma aprovação e credencial próprias.
6. O workflow deverá registrar commit, artefato, destino e versão retornada pela API. Confira que o build inclui toda a cena antes de aprovar a substituição de um Place existente.

[Roblox Open Cloud — publicação de Places](https://create.roblox.com/docs/cloud/guides/usage-place-publishing) · [Decisões versionadas](docs/decisions/README.md)
