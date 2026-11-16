# 0002 — Selo de Ember idempotente, perfil de sessão e visual do hub

**Estado:** implementada no servidor (sessão). Teste jogável e persistência DataStore pendentes.

Responsáveis nesta rodada: GLM 5.3 (`src/server/Hub/`, `src/server/Profile/`, `Start.server.luau` já editado pela rodada anterior com autorização do usuário, docs 0002 e linha do README de decisões). Sol: `src/server/Ember/` (branch `sol/ember-combate`).

## Contexto

O jogador entra no hub, identifica Ember entre os quatro selos, entra pelo portal, enfrenta o guardião e volta. A vitória libera o selo de Ember uma única vez; vitória repetida ou evento reenviado não pode conceder a recompensa de novo. O hub também precisa deixar a entrada de Ember clara e mostrar o estado dos quatro selos.

## Decisões

1. **Contrato vitória → perfil.** Cada build de reino recebe um callback por escopo: `Ember.build(parent, onVictory(player, encounterId))`. O servidor de Ember valida a vitória (estado terminal no servidor, nunca no cliente) e emite um GUID por tentativa como `encounterId`. `Profile.recordVictory(player, realmId, encounterId)` concede o selo do reino uma única vez por sessão: nova vitória do mesmo reino, segunda emissão da mesma tentativa ou evento reenviado devolvem `"duplicate"`. Duplicatas são contadas em `session.duplicates` e registradas com `warn` (detecção pedida pelo GDD).

2. **Estado visual dos selos.** Bloqueado: orbe de basalto escurecido com runa fraca, luz e partículas desligadas. Conquistado: orbe aceso na cor do reino, `PointLight`, faíscas e etiqueta "✓ conquistado". O estado é por sessão e acende no mundo quando a concessão chega; **a visão por jogador no cliente é pendência do piloto seguinte** (hoje, com vários jogadores, o acender vale para a sessão do servidor inteiro).

3. **Entrada de Ember no hub.** Portal rúnico: base de granito, dois batentes, verga com runa, superfície `ForceField` na cor de Ember, luz, placa "Reino de Ember · Conquiste o primeiro selo", caminho de pedras do spawn e pedras entalhadas ladeando a entrada. O gatilho continua validado no servidor (personagem vivo, a até 16 studs, sem travessia em andamento).

4. **Progresso para testar a partida.** `Profile/StudioSealDemo.server.luau` roda só no Studio (`RunService:IsStudio()`): 4 segundos após a entrada simula a vitória, exercita `recordVictory` duas vezes (esperado `granted` e depois `duplicate`) e atualiza o hub. Não afeta o jogo publicado; pode ser removido quando o combate real estiver integrado.

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
- **Verificação:** demo do Studio (idempotência imprimida) e caminho jogável; **confirmação jogável pendente** nesta rodada.

## Revisão do PR de Ember (`sol/ember-combate`)

Conferido **no código** (sem teste jogável nesta rodada):

- Entrada pelo portal: hub valida no servidor; `Combat:enter` impede segunda sessão simultânea. ✔
- Retorno ao hub após vitória: estado terminal definido antes da recompensa; portal de retorno fecha a sessão e devolve ao spawn. ✔
- Selo concedido uma única vez: regras no servidor + idempotência no perfil. ✔
- Derrota com nova tentativa: morte fecha a sessão, respawn no hub, reentrada liberada ao renascer. ✔
- Plataforma preservada: servo prismatic intacto; loop encerra quando o modelo sai do mundo. ✔
- Observações menores: o spec de regras roda só com o CLI Luau local (CI apenas compila); auto-retorno por limite da arena (queda ou afastamento) está coberto.

**Pendente jogando:** percorrer os cinco casos no Studio/cliente (teclado e mobile), incluindo o estado do selo após cada tentativa.

## Como verificar

1. CI do PR: sintaxe Luau e build Rojo do `mythragon-pilot`.
2. Studio: abrir o artefato, Play; 4s após entrar, selo de Ember acende com toast e log de duplicata; portal rúnico visível; entrar em Ember, vencer (ou não), voltar, conferir os cinco casos da revisão.
