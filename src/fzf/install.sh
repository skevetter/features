#!/usr/bin/env bash

set -eo pipefail

. ./lib.sh

main() {
    echo "Ensuring picolayer CLI is available"
    ensure_picolayer

    echo "Installing Biome (version: ${VERSION})"
    "${PICOLAYER_BIN}" gh-release --owner junegunn --repo fzf --version "$VERSION"

    {
        echo ""
        echo "# fzf Configuration"
        echo "eval \"\$(fzf --bash)\""
    } >> /etc/bash.bashrc

    if [ -f /etc/zsh/zshrc ]; then
        {
            echo ""
            echo "# fzf Configuration"
            echo "source <(fzf --zsh)"
        } >> /etc/zsh/zshrc
    fi

    echo "Done!"
}

main "$@"
