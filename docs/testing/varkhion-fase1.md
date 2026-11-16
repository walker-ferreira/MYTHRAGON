# Fase 1 — Varkhion: evidências e bloqueios

**Editor:** Codex. **Base:** `fd188854a8bf9176a636b1c9ec71167c82dfbd72`.
**Branch:** `codex/varkhion-fase1`. O SHA da implementação e links de CI devem ser registrados no PR; não confundir a base com o candidato de teste.

## Candidato para o dono testar — autorização posterior

O dono pediu expressamente **“publica para eu testar”**. Está autorizado este candidato no Place de teste mesmo com o percurso jogável pendente; **não** é aceite da Fase 1 ou autorização de produção.

Incorporado GLM `0f99a92`: material Wood válido, painéis responsivos e revisão completa dos fontes Codex pelo GLM em `18ddc90`. Codex revisou o diff e preservou seus próprios fontes/Start revisados; Hub e documentos GLM foram incorporados sem edição por Codex. Achados A/B corrigidos no código; legibilidade real, encaixe e fluxo completo continuam sem execução no cliente.

Esta exceção posterior vale só para disponibilizar o candidato ao teste do dono. A tabela de casos abaixo continua **pendente**, sem marcação fictícia de teclado, toque, vitória, derrota, plataforma ou dois jogadores. SHA final, CI e confirmação da publicação serão registrados nos PRs para não alterar o commit publicado depois do envio.

## Automação local

Ambiente: Windows, CLI Luau 0.744 e Rojo 7.6.1. Resultados executados nesta rodada:

| Verificação | Comando / critério | Resultado |
| --- | --- | --- |
| Sintaxe | `luau-compile --null` em todos os `.luau` de `src` | PASS: 13 fontes (inclui compilação, não execução, do spec de motor) |
| Combate existente | `luau src/server/Ember/EncounterState.spec.luau` | PASS: `Ember rules: PASS` |
| Perfil existente | `luau src/server/Profile/Profile.spec.luau` | PASS: `Profile rules: PASS` |
| Interação Varkhion | `luau src/server/Dragons/InteractionState.spec.luau` | PASS: `Varkhion interaction rules: PASS` |
| Build | `rojo build default.project.json -o mythragon-varkhion.rbxlx` | PASS: saída em pasta temporária, fora do Git |
| Preservação anterior | Na entrega isolada, comparar Ember/Hub/Profile/Start com `fd18885` | PASS em `85a5152`; na continuação Start foi autorizado e Hub entrou por merge do PR #7 (ver abaixo) |

## CI remota

[PR #6](https://github.com/walker-ferreira/MYTHRAGON/pull/6), implementação `d923e6f`: [execução 43791170078](https://github.com/walker-ferreira/MYTHRAGON/actions/runs/43791170078), **PASS** (sintaxe/build das 12 fontes desse commit). A atualização posterior adiciona o spec manual do motor e estas evidências; resultado do HEAD mais recente deve ser conferido nos checks do PR.

O workflow atual verifica sintaxe e build; **não executa as specs**. Não contar os testes locais como CI nem build como validação de cliente.

## Continuação — PR #7 combinado com Varkhion

- GLM: implementação `9320b1d`, documentação `47501c14ec823b0bf19cd7c348918e1678f6a3c4`; [CI 43794254570](https://github.com/walker-ferreira/MYTHRAGON/actions/runs/43794254570) PASS, reaproveitada, sem disparar outra execução na branch do parceiro.
- Codex combinou `47501c1` por merge normal **somente em `codex/varkhion-fase1`**, preservando autoria. O dono transferiu exclusivamente Start para Codex nesta continuação; Hub e documentos GLM não foram editados por Codex.
- Na releitura antes de encerrar surgiram `db6da8f`/`2e72b54`: âncora renomeada para `VarkhionAnchor`, santuário ampliado e montagem condicional do GLM. Incorporados em novo merge normal; conflito em Start resolvido pelo editor Codex, sem duplicar chamadas nem descartar a lógica condicional do parceiro.
- Start detecta Dragons.Varkhion, exige `Hub.VarkhionAnchor` quando o módulo existe, monta uma vez em `map` e liga conversa validada a `Hub.completeObjective(player, "santuario")`. false por objetivo já concluído é duplicata legítima; Ember/Profile continuam donos da vitória/selo. Modelo montado fica em `workspace.MythragonMap.Varkhion`.
- Registro Codex renumerado para `0005-varkhion-interacao.md`, preservando o `0004-aetheria-fase-1.md` do parceiro e seu índice. Respostas/revisão detalhada: GLM-R001/002/003 em CODEX.md.
- Verificações locais da árvore combinada (Windows, Luau 0.744 / Rojo 7.6.1): **PASS** na compilação de 13 fontes, nas três specs puras (Ember/Profile/InteractionState) e no build `mythragon-aetheria-varkhion.rbxlx` em pasta temporária fora do Git.
- Comparações automatizadas repetidas após incorporar `2e72b54`: **PASS**, Ember completo (inclui plataforma), Profile, Rojo e workflows idênticos à main; Hub e registros do GLM idênticos a `2e72b54`. Em Start foi conciliada a ligação única e o comentário de editor, preservando a guarda do GLM.
- Auditoria estática de membros `Enum.Material.*` contra a lista oficial: **FAIL**, um membro inválido: `DarkWood`, `src/server/Hub/Map.luau:101`. Este resultado é separado de compilação/specs/build e continua bloqueando aceite mesmo com CI verde.
- CI da árvore combinada `18ddc901391135d2fe9f4ade5b602b3cf4483fcd`: [43796258306](https://github.com/walker-ferreira/MYTHRAGON/actions/runs/43796258306), **PASS** (sintaxe/build). Também conferida a CI GLM `2e72b54`: [43795441191](https://github.com/walker-ferreira/MYTHRAGON/actions/runs/43795441191), PASS. O próximo commit só atualiza estes registros; o check do HEAD documental deve ser conferido no PR.
- Inspeção XML do build local combinado: **PASS**, 13 fontes, apenas um script autoexecutável Start, uma chamada de montagem e referências ao anchor/objetivo atuais. **Bloqueado**, `DarkWood` ainda presente no Source do Hub. Não é teste de execução ou comprovação de jogabilidade.

### Bloqueios encontrados por revisão, não por teste jogável

1. **Inicialização:** `Hub/Map.luau:createTree` usa `Enum.Material.DarkWood`. A [lista oficial](https://create.roblox.com/docs/reference/engine/enums/Material) não contém esse membro; deve ser Wood/WoodPlanks. O Hub tenta criar a árvore antes de criar VarkhionAnchor/terminar Hub.build. Isso impede o percurso antes de a ligação de Varkhion poder executar. Sintaxe e build não validam Enum.
2. **Mobile:** painéis de largura fixa (250 + 230 + margens) no mesmo Y se sobrepõem; em largura 320, os intervalos X=[16,266] e [74,304] se cruzam em 192 px. Resultado de cálculo do layout, **não observação em emulador/cliente**. GLM precisa ajustar responsividade/textos antes do aceite mobile.
3. **Santuário — atualizado:** a colisão de geometria apontada em `47501c1` foi afastada no código de `db6da8f` (colunas raio 20, dais Ø48, deck 66×60, nova âncora). Inspeção visual de asas/cauda/pés continua pendente, inclusive 0,2 stud entre centro da âncora e topo do dais. Não manter o achado antigo como defeito ainda não corrigido, nem confundir correção estática com teste no cliente.

Correções de Hub foram solicitadas ao seu editor, GLM, com caminho, mudança esperada e critério de teste. Nenhuma correção silenciosa, override em runtime ou mudança de autoria foi feita. Não confundir revisão solicitando mudanças com aprovação cruzada.

## Spec de motor disponível, ainda não executado

`src/server/Dragons/Varkhion.engine.spec.luau` é um ModuleScript sem autoexecução, sem jogador simulado ou concessão. No **servidor do Studio durante Play**, executar pela Command Bar:

```luau
require(game.ServerScriptService.Mythragon.Dragons["Varkhion.engine.spec"])()
```

Cria e limpa um fixture temporário afastado do mapa. Verifica montagem única, âncora girada, limite de geometria, identidade visual estrutural, partes inertes, prompt, destruição explícita/recriação e ausência de scripts dentro do modelo. Saída esperada: `Varkhion engine geometry/lifecycle: PASS`. **Estado real: não executado**; não substitui o percurso jogável nem valida a aparência visual.

## Cliente Roblox / Studio

**Nenhum caso abaixo foi executado jogando nesta rodada.** Há Studio instalado, mas esta sessão não dispõe de ferramenta de controle/observação interativa do cliente. O PR #7 agora fornece o santuário e a ligação de Start foi implementada pelo Codex autorizado; entretanto, o erro de material impede a inicialização normal do Hub e há correções de layout/encaixe pendentes. Não iniciar publicação nem declarar o percurso aprovado a partir de leitura, specs puras ou build.

| Caso exigido | Evidência necessária | Estado |
| --- | --- | --- |
| Aetheria → Varkhion | Spawn seguro, santuário acessível, silhueta/escamas/olhos/chifres/asas/marcas legíveis | Ligação atualizada pronta; bloqueado: material GLM-R002 A; encaixe C pendente no cliente |
| Primeira interação, teclado | E abre resposta individual e atualiza objetivo uma única vez | Implementada/ligada; execução no cliente pendente |
| Primeira interação, toque | Prompt acionável; diálogo legível sem encobrir controles | Pendente: mobile |
| Repetição / respawn | Diálogo repete; objetivo não duplica e persiste durante a sessão | Pendente |
| Dois jogadores | A interage sem concluir objetivo de B; ambos recebem diálogo próprio | Pendente |
| Varkhion → Ember → vitória → retorno | Portal reconhecível; cinco ataques válidos; selo individual só após vitória; objetivo correto ao retornar | Pendente |
| Segunda vitória | Nenhuma segunda concessão de selo | Pendente |
| Derrota e tentativa seguinte | Considerar ForceField inicial; respawn seguro, arena liberada, retry pode vencer | Pendente |
| Saída antecipada | Portal roxo devolve ao hub, sem selo antes de vencer; nova entrada permitida | Pendente |
| Desconexão e reset | Desconectar participante libera arena; callback/diálogo Varkhion limpos; outro jogador pode entrar | Pendente |
| Auto-retorno pós-vitória | Volta em 30–32 s; afastamento/queda resgatam; sem dano após vitória | Pendente |
| Plataforma 12 studs | Sobe/desce e carrega personagem, sem alteração da revisão aprovada pelo dono | Pendente: regressão no cliente |
| Selo com dois jogadores | A vence e vê seu selo; B permanece bloqueado; repetir após respawn | Pendente |
| Ciclo de vida Varkhion | Montagem repetida não duplica; destruir anchor/modelo/parent desconecta e permite recriar | Pendente: motor |

## Revisão cruzada e publicação

- Revisão GLM da entrega Codex: solicitada, pendente (VX-003).
- Atualização `2e72b54`: GLM registrou revisão de contrato/docs/CI **parcial**, com bloqueio de permissão para ler fontes do PR #6. Falta concluir a revisão de código após liberar esse acesso; não registrar como aprovação.
- Revisão Codex da entrega GLM: PR #7 revisado em `47501c1`, **correções solicitadas**, GLM-R002 em CODEX.md. Não substituir por aprovação dos PRs antigos #2/#3.
- **Não publicar esta fase** enquanto qualquer caso obrigatório, revisão cruzada ou CI ficar pendente.
- Alvo único futuro: Universe `10777026486`, Place `135004978091658`.
- Execução de publicação desta fase: **nenhuma**. Commit/artefato/revisão desta fase: não publicados. Workflow anterior [43786254524](https://github.com/walker-ferreira/MYTHRAGON/actions/runs/43786254524) é histórico da base, sem revisão numérica informada no resumo; não serve como evidência desta entrega.
- Bloqueio futuro de observabilidade: confirmar revisão real na resposta Roblox. O workflow existente grava somente campos de revisão conhecidos no resumo; se vier “não informada”, registrar bloqueio, sem inventar número ou repetir upload para descobri-lo.
