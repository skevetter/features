#!/usr/bin/env bash

set -eo pipefail

. ./lib.sh

NANOLAYER_VERSION="v0.5.6"

main() {
    echo "Ensuring nanolayer CLI (${NANOLAYER_VERSION}) is available"
    ensure_nanolayer nanolayer_location "${NANOLAYER_VERSION}"

    echo "Installing Pulumi (version: ${VERSION})"
    # shellcheck disable=SC2154
    "${nanolayer_location}" \
        install \
        devcontainer-feature \
        "ghcr.io/devcontainers-extra/features/gh-release:1" \
        --option repo="pulumi/pulumi" --option binaryNames="pulumi" --option version="${VERSION}"

    echo "Done!"
}

main "$@"
