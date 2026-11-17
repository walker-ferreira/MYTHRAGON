# RETURN-ACK-001 — retorno de Ember/Latúnia confirmado pelo Hub

O retorno ao Hub agora tem contrato explícito `returnToHub(player): boolean`. **Somente `true`** confirma que o personagem válido foi movido para perto do spawn de Aetheria.

- Hub rejeita jogador desconectado, personagem sem `HumanoidRootPart` ou `Humanoid`, e personagem morto.
- `PivotTo` roda protegido por `pcall`, seguido de verificação de proximidade ao spawn (até 12 studs). Em erro, retorno é `false` e o estado de trânsito não é descartado.
- Ember exige `pcall == true` **e** resposta `true`; se falhar mantém o encontro, exibe aviso e permite nova tentativa pelo portal roxo.
- Latúnia exige a mesma confirmação tanto para saída da Vila ao Hub quanto para teleporte debug; se não houver confirmação, não esquece a ilha atual.
- O registro persistente do marco `retorno` de Ember só ocorre após retorno confirmado e vitória real do encontro, preservando as correções anteriores.

## QA em cliente Roblox necessária

1. Depois de vencer Ember, usar portal roxo e confirmar retorno real e registro do marco.
2. Repetir com personagem inválido/saída simultânea/erro injetado em `PivotTo`: nenhuma confirmação falsa, nenhuma marcação `retorno` e nova tentativa disponível se personagem continuar válido.
3. Entrar na Vila, usar portal de saída e repetir teste de falha; manter origem atual e tentar novamente sem desincronização.
4. Testar `debugWarp` do dono (Studio/staging): confirmar `false` quando retorno falha e nenhuma concessão de objetivo.
5. Testar dois jogadores, respawn, mobile, teclas, controle e console F9.

CI, Luau e motor isolado não demonstram deslocamento físico entre servidores.
