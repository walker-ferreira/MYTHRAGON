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

O commit que contém cada registro é consultável por `git log -- <arquivo>`;
não inserir SHA autorreferencial fictício. Resultados posteriores entram abaixo.
