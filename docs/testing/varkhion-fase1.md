# Fase 1 — Varkhion: evidências e bloqueios

**Editor:** Codex. **Base:** `fd188854a8bf9176a636b1c9ec71167c82dfbd72`.
**Branch:** `codex/varkhion-fase1`. O SHA da implementação e links de CI devem ser registrados no PR; não confundir a base com o candidato de teste.

## Automação local

Ambiente: Windows, CLI Luau 0.744 e Rojo 7.6.1. Resultados executados nesta rodada:

| Verificação | Comando / critério | Resultado |
| --- | --- | --- |
| Sintaxe | `luau-compile --null` em todos os `.luau` de `src` | PASS: 12 fontes |
| Combate existente | `luau src/server/Ember/EncounterState.spec.luau` | PASS: `Ember rules: PASS` |
| Perfil existente | `luau src/server/Profile/Profile.spec.luau` | PASS: `Profile rules: PASS` |
| Interação Varkhion | `luau src/server/Dragons/InteractionState.spec.luau` | PASS: `Varkhion interaction rules: PASS` |
| Build | `rojo build default.project.json -o mythragon-varkhion.rbxlx` | PASS: saída em pasta temporária, fora do Git |
| Preservação | Comparar `src/server/Ember/` inteiro e Hub/Profile/Start com `fd18885`; nenhuma alteração pretendida | PASS: `git diff fd18885 --exit-code -- ...` sem diferenças; inclui plataforma inteira |

## CI remota

Pendente de PR/execução. O workflow atual verifica sintaxe e build; **não executa as specs**. Não contar os testes locais como CI nem build como validação de cliente.

## Cliente Roblox / Studio

**Nenhum caso abaixo foi executado nesta rodada.** Há Studio instalado, mas esta sessão não dispõe de controle/observação interativa do cliente. Além disso, montagem e objetivo de Aetheria dependem do GLM (VX-001/VX-002), ainda sem resposta no registro consultado.

| Caso exigido | Evidência necessária | Estado |
| --- | --- | --- |
| Aetheria → Varkhion | Spawn seguro, santuário acessível, silhueta/escamas/olhos/chifres/asas/marcas legíveis | Bloqueado: santuário/Start do GLM |
| Primeira interação, teclado | E abre resposta individual e atualiza objetivo uma única vez | Pendente: cliente + integração |
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
- Revisão Codex da entrega GLM: sem PR de Aetheria identificado na leitura inicial; pendente, não substituir pela revisão dos PRs antigos #2/#3.
- **Não publicar esta fase** enquanto qualquer caso obrigatório, revisão cruzada ou CI ficar pendente.
- Alvo único futuro: Universe `10777026486`, Place `135004978091658`.
- Execução de publicação desta fase: **nenhuma**. Commit/artefato/revisão desta fase: não publicados. Workflow anterior [43786254524](https://github.com/walker-ferreira/MYTHRAGON/actions/runs/43786254524) é histórico da base, sem revisão numérica informada no resumo; não serve como evidência desta entrega.
- Bloqueio futuro de observabilidade: confirmar revisão real na resposta Roblox. O workflow existente grava somente campos de revisão conhecidos no resumo; se vier “não informada”, registrar bloqueio, sem inventar número ou repetir upload para descobri-lo.
