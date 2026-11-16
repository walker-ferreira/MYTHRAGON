# Latúnia 3D — primeira versão Codex

**Editor:** Codex. **Branch:** `codex/latunia-3d`. **Base:** `6f8a82190e3213e281dffbfd90445852d2ca652c`.

## Escopo real

Deserto e Vulcânica construídos com geometria nativa; atlas físico 3D na área de desembarque da Vila; organização N=-Z, Gelo/norte, Deserto/leste, Selva/oeste e Vulcânica/sul. Centro global em (2400,24,0), separado do piloto existente. Nenhum SpawnLocation novo, mudança de Lighting global, Terrain:Clear ou alteração em Ember/Profile/Hub.

Vila Central, Gelo e Selva têm **apenas bases provisórias de desembarque**, sinalizadas como conteúdo 3D pendente do GLM. Não são versões completas dos mapas dele.

Dirigíveis são modelos estáticos vazios. O transporte entre docas é **travessia rápida por teleporte no servidor**, não voo pilotável/animado. Entrada por E/toque no acesso âmbar em Aetheria, aproximadamente (24,4.5,8); saída pela Vila. Não há missões, mineração econômica ou recompensas novas. Lava é cenográfica; queda no interior da cratera é resgatada.

## Verificações automatizadas

| Verificação | Estado |
| --- | --- |
| Sintaxe de todas as fontes Luau | PASS: 20 fontes, Luau 0.744 |
| Specs existentes Ember/Profile/Varkhion | PASS: três specs CLI, regressão de lógica, não cliente |
| `luau src/server/Latunia/Codex/Layout.spec.luau` | PASS: posições, rotas, chegada em terra, cooldown/concorrência/saída |
| Build Rojo | PASS: Rojo 7.6.1, artefato local fora do Git |
| Preservação de Hub/Ember/Profile/Dragons/config em relação à base | PASS: comparação Git sem diferenças |
| CI do novo PR | Pendente de publicação da branch |

## Motor e cliente — nenhum teste jogável ainda

Não confundir os testes de lógica com o jogo rodando. Nesta sessão não há ferramenta de controle/observação interativa do cliente. O módulo abaixo é uma inspeção manual no **servidor do Studio durante Play**, sem alterar a cena nem conceder progresso:

```luau
require(game.ServerScriptService.Mythragon.Latunia.Codex["Map.engine.spec"])()
```

Verifica piso sob chegadas, cinco slots, dez prompts, ausência de scripts/spawns embutidos, geometria ancorada e orçamento de até 2500 peças. **Ainda não executado no motor.**

| Caso | Resultado jogando |
| --- | --- |
| Nascer em Aetheria, acessar Latúnia por E e por toque | Pendente |
| Caminhar do desembarque ao atlas e às quatro docas da Vila | Pendente |
| Visitar Deserto: doca oeste, ferrovia passando na mina e terminando na refinaria | Pendente |
| Entrar no galpão, atravessar cânion e subir/descer sua escadaria | Pendente |
| Visitar Vulcânica: doca NE, escadarias, forja elevada, pontes, caldeiras e fundição sul | Pendente |
| Confirmar que degraus/terreno não bloqueiam portas e caminhos | Pendente |
| Cair no mar/cratera e retornar ao desembarque seguro | Pendente |
| Retornar à Vila e a Aetheria sem alterar selos | Pendente |
| Dois jogadores em rotas diferentes e acionamentos repetidos | Pendente |
| Morrer/resetar/desconectar durante a espera de travessia; sem teleporte do novo personagem | Pendente |
| Regressão de Ember: vitória/selo único, derrota/retry, retorno e plataforma de 12 studs | Pendente; fontes preservadas não equivalem a teste de cliente |
| FPS/memória/tempo de entrada em dispositivo representativo | Pendente |

## Publicação

Nenhum upload nesta rodada de construção. Revisão cruzada/integração do GLM e teste de cliente ainda pendentes. Destino futuro de teste, se solicitado e validado: Place `135004978091658`, Universe `10777026486`; não produção.

## Revisão do parceiro — GLM-R007

PR #9 revisado em `9440c47`, CI [43806774484](https://github.com/walker-ferreira/MYTHRAGON/actions/runs/43806774484) PASS. **Correções solicitadas**, não aprovado: DarkStone inválido, continuidade do trajeto/desembarque e validação/estado dos elevadores. Auto-montagem e posição X=72 ainda precisam de acordo para não duplicar o slot Central deste protótipo. Detalhes no CODEX.md; nenhuma fonte do GLM foi alterada ou incorporada nesta branch.
