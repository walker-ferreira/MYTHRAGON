# MYTHRAGON — documento de design

## Visão

RPG de fantasia épica no Roblox. O jogador explora ilhas mágicas em terceira pessoa com câmera livre. Dragões de visual realista e batalhas cinematográficas orientam a direção artística. Colecionar e evoluir dragões e tomar decisões táticas são objetivos de design para depois do piloto.

## Primeira entrega jogável

O jogador nasce no hub, identifica Ember entre os quatro selos, entra pelo portal e enfrenta um inimigo. A vitória libera o selo de Ember uma vez. A derrota permite tentar de novo. O retorno ao hub mostra o progresso da sessão.

| Área | Estado no piloto | Próxima entrega |
| --- | --- | --- |
| Hub | Plataforma inicial, quatro selos visuais e portal de Ember | Mostrar o estado de Ember e dos outros três selos |
| Ember | Arena com portal de volta | Um inimigo, um ataque, feedback de dano e fim do encontro |
| Perfil | Persistência ainda pendente | Detectar recompensas duplicadas na sessão. Definir os campos de salvamento a partir do fluxo jogável |
| Dragões e outros reinos | Direção de design | Detalhar depois da validação de Ember |

## Critérios de aceite

- Um jogador novo encontra o portal, entra em Ember, vence e volta ao hub.
- O selo de Ember aparece após a vitória. Repetir o encontro ou o evento de conclusão concede o mesmo selo uma única vez.
- Derrota e saída antecipada permitem recomeçar e preservam a possibilidade de ganhar a primeira recompensa.
- Testar o percurso com teclado e no cliente mobile. Conferir o estado do selo após cada tentativa.

Consulte [a arquitetura](ARCHITECTURE.md) e [as decisões versionadas](docs/decisions/README.md).
