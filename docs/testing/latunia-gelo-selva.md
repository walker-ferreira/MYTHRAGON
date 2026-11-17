# Latúnia — Gelo e Selva (exploração inicial)

Candidato experimental da Fase 1, sem declarar conclusão de jogabilidade.

- Origem: `src/server/Latunia/Codex/Expansion.luau`, módulos procedurais próprios e integrados via `Bootstrap` / `partnerBuilders`.
- Gelo: terreno sólido, doca, caminho, cristais e Observatório do Inverno.
- Selva: terreno sólido, doca, caminho, árvores e Ruínas da Copa Antiga.
- Ambas: nenhuma missão, inventário, drop, combate ou recompensa; sem modelos de terceiros.
- Contrato de viagem permanece no controller autoritativo: Hub ↔ Central ↔ Gelo/Selva; dez prompts originais.
- Builds existentes de Central, Deserto, Vulcânica, Ember e Varkhion permanecem.

## Verificação necessária

1. CI: Luau compile, specs CLI, LSP Enum e build Rojo, source match.
2. Staging: revisão persistida, bootstrap isolado, cinco ilhas e dez prompts, <2500 partes, pisos dos desembarques, marcos presentes.
3. Servidor novo normal: marca READY, portais acessíveis, gelo/selva visíveis, ida e volta, movimento/física segura.
4. Cliente teclado/toque e duas pessoas. Visual e performance em mobile precisam de avaliação do dono.

*Sem 3 e 4: não declarar RUNTIME_OK, PLAYTEST_OK nem produção pronta.*
