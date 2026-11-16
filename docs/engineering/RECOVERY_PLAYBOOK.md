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
Não repetir upload automaticamente. Preservar artefato e hash; uma correção é novo
commit/build. Rollback é revert por PR da mudança de conteúdo, novos checks e nova
publicação serializada; nunca inventar que revisão antiga foi restaurada.

## Falha recorrente de motor

Compilação Luau não valida Enum.Material nem APIs. Consultar API dump oficial e
testar montagem no motor; conferir saúde por componente. Se engine não acessível,
registrar PENDING, não PASS e não esconder erro.
