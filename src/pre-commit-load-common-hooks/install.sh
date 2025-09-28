#!/usr/bin/env bash

# TODO: Instead of installing hooks as user, create a group pre-commit and set group ownership of /pre_commit_cache to that group
# and add the user to that group. This would allow multiple users to share the same cache.

set -eo pipefail

. ./lib.sh

USERNAME="${USERNAME:-${_REMOTE_USER:-"vscode"}}"
PRE_COMMIT_HOME="/pre_commit_cache"
NANOLAYER_VERSION="v0.5.6"

install_config() {
    local config_file="${1:-base}"

    CONFIG_CONTENT=$(cat "config/${config_file}.yaml")

    SCRIPT="export PATH=/usr/local/py-utils/bin:\$PATH
git init -q /tmp/feature_repo
cd /tmp/feature_repo
git config user.name 'Dev Container Features'
git config user.email 'dev@container'
git config --local init.defaultBranch main

cat > .pre-commit-config.yaml << 'EOF'
${CONFIG_CONTENT}
EOF

PRE_COMMIT_HOME=$PRE_COMMIT_HOME pre-commit install --install-hooks"

    SCRIPT_B64=$(printf '%s' "$SCRIPT" | base64 -w 0)

    # shellcheck disable=SC2154
    "${nanolayer_location}" \
        install \
        devcontainer-feature \
        "ghcr.io/devcontainers-extra/features/bash-command:1" \
        --option command="su - $USERNAME bash -c 'echo ${SCRIPT_B64} | base64 -d | bash'"
}

main() {
    echo "Ensuring nanolayer CLI (${NANOLAYER_VERSION}) is available"
    ensure_nanolayer nanolayer_location "${NANOLAYER_VERSION}"

    export PATH="/usr/local/py-utils/bin:$PATH"

    if ! command -v pre-commit &> /dev/null; then
        echo "pre-commit not found, installation failed"
        exit 1
    fi

    ls -la /pre_commit_cache || true

    install_config
    install_config "python"
    install_config "lua"
    install_config "shell"

    ls -la /pre_commit_cache || true

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
}

main "$@"
