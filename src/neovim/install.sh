#!/usr/bin/env bash

set -eo pipefail

. ./lib.sh

NANOLAYER_VERSION="v0.5.6"

main() {
    echo "Ensuring nanolayer CLI (${NANOLAYER_VERSION}) is available"
    ensure_nanolayer nanolayer_location "${NANOLAYER_VERSION}"

    case "$(uname -s)" in
        Linux)
            os="linux"
            ;;
        Darwin)
            os="macos"
            ;;
        *)
            echo "Unsupported OS: $(uname -s)" >&2
            exit 1
            ;;
    esac

    case "$(uname -m)" in
        x86_64|amd64)
            arch="x86_64"
            ;;
        aarch64|arm64)
            arch="arm64"
            ;;
        *)
            arch="$(uname -m)"
            ;;
    esac

    asset_regex="nvim-${os}-${arch}\\.tar\\.gz$"

    echo "Detected OS=${os} ARCH=${arch} -> assetRegex=${asset_regex}"

    # shellcheck disable=SC2154
    "${nanolayer_location}" \
        install \
        devcontainer-feature \
        "ghcr.io/devcontainers-extra/features/gh-release:1" \
        --option repo='neovim/neovim' --option binaryNames='nvim' --option assetRegex="${asset_regex}" --option version="$VERSION"

    echo "Done!"
}

main "$@"
