# Fila oficial — MYTHRAGON

Campos obrigatórios por tarefa: ID, objetivo, responsável, base completa, branch,
caminhos, dependências, aceite, estado, próximo checkpoint e evidências.
Claim por branch/PR, nunca dois escritores no mesmo worktree.
Estados de trabalho: AVAILABLE, ASSIGNED, IMPLEMENTING, REVIEW, BLOCKED, INTEGRATED,
AWAITING_OWNER. Estados de certificação são separados (AGENTS.md).

## REC-001 — recuperar autonomia e releases

- Responsável: CODEX/integrador GPT-6.1 Sol.
- Base: 9c6c0009f41293bf40bb8fbaf581765862a81096.
- Branch/worktree: codex/recovery-autonomy / MYTHRAGON-recovery.
- Caminhos: AGENTS.md, ARCHITECTURE.md, .github/, tools/, tests/,
  docs/engineering/, docs/releases/, docs/agents/CODEX.md e esta fila,
  src/server/Start.server.luau, src/server/Diagnostics/, identidade gerada de build.
- Dependências: GitHub autenticado; secret Roblox existente; acesso Luau Execution
  ainda precisa ser testado; não presume executor externo GLM/Codex instalado.
- Aceite: sem publicação fantasma, build/SHA/destino/revisão rastreáveis,
  testes disponíveis executados, saúde do mundo e pendências verdadeiras.
- Estado: IMPLEMENTING. OPS-002 resolvido; #12 integrado com CI nova PASS em
  main c669613. Primeiro publish automático falhou antes de PATCH (REL-004).
  F motor pendente; G sem nova publicação; H planejado.
- Próximo checkpoint: corrigir/revisar journal do environment, PR/CI e novo
  candidato oficial; conferir revisão e inspeção de motor disponível.
- Evidência: docs/engineering/AUDIT-2026-11-16.md.

## LAT-GLM-001 — Gelo/Selva e revisão independente da recuperação

- Responsável: GLM. Revisão REC-001 recebida pela sessão real
  `ses_e194c8a04ffemstop4QUSgtZTG`; correções enviadas à segunda revisão.
  Segunda revisão recebida sem bloqueante fail-open; engine/playtest não aprovados.
  Conteúdo Gelo/Selva **não atribuído a um executor nesta sessão**. Estado: REVIEW
  para recuperação; AVAILABLE para conteúdo futuro.
- Base/branch: selecionar main atual ao claim, registrar SHA completo no PR.
- Caminhos: módulos próprios Gelo/Selva em src/server/Hub/ ou caminho acordado;
  docs/agents/GLM.md e testes próprios; revisão somente leitura de REC-001.
- Dependências: contrato L3D-001 e pipeline recuperado. Não editar Start/workflows.
- Aceite: geometria/piso/chegadas seguros, sem recompensas não autorizadas,
  contrato partnerBuilders, tests/evidências de engine e cliente separados.
- Próximo checkpoint: confirmar recebimento e escopo; não iniciar conteúdo em paralelo
  no worktree do integrador.
