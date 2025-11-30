#!/usr/bin/env bash

set -eo pipefail

USERNAME="${USERNAME:-${_REMOTE_USER:-"vscode"}}"

main() {
    picolayer gh-release --owner junegunn --repo fzf --version "$VERSION"

    {
        echo ""
        echo "# fzf Configuration"
        echo "eval \"\$(fzf --bash)\""
    } >>/etc/bash.bashrc

    if [ -f /etc/zsh/zshrc ]; then
        {
            echo ""
            echo "# fzf Configuration"
            echo "source <(fzf --zsh)"
        } >>/etc/zsh/zshrc
    fi

    # If oh-my-zsh is installed, also add to the user's .zshrc
    # because oh-my-zsh overwrites /etc/zsh/zshrc settings
    HOME_DIR="/home/${USERNAME}"
    if [ -d "${HOME_DIR}/.oh-my-zsh" ]; then
        ZSHRC="${HOME_DIR}/.zshrc"
        touch "${ZSHRC}"
        chown "${USERNAME}" "${ZSHRC}"
        chmod 644 "${ZSHRC}"

        if ! grep -qF "fzf --zsh" "${ZSHRC}"; then
            {
                echo ""
                echo "# fzf Configuration"
                echo "source <(fzf --zsh)"
            } >>"${ZSHRC}"
        fi
    fi
}

main "$@"
