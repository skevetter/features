#!/usr/bin/env bash

set -eo pipefail

. ./lib.sh

main() {
    echo "Ensuring nanolayer CLI (${NANOLAYER_VERSION}) is available"
    ensure_nanolayer nanolayer_location "${NANOLAYER_VERSION}"

    local arch_suffix
    case "$(uname -m)" in
        x86_64|amd64) arch_suffix="x64" ;;
        aarch64|arm64) arch_suffix="arm64" ;;
        *) error "Unsupported architecture: $(uname -m)"; return 1 ;;
    esac

    echo "Installing Pulumi (version: ${VERSION})"
    # shellcheck disable=SC2154
    "${nanolayer_location}" \
        install \
        devcontainer-feature \
        "ghcr.io/devcontainers-extra/features/gh-release:1" \
        --option repo="pulumi/pulumi" \
        --option version="${VERSION}" \
        --option assetRegex="^pulumi-.*-linux-${arch_suffix}\\.tar\\.gz$" \
        --option binaryNames="pulumi"

    echo "Done!"
}

main "$@"
