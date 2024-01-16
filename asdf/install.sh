#!/usr/bin/env zsh
set +euo pipefail

brew install coreutils curl git
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.13.1
echo '. "$HOME/.asdf/asdf.sh"' >> ~/.zshrc
asdf plugin add erlang https://github.com/asdf-vm/asdf-erlang.git
asdf plugin-add elixir https://github.com/asdf-vm/asdf-elixir.git
asdf plugin-add postgres

brew install autoconf openssl@1.1 openssl libxslt fop gcc readline zlib curl ossp-uuid
export KERL_CONFIGURE_OPTIONS="--without-javac --with-ssl=$(brew --prefix openssl@1.1)"

asdf install
