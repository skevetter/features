#!/usr/bin/env bash

set -eo pipefail

. ./lib.sh

NANOLAYER_VERSION="v0.5.6"

main() {
    echo "Ensuring nanolayer CLI (${NANOLAYER_VERSION}) is available"
    ensure_nanolayer nanolayer_location "${NANOLAYER_VERSION}"

    echo "Installing Biome (version: ${VERSION})"
    # shellcheck disable=SC2154
    "${nanolayer_location}" \
        install \
        devcontainer-feature \
        "ghcr.io/devcontainers-extra/features/npm-package:1" \
        --option package='@biomejs/biome' --option version="$VERSION"

    echo "Done!"
}

main "$@"
