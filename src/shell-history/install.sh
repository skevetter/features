#!/usr/bin/env bash

set -eo pipefail

. ./lib.sh

FEATURE_USER="${FEATURE_USER:-${_REMOTE_USER:-"vscode"}}"
SHELLHISTORY_DIR="/shellhistory"
BASH_SHELLHISTORY_FILE="${SHELLHISTORY_DIR}/.bash_history"
ZSH_SHELLHISTORY_FILE="${SHELLHISTORY_DIR}/.zsh_history"
NANOLAYER_VERSION="v0.5.6"

setup_persistent_history() {
    mkdir -p "${SHELLHISTORY_DIR}"

    chown "${FEATURE_USER}" "${SHELLHISTORY_DIR}"
    chmod 700 "${SHELLHISTORY_DIR}"

    touch "${BASH_SHELLHISTORY_FILE}"
    chown "${FEATURE_USER}" "${BASH_SHELLHISTORY_FILE}"
    chmod 600 "${BASH_SHELLHISTORY_FILE}"

    {
        echo ""
        echo "# Shell History Configuration"
        echo "export HISTFILE=${BASH_SHELLHISTORY_FILE}"
    } >>/etc/bash.bashrc

    touch "${ZSH_SHELLHISTORY_FILE}"
    chown "${FEATURE_USER}" "${ZSH_SHELLHISTORY_FILE}"
    chmod 600 "${ZSH_SHELLHISTORY_FILE}"

    {
        echo ""
        echo "# Shell History Configuration"
        echo "export HISTFILE=${ZSH_SHELLHISTORY_FILE}"
    } >>/etc/zsh/zshrc

    # Ensure HISTFILE is also configured for non-interactive login shells
    # (the test invokes `zsh -lc`, which does not source zshrc)
    # zsh reads zprofile for login shells (interactive or not), so add it there too
    {
        echo ""
        echo "# Shell History Configuration"
        echo "export HISTFILE=${ZSH_SHELLHISTORY_FILE}"
    } >>/etc/zsh/zprofile

    # If oh-my-zsh is installed, also add to the user's .zshrc
    # because oh-my-zsh overwrites /etc/zsh/zshrc settings
    HOME_DIR="$(eval echo "~${FEATURE_USER}")"
    if [ -d "${HOME_DIR}/.oh-my-zsh" ]; then
        ZSHRC="${HOME_DIR}/.zshrc"
        touch "${ZSHRC}"
        chown "${FEATURE_USER}" "${ZSHRC}"
        chmod 644 "${ZSHRC}"

        if ! grep -qF "HISTFILE=${ZSH_SHELLHISTORY_FILE}" "${ZSHRC}"; then
            {
                echo ""
                echo "# Shell History Configuration"
                echo "export HISTFILE=${ZSH_SHELLHISTORY_FILE}"
            } >>"${ZSHRC}"
        fi
    else
        echo "oh-my-zsh not detected, skipping update to ${HOME_DIR}/.zshrc"
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
