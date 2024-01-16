#!/bin/zsh
set +euo pipefail

command -v brew &>/dev/null || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
command -v pkgx &>/dev/null || brew install pkgxdev/made/pkgx
command -v dev &>/dev/null || echo 'source <(pkgx --shellcode)' >> ~/.zshrc && source ~/.zshrc

echo "Setup complete."
