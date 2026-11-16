# Fase 1 — Varkhion: evidências e bloqueios

**Editor:** Codex. **Base:** `fd188854a8bf9176a636b1c9ec71167c82dfbd72`.
**Branch:** `codex/varkhion-fase1`. O SHA da implementação e links de CI devem ser registrados no PR; não confundir a base com o candidato de teste.

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
- Start requer Dragons.Varkhion, encontra `Hub.VarkhionMount`, monta uma vez e liga conversa validada a `Hub.completeObjective(player, "santuario")`. false por objetivo já concluído é duplicata legítima; Ember/Profile continuam donos da vitória/selo.
- Registro Codex renumerado para `0005-varkhion-interacao.md`, preservando o `0004-aetheria-fase-1.md` do parceiro e seu índice. Respostas/revisão detalhada: GLM-R001/002/003 em CODEX.md.
- Verificações locais da árvore combinada (Windows, Luau 0.744 / Rojo 7.6.1): **PASS** na compilação de 13 fontes, nas três specs puras (Ember/Profile/InteractionState) e no build `mythragon-aetheria-varkhion.rbxlx` em pasta temporária fora do Git.
- Comparações automatizadas: **PASS**, Ember completo (inclui plataforma), Profile, Rojo e workflows idênticos à main; Hub e registros do GLM idênticos a `47501c1`. Start só ganhou a ligação autorizada e o comentário de editor.
- Auditoria estática de membros `Enum.Material.*` contra a lista oficial: **FAIL**, um membro inválido: `DarkWood`, `src/server/Hub/Map.luau:101`. Este resultado é separado de compilação/specs/build e continua bloqueando aceite mesmo com CI verde.
- CI da árvore combinada: conferir o novo HEAD do PR #6; links de resultado registrados no PR após execução. A CI anterior do GLM não valida automaticamente a nova ligação.

### Bloqueios encontrados por revisão, não por teste jogável

1. **Inicialização:** `Hub/Map.luau:createTree` usa `Enum.Material.DarkWood`. A [lista oficial](https://create.roblox.com/docs/reference/engine/enums/Material) não contém esse membro; deve ser Wood/WoodPlanks. O Hub tenta criar a árvore antes de criar VarkhionMount/terminar Hub.build. Isso impede o percurso antes de a ligação de Varkhion poder executar. Sintaxe e build não validam Enum.
2. **Mobile:** painéis de largura fixa (250 + 230 + margens) no mesmo Y se sobrepõem; em largura 320, os intervalos X=[16,266] e [74,304] se cruzam em 192 px. Resultado de cálculo do layout, **não observação em emulador/cliente**. GLM precisa ajustar responsividade/textos antes do aceite mobile.
3. **Santuário:** colunata de raio 9 intercepta a cauda natural; origem Y=1,8 não corresponde ao piso Y=1,2. Requer ajustar espaço/piso ou acordar escala com Codex; inspeção visual no motor ainda pendente.

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
| Aetheria → Varkhion | Spawn seguro, santuário acessível, silhueta/escamas/olhos/chifres/asas/marcas legíveis | Ligação pronta; bloqueado: correções GLM-R002 A/C |
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
- Revisão Codex da entrega GLM: PR #7 revisado em `47501c1`, **correções solicitadas**, GLM-R002 em CODEX.md. Não substituir por aprovação dos PRs antigos #2/#3.
- **Não publicar esta fase** enquanto qualquer caso obrigatório, revisão cruzada ou CI ficar pendente.
- Alvo único futuro: Universe `10777026486`, Place `135004978091658`.
- Execução de publicação desta fase: **nenhuma**. Commit/artefato/revisão desta fase: não publicados. Workflow anterior [43786254524](https://github.com/walker-ferreira/MYTHRAGON/actions/runs/43786254524) é histórico da base, sem revisão numérica informada no resumo; não serve como evidência desta entrega.
- Bloqueio futuro de observabilidade: confirmar revisão real na resposta Roblox. O workflow existente grava somente campos de revisão conhecidos no resumo; se vier “não informada”, registrar bloqueio, sem inventar número ou repetir upload para descobri-lo.
