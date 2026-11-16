# MYTHRAGON

Mapa piloto do MYTHRAGON, feito em Luau e compilado com Rojo. Hub e Ember ficam no mesmo Place no piloto. O cenário é criado quando o servidor inicia. Abra o `.rbxlx` no Roblox Studio e pressione **Play** para ver o mapa.

## Teste do mapa

1. Nasça no hub e confira os quatro selos visuais.
2. Use o portal laranja para chegar à arena de Ember.
3. Use o portal roxo em Ember para voltar ao ponto de nascimento.

Inimigos, combate, recompensas e perfil persistente ficam para as próximas etapas.

## Build

A Action **Validar e compilar mapa** verifica a sintaxe dos scripts e disponibiliza o artefato `mythragon-pilot`. Para compilar localmente com Rokit e Rojo:

```sh
rokit install
mkdir -p dist
rojo build default.project.json -o dist/mythragon.rbxlx
```

Consulte [AGENTS.md](AGENTS.md) para a divisão dos arquivos. A publicação via Roblox Open Cloud será ligada primeiro a uma experiência de teste, após a configuração do Universe ID, do Place ID e do segredo no GitHub.
