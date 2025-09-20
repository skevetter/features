#!/usr/bin/env bash

set -eo pipefail

. ./lib.sh

NANOLAYER_VERSION="v0.5.6"

main() {
    echo "Ensuring nanolayer CLI (${NANOLAYER_VERSION}) is available"
    ensure_nanolayer nanolayer_location "${NANOLAYER_VERSION}"

    local arch_suffix
    case "$(uname -m)" in
        x86_64|amd64) arch_suffix="x86_64" ;;
        aarch64|arm64) arch_suffix="arm64" ;;
        *) error "Unsupported architecture: $(uname -m)"; return 1 ;;
    esac

    echo "Installing Lazygit (version: ${VERSION})"
    # shellcheck disable=SC2154
    "${nanolayer_location}" \
        install \
        devcontainer-feature \
        "ghcr.io/devcontainers-extra/features/gh-release:1" \
        --option repo="jesseduffield/lazygit" \
        --option version="${VERSION}" \
        --option assetRegex="^lazygit_.*_linux_${arch_suffix}\\.tar\\.gz$" \
        --option binaryNames="lazygit"

    echo "Done!"
}

main "$@"
