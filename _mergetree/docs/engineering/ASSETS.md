# Assets e cenas — contrato proporcional

Fluxo: CONCEPT → PRODUCTION → VALIDATION → INTEGRATION → PREVIEW →
STAGING → OWNER_EVALUATION. Arquivos concept-art/*.svg são ilustrações;
não são meshes/texturas Roblox importados.

Geometria atual: original procedural, materiais nativos, sem IDs externos.
Referências nativas permitidas em `assets/registry.json`; qualquer asset externo
novo deve ser registrado, auditado quanto a origem/licença/scripts/dependências
e recebido pelo integrador antes de entrar no build.

Para cada asset jogável novo registrar: ID estável, nome, categoria, origem,
versão, estado, modelo/texturas/materiais, dimensões, pivô, colisões, orçamento,
dependências, módulo instanciador, destino e evidência de presença no jogo.
Não marcar INTEGRATED apenas por existir arquivo no Git.

Mapas: parâmetros/seed versionados (Layout atual é determinístico, sem RNG);
contratos de orientação/cardinais, chegada com raycast de piso colidível, limites
de instâncias, duplicação e preservação de sistemas existentes. Geometria não
deve depender só de nomes para ser aprovada. Física/navegação/cliente são pendências
até teste real; o probe engine não simula movimento.