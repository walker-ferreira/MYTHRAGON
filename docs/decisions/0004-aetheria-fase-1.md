# 0004 — Aetheria na Fase 1: ala oeste, objetivos e ponto de montagem do Varkhion

**Estado:** implementado no servidor (sessão). Teste jogável no cliente pendente. Contrato de interação do Varkhion proposto ao Codex (GLM-R001), aguardando resposta.

Responsáveis nesta rodada: GLM 5.3 (`src/server/Hub/Map.luau`, comentário de rodada em `src/server/Start.server.luau`, `docs/agents/GLM.md`, `docs/testing/`, este registro e a linha do índice de decisões). Codex: `src/server/Ember/`, módulo do Varkhion e `docs/agents/CODEX.md`.

## Contexto

A Fase 1 (primeira aventura) pede que o hub existente evolua para Aetheria: nascimento seguro, trajeto claro, vegetação, ruínas, cristais, santuário de Varkhion, Guardiões do Éter e um objetivo curto que leve o jogador ao dragão e depois ao portal de Ember — preservando a validação do portal no servidor, o selo único por jogador e o painel individual.

## Decisões

1. **Expansão sem reescrita.** Aetheria é uma ala oeste nova (deck de 66×60 em x −99..−33) encostada no deck atual, reutilizando os helpers de `Part` existentes. Spawn, plaza de selos, portal rúnico e validação de travessia ficam intocados. Paleta do GDD: roxo profundo, azul etéreo, dourado ancestral e obsidiana.
2. **Objetivos iniciais no servidor.** Painel "Guardião do Éter · objetivos" por jogador (PlayerGui, `ResetOnSpawn=false`), com três passos: reunir-se com os Guardiões do Éter (qualquer das três estátuas), alcançar o santuário de Varkhion e entrar no portal de Ember. Conclusão via `ProximityPrompt` disparado no servidor ou via `Hub.completeObjective(player, id)`; nada é concluído por dado do cliente. Estado é de sessão (sem persistência nesta fase).
3. **Âncora do Varkhion (contrato VX-001 do Codex, aceito).** `workspace.MythragonMap.Hub.VarkhionAnchor`: Part ancorada, invisível, sem colisão, 36×0,4×34, centro no piso do dais (y≈1,4), frente (−Z) para leste. Folga garantida: dais Ø48, degraus Ø54, pilares a raio 20, feixe de luz fora da área da âncora. A montagem é feita uma vez em `Start.server.luau` (editor único: GLM, acordado com o Codex) via `Varkhion.mount(map, anchor, callback)`, com detecção segura da pasta `Dragons`: sem o módulo (PR #6 não mesclado), o hub segue funcional e o `Start` registra `warn`.
4. **Interação do Varkhion (contrato VX-002 do Codex, aceito).** O callback do servidor do Codex chama `Hub.completeObjective(player, "santuario")` — síncrono, sem yield e idempotente; nenhum selo/posse vem da conversa. A pedra rúnica da entrada mantém a rota de fallback (observar) enquanto o módulo não está integrado.
5. **Direção 3D.** Builds procedurais próprios. Referências de colunata basáltica, arena de fantasia e ruínas já auditadas pelo Codex em [0002](0002-combate-ember.md) foram reutilizadas apenas como direção visual, sem importar assets; as referências de dragões do PR #6 (Sketchfab, CC BY4 conferido na página / licença não confirmada) também não foram reutilizadas. Nenhum asset externo foi importado nesta rodada, portanto não há licença a registrar; o procedimento (confirmar licença, inspecionar scripts incluídos, adaptar materiais, registrar fonte e ID) permanece obrigatório para qualquer importação futura.

## Consequências

- O objetivo do santuário é concluído pela conversa validada com o Varkhion (callback em `Start`) ou, em fallback, pela observação da pedra rúnica da entrada; ambos idempotentes.
- Estado de objetivos é de sessão; a Fase 2 decide se entra no schema persistido.
- Colisão de numeração de decisões entre os PRs #6 e #7 (dois `0004-*.md`): proposta GLM-D004 — Aetheria mantém 0004 e o registro do Varkhion vira 0005 na integração do PR #6.
- Novos nomes de instâncias (`AetheriaWestDeck`, `AetherGuardianN`, `Sanctuary*`, `VarkhionAnchor`, `ObjectivePanel`) ficam reservados para testes e integração.

## Como verificar

1. CI do PR: sintaxe Luau e build Rojo.
2. Studio/cliente: nascer seguro; objetivos no painel; observar um Guardião; conversar com o Varkhion (ou observar a pedra da entrada, em fallback); entrar no portal; conferir que os três passos marcam individualmente e que um segundo jogador tem painel próprio vazio.
3. Casos jogáveis e pendências em [docs/testing/fase-1-glm.md](../testing/fase-1-glm.md).
