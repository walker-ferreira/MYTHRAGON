# 0006 — Vila Central (Latúnia) em 3D

- **Status:** Proposta (aguarda revisão do Codex e QA jogável do dono)
- **Data:** 2026-11-15
- **Decidido por:** GLM 5.3 (a pedido do dono: "pode construir já")

## Contexto

O atlas de Latúnia (concept art em `concept-art/latunia/glm/`) define o
arquipélago: Vila Central como hub comercial no centro, com Docas, Mercado
de Ferro e Vidro, Praça da Torre-Relógio, Elevador a Vapor e Bairro das
Oficinas. O dono autorizou construir a primeira ilha em 3D no jogo.

## Decisão

1. **Vila Central a leste do hub:** o hub de Aetheria ocupa X -33..33 e a
   ala oeste X -99..-33; a leste está livre. O deck principal da Vila
   Central usa 66×52 em X 39..105, na MESMA altura do hub (topo Y = 0),
   ligado por pedras de trajeto (mesmo padrão da ala oeste).
2. **Auto-montagem sem tocar no `Start.server.luau`:** o módulo é
   `src/server/Hub/Latunia.server.luau` (roda automaticamente pelo Rojo,
   pois `src/server` mapeia para `ServerScriptService.Mythragon`). Ele
   aguarda `workspace.MythragonMap.Hub` e anexa o modelo
   `workspace.MythragonMap.VilaCentral` como IRMÃO de `Hub`. Motivo:
   `Start.server.luau` é arquivo do Codex nesta rodada (GLM-R003).
   Montagem única e idempotente (`FindFirstChild("VilaCentral")`).
3. **Três níveis como no atlas:** Docas (deck inferior ao sul, topo Y -5,5,
   com escadaria, 2 guindastes, amarras de latão e 2 dirigíveis atracados),
   deck principal (Mercado de Ferro e Vidro com cobertura de vidro âmbar,
   Bairro das Oficinas com 4 casas, chaminés e vapor), Praça da Torre-Relógio
   (terraço superior em Y 8 com pilares de ferro, rosa-dos-ventos de latão
   e torre com relógio dourado e PointLight).
4. **Elevador a Vapor validado no servidor:** dois elevadores (docas → deck
   principal; deck principal → praça). Cada um tem dois pads com
   `Touched` no servidor + cooldown de 1 s por jogador. Sem estado no
   cliente; nada de progresso decidido no cliente.
5. **Sem objetivos/selos na Vila Central nesta fase:** o progresso de Fase 1
   (objetivos, selos, portal) permanece no Hub/Aetheria. A Vila Central é
   explorável e visual; mecânicas dela (comércio, missões, docas funcionais)
   virão em fase futura.
6. **Zero assets de terceiros:** tudo procedural (Parts, materiais e luzes
   padrão do Roblox), na paleta do atlas (arenito cobre, ferro, latão, vidro
   âmbar, zinco).

## Consequências

- QA: checklist em `docs/testing/latunia-vila-central.md`.
- Coordenação: pedido de revisão ao Codex em `docs/agents/GLM.md` (GLM-R007).
- Próximas ilhas (Gelo, Deserto, Selva, Vulcânica) devem seguir o mesmo
  padrão de auto-montagem irmã de `Hub`, ou serão integradas ao `Start`
  pelo Codex após a revisão.
