#!/usr/bin/env bash

set -eo pipefail

. ./lib.sh

NANOLAYER_VERSION="v0.5.6"

init_precommit_hooks() {
    workspace_dir=$(find /workspaces -mindepth 2 -maxdepth 2 -type f -name '.pre-commit-config.yaml' -print -quit | xargs -0 -r dirname)
    if [ -n "$workspace_dir" ]; then
        echo "cd ${workspace_dir} && pre-commit install --install-hooks"
    else
        echo "echo 'No .pre-commit-config.yaml found in any workspace folder. Skipping pre-commit hook installation.'"
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
        --option command="$(init_precommit_hooks)"

    echo "Done!"
}

main "$@"
