# Releases de staging

O CI é **PREVIEW**, nunca publicação. `PUBLISH staging experimental` dispara somente
de CI aprovado por push na main e seleciona automaticamente esse build.
Um job skipped por CI falho/branch não é release. Não existe input `publish=false`.

Cada execução preserva manifesto, artefato, tests.json, recibo, intenção de upload,
operação e inspeções disponíveis como `staging-evidence-<run>-<attempt>` (90 dias).
O histórico GitHub Deployments registra SHA/hash/build antes do envio, bloqueando
novo upload do mesmo SHA se o runner morrer. Revisão só é aceita com destino exato,
`isPublished=true` e `revisionId` numérico. Falha/timeout não dispara novo PATCH.

Recuperação automática de rerun: recuperar recibo do artefato da execução anterior,
conferir SHA/build/hash/Place/deployment e retomar **somente GET** da operação.
Sem recibo/operação recuperável: bloquear, baixar evidências e investigar, sem PATCH.
Se upload foi rejeitado definitivamente, corrigir e produzir novo SHA/build; se
aceito, não reenviar. Falha engine após publicação é release publicada **com falha**,
não release não publicada. Corrigir por PR e publicar novo candidato.

Inspeção Open Cloud compara os Sources persistidos da revisão e executa Bootstrap
explicitamente em instância isolada. Não inicia scripts automaticamente nem simula
física/jogadores; **não** equivale a RUNTIME_OK/PLAYTEST_OK em servidor normal.
Sem permissão Luau Execution, registrar PENDING_ACCESS e entregar experimental,
nunca PASS fictício. Produção não é destino suportado por estes scripts.
Somente 401/403 são falta de acesso; 404/COMPLETE com error/retorno inválido falham
a verificação. Deployment success só é emitido após a tentativa de inspeção e sua
descrição distingue engine PASS de PENDING_ACCESS. Publicação confirmada permanece
no recibo mesmo se uma inspeção posterior falhar.

Rollback preferido: PR revertendo apenas a alteração problemática, checks, merge e
nova publicação de staging. Preservar recibo anterior e vincular ambos os SHAs.
Não restaurar Place inteiro a partir de trabalho local não integrado.

## Roteiro curto para o proprietário

1. Entrar em servidor novo: https://www.roblox.com/games/135004978091658
2. Conferir SHA/revisão e READY na faixa STAGING EXPERIMENTAL.
3. Portal Latúnia em (24,4.5,8); visitar Vila, Deserto e Vulcânica e voltar.
4. Gelo/Selva ainda são desembarques provisórios.
5. Conferir Ember, selo único, retorno, Varkhion; informar erro e versão exibida.
