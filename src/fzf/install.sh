#!/usr/bin/env bash

set -eo pipefail

setup_picolayer() {
    PICOLAYER_BIN=$(curl -fsSL  https://raw.githubusercontent.com/skevetter/picolayer/main/install.sh | bash)
}


setup() {
    if command -v apt-get >/dev/null 2>&1; then
        apt-get update && apt-get install -y curl
    elif command -v apk >/dev/null 2>&1; then
        apk add --no-cache curl
    else
        echo "No supported package manager found" >&2; return 1
    fi

    setup_picolayer
}

cleanup() {
    if command -v apt-get >/dev/null 2>&1; then
        apt-get remove -y curl && apt-get autoremove -y && apt-get clean
    elif command -v apk >/dev/null 2>&1; then
        apk del curl
    fi
}

main() {
    setup

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
    cleanup
}

main "$@"
