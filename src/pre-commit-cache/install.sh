#!/usr/bin/env bash

set -eo pipefail

. ./lib.sh

USERNAME="${USERNAME:-${_REMOTE_USER:-"vscode"}}"
PRE_COMMIT_CACHE_DIR="/pre_commit_cache"
NANOLAYER_VERSION="v0.5.6"

main() {
    echo "Ensuring nanolayer CLI (${NANOLAYER_VERSION}) is available"
    ensure_nanolayer nanolayer_location "${NANOLAYER_VERSION}"

    CACHE_CONFIGURATION="
# Pre-commit Cache Configuration
export PRE_COMMIT_HOME=$PRE_COMMIT_CACHE_DIR
"

    CACHE_CONFIG_B64=$(echo "$CACHE_CONFIGURATION" | base64 -w 0)

    # shellcheck disable=SC2154
    "${nanolayer_location}" \
        install \
        devcontainer-feature \
        "ghcr.io/devcontainers-extra/features/bash-command:1" \
        --option command="echo ${CACHE_CONFIG_B64} | base64 -d | tee -a /etc/profile.d/pre_commit_cache.sh /etc/bash.bashrc /etc/zsh/zshrc > /dev/null"

    PRE_COMMIT_CACHE_DIR_SCRIPT="
    mkdir -p ${PRE_COMMIT_CACHE_DIR}
    chmod 700 ${PRE_COMMIT_CACHE_DIR}
    chown -R ${USERNAME} ${PRE_COMMIT_CACHE_DIR}
    "

    PRE_COMMIT_CACHE_DIR_B64=$(printf '%s' "$PRE_COMMIT_CACHE_DIR_SCRIPT" | base64 -w 0)

    # shellcheck disable=SC2154
    "${nanolayer_location}" \
        install \
        devcontainer-feature \
        "ghcr.io/devcontainers-extra/features/bash-command:1" \
        --option command="echo ${PRE_COMMIT_CACHE_DIR_B64} | base64 -d | bash"

    echo "Done!"
}

main "$@"
