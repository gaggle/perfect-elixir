#!/bin/zsh
set +euo pipefail

command -v nix-build &> /dev/null || { echo "Installing Nix..."; sh <(curl -L https://nixos.org/nix/install); }
command -v direnv &> /dev/null || { echo "Installing direnv..."; nix-env -iA nixpkgs.direnv; }
type direnv &>/dev/null || {
    echo 'Direnv is not active. Activate it like this: eval "$(direnv hook zsh)" >> ~/.zshrc; source ~/.zshrc';
    exit 1;
}
echo "Setup complete."
