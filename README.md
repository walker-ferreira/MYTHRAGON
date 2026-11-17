# MYTHRAGON

Jogo de fantasia épica para Roblox. Repositório principal em **Luau + Rojo**; a Fase 1 é um protótipo experimental **em desenvolvimento**, não um jogo certificado como concluído.

## Estado implementado

- **Aetheria (Hub):** spawn, cenário, quatro selos visuais, Guardiões do Éter, objetivos e santuário de Varkhion.
- **Ember:** portal, arena com volume em basalto, Guardião, barra de vida, combate e vitórias validadas no servidor, portal de retorno e recuperação de falhas.
- **Latúnia:** Vila Central, atlas, docas e rotas de teleporte autenticadas no servidor. Deserto, Vulcânica, Gelo e Selva possuem cenários exploráveis iniciais; dirigíveis e ferrovias são cenográficos, sem transporte real.
- **NPCs:** biblioteca de 10 personagens com diálogos e catálogos **preparada, mas não instalada no mundo**, aguardando autorização de colocação.
- **Engenharia:** CI verifica compilação Luau, contratos unitários, Enums Roblox e build Rojo. Publicação automática somente em **staging** após integração e CI aprovada, seguida por inspeção de fontes/Bootstrap em motor isolado.

A persistência v1 do **Selo de Ember** e dos três objetivos atuais de Aetheria foi implementada via DataStore com gravação monotônica e recuperação na interface; **ainda não foi comprovada entre sessões reais de jogadores**. Não afirmar `DATASTORE_OK`, `RUNTIME_OK`, `PLAYTEST_OK` ou `PRODUCTION_APPROVED` sem as evidências correspondentes. A sequência narrativa completa de dez missões, multiplayer, interface no celular e desempenho ainda precisam ser desenvolvidos e testados.

## Como testar

Versão experimental: https://www.roblox.com/games/135004978091658

Em **servidor novo**:
1. Confira a faixa `STAGING EXPERIMENTAL`, SHA, versão e estado `READY`.
2. Use o portal de Ember, vença o Guardião, confira o selo e volte pelo portal roxo.
3. Interaja com Varkhion e os Guardiões, observe os objetivos individuais; saia e entre novamente em servidor novo para verificar a persistência do selo e dos três objetivos.
4. Entre em Latúnia pelo portal próximo de (24, 4.5, 8); use as docas da Vila Central para visitar Deserto, Vulcânica, Gelo e Selva, retornando pela Vila.
5. Teste teclado, toque, duas contas, FPS e falhas do DataStore. Registre os erros do console F9 junto da versão exibida.

Comandos `/ir` / `!ir` são **apenas para testes no Roblox Studio** e passam pelo controlador oficial de Latúnia, não ficam liberados para jogadores em servidores publicados.

## Build local

```sh
rokit install
mkdir -p dist
rojo build default.project.json -o dist/mythragon.rbxlx
```

Consultar [AGENTS.md](AGENTS.md), [fila oficial](docs/agents/TASK_QUEUE.md), [releases](docs/releases/README.md) e [roteiro de Gelo/Selva](docs/testing/latunia-gelo-selva.md). Propostas não integradas não fazem parte da versão jogável.
