# Checkpoints de recuperação

## 2026-11-16 — REC-001

- A: auditoria concluída na base 9c6c0009f; evidências e plano em AUDIT-2026-11-16.md.
- B: contrato permanente escrito; worktree isolado; Git fetch e gh autenticados.
- C: fila criada; executor do parceiro ainda não comprovado.
- D/E/F/G: em aberto; não confundir plano com implementação ou publicação.
- H: conteúdo aguardando recuperação.

## Implementação e validação local (mesma sessão)

- B: AGENTS permanente e worktree exclusivo concluídos. GitHub autenticação real;
  proteção main, auto-merge e staging main-only aplicados/conferidos por API.
  Bloqueio residual: escopo OAuth `workflow` ausente.
- C: fila + lease transacional SQLite entre worktrees, histórico e tokens de
  retomada. Dez testes Python incluindo bloqueios de concorrência/publicação.
  GLM real iniciado por sessão-filha de revisão read-only; sem executor desktop
  público documentado, não alegar daemon 24/7 ou persistência após encerrar harness.
- D: implementado localmente: sintaxe, quatro specs CLI, contratos/negativos,
  registry de assets, LSP Roblox cinco políticas/Enums + negativo de tipos,
  identidade, manifesto, SHA-256, duas compilações idênticas e comparação Sources.
  PASS local; CI nova ainda não enviada. CI remota antiga 43980823371 PASS,
  explicitamente não equivalente aos testes ampliados.
- E: implementado localmente workflow_run/artefato automático, preview separado,
  serialização, origem/SHA/destino, fence de duplicação, operação/revisão/recibo.
  NÃO instalado em main; push de workflow bloqueado (OPS-002).
- F: Bootstrap/Health por etapas + UI staging e probe de geometria/chegadas
  implementados. Não houve execução no motor; PENDING.
- G: BLOCKED por OAuth; nenhum novo candidato publicado. Não confundir artefato
  local com release. H aguarda recuperação, Gelo/Selva continuam provisórios.

Auditoria: commit 1dbb283. Código remoto inicial: 9b7f9d2 (PR #12).
Workflow local inicial: 048195a. Backup integral inicial: codex/recovery-full-backup-52ff492.
Recibos remotos de progresso: issue #13. Revisões finais do código podem mudar
esses SHAs, sem invalidar a natureza limitada das evidências registradas.

## Revisão GLM e autocorreção (mesma sessão)

Revisão independente real recebida de GLM 5.3 Flash, sessão
`ses_e194c8a04ffemstop4QUSgtZTG`. Confirmou parser/gates/honestidade da evidência,
mas NÃO aprovou instalação/release/runtime. Achados corrigidos localmente:

- Deployment success passa a ocorrer só depois da tentativa de verificação,
  distinguindo candidato experimental sem acesso de bootstrap engine aprovado.
- Rerun recupera recibo pelo artefato anterior e retoma GET da operação sem PATCH;
  identidade diferente ou operação irrecuperável bloqueia, nunca duplica envio.
- 404 não vira PENDING_ACCESS; COMPLETE com erro/resultado inválido falha;
  identidade Universe/Place/revisão e quantidade de scripts conferidas.
- Conexão de perfil rastreada para cleanup do Core; specs embarcados declarados
  como ModuleScripts inertes e engine/cliente continuam pendentes.
- Treze testes Python PASS (inclui retomada com API simulada, não publicação real).

Segunda revisão GLM recebida: nenhum bloqueante fail-open no diff; ALTA 1–4
fechados por inspeção independente. Observações adicionais tratadas: falha na
retomada atualiza deployment; teste mockado cobre recuperação feliz do recibo;
PENDING_ACCESS não acumula duplicatas idênticas. Dezoito testes Python PASS,
incluindo COMPLETE com error, Universe incorreto, 403 vs 404 e isolamento de
runtime normal. Esses testes são mocks, não execução Roblox.

Condição de
merge explícita: código e workflows completos juntos, CI nova aprovada. Não
integrar PR #12 parcial nem acionar publisher antigo para contornar OPS-002.

## Retomada após autenticação — publicação real em recuperação

- Proprietário concluiu refresh; scope workflow conferido e push b3f6888 aceito.
- CI ampliada de PR 43983522637 PASS, todas etapas novas executadas.
- PR #12 integrado sem bypass, main c66961397f30bb684f939421642dfc27c7a5848f.
- CI oficial main 43983671970 PASS. Artefato baixado e manifesto validado
  independentemente; SHA-256 rbxlx:
  cf02566f287132ea7ce1bdc3611e656ba2422b971b41fb4b629c620936a29ad2.
- PUBLISH workflow_run 43983719759 disparou automaticamente, mas falhou
  corretamente antes de PATCH: environment job criou deployment vazio e ele foi
  confundido com journal de upload (REL-004). Sem upload-intent/response/receipt.
- Fix mínimo e regressão em codex/fix-staging-journal, base main c669613;
  19 testes Python PASS local. Nova revisão GLM solicitada. Não republicar build
  anterior por caminho manual; integrar correção e deixar pipeline oficial agir.

## Primeira publicação rastreável e falha real de inspeção

- PR #14 revisado pelo GLM sem bloqueantes e CI 43984167625 PASS; integrado em
  f0ebd49bfd56f65c482cfad81246cb91bef1f5bc.
- CI main 43984307864 PASS; PUBLISH automático 43984354467 enviou uma vez,
  Roblox confirmou revisionId 13, destino autorizado, isPublished true.
- Operação 470fdc76-0aeb-482d-8753-83d396c19267; recibo completo e resposta
  preservados no artefato staging-evidence-43984354467-1.
- Luau Execution real disponível: revisão 13 e 24 Sources conferidos. PERSISTED_OK.
- Bootstrap explícito no motor isolado falhou (WORLD-002), portanto workflow
  FAILED e release NÃO saudável. Nenhuma prova de servidor normal/cliente.
- Diagnóstico precisa dos logs estruturados da tarefa existente. Inspeção separada
  sem upload evita republicação da mesma falha; docs/inspeção não geram release
  de conteúdo, mas continuam sob CI no PR. Recuperação em andamento.

## Causa real recuperada sem upload duplicado

- PR #16, CI 43985546889 PASS e revisão GLM (B1/B2 corrigidos) integrado em
  c5d4777. Somente tooling/docs não criou novo build/publicação de conteúdo.
- INSPECT 43985660493 SUCCESS: logs da tarefa da revisão 13 recuperados por GET,
  sem repetir tarefa/upload. Arquivo engine-logs.json preservado no artefato.
- Core READY e Latunia READY; Varkhion FAILED:
  `Module code did not return exactly one value` em Varkhion.luau linha 3.
- Fonte VarkhionModel não retornava Model após definir build. Causa comprovada;
  não remover componente obrigatório nem inventar limitação da API.
- Fix mínimo na branch codex/fix-engine-bootstrap, base main c5d4777:
  return Model e gate positivo/negativo de exportação CLI com Color3 stubado
  (não testa geometria). 22 testes Python + quatro specs + export gate PASS local.
- Contribuição GLM externa detectada/preservada em PR #15; feedback técnico
  enviado via comentário, sem presumir recebimento nem integrar código conflitante.

O commit que contém cada registro é consultável por `git log -- <arquivo>`;
não inserir SHA autorreferencial fictício. Resultados posteriores entram abaixo.
