# Problemas conhecidos

| ID | Sintoma / causa | Estado / responsável |
| --- | --- | --- |
| OPS-001 | gh fora do PATH, embora instalado e autenticado | Resolvido por caminho absoluto; CODEX |
| REL-001 | workflow verde com publish=false | Corrigido na main pelo PR #12; PUBLISH agora falha quando envio não ocorre |
| REL-002 | revisão/operação históricas só no Step Summary | Evidência histórica incompleta; CODEX |
| QA-001 | CI não executa specs CLI, só sintaxe/build | Resolvido: CI ampliada 43983522637/43983671970 PASS; CODEX |
| QA-002 | cliente/visual e servidor normal sem prova de execução | Engine isolado PASS na revisão14; demais pendentes; CODEX + GLM |
| WORLD-001 | falha em Start pode omitir Latúnia sem certificar falha da release | Resolvido: Health obrigatório e probe bloquearam revisão13; revisão14 PASS |
| CONTENT-001 | Gelo/Selva são desembarques provisórios | Planejado GLM; não são ilhas completas |
| AGENT-001 | executor desktop não interativo permanente não comprovado | Harness executou GLM real; daemon/API desktop pública não documentada; limite registrado |
| DATA-001 | Profile mantém só sessão | Conhecido; fora do escopo desta recuperação |
| OPS-002 | Push que altera workflows recusado: OAuth sem escopo workflow | Resolvido: proprietário autorizou scope; push real aceito |
| REL-003 | Não mesclar código novo sem workflows | Resolvido: #12 integrou código e workflows juntos em c669613 |
| REL-004 | Registro automático do environment confundido com journal de upload | Resolvido pelo PR #14; publicação seguinte chegou à revisão 13 |
| WORLD-002 | VarkhionModel sem return Model causava require falhar; Core/Latúnia montaram | Resolvido pelo PR #17; revisão14 persisted/bootstrap PASS e export gate ativo |
