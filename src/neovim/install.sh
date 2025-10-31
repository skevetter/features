#!/usr/bin/env bash

set -eo pipefail

setup_picolayer() {
    PICOLAYER_BIN=$(curl -fsSL  https://raw.githubusercontent.com/skevetter/picolayer/main/install.sh | bash)
}

setup() {
    if command -v apt-get >/dev/null 2>&1; then
        apt-get update && apt-get install -y curl
    elif command -v apk >/dev/null 2>&1; then
        apk add --no-cache curl
    else
        echo "No supported package manager found" >&2; return 1
    fi

    setup_picolayer
}

cleanup() {
    if command -v apt-get >/dev/null 2>&1; then
        apt-get remove -y curl && apt-get autoremove -y && apt-get clean
    elif command -v apk >/dev/null 2>&1; then
        apk del curl
    fi
}

main() {
    setup

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

    echo "Detected OS=${os} ARCH=${arch} -> Filter=${asset_regex}"

    "${PICOLAYER_BIN}" gh-release --owner neovim --repo neovim --binary nvim --filter "${asset_regex}" --version "$VERSION"

    echo "Done!"
    cleanup
}

main "$@"
