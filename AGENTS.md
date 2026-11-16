# MYTHRAGON — contrato operacional dos agentes

## Autorização permanente

O proprietário autorizou desenvolvimento, edição, dependências confiáveis, testes,
branches/worktrees, commits, push, PRs, revisão, integração tecnicamente validada e
publicação automática **somente em staging**. Não pedir confirmação para repetir
essas operações dentro de uma tarefa atribuída. Esta política substitui exigências
antigas de aprovação por arquivo/commit/publicação nos registros históricos.
Não amplia permissões reais do aplicativo, sandbox, Windows ou credenciais.
Nunca expor segredos, descartar trabalho alheio, burlar controles ou publicar em
produção sem aprovação específica. Risco destrutivo exige intervenção consolidada.

## Responsabilidades permanentes

- **CODEX / integrador técnico (nesta sessão GPT-6.1 Sol):** arquitetura, sistemas,
  integração, contratos, revisão, testes, ferramentas, CI/CD, releases e diagnóstico.
  Editor de `Start.server.luau`, `default.project.json`, `rokit.toml`, workflows e
  documentação de engenharia. Desenvolve também conteúdo e gameplay atribuídos.
- **GLM:** mapas, assets, Hub, interfaces, perfil e sistemas/gameplay atribuídos;
  testes das entregas e revisão cruzada. Não limitado ao trabalho visual.
- Cada agente mantém seu registro em `docs/agents/`. Fila oficial:
  `docs/agents/TASK_QUEUE.md`. Não modificar o registro pessoal do parceiro.
- Contribuições GLM chegam por branch/PR; somente o pipeline oficial publica o
  Place compartilhado. Não iniciar publicações concorrentes por outro caminho.

## Antes e durante cada tarefa

1. Ler GDD, arquitetura, decisões, ambos os registros e fila/memória de engenharia.
2. Executar `git status`, `git fetch origin`, verificar branch e SHA de base.
3. Usar worktree/clone exclusivo; nunca dois escritores no mesmo diretório.
   Preservar alterações locais. Não fazer force-push destrutivo.
4. Registrar ID, responsável, base, branch, caminhos, dependências, aceite, estado e
   próximo checkpoint. Informar os caminhos ao iniciar; o integrador resolve
   sobreposição técnica por contrato, sem exigir arbitragem rotineira do dono.
5. Um Markdown atualizado não prova que outro executor recebeu a tarefa.
   Registrar PR/issue e confirmação de recebimento quando houver.
6. Não executar subagentes sem atribuição explícita. Não simular revisão independente.

## Qualidade e publicação

- Servidor é autoridade de combate, viagem, vitória e concessão idempotente de selos.
  Preservar contratos Ember → Profile → Hub e montagem de Varkhion/Latúnia.
- Main integrada é fonte oficial; local, push, merge, build, publicação, persistência
  e runtime são fatos distintos, cada um com sua evidência.
- Staging autorizado: Universe **10777026486**, Place **135004978091658**.
  Confirmar associação via API antes de cada publicação.
- Staging experimental pode ser publicado após integração e checks técnicos
  obrigatórios, com cliente/visual pendentes declarados. Falha conhecida que impede
  inicialização principal bloqueia candidato normal. Produção exige destino
  separado, aceite do proprietário, evidências e rollback.
- Estados: PLANNED → IMPLEMENTING → REVIEW → BUILD_OK → PREVIEW_OK → PUBLISHED.
  PERSISTED_OK, RUNTIME_OK, PLAYTEST_OK e PRODUCTION_APPROVED exigem evidências
  próprias; skipped nunca significa PASS. Motor isolado não prova física/cliente.

## Recuperação e entrega

Ler erro/log completo, conferir versões/caminhos/permissões, consultar documentação
oficial e operações anteriores, aplicar correção mínima, repetir com estratégia
justificada, validar e registrar em `docs/engineering/RECOVERY_PLAYBOOK.md`.
Publicação ambígua: consultar a operação anterior **antes** de reenviar.
Não repetir indefinidamente nem esconder erro.

Ao fechar checkpoint: registrar commit, testes realmente executados, links de
evidência, limitações e próxima ação. Continuar a missão autorizada enquanto houver
capacidade. Pedir ajuda só para acesso humano inevitável, decisão de escopo/design,
risco destrutivo, avaliação indisponível ou produção; consolidar bloqueios numa mensagem.
