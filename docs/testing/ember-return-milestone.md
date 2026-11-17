# STORY-RETURN-001 — retorno de Ember validado na Fase 1

A jornada de descoberta passa de 9 para **10 marcos**. O novo objetivo `retorno` aparece depois da conquista do Selo de Ember e antes da descoberta da Vila Central. Ele é registrado **somente** quando o controlador de combate de Ember consegue retornar o participante a Aetheria via portal roxo ou retorno automático depois da vitória.

- Após o deslocamento oficial, o servidor exige vitória no encontro que o jogador acabou de disputar e confirma a presença do Selo de Ember. Jogadores com selo antigo podem repetir a vitória e concluir o retorno.
- Viagens de debug, saída de Latúnia e comandos de proprietário não registram a etapa; a callback especial só é ligada à arena de Ember.
- `ObjectivesStore.recordEmberReturn` deduplica por jogador/sessão, envia atualização somente à interface individual e salva em `Mythragon_Progress_v1` com `UpdateAsync` monotônico, sem novas recompensas.
- `ObjectivesData` preserva esquema v1 e campos históricos. O painel carrega o marco após reconexão, sem contá-lo como uma sexta ilha.
- Não altera NPCs, GLM, viagem de Latúnia ou outras rotas; não inventa etapa de diálogo que não existe.

## QA indispensável

1. Entre em Ember e saia antes da vitória. O marco deve continuar pendente. Repita com um jogador que já possui o selo de uma vitória antiga, mas ainda tem o retorno pendente.
2. Derrotar o Guardião, ganhar o selo, sair pelo portal roxo: marcar `retorno` uma única vez e avançar para Vila Central.
3. Repetir o retorno automático após 30 s; verificar mesma deduplicação.
4. Viagem debug Ember→Hub não marca a etapa; usuário sem selo não recebe progresso.
5. Sair e entrar com duas contas; verificar `objectives.retorno=true` somente onde houve retorno válido, sem perder outras conquistas.
6. Testar teclado, toque, controle e comportamento com servidor lento/falha do DataStore.

**Limite:** 10 marcos técnicos são verificáveis, mas **não equivalem** às 10 cenas narrativas completas solicitadas; parte da história (ex.: apresentação dos quatro selos e próxima missão de Vila Central) ainda precisa aprofundamento. Não declarar Fase 1 terminada sem PLAYTEST real.
