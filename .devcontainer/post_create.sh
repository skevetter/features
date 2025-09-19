#!/bin/bash

set -eo pipefail

sudo cp .devcontainer/welcome.txt /usr/local/etc/vscode-dev-containers/first-run-notice.txt

sudo chown -R vscode:vscode /cmd_history

if ! command -v git &>/dev/null; then
  sudo apt-get update && sudo apt-get install -y git
fi

if ! command -v npm &>/dev/null; then
  sudo apt-get update && sudo apt-get install -y npm
  sudo /usr/bin/npm install -g @biomejs/biome # required for pre-commit hook
fi

pre-commit install --install-hooks
pre-commit run --all-files

TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": *"v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit -D -t /usr/local/bin/
cd - >/dev/null
rm -rf "$TMP_DIR"

# Install go tasks
sudo sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b /usr/local/bin
