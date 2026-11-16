#!/usr/bin/env bash
set -euo pipefail
version=1.70.1
dir="$(mktemp -d)"
curl -fsSL --retry 3 "https://github.com/JohnnyMorganz/luau-lsp/releases/download/$version/luau-lsp-linux-x86_64.zip" -o "$dir/lsp.zip"
echo "1a2ea1ae4f98f8946cefd970a4b54853e11ab4775e6932faa7f60cf920346567  $dir/lsp.zip" | sha256sum -c -
unzip -q "$dir/lsp.zip" -d "$dir"
chmod +x "$dir/luau-lsp"
curl -fsSL --retry 3 "https://raw.githubusercontent.com/JohnnyMorganz/luau-lsp/$version/scripts/globalTypes.None.d.luau" -o "$dir/roblox.d.luau"
test "$(git hash-object "$dir/roblox.d.luau")" = "674fd4f5d95eaf5d0061ab403b1648c6fd341b80"
echo "$dir" >> "$GITHUB_PATH"
echo "ROBLOX_DEFINITIONS=$dir/roblox.d.luau" >> "$GITHUB_ENV"
