# Coordenação real e limites do executor

## Suporte comprovado nesta sessão

O harness oferece criação de sessões-filhas com modelo selecionado. A descoberta
retornou `opencode/glm-5.3-flash-free`; uma sessão GLM foi iniciada de fato para
revisão independente de REC-001, **somente leitura** no worktree do integrador.
Resultado e session ID devem ser registrados depois do retorno; chamada de início
não é revisão aprovada. Escrita paralela exige worktree próprio.

Esse mecanismo existe nesta sessão do harness; não é prova de que a interface
DeepAI Code do proprietário possua daemon/API pública equivalente. A documentação
oficial DeepAI (`https://deepai.org/docs`, seção Code, consultada 2026-11-16)
documenta pasta, modelo e modo de acesso (Plan somente exploração), mas não
documenta CLI headless, endpoint de iniciar sessões ou formato de permissões em
arquivo. Não inventar esses mecanismos nem alterar app.asar.

Codex CLI externo não encontrado; não confundir a identidade do integrador com
instalação/autenticação oficial Codex. Não instalar um executor paralelo que exija
login sem primeiro consolidar a necessidade real. O pipeline de staging independe
desse executor e funciona no GitHub.

## Lease persistente local

`python tools/coordinate.py claim --task REC-001 --owner CODEX --checkpoint B`
retorna token local (não é credencial externa). Guardar na sessão. `checkpoint` e
`submit` exigem o mesmo token/owner/worktree; `status` não expõe token.

SQLite em `git-common-dir/mythragon-coordination/leases.sqlite` permite transação
atômica entre worktrees, histórico e retomada após interrupção. Não expira claims
automaticamente: risco de dois processos vivos impede roubo automático de lease.
Nunca apagar banco para liberar tarefa sem verificar processo e evidências.

Fila/contratos no Git e issues/PRs são coordenação oficial entre máquinas.
O lease local não resolve execução distribuída nem dispara um modelo. O executor
do harness pode ler tarefa, claim, trabalhar, registrar checkpoint, submeter PR e
disparar revisão real; GitHub checks e pipeline assumem validação/publicação.
Nenhum polling em loop ou documentação é rotulado como agente autônomo.