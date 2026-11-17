#!/usr/bin/env bash
set -euo pipefail
dir="$(mktemp -d)"
curl -fsSL --retry 3 https://github.com/luau-lang/luau/releases/download/0.744/luau-ubuntu.zip -o "$dir/luau.zip"
echo "6506f0852c623aaffcb28494aac16c26dc04a269ea0e16cc0aafc8c8ac79f3ec  $dir/luau.zip" | sha256sum -c -
unzip -q "$dir/luau.zip" -d "$dir"
chmod +x "$dir/luau" "$dir/luau-compile"
echo "$dir" >> "$GITHUB_PATH"