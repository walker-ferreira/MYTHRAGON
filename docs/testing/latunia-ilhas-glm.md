# QA — Melhorias GLM nas ilhas de Latúnia (LAT-GLM-001)

Builds: `src/server/Hub/LatuniaGelo.luau`, `src/server/Hub/LatuniaSelva.luau`,
melhorias em `src/server/Hub/Latunia.luau` (Vila Central). Geometria validada por
`LatuniaIslandsData.spec.luau` na CI. Referência: decisão 0007.

## Pré-condições

- [ ] Servidor novo após integração (a faixa no topo mostra SHA e State).
- [ ] Ativação requer o Codex apontando o Bootstrap para `Vila.partnerBuilders`
      (GLM-R009); sem isso, Gelo/Selva continuam com o cenário base antigo.

## Gelo (/ir gelo)

1. [ ] Chegada na doca conecta andando até o Observatório SEM pulos (conector
       novo + 4 degraus de gelo no vão que existia).
2. [ ] Caverna de Cristal: entrada oeste da trilha, interior com cristais
       iluminados, braseiro azul; sem paredes invisíveis.
3. [ ] Lago Congelado: vidro caminhável, borda de pedra; não cair do disco.
4. [ ] Monolito Rúnico visível do observatório (orientação).
5. [ ] 6 coníferas nevadas nas bordas, sem flutuar.
6. [ ] Posto da Geleira: barraca com medalhão de latão "chega em breve"
       (NPC NÃO instalado — corretto).
7. [ ] Placas de direção legíveis nos desvios.

## Selva (/ir selva)

1. [ ] Chegada na doca leste conecta ao templo e ao Mirante sem buracos.
2. [ ] Cachoeira Esmeralda: paredão, cortina de vidro, poço raso caminhável
       (não afundar nem atravessar de queda).
3. [ ] Mirante das Copas: pedra talhada com "olhos", tochas; sem flutuação.
4. [ ] Templo: altar brilhante, braseiros verdes, arcos em ruína estáveis.
5. [ ] Totem da Copa no caminho leste; cipós pendurados nas copas base.
6. [ ] Barraca do Mercador das Vinhas com medalhão (NPC NÃO instalado).
7. [ ] Tochas ao longo da trilha principal (visível à noite).

## Vila Central (/ir vila)

1. [ ] 3 ruas de pedra ligando docas→mercado→oficinas→praça, sem degraus
       inesperados (ruas são finas, topo +0,16).
2. [ ] Fonte da Praça: borda, água de vidro, jato; nada sobrepõe a
       rosa-dos-ventos nem a torre.
3. [ ] Bancos e vasos da praça estáveis (sem atravessar pilares).
4. [ ] Mural de Avisos na entrada; papéis legíveis de perto.
5. [ ] Barracas novas (2) sem invadir o mercado.
6. [ ] Oficina 5 e Pensão: telhados/chaminés com vapor, alinhadas às ruas.
7. [ ] Medalhões de NPC nos 3 níveis (docas em cima do deck de madeira,
       deck sobre a base do mercado, praça no terraço alto).
8. [ ] Bandeiras nas escadarias das docas; lampiões extras acesos.

## Terminais de Viagem (GLM-R011)

1. [ ] Hub: terminal visível a leste do spawn (deck), pad "Vila Central";
       clique/toque teleporta para a chegada da Vila.
2. [ ] Vila: terminal na praça com 5 pads (Hub/Gelo/Selva/Deserto/Vulcânica).
3. [ ] Cada ilha tem terminal de retorno junto à chegada (pad "Vila Central").
4. [ ] Cooldown 1,5 s (cliques rápidos não aceleram viagem).
5. [ ] Deserto/Vulcânica: terminal sobre piso da chegada, sem flutuar
       (posicional estimado pelo Layout — confirmar visualmente).
6. [ ] Mobile: toque no pad funciona; rótulos legíveis.

## Registro

| Data | Build (SHA) | Resultado | Observações |
| ---- | ----------- | --------- | ----------- |
|      |             |           |             |
