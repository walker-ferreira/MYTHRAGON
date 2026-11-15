# MYTHRAGON — instruções para os agentes

Leia este arquivo no início de cada sessão. O usuário identifica o agente como GPT‑6.1 Sol ou GLM 5.3. Se a identidade ou o escopo estiverem indefinidos, faça apenas leitura e peça a informação necessária.

## Responsabilidades

| Agente | Responsabilidade | Branch sugerida |
| --- | --- | --- |
| GPT‑6.1 Sol | Reino Ember, inimigos, combate, regras de vitória e derrota e execução da saída do reino. | `sol/ember-combate` |
| GLM 5.3 | Perfil, DataStore, hub, portal no lado do hub e estado e concessão dos quatro selos. | `glm/perfil-hub-selos` |

## Antes de editar

1. Confirme a aprovação do usuário para implementar a tarefa. A análise inicial é somente leitura.
2. Consulte `git status --short` e inspecione a árvore real. Informe ao usuário os caminhos exatos que pretende criar ou alterar. Cada caminho recebe um único responsável por rodada, incluindo arquivos novos, renomeados e excluídos.
3. Se um arquivo misturar responsabilidades, ou se a tarefa envolver configuração, scripts compartilhados, interfaces, eventos ou um arquivo de lugar do Roblox (`.rbxl` ou `.rbxlx`), combine com o usuário quem fará a edição. Até haver um responsável definido, apenas leia esse arquivo.
4. Para trabalhar em paralelo, cada agente usa sua própria branch e uma pasta de trabalho separada, com clone ou `git worktree`. Duas sessões na mesma pasta podem fazer a revisão somente leitura. Preserve qualquer alteração local do usuário.

## Integração entre Ember e o hub

- Sol é responsável pelo resultado do combate em Ember. GLM é responsável por registrar o progresso e conceder o selo. Antes de ligar os dois, combinem a interface e quem vai editar o arquivo que a declara. A mesma vitória deve conceder a recompensa uma única vez.
- GLM cuida da interação com o portal no hub. Sol cuida da chegada a Ember e da saída do reino. Quando precisar de uma alteração fora do seu escopo, informe ao responsável o caminho, o comportamento esperado e como verificar a mudança.
- Se o jogo estiver concentrado em um único arquivo de lugar, só o responsável definido pode salvá-lo naquela rodada. O outro entrega sua contribuição separadamente para o responsável integrar.

## Entrega

- Confira `git status --short`, `git diff --name-only` e `git diff --cached --name-only`. Se já houver commits de trabalho, compare também a branch com a revisão de base. Resolva qualquer sobreposição com o responsável pelo arquivo.
- Informe os arquivos alterados, os testes feitos no Roblox Studio e as pendências de integração.
- Peça aprovação antes de fazer commits, enviar alterações ao GitHub, integrar branches ou publicar no Roblox.
