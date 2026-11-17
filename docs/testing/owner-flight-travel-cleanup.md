# Owner Flight — limpeza após teleporte

O botão Voar segue restrito ao proprietário autorizado pelo servidor. Ao usar portal normal ou teleporte de teste entre Aetheria, Ember e Latúnia, o servidor compara o deslocamento real da raiz com a velocidade máxima plausível desde o último Heartbeat. Em salto incompatível com voo normal, cancela LinearVelocity e restaura PlatformStand=false.

A política pura FlightTravelPolicy tem testes CLI para movimento regular, lag e deslocamentos grandes. Não altera sistemas de viagem, objetivos, recompensas, NPCs, arquivos do GLM nem a interface do botão.

QA em servidor Roblox ainda necessária: voar na Vila, atravessar portal para Gelo e confirmar que o voo desligou e o personagem anda; repetir no retorno ao Hub e ao combate Ember; conferir botão mudou para Voar, scroll e joystick funcionam ao reativar; conferir mobile/PC e jogador não proprietário.

CI e engine isolado não substituem testes reais de física.