#!/usr/bin/env bash

set -eo pipefail

. ./lib.sh

USERNAME="${USERNAME:-${_REMOTE_USER:-"vscode"}}"
PRE_COMMIT_CACHE_DIR="/pre_commit_cache"

install_config() {
    local config_file="${1:-base}"
    pre-commit install --install-hooks -c "config/$config_file.yaml"
}

preload() {
    echo "Preloading pre-commit hooks into cache directory: ${PRE_COMMIT_CACHE_DIR}"

    export PATH="/usr/local/py-utils/bin:$PATH"

    if ! command -v pre-commit &>/dev/null; then
        echo "pre-commit not found, installation failed"
        exit 1
    fi

    # Temporarily initialize a git repository to allow pre-commit to install hooks.
    # This is required because pre-commit refuses to install hooks outside of a git repo.
    git init -q
    git config user.name 'Dev Container Features'
    git config user.email 'dev@container'
    git config --local init.defaultBranch main

    install_config
    install_config "lua"
    install_config "shell"
    install_config "actions"

    if command -v python3 &>/dev/null || command -v python &>/dev/null; then
        install_config "python"
    fi

    if command -v go &>/dev/null; then
        install_config "golang"
    fi

    if command -v rustc &>/dev/null; then
        install_config "rust"
    fi

    if command -v node &>/dev/null; then
        install_config "biome"
    fi

    if command -v terraform &>/dev/null; then
        install_config "terraform"
    fi

    rm -rf .git
}

main() {
    export PRE_COMMIT_HOME="${PRE_COMMIT_CACHE_DIR}"

    # Create pre-commit cache directory
    mkdir -p "${PRE_COMMIT_CACHE_DIR}"
    chmod 700 "${PRE_COMMIT_CACHE_DIR}"

    if [ "${PRELOADHOOKS}" = "true" ]; then
        preload
    fi

    # Create group
    groupadd pre-commit

    # Add the user to the group
    usermod -aG pre-commit "$USERNAME"

    # Set group ownership
    chown -R :"pre-commit" "$PRE_COMMIT_HOME"

    # Allow user to update the cache
    chmod -R g+rwX "$PRE_COMMIT_HOME"

    # Update shell profiles
    {
        echo ""
        echo "# Pre-commit Cache Configuration"
        echo "export PRE_COMMIT_HOME=$PRE_COMMIT_CACHE_DIR"
    } >> /etc/profile.d/pre_commit_cache.sh

    {
        echo ""
        echo "# Pre-commit Cache Configuration"
        echo "export PRE_COMMIT_HOME=$PRE_COMMIT_CACHE_DIR"
    } >> /etc/bash.bashrc

    if [ -f /etc/zsh/zshrc ]; then
        {
            echo ""
            echo "# Pre-commit Cache Configuration"
            echo "export PRE_COMMIT_HOME=$PRE_COMMIT_CACHE_DIR"
        } >> /etc/zsh/zshrc
    fi

    echo "Done!"
}

main "$@"
