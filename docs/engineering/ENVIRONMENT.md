# Ambiente híbrido — sem segredos

Verificado em 2026-11-16 no Windows:

- Workspace: `C:\Users\izael ferreira\.deepai-code\scratch\2026-11-15-5f460792`.
- Integração exclusiva: `MYTHRAGON-recovery`, branch `codex/recovery-autonomy`.
- Git fornecido por DeepAI Code Desktop; HTTPS fetch funciona.
- gh portátil em `%LOCALAPPDATA%\Temp\opencode\mythragon-tools\gh\bin\gh.exe`;
  autenticado via keyring, acesso admin ao repo (não copiar token para arquivos).
- Luau CLI e Rojo portáteis em `mythragon-tools\luau` e `mythragon-tools\rojo`.
- Python em `C:\Python315\python.exe`; Node em `C:\Program Files\nodejs\node.exe`.
- Roblox Studio instalado em `%LOCALAPPDATA%\Roblox\Versions\version-63eb6055af4e4688`.
  Instalação não é prova de controle automatizado nem de Play executado.
- `codex` não encontrado no PATH nem em npm roaming; `.codex` não encontrado.
  Não declarar Codex CLI externo configurado. Esta sessão é integrador GPT-6.1 Sol.
- DeepAI Code Desktop contém app.asar/server.asar; não alterar pacote instalado
  nem inventar flags de autonomia. Escrita no worktree, terminal e rede GitHub
  foram exercitados nesta sessão; permissões persistentes para futuras sessões
  dependem do aplicativo real e ainda não estão comprovadas.
- GitHub Actions executa Linux builds/publicação; Roblox secret existe no repo.
  Não há environment protegido configurado na auditoria inicial.
- Produção não configurada. Staging: 10777026486 / 135004978091658.

Atualização operacional: main protegida via API (check `build` obrigatório e base
atualizada, conversas resolvidas, inclusive admin; sem force-push/deleção; zero
aprovações humanas obrigatórias). Auto-merge habilitado. Environment staging
criado e restrito à branch main, sem reviewers. Respostas API conferidas.

Bloqueio histórico OPS-002 resolvido: proprietário concluiu refresh OAuth; scope
`workflow` confirmado e push aceito. PR #12 integrado com código+workflows em
main c66961397f30bb684f939421642dfc27c7a5848f; CI ampliada oficial 43983671970 PASS.
Primeiro PUBLISH automático 43983719759 falhou antes de upload por REL-004,
não por falta de permissão. Não confundir pipeline instalado com release publicada.

Validação operacional final da recuperação: main de conteúdo fc262b4a63e4,
CI43986367988 e PUBLISH43986456709 SUCCESS, revisão14 publicada. Secret existente
também autorizou Luau Execution: leitura de Source da revisão, bootstrap isolado
e logs estruturados foram executados de fato. Não precisou nova credencial nem
extração local do secret. Servidor normal/cliente continuam fora dessa prova.

Não registrar cookies, tokens, API keys ou conteúdo de configuração com segredos.
