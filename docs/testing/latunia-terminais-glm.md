# QA — Terminais de Viagem seguros (GLM-R013)

Build: `src/server/Hub/LatuniaTerminals.server.luau`. Toda travessia passa por
`Map.requestTravel` (controlador do Codex, PR #58). Referência: `GLM.md` GLM-R013.

## Pré-condições

- [ ] Servidor novo; faixa no topo com revisão/SHA e READY.
- [ ] Menu VIAGEM oficial (Codex) funcionando normalmente — os terminais são
      complemento físico, não substituto.

## Posições (todas ≤ ~8 studs do ponto de embarque oficial)

1. [ ] Hub: terminal ao lado do portão de Latúnia; pad único "Vila Central".
2. [ ] Vila Central: 4 terminais de embarque nas docas centrais (Gelo norte,
       Deserto leste, Selva oeste, Vulcânica sul), cada um com 1 pad.
3. [ ] Cada ilha: terminal de retorno junto à doca de chegada, pad "Vila Central".
4. [ ] Vila Central: terminal "Retorno Aetheria" junto ao portal de saída sul.

## Comportamento

1. [ ] PC: clique no pad dispara a travessia oficial (bilhete, ~1,2 s, mesmo
       comportamento do prompt E). Mobile: toque no pad.
2. [ ] Pad da rota certa perto da doca: embarca.
3. [ ] Pad de rota errada ou jogador longe do ponto de embarque: aviso
       "Aproxime-se do ponto de embarque..." — NADA teleporta fora do padrão.
4. [ ] Cliques rápidos repetidos: sem spam (cooldown local 1,5 s) e o
       controlador continua mando no ritmo real.
5. [ ] Duas contas: viagem de um não interfere na GUI/viagem do outro.
6. [ ] F9 (Servidor): sem erros novos; warns de slot ausente só se uma ilha
       não montar (não devem aparecer em servidor saudável).

## Limitações honestas

- Validação de CI: sintaxe, build e specs — nada disso comprova física ou
  cliente. Este checklist só pode ser concluído em partida real.
