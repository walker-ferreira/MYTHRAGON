# 0004 — Aetheria na Fase 1: ala oeste, objetivos e ponto de montagem do Varkhion

**Estado:** implementado no servidor (sessão). Teste jogável no cliente pendente. Contrato de interação do Varkhion proposto ao Codex (GLM-R001), aguardando resposta.

Responsáveis nesta rodada: GLM 5.3 (`src/server/Hub/Map.luau`, comentário de rodada em `src/server/Start.server.luau`, `docs/agents/GLM.md`, `docs/testing/`, este registro e a linha do índice de decisões). Codex: `src/server/Ember/`, módulo do Varkhion e `docs/agents/CODEX.md`.

## Contexto

A Fase 1 (primeira aventura) pede que o hub existente evolua para Aetheria: nascimento seguro, trajeto claro, vegetação, ruínas, cristais, santuário de Varkhion, Guardiões do Éter e um objetivo curto que leve o jogador ao dragão e depois ao portal de Ember — preservando a validação do portal no servidor, o selo único por jogador e o painel individual.

## Decisões

1. **Expansão sem reescrita.** Aetheria é uma ala oeste nova (deck de 58×56 em x −91..−33) encostada no deck atual, reutilizando os helpers de `Part` existentes. Spawn, plaza de selos, portal rúnico e validação de travessia ficam intocados. Paleta do GDD: roxo profundo, azul etéreo, dourado ancestral e obsidiana.
2. **Objetivos iniciais no servidor.** Painel "Guardião do Éter · objetivos" por jogador (PlayerGui, `ResetOnSpawn=false`), com três passos: reunir-se com os Guardiões do Éter (qualquer das três estátuas), alcançar o santuário de Varkhion e entrar no portal de Ember. Conclusão via `ProximityPrompt` disparado no servidor ou via `Hub.completeObjective(player, id)`; nada é concluído por dado do cliente. Estado é de sessão (sem persistência nesta fase).
3. **Ponto de montagem do Varkhion.** `workspace.MythragonMap.Hub.VarkhionMount`: Part invisível, ancorada, sem colisão, no centro do dais do santuário, orientada para leste (em direção ao portal). O Codex monta o modelo nesse ponto; a montagem acontece uma vez em `Start`/módulo do Codex. Proposta de interação: prompt validado no servidor pelo módulo do Codex, que chama `Hub.completeObjective(player, "santuario")` ao validar a conversa (idempotente).
4. **Direção 3D.** Builds procedurais próprios. Referências de colunata basáltica, arena de fantasia e ruínas já auditadas pelo Codex em [0002](0002-combate-ember.md) foram reutilizadas apenas como direção visual, sem importar assets. Nenhum asset externo foi importado nesta rodada, portanto não há licença a registrar; o procedimento (confirmar licença, inspecionar scripts incluídos, adaptar materiais, registrar fonte e ID) permanece obrigatório para qualquer importação futura.

## Consequências

- O objetivo do santuário é concluído pela observação da pedra rúnica enquanto o módulo do Varkhion não existe; quando o Codex integrar a interação, a mesma chamada `Hub.completeObjective(player, "santuario")` serve aos dois caminhos (idempotente).
- Estado de objetivos é de sessão; a Fase 2 decide se entra no schema persistido.
- Novos nomes de instâncias (`AetheriaWestDeck`, `AetherGuardianN`, `Sanctuary*`, `VarkhionMount`, `ObjectivePanel`) ficam reservados para testes e integração.

## Como verificar

1. CI do PR: sintaxe Luau e build Rojo.
2. Studio/cliente: nascer seguro; objetivos no painel; observar um Guardião; observar a pedra do santuário; entrar no portal; conferir que os três passos marcam individualmente e que um segundo jogador tem painel próprio vazio.
3. Casos jogáveis e pendências em [docs/testing/fase-1-glm.md](../testing/fase-1-glm.md).
