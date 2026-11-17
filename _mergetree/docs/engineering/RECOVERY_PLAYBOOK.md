# Recuperação operacional

## OPS-001 — CLI GitHub fora do PATH

- Sintoma: `Get-Command gh` não encontra; pasta AppData/Local/GitHub CLI não tem exe.
- Causa: instalação portátil de sessão anterior, não exposta no PATH.
- Correção verificada: executar
  `C:\Users\izael ferreira\AppData\Local\Temp\opencode\mythragon-tools\gh\bin\gh.exe`.
- Evidência: `gh auth status`, API repo, run view/log e lista de PRs funcionaram.
- Não reinstalar, pedir token ou imprimir credenciais. Não confundir cache com binário.

## Publicação ambígua

Consultar recibo/operação antes de novo PATCH. Timeout não significa rejeição.
Rerun novo recupera receipt.json pelo artefato da execução anterior, valida
SHA/build/hash/destino/deployment e retoma GET da operação. Sem recibo recuperável,
bloqueia para investigação técnica; não faz upload às cegas.
Não repetir upload automaticamente. Preservar artefato e hash; uma correção é novo
commit/build. Rollback é revert por PR da mudança de conteúdo, novos checks e nova
publicação serializada; nunca inventar que revisão antiga foi restaurada.

## Falha recorrente de motor

Compilação Luau não valida Enum.Material nem APIs. Consultar API dump oficial e
testar montagem no motor; conferir saúde por componente. Se engine não acessível,
registrar PENDING, não PASS e não esconder erro.

## OPS-002 — OAuth sem escopo workflow

- Erro real ao enviar o commit 52ff492: `refusing to allow an OAuth App to create
  or update workflow .github/workflows/ci.yml without workflow scope`.
- Autenticação existente possui repo/read:org/gist, mas não workflow.
- Não tentar Contents API, token extraído de outro app ou workflow alternativo para
  contornar a restrição. O acesso deve ser ampliado pelo fluxo oficial GitHub CLI.
- Ação mínima do proprietário: executar no PowerShell
  `& "$env:LOCALAPPDATA\Temp\opencode\mythragon-tools\gh\bin\gh.exe" auth refresh -h github.com -s workflow`
  e concluir a autorização GitHub no navegador. Não enviar token no chat.
- Depois: integrador confirma auth scopes, faz push, acompanha CI, resolve falhas,
  integra pelo PR e deixa staging automático selecionar o build.
- Commits locais preservados; registro remoto da auditoria não prova que o novo
  pipeline já esteja instalado no GitHub.

## REL-004 — deployment automático do environment confundido com journal

- Run real 43983719759, SHA c66961397f30bb684f939421642dfc27c7a5848f:
  falhou em `recover_receipt` com "Prior deployment has a different artifact/build".
- API mostrou deployment 7839851079, ref main, task deploy e payload vazio,
  criado pelo GitHub para iniciar o job com environment staging. Não era upload.
- Evidências do run contêm manifesto/artefato/target/tests, mas não upload-intent,
  upload-response, operação ou receipt. A falha ocorreu antes do PATCH.
- Correção: distinguir registros automáticos vazios de journals de publicação,
  que possuem marcador de schema e identidade build/hash. Journals desconhecidos
  continuam bloqueando; recibos reais continuam exigindo retomada sem PATCH.
- Teste de regressão: environment sozinho é ignorado; journal coexistente é
  preservado; payload desconhecido é rejeitado. Não apagar deployments para ocultar erro.