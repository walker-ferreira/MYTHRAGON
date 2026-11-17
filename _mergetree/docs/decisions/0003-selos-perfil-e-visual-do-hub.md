# 0003 — Selo de Ember idempotente, perfil de sessão e visual do hub

**Estado:** implementada no servidor (sessão). Teste jogável e persistência DataStore pendentes.

Responsáveis nesta rodada: GLM 5.3 (`src/server/Hub/`, `src/server/Profile/` e `src/server/Start.server.luau`, autorizado pelo usuário). Sol: `src/server/Ember/` (branch `sol/ember-combate`) e `0002-combate-ember.md`. Após identificar a colisão de numeração, o usuário autorizou Sol como único editor deste documento e do índice para renumeração e correção das descrições, preservando a contribuição original.

## Contexto

O jogador entra no hub, identifica Ember entre os quatro selos, entra pelo portal, enfrenta o guardião e volta. A vitória libera o selo de Ember uma única vez; vitória repetida ou evento reenviado não pode conceder a recompensa de novo. O hub também precisa deixar a entrada de Ember clara e mostrar o estado dos quatro selos.

## Decisões

1. **Contrato vitória → perfil.** Cada build de reino recebe um callback por escopo: `Ember.build(parent, onVictory(player, encounterId))`. O servidor de Ember valida a vitória (estado terminal no servidor, nunca no cliente) e emite um GUID por tentativa como `encounterId`. `Profile.recordVictory(player, realmId, encounterId)` concede o selo do reino uma única vez por sessão: nova vitória do mesmo reino, segunda emissão da mesma tentativa ou evento reenviado devolvem `"duplicate"`. Duplicatas são contadas em `session.duplicates` e registradas com `warn` (detecção pedida pelo GDD).

2. **Estado visual dos selos.** Os orbes de basalto no mundo ficam neutros, com runa fraca, luz e partículas desligadas: identificam os reinos, não a conquista. O painel `SealPanel` no `PlayerGui` mostra os quatro estados por jogador; começa bloqueado e apenas o vencedor recebe "✓ conquistado" para Ember. `ResetOnSpawn=false` preserva o painel ao renascer. `Hub.setSealEarned(player, index)` atualiza somente esse jogador, seguindo a concessão do perfil. A conquista é de sessão, não persiste entre servidores.

3. **Entrada de Ember no hub.** Portal rúnico: base de granito, dois batentes, verga com runa, superfície `ForceField` na cor de Ember, luz, placa "Reino de Ember · Conquiste o primeiro selo", caminho de pedras do spawn e pedras entalhadas ladeando a entrada. O gatilho continua validado no servidor (personagem vivo, a até 16 studs, sem travessia em andamento).

4. **Progresso para testar a partida.** Não há concessão automática nem demo executável no Studio. `Profile/Profile.spec.luau` testa as regras puras com jogadores simulados sem alterar o mapa. No Studio e no Place publicado, a concessão do fluxo jogável vem exclusivamente do callback de vitória validada de Ember.

5. **Direção 3D.** Builds procedurais próprios inspirados em referências visuais usuais de fantasia: portal rúnico em arco de pedra, pedras entalhadas com marcas luminosas, ilha flutuante com maciço rochoso, orbes de selo sobre pedestais (estilo santuário). **Nenhum modelo externo foi importado nesta rodada**: a verificação de permissão de uso e a inspeção de scripts incluídos não pôde ser feita neste ambiente, então, pela regra da tarefa, criou-se a própria versão a partir da referência visual. Para importar modelos depois: (a) confirmar a licença/permissão na página do modelo; (b) inspecionar todo script incluído antes de importar; (c) adaptar formas e materiais ao visual MYTHRAGON; (d) registrar aqui a fonte e o ID do modelo. Buscas sugeridas no Creator Store: "rune portal", "carved stone", "floating island", "fantasy shrine" (filtro gratuito).

## Campos a persistir (pendência de implementação)

Por jogador, num DataStore `PlayerProfile_v1` (carregar na entrada com retry; salvar na saída, em `BindToClose` e com autosave periódico):

- `profileVersion` — migração de esquema;
- `seals` — por selo: `grantedAt` (época em segundos), `firstEncounterId` (GUID da primeira tentativa que concedeu), `grantedVia` (id do encontro);
- `duplicates` — contador diagnóstico de recompensas duplicadas;
- `updatedAt`.

## Testes de DataStore ainda pendentes

1. Perfil novo: carga vazia, sessão sem selos.
2. Conceder Ember, sair e voltar: selo permanece; repetir a vitória devolve `duplicate` sem nova recompensa.
3. Vitória repetida na mesma sessão: recompensa única.
4. Duas emissões quase simultâneas do mesmo evento: uma concessão.
5. Falha de save na saída (throttle/erro): retry; selo não perdido.
6. `BindToClose` no desligamento: saves concluídos.
7. Migração de `profileVersion`: campos novos preservados.
8. Jogador sai durante a concessão: sem erro nem corrupção.

## Correção registrada

- **Sintoma:** com o mapeamento por nome/prefixo de encontro, o GUID emitido por Ember não casava com nenhum id conhecido e a vitória devolveria `"unknown"` sem conceder o selo.
- **Causa:** o perfil mapeava o id do encontro para o selo; o id real é um GUID por tentativa.
- **Correção:** contrato por reino — o callback é criado por escopo de reino em `Start`, e o perfil recebe `realmId` explicitamente usando o GUID apenas para deduplicar (commit 3d7878d desta branch).
- **Verificação:** inspeção do callback em `Start` e testes puros do perfil; **confirmação jogável pendente** nesta rodada. A demo antiga não é evidência de vitória real.

### Correções na revisão cruzada

- **Estado compartilhado indevido:** Sol identificou que o selo global exibia conquista também a jogadores sem recompensa. GLM substituiu o indicador global por painel individual no commit `32497ae`; teste puro confirma que B não herda o selo de A. Visibilidade do painel no cliente ainda pendente. [Revisão](https://github.com/walker-ferreira/MYTHRAGON/pull/3#issuecomment-6904520756).
- **Vitória automática no Studio:** Sol identificou a demo que concedia selo após 4 s sem combate, invalidando testes de derrota/saída e do jogador novo. GLM removeu `StudioSealDemo.server.luau` no commit `1115c4f`. O spec puro substitui a simulação automática; sintaxe e build aprovados na [CI](https://github.com/walker-ferreira/MYTHRAGON/actions/runs/43785402359). [Revisão](https://github.com/walker-ferreira/MYTHRAGON/pull/3#issuecomment-6904635265).
- **Colisão documental:** o registro original `0002-selos...` foi preservado e renumerado para `0003` pelo editor Sol autorizado pelo dono; `0002-combate-ember.md` registra o combate. Nenhum commit alheio foi descartado.

## Revisão do PR de Ember (`sol/ember-combate`)

Conferido **no código** (sem teste jogável nesta rodada):

- Entrada pelo portal: hub valida no servidor; `Combat:enter` impede segunda sessão simultânea. ✔
- Retorno ao hub após vitória: estado terminal definido antes da recompensa; portal de retorno fecha a sessão e devolve ao spawn. ✔
- Selo concedido uma única vez: regras no servidor + idempotência no perfil. ✔
- Derrota com nova tentativa: morte fecha a sessão, respawn no hub, reentrada liberada ao renascer. ✔
- Plataforma preservada: servo prismatic intacto; loop encerra quando o modelo sai do mundo. ✔
- Observações menores: os specs de regras rodam com o CLI Luau local (CI apenas compila); o monitor verifica limites da arena (queda ou afastamento) e retorna automaticamente 30–32 s após a vitória. Confirmação no cliente pendente.

**Pendente jogando:** percorrer os cinco casos no Studio/cliente (teclado e mobile), incluindo o estado do selo após cada tentativa.

## Como verificar

1. CI do PR: sintaxe Luau e build Rojo do `mythragon-pilot`.
2. Local: `luau src/server/Profile/Profile.spec.luau` e `luau src/server/Ember/EncounterState.spec.luau` após combinar os PRs. Os specs não são executados automaticamente pela CI existente.
3. Studio/cliente: abrir o artefato e Play; o painel deve começar bloqueado, sem selo automático. Entrar pelo portal rúnico, vencer, retornar e conferir o próprio selo; repetir vitória e verificar que não há segunda concessão. Derrota/saída antes da vitória não concedem selo; uma nova tentativa pode vencer.
4. Dois jogadores: A vence; B deve continuar bloqueado em seu próprio painel. Revalidar após respawn, retorno automático e reconexão (nova sessão sem persistência). Exercitar teclado e mobile; nenhum desses percursos foi executado nesta sessão.
