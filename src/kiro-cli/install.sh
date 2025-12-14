#!/usr/bin/env bash

set -eo pipefail

USERNAME="${USERNAME:-${_REMOTE_USER:-"vscode"}}"
INSTALL_SOURCE="${HOME}/.local/bin"
INSTALL_DEST="/usr/local/bin"

main() {
    # The installer installs to $HOME/.local/bin
    curl -fsSL https://cli.kiro.dev/install | bash

    for binary in kiro-cli kiro-cli-chat kiro-cli-term; do
        mv "$INSTALL_SOURCE/$binary" "$INSTALL_DEST/"
        chmod +x "$INSTALL_DEST/$binary"
    done

    echo "Done!"
}

main "$@"
