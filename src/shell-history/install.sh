#!/usr/bin/env bash

set -eo pipefail

USERNAME="${USERNAME:-${_REMOTE_USER:-"vscode"}}"
SHELLHISTORY_DIR="/shellhistory"
BASH_SHELLHISTORY_FILE="${SHELLHISTORY_DIR}/.bash_history"
ZSH_SHELLHISTORY_FILE="${SHELLHISTORY_DIR}/.zsh_history"
NANOLAYER_VERSION="v0.5.6"

main() {
    # Create shell history directory
    mkdir -p "${SHELLHISTORY_DIR}"
    chmod 700 "${SHELLHISTORY_DIR}"

    # Update bash configuration
    {
        echo ""
        echo "# Shell History Configuration"
        echo "export HISTFILE=${BASH_SHELLHISTORY_FILE}"
    } >>/etc/bash.bashrc

    # Update profile.d configuration
    {
        echo ""
        echo "# Shell History Configuration"
        echo "export HISTFILE=${ZSH_SHELLHISTORY_FILE}"
    } >>/etc/profile.d/shell_history.sh

    # Update zsh configuration if present
    if [ -f /etc/zsh/zshrc ]; then
        {
            echo ""
            echo "# Shell History Configuration"
            echo "export HISTFILE=${ZSH_SHELLHISTORY_FILE}"
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

        if ! grep -qF "HISTFILE=${ZSH_SHELLHISTORY_FILE}" "${ZSHRC}"; then
            {
                echo ""
                echo "# Shell History Configuration"
                echo "export HISTFILE=${ZSH_SHELLHISTORY_FILE}"
            } >>"${ZSHRC}"
        fi
    fi

    # Create group
    if ! getent group shellhistory >/dev/null 2>&1; then
        groupadd shellhistory
    fi

    # Add the user to the group
    usermod -aG shellhistory "$USERNAME"

    # Set group ownership
    chown -R :"shellhistory" "$SHELLHISTORY_DIR"

    # Allow user to update the history files
    chmod -R g+rwX "$SHELLHISTORY_DIR"

    # Create bash history file
    touch "${BASH_SHELLHISTORY_FILE}"
    chown :"shellhistory" "${BASH_SHELLHISTORY_FILE}"
    chmod 660 "${BASH_SHELLHISTORY_FILE}"

    # Create zsh history file
    touch "${ZSH_SHELLHISTORY_FILE}"
    chown :"shellhistory" "${ZSH_SHELLHISTORY_FILE}"
    chmod 660 "${ZSH_SHELLHISTORY_FILE}"

    echo "Done!"
}

main "$@"
