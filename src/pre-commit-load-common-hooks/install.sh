#!/usr/bin/env bash

set -eo pipefail

. ./lib.sh

PRE_COMMIT_HOME="/pre_commit_cache"
PRE_COMMIT_DEFAULT_BIN="/usr/local/py-utils/bin/pre-commit"
NANOLAYER_VERSION="v0.5.6"

deploy() {
    export PRE_COMMIT_HOME

    if [ -z "${PRE_COMMIT_BIN}" ] ; then
        if type pre-commit >/dev/null 2>&1; then
            PRE_COMMIT_BIN=pre-commit
        elif [ -x "$PRE_COMMIT_DEFAULT_BIN" ] ; then
            PRE_COMMIT_BIN=$PRE_COMMIT_DEFAULT_BIN
        else
            echo "pre-commit is not installed or not found in PATH"
            exit 1
        fi
    fi

    git init --quiet

    install_cfgs=(base lua shell python)

    if command -v node >/dev/null 2>&1; then
        install_cfgs+=(biome)
    else
        echo "Skipping Biome hook installation."
    fi

    if command -v rustc >/dev/null 2>&1; then
        install_cfgs+=(rust)
    else
        echo "Skipping Rust hook installation."
    fi

    if command -v go >/dev/null 2>&1; then
        install_cfgs+=(golang)
    else
        echo "Skipping Go hook installation."
    fi

    if command -v terraform >/dev/null 2>&1; then
        install_cfgs+=(terraform)
    else
        echo "Skipping Terraform hook installation."
    fi

    for cfg in "${install_cfgs[@]}"; do
        "$PRE_COMMIT_BIN" install --install-hooks -c "config/${cfg}.yaml" || {
            echo "Failed to install ${cfg} hooks"
        }
    done

    rm -rf .git
}

main() {
    echo "Ensuring nanolayer CLI (${NANOLAYER_VERSION}) is available"
    ensure_nanolayer nanolayer_location "${NANOLAYER_VERSION}"

    # shellcheck disable=SC2154
    "${nanolayer_location}" \
        install \
        devcontainer-feature \
        "ghcr.io/devcontainers-extra/features/bash-command:1" \
        --option command="$deploy"

    echo "Done!"
}

main "$@"
