# MYTHRAGON

Jogo de fantasia épica para Roblox. Repositório principal em **Luau + Rojo**; a Fase 1 é um protótipo experimental **em desenvolvimento**, não um jogo certificado como concluído.

## Estado implementado

- **Aetheria (Hub):** spawn, cenário, quatro selos visuais, Guardiões do Éter, objetivos e santuário de Varkhion.
- **Ember:** portal, arena com volume em basalto, Guardião, barra de vida, ataque, esquiva (Q/controle B/toque, cooldown autoritativo), dano alinhado ao aviso laranja, vitórias validadas no servidor e retorno com recuperação de falhas.
- **Latúnia:** Vila Central, atlas, docas e rotas de teleporte autenticadas no servidor. Gelo e Selva incluem camadas visuais do GLM sobre os cenários-base do Codex (caverna, lago, cachoeira e templo); Deserto e Vulcânica mantêm cenários exploráveis iniciais. A primeira visita a cada ilha gera uma descoberta persistente (DataStore) validada pelo servidor. Dirigíveis e ferrovias seguem cenográficos.
- **Jornada:** dez marcos de progresso com validação no servidor, incluindo primeiro selo, retorno a Aetheria e cinco descobertas; Varkhion explica quatro selos e o Mural de Avisos da Vila orienta a próxima tarefa.
- **Menu VIAGEM:** botão público para teclado/toque que utiliza somente os portais e cais físicos validados pelo servidor; rotas não permitidas ou à distância são recusadas.
- **NPCs:** biblioteca de 10 personagens com diálogos e catálogos **preparada, mas não instalada no mundo**, aguardando autorização de colocação.
- **Engenharia:** CI verifica compilação Luau, contratos unitários, Enums Roblox e build Rojo. Publicação automática somente em **staging** após integração e CI aprovada, seguida por inspeção de fontes/Bootstrap em motor isolado.

A persistência v1 do **Selo de Ember**, dos objetivos de Aetheria, do retorno de Ember e das cinco descobertas de Latúnia usa DataStore com gravação monotônica e retentativas; **ainda não foi comprovada entre sessões reais de jogadores**. Os dez marcos técnicos da jornada estão implementados, mas não equivalem a dez cenas narrativas completas. **Última revisão de staging verificada: 51** (SHA `da50ac3e`), com CI e Bootstrap isolado PASS; não afirmar `DATASTORE_OK`, `RUNTIME_OK`, `PLAYTEST_OK` ou `PRODUCTION_APPROVED` sem testes reais de cliente, controles, persistência e desempenho. Ver [aceitação da Fase 1](docs/testing/phase1-final-acceptance.md).

## Como testar

Versão experimental: https://www.roblox.com/games/135004978091658

Em **servidor novo**:
1. Confira a faixa `STAGING EXPERIMENTAL`, SHA, versão e estado `READY`.
2. Use o portal de Ember, vença o Guardião, confira o selo e volte pelo portal roxo.
3. Interaja com Varkhion e os Guardiões, observe os objetivos individuais; saia e entre novamente em servidor novo para verificar a persistência do selo e dos três objetivos.
4. Entre em Latúnia pelo portal próximo de (24, 4.5, 8); use as docas da Vila Central para visitar Deserto, Vulcânica, Gelo e Selva, retornando pela Vila. Confirme a descoberta de cada ilha apenas uma vez e a permanência após reconectar.
5. Teste teclado, toque, duas contas, FPS e falhas do DataStore. Registre os erros do console F9 junto da versão exibida.

Comandos `/ir` / `!ir` são **apenas para testes no Roblox Studio** e passam pelo controlador oficial de Latúnia, não ficam liberados para jogadores em servidores publicados.

## Build local

```sh
rokit install
mkdir -p dist
rojo build default.project.json -o dist/mythragon.rbxlx
```

Consultar [AGENTS.md](AGENTS.md), [fila oficial](docs/agents/TASK_QUEUE.md), [releases](docs/releases/README.md) e [roteiro de Gelo/Selva](docs/testing/latunia-gelo-selva.md). Propostas não integradas não fazem parte da versão jogável.
