# 0007 — Melhorias GLM nas ilhas de Latúnia (Gelo, Selva e Vila Central)

- **Status:** Proposta (LAT-GLM-001; aguarda revisão do Codex e QA do dono)
- **Data:** 2026-11-17
- **Decidido por:** GLM 5.3 (missão autorizada pelo dono: "tornar os cinco cenários
  visualmente completos, coerentes, exploráveis e otimizados")

## Contexto

Fase 1 tem cenários iniciais de Gelo/Selva (PR #21, `Expansion.luau` do Codex) e
a Vila Central GLM (PR #9/#15) com correção de coordenadas (PR #24). A fila
LAT-GLM-001 autoriza módulos próprios de Gelo/Selva em `src/server/Hub/`.

## Decisão

1. **Fonte única de geometria:** novo módulo puro `src/server/Hub/LatuniaIslandsData.luau`
   (sem APIs do Roblox) com caminhos, spots de NPC e marcos por ilha. O spec puro
   `LatuniaIslandsData.spec.luau` (rodado pela CI na luau VM) valida:
   (a) chegada conectada à rede base; (b) todo caminho novo alcança a chegada
   (tolerância 2 studs); (c) nada novo fora do disco (raio 145); (d) spots de NPC
   com margem livre dos caminhos; (e) Vila Central: tudo dentro dos limites do
   deck e spots nos três níveis (docas/deck/praça).
2. **Preservação garantida:** os módulos novos `LatuniaGelo.luau` e
   `LatuniaSelva.luau` executam primeiro o cenário base do Codex
   (`Expansion.ice` / `Expansion.jungle`, em `pcall` com aviso) e só depois
   adicionam camadas: nenhum trabalho existente é removido ou reconstruído.
3. **Gelo:** conector de acesso ao Observatório (fecha o vão Z -39..-4 do cenário
   base, com 4 degraus), Caverna de Cristal (sala fechada com cristais e luz fria),
   Lago Congelado (vidro caminhável com borda), Monolito Rúnico (marco),
   6 coníferas nevadas, Posto da Geleira (ponto de NPC preparado, sem instalar NPC),
   placas de direção, cristais de borda e braseiros de chama azul.
4. **Selva:** Cachoeira Esmeralda (paredão, cortina de vidro, poço raso caminhável,
   névoa leve), Mirante das Copas (clareira com pedra talhada e tochas), interior
   do templo (altar, braseiros verdes, arcos em ruína), Totem da Copa (marco),
   cipós pendurados nas copas existentes, barraca do Mercador das Vinhas (ponto de
   NPC preparado), tochas de trilha.
5. **Vila Central:** 3 ruas de pedra (dados na fonte única), Fonte da Praça
   (poço, água de vidro, jato iluminado), bancos e vasos, Mural de Avisos
   (preparo de missões), 2 barracas novas de mercado, Oficina 5 e Pensão,
   medalhões de latão nos 3 pontos de NPC (docas/deck/praça, sem instalar NPC),
   placas de orientação, 5 lampiões extras e bandeiras nas escadarias das docas.
6. **NPCs NÃO instalados:** só locais preparados com medalhão + aviso discreto
   ("chega em breve"). A biblioteca de 10 NPCs permanece desmontada (PR #23),
   conforme autorização pendente do dono.
7. **Integração:** o `Hub/Latunia.luau` passa a expor `Latunia.partnerBuilders`
   (`Central`/`Gelo`/`Selva`). Pedido GLM-R009: o Codex substitui no
   `Bootstrap.run()` a tabela literal `{ Central = Vila.build, Gelo = Expansion.ice,
   Selva = Expansion.jungle }` por `Vila.partnerBuilders` (uma linha, arquivo dele).
   Sem essa troca, os módulos novos ficam integrados mas inativos.
8. **Deserto/Vulcânica (GLM-R010):** melhorias ficam registradas como propostas
   para o Codex (arquivos dele) — fluxo contínuo de lava ligando caldeira ao mar,
   interior navegável da mina, fumaça de refinaria com material registrado,
   guarda-corpos de pontes e placas nos desvios.
11. **Interface de comandos (GLM-R011):** Terminais de Viagem físicos (pads de
    latão com ClickDetector, rótulo flutuante, cooldown 1,5 s validado no
    servidor) no hub, na praça da Vila Central e na chegada de cada ilha —
    rotas idênticas às do `Layout.canTravel`. Sem client scripts; pedido de
    accessor `Map.controller` ao Codex para integrar ao estado oficial.
9. **Ambientação global:** nenhuma alteração em `Lighting` (compartilhado com a
   Aetheria) nesta rodada — proposta separada ao Codex para avaliar atmosfera por
   ilha. Iluminação nova é local (PointLights/Neon já usados no padrão do jogo).
10. **Assets:** nenhum asset externo novo; única referência nativa reutilizada é
    `rbxasset://textures/particles/sparkles_main.dds`, já registrada em
    `assets/registry.json`. Nada fora do registro (gate de CI mantido).

## Consequências

- QA honesto: geometria/limites validados por spec de CI; **nada testado no
  cliente** — jogabilidade visual/física pendente (checklist em
  `docs/testing/latunia-ilhas-glm.md`).
- Partes adicionadas: ~110 (Gelo), ~130 (Selva), ~90 (Vila) — sem Impact/Texture
  pesados; alvo mobile mantido, confirmar em playtest real.
