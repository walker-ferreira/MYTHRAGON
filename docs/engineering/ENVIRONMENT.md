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

Não registrar cookies, tokens, API keys ou conteúdo de configuração com segredos.
