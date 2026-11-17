# MYTHRAGON — Gate final de aceitação da Fase 1

**Estado atual:** implementação e build da Fase 1 em `main` entregues como **candidato de teste**, não certificadas como jogáveis. Última publicação experimental verificada: **staging revisão 51**, SHA `da50ac3ec6d93b0021d9250676b18845e62bc808`, GitHub Actions `44097503800`, `PERSISTED_OK` + `isolated engine bootstrap PASS`. Nenhum teste de cliente real é inferido disso.

## Fluxo de 10 marcos implementado no servidor

1. Observar Guardiões do Éter em Aetheria (validação espacial).
2. Interagir com Varkhion e conhecer os quatro Selos do Éter (Ember é o primeiro reino disponível).
3. Entrar no portal de Ember validado pelo servidor.
4. Vencer o Guardião de Ember e receber o primeiro selo uma única vez.
5. Retornar pelo portal roxo ou pelo retorno automático a Aetheria; registrar o marco persistente `retorno`.
6. Descobrir a Vila Central em Latúnia.
7. Descobrir a Ilha do Gelo.
8. Descobrir a Ilha do Deserto.
9. Descobrir a Ilha da Selva.
10. Descobrir a Ilha Vulcânica.

A jornada visual também possui spawn, painéis de objetivos, quatro selos visuais, menu VIAGEM público junto aos cais, mural GLM interativo na Vila Central e orientação dinâmica de Varkhion. Os três outros reinos dos selos, transporte real dos dirigíveis, economia e dez NPCs ativos **não** pertencem à Fase 1 atual. A biblioteca de 10 NPCs permanece desativada.

## Gate A — código, build e cenário

- [x] PRs de jogabilidade integrados, mantendo contribuições Codex/GLM.
- [x] Compilação/CI Luau e Rojo da `main` passando para revisão 51.
- [x] Publicação somente em staging e conferência da versão persistida.
- [x] Inspector isolado verifica Aetheria, Ember, Varkhion, cinco ilhas, modelos GLM, prompts de viagem, mural, barra de vida e fontes.
- [ ] Confirmar funcionamento físico com jogadores; CI e engine isolado não substituem.

## Gate B — teste real da jornada

- [ ] Abrir **servidor novo** em https://www.roblox.com/games/135004978091658, confirmar a revisão no HUD e READY.
- [ ] Em PC, ir de Aetheria a Ember pelo portal (E), usar ataque, aviso do sopro, esquiva Q, vencer, receber selo e voltar.
- [ ] Repetir em Android/iPhone com toque; testar controle com botão B para esquiva e X para viagem.
- [ ] Verificar a orientação de Varkhion antes/depois de Ember, o retorno persistente, mural da Vila Central e missão seguinte.
- [ ] Ir da Vila às quatro ilhas e voltar; testar o botão VIAGEM **dentro e fora** da distância do cais, inclusive rotas proibidas.
- [ ] Em servidor com duas contas, conferir isolamento de batalha, GUI, selos, viagem, histórico de objetivos e ausência de recompensas duplicadas.
- [ ] Conferir respawn, quedas, retornos negados, várias viagens rápidas e console F9 sem erros relevantes.

## Gate C — DataStore real

- [ ] Completar o primeiro selo, retorno e as cinco descobertas com conta A; sair completamente.
- [ ] Entrar em **servidor diferente**, confirmar estado restaurado no painel, quatro selos visuais e Varkhion.
- [ ] Usar conta B nova sem herdar dados de A; testar duas contas simultâneas.
- [ ] Simular falha de `GetAsync` e `UpdateAsync` apenas em **ambiente de teste autorizado**. O servidor deve avisar e recuperar sem apagar progresso existente.
- [ ] Registrar evidências de reconexão e retentativa sem gravações duplicadas.

## Gate D — experiência visual e desempenho

- [ ] Conferir rochas/cachoeira/caverna, piso e altura das cinco ilhas em cliente, com screenshots.
- [ ] Verificar aviso laranja do Guardião, esquiva de 0,45 s, barra de vida e retorno do portal roxo.
- [ ] Conferir painel de 10 marcos, mural, aviso de viagem e joystick em 320×568 e aparelho real.
- [ ] Medir quedas perceptíveis de FPS e falhas de carregamento; anotar dispositivo, F9 e revisão.

## Bloqueios e política de release

**RUNTIME_OK, PLAYTEST_OK, DATASTORE_OK e PRODUCTION_APPROVED estão PENDING** até receber evidências reais. Não publicar em produção. O PR histórico **#45 do GLM** ainda contém teleporte direto inseguro; o **menu público protegido do PR #58** já foi integrado. Não mesclar #45 sem substituição completa pelo controlador seguro.

Em caso de falha: registrar ação reproduzível, dispositivo, imagem/vídeo ou logs F9, SHA/revisão, conta de teste (sem senha ou dados pessoais) e PR corretivo. Não declarar conclusões apenas com sucesso de CI. A Fase 1 só poderá ser certificada quando B, C e D forem verificados em partida real.
