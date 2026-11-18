# 0008 — Proposta GLM de escopo para a Fase 2 (aguarda aceite da Fase 1)

- **Status:** Proposta — só implementar após o dono aceitar a Fase 1
  (Gates B/C/D de `docs/testing/phase1-final-acceptance.md` concluídos).
- **Data:** 2026-11-17
- **Autor:** GLM 5.3

## Contexto

O plano original reservava "perfil persistente (GLM)" para a Fase 2. Na prática,
o Codex já entregou a fundação de persistência na Fase 1: `ObjectivesStore`,
`ProgressStore`, `ExplorationState`, `JourneyGuide` e retentativas de DataStore
(PRs #68/#72/#40), com revisão 57/58 publicada e `PERSISTED_OK`. Portanto a
proporção de trabalho muda: a GLM propõe concentrar sua Fase 2 em conteúdo,
apresentação e acessibilidade — sem invadir os módulos de dados do Codex.

## Escopo proposto para a GLM

1. **Integração de NPCs nos pontos preparados** (requer autorização do dono
   para desativar a regra atual): os 6 pontos GLM já existem no mundo com
   medalhão e aviso "chega em breve" (docas/deck/praça da Vila Central, Posto
   da Geleira no Gelo, Mercador das Vinhas na Selva). Proposta: montar os NPCs
   da biblioteca (PR #23) **nesses pontos**, com interação via prompt, diálogo
   curto no PlayerGui e validação no servidor — mesma arquitetura do Varkhion.
   Nenhum movimento de NPC, nenhuma recompensa automática: só orientação e
   sabor (a economia fica fora).
2. **Polimento visual por ilha a partir do playtest real:** correções
   pontuais de piso/colisão/luz nos 5 cenários a partir das evidências dos
   Gates B/D (nada especulativo; cada correção com caso reprodutível).
3. **Acessibilidade mobile da geometria GLM:** confirmar em dispositivo real
   que todos os caminhos da Vila/Gelo/Selva passam com joystick e toque,
   ajustando degraus > 1 stud e apertando passagens < 4 studs se necessário.
4. **Apresentação da jornada (com coordenação):** se o dono quiser, melhorias
   visuais no painel de 10 marcos e selos — mas os módulos (`JourneyGuide`,
   `ExplorationPanel`) são do Codex; a GLM só proporia mockups/valores de
   estilo ou assumiria os arquivos por acordo registrado.
5. **Apoio ao catálogo de dragões (Codex):** GLM fornece molduras/pedestais
   e ambientes de exibição nos cenários (arquivos GLM), quando o Codex pedir.

## Fora de escopo para a GLM

- Módulos de dados/persistência (`Profile/*Store*`) — Codex.
- Combate, Ember, Varkhion, Start, Bootstrap, workflows — Codex.
- Economia, transporte real de dirigíveis, produção — Fase futura.

## Pré-requisitos

1. Fase 1 aceita pelo dono (Gates B, C, D com evidências reais).
2. Autorização explícita do dono para montar a biblioteca de NPCs (item 1).
3. Escopo confirmado aqui ou ajustado pelo dono/Codex.
