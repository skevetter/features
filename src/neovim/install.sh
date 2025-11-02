#!/usr/bin/env bash

set -eo pipefail

main() {
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
        x86_64 | amd64)
            arch="x86_64"
            ;;
        aarch64 | arm64)
            arch="arm64"
            ;;
        *)
            arch="$(uname -m)"
            ;;
    esac

    asset_regex="nvim-${os}-${arch}\\.tar\\.gz$"

    echo "Detected OS=${os} ARCH=${arch} -> Filter=${asset_regex}"

    picolayer gh-release --owner neovim --repo neovim --binary nvim --filter "${asset_regex}" --version "$VERSION"
}

main "$@"
