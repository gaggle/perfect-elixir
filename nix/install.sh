#!/bin/zsh
set +euo pipefail

command -v nix-build &> /dev/null || {
  echo "Installing Nix..."; sh <(curl -L https://nixos.org/nix/install);
  echo "Nix installed, please restart terminal & re-run this script"
  exit 1
}

mkdir -p ~/.config/nix && echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf

command -v direnv &> /dev/null || {
  echo "Installing direnv..."; nix-env -iA nixpkgs.direnv;
}

grep -q 'eval "\$(direnv hook zsh)"' ~/.zshrc || {
  echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc
  echo "Hook added to .zshrc, please restart terminal & re-run this script"
  exit 1;
}

echo "Setup complete"
