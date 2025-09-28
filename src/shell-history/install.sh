#!/usr/bin/env bash

set -eo pipefail

. ./lib.sh

USERNAME="${USERNAME:-${_REMOTE_USER:-"vscode"}}"
SHELLHISTORY_DIR="/shellhistory"
BASH_SHELLHISTORY_FILE="${SHELLHISTORY_DIR}/.bash_history"
ZSH_SHELLHISTORY_FILE="${SHELLHISTORY_DIR}/.zsh_history"
NANOLAYER_VERSION="v0.5.6"

setup_persistent_history() {
    mkdir -p "${SHELLHISTORY_DIR}"

    chown "${USERNAME}" "${SHELLHISTORY_DIR}"
    chmod 700 "${SHELLHISTORY_DIR}"

    touch "${BASH_SHELLHISTORY_FILE}"
    chown "${USERNAME}" "${BASH_SHELLHISTORY_FILE}"
    chmod 600 "${BASH_SHELLHISTORY_FILE}"

    {
        echo ""
        echo "# Shell History Configuration"
        echo "export HISTFILE=${BASH_SHELLHISTORY_FILE}"
    } >>/etc/bash.bashrc

    touch "${ZSH_SHELLHISTORY_FILE}"
    chown "${USERNAME}" "${ZSH_SHELLHISTORY_FILE}"
    chmod 600 "${ZSH_SHELLHISTORY_FILE}"

    {
        echo ""
        echo "# Shell History Configuration"
        echo "export HISTFILE=${ZSH_SHELLHISTORY_FILE}"
    } >>/etc/zsh/zshrc

    {
        echo ""
        echo "# Shell History Configuration"
        echo "export HISTFILE=${ZSH_SHELLHISTORY_FILE}"
    } >>/etc/profile.d/shell_history.sh

    # If oh-my-zsh is installed, also add to the user's .zshrc
    # because oh-my-zsh overwrites /etc/zsh/zshrc settings
    HOME_DIR="/home/${USERNAME}"
    if [ -d "${HOME_DIR}/.oh-my-zsh" ]; then
        ZSHRC="${HOME_DIR}/.zshrc"
        touch "${ZSHRC}"
        chown "${USERNAME}" "${ZSHRC}"
        chmod 644 "${ZSHRC}"

        if ! grep -qF "HISTFILE=${ZSH_SHELLHISTORY_FILE}" "${ZSHRC}"; then
            {
                echo ""
                echo "# Shell History Configuration"
                echo "export HISTFILE=${ZSH_SHELLHISTORY_FILE}"
            } >>"${ZSHRC}"
        fi
    fi
}

main() {
    echo "Ensuring nanolayer CLI (${NANOLAYER_VERSION}) is available"
    ensure_nanolayer nanolayer_location "${NANOLAYER_VERSION}"

    # shellcheck disable=SC2154
    "${nanolayer_location}" \
        install \
        devcontainer-feature \
        "ghcr.io/devcontainers-extra/features/bash-command:1" \
        --option command="$(setup_persistent_history)"

    echo "Done!"
}

main "$@"
