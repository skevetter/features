#!/usr/bin/env bash

set -eo pipefail

. ./lib.sh

main() {
    echo "Ensuring picolayer CLI is available"
    ensure_picolayer

    echo "Installing Biome (version: ${VERSION})"
    # shellcheck disable=SC2154
    "${PICOLAYER_BIN}" \
        devcontainer-feature \
        "ghcr.io/devcontainers-extra/features/npm-package:1" \
        --option package='@biomejs/biome' --option version="$VERSION"

    echo "Done!"
}

main "$@"
