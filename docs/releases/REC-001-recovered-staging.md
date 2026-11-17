# REC-001 — staging recuperado, revisão 14

**Disponível para avaliação experimental, não aprovado para produção.**

- Place: https://www.roblox.com/games/135004978091658
- Versão: **14**, SHA **fc262b4a63e4**.
- CI main: [43986367988](https://github.com/walker-ferreira/MYTHRAGON/actions/runs/43986367988).
- Publicação/inspeção: [43986456709](https://github.com/walker-ferreira/MYTHRAGON/actions/runs/43986456709).
- Manifesto: [REC-001-fc262b4.json](REC-001-fc262b4.json).

## O que foi comprovado

Artefato e identidade validados; API Roblox confirmou revisão/destino/isPublished.
Inspeção real da revisão confirmou as 24 fontes persistidas, Core/Varkhion/Latúnia
READY, bootstrap idempotente, cinco slots, uma Vila Central, conteúdo de Deserto/
Vulcânica, dez prompts e piso colidível nas cinco chegadas. 1.317 partes na Latúnia.

Falhas da recuperação não foram escondidas: run inicial foi bloqueado antes do
upload pelo journal; revisão 13 publicou, mas falhou no motor. Logs reais mostraram
VarkhionModel sem retorno. Corrigido por PR #17, com gate positivo/negativo. A
revisão 14 passou. Relatórios e recibos de ambas as versões foram preservados.

## Avaliação curta do proprietário

1. Entrar em **servidor novo** e conferir a faixa `STAGING EXPERIMENTAL`,
   SHA `fc262b4a63e4`, `v14`, `READY`.
2. Usar o portal Latúnia no Hub, perto de (24,4.5,8). Visitar Vila Central,
   Deserto e Vulcânica; voltar às docas e depois a Aetheria.
3. Conferir Varkhion e percurso Ember (vitória/selo único/retorno). Informar
   qualquer erro junto com a versão exibida.

**Gelo e Selva são desembarques provisórios**, não ilhas detalhadas concluídas.

A API de motor isolado não simula física nem jogadores, e não inicia Start
automaticamente. Logo servidor normal, cliente/toque/multijogador, viagens,
experiência visual e playtest permanecem pendentes — não RUNTIME_OK/PLAYTEST_OK.
Nenhum servidor foi encerrado e nenhuma produção foi alterada.

## Próximo ciclo

Feedback do candidato → correção por branch/PR → CI → publicação serializada de
conteúdo/composição → inspeção. PR #15 (GLM-R008) continua separado, preservado e
sujeito a revisão/atualização da base; não faz parte da revisão 14. Execução de dois
agentes foi exercitada por sessões GLM reais; não há alegação de daemon desktop
24/7 ou integração pública inexistente.
