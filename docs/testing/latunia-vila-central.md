# QA — Vila Central (Latúnia, Fase Atlas)

Build: `src/server/Hub/Latunia.server.luau` · referência visual:
`concept-art/latunia/glm/vila-central.svg` · decisão:
`docs/decisions/0006-latunia-vila-central-3d.md`.

## Pré-condições

- [ ] Abrir o build mais recente (artefato da CI ou Rojo no Studio) e dar Play.
- [ ] Nascer no hub de Aetheria (spawn seguro) e caminhar para LESTE pelas
      pedras de trajeto (oeste é a Aetheria; leste é a Vila Central).

## Checklist

1. [ ] Trajeto: pedras de trajeto (3) ligam o hub à Vila Central sem falhas.
2. [ ] Deck principal: arenito cobre, rochas de sustentação embaixo.
3. [ ] Docas da Vila (1): deck de madeira abaixo do nível sul; escadaria de
       5 degraus desce do deck principal até a doca; 2 guindastes com braço,
       cabo e gancho; postes de amarração de latão; 2 dirigíveis atracados
       (envelope + cabine + aletas + amarras).
4. [ ] Mercado de Ferro e Vidro (2): pilares de ferro, cobertura de vidro
       âmbar em dois águas, 3 bancas com bens brilhando.
5. [ ] Bairro das Oficinas (5): 4 casas com telhado de zinco, janelas âmbar,
       chaminés com colunas de vapor.
6. [ ] Praça da Torre-Relógio (3): terraço superior com pilares de ferro,
       rosa-dos-ventos no piso, escadaria de 8 degraus subindo pelo lado
       oeste; torre com coroa de zinco, pináculo de latão, face dourada
       iluminada com ponteiros.
7. [ ] Elevador a Vapor (4), elevador 1 (docas ↔ deck principal): pisar no
       pad de latão teletransporta ao pad oposto; vapor sobe no pad; não
       há vaivém automático (cooldown 1 s por jogador).
8. [ ] Elevador a Vapor, elevador 2 (deck principal ↔ praça): mesmo
       comportamento, pouso na área estendida da praça.
9. [ ] Lampiões a gás: luz quente (âmbar) em docas, mercado, oficinas,
       trajeto e praça.
10. [ ] Tubo de latão ligando oficinas ao mercado pelo lado norte.
11. [ ] Painéis de objetivos/selos de Fase 1 continuam funcionando
       normalmente (Vila Central não mexe neles).
12. [ ] Não cair do mundo: bordas dos decks têm rochas visuais; nenhum
       piso do trajeto tem buraco.

## Registro

| Data | Build (SHA) | Resultado | Observações |
| ---- | ----------- | --------- | ----------- |
|      |             |           |             |
