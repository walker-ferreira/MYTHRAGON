# 0001 — Mapa piloto e caminho de publicação

**Estado:** mapa e CI implementados no piloto. Teste no cliente e publicação Open Cloud pendentes.

O MYTHRAGON começou sem um mapa existente. O primeiro marco é percorrer hub e Ember e validar a montagem remota sem exigir dois Places.

- **Um Place no piloto.** Hub e Ember têm módulos próprios. Considere separá-los quando houver uma necessidade de jogo demonstrada.
- **Um editor por arquivo.** Sol trabalha em Ember e GLM em hub e perfil. Em paralelo, cada agente usa sua branch e pasta. A combinação de alterações acontece na revisão, incluindo mudanças em interfaces compartilhadas.
- **Verificação em etapas.** CI valida a sintaxe e monta o Place. O cliente Roblox confirma o comportamento de jogo. Só declare vitória, recompensa e persistência verificados após exercitar os fluxos correspondentes.
- **Teste antes de produção.** Configure uma experiência privada de teste. Use o artefato aprovado, confira Universe ID e Place ID e registre a versão retornada. O envio integral substitui o Place, então confirme que o build contém a cena desejada antes do upload.
- **Credenciais fora do Git.** A chave Open Cloud entra pelos Actions Secrets. Mantenha as permissões limitadas à experiência que o workflow publica.

**Verificação inicial:** [PR do mapa piloto](https://github.com/walker-ferreira/MYTHRAGON/pull/1) e [execução com build aprovado](https://github.com/walker-ferreira/MYTHRAGON/actions/runs/43778572658). Ao validar uma publicação futura, registre a execução e a versão do Place.
