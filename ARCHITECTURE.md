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
3. O workflow `publish-staging.yml` está configurado para Universe `10777026486` e Place `135004978091658`. Antes do primeiro envio, confirme no Creator Dashboard que esse destino é a experiência privada de teste. Após integrar o PR, rode o workflow na `main` com o ID da execução CI bem-sucedida do commit atual. Rode primeiro com a opção de publicação desmarcada para verificar a relação entre IDs e o artefato.
4. Registre o Universe ID e o Place ID de cada destino em configuração versionada após conferir os valores no Creator Dashboard. Os IDs identificam o alvo. A credencial é armazenada nos GitHub Actions Secrets como `ROBLOX_OPEN_CLOUD_API_KEY`.
5. Na primeira fase, dê à chave acesso de escrita somente à experiência de teste. Para a Assets API do Open Cloud, confira as operações Read e Write da permissão `assets` nessa experiência. O envio exige marcar a opção de publicação e digitar o Place ID de teste. Reserve produção para uma aprovação e credencial próprias.
6. O workflow registra commit, SHA-256 do artefato, destino e operação retornada pela API, além da revisão quando informada. Confira que o build inclui toda a cena antes de aprovar a substituição de um Place existente.

[Roblox Open Cloud — publicação de Places](https://create.roblox.com/docs/cloud/guides/usage-place-publishing) · [Decisões versionadas](docs/decisions/README.md)
