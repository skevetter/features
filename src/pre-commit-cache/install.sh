#!/usr/bin/env bash

set -eo pipefail

. ./lib.sh

FEATURE_USER="${FEATURE_USER:-${_REMOTE_USER:-"vscode"}}"
PRE_COMMIT_CACHE_DIR="/pre_commit_cache"
NANOLAYER_VERSION="v0.5.6"

deploy() {
    mkdir -p "${PRE_COMMIT_CACHE_DIR}"
    chown "${FEATURE_USER}" "${PRE_COMMIT_CACHE_DIR}"
    chmod 700 "${PRE_COMMIT_CACHE_DIR}"

    {
        echo ""
        echo "# Pre-commit Cache Configuration"
        echo "export PRE_COMMIT_HOME=${PRE_COMMIT_CACHE_DIR}"
    } >> /etc/profile.d/pre_commit_cache.sh

    {
        echo ""
        echo "# Pre-commit Cache Configuration"
        echo "export PRE_COMMIT_HOME=${PRE_COMMIT_CACHE_DIR}"
    } >> /etc/bash.bashrc

    {
        echo ""
        echo "# Pre-commit Cache Configuration"
        echo "export PRE_COMMIT_HOME=${PRE_COMMIT_CACHE_DIR}"
    } >> /etc/zsh/zshrc

}

main() {
    echo "Ensuring nanolayer CLI (${NANOLAYER_VERSION}) is available"
    ensure_nanolayer nanolayer_location "${NANOLAYER_VERSION}"

    # shellcheck disable=SC2154
    "${nanolayer_location}" \
        install \
        devcontainer-feature \
        "ghcr.io/devcontainers-extra/features/bash-command:1" \
        --option command="$(setup_cache)"

    echo "Done!"
}

main "$@"
