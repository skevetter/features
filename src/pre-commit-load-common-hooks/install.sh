#!/usr/bin/env bash

set -eo pipefail

. ./lib.sh

USERNAME="${USERNAME:-${_REMOTE_USER:-"vscode"}}"

install_config() {
    local config_file="${1:-base}"
    pre-commit install --install-hooks -c "config/$config_file.yaml"
}

main() {
    export PATH="/usr/local/py-utils/bin:$PATH"

    if ! command -v pre-commit &> /dev/null; then
        echo "pre-commit not found, installation failed"
        exit 1
    fi

    export PRE_COMMIT_HOME="/pre_commit_cache"

    git init -q
    git config user.name 'Dev Container Features'
    git config user.email 'dev@container'
    git config --local init.defaultBranch main

    install_config
    install_config "python"
    install_config "lua"
    install_config "shell"
    install_config "actions"

    if command -v go &> /dev/null; then
        install_config "golang"
    fi

    if command -v rustc &> /dev/null; then
        install_config "rust"
    fi

    if command -v node &> /dev/null; then
        install_config "biome"
    fi

    if command -v terraform &> /dev/null; then
        install_config "terraform"
    fi

    # Create the pre-commit group
    groupadd pre-commit

    # Add the user to the pre-commit group
    usermod -aG pre-commit "$USERNAME"

    # Set ownership to the pre-commit group
    chown -R :"pre-commit" "$PRE_COMMIT_HOME"

    # Allow group read, write, and execute to allow vscode user to update the cache
    chmod -R g+rwX "$PRE_COMMIT_HOME"

    rm -rf .git
}

main "$@"
