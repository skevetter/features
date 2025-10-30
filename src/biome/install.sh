#!/usr/bin/env bash

set -eo pipefail

setup_picolayer() {
    PICOLAYER_BIN=$(curl -fsSL  https://raw.githubusercontent.com/skevetter/picolayer/refs/heads/main/install.sh | bash)
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

    echo "Installing Biome (version: ${VERSION})"
    # shellcheck disable=SC2154
    "${PICOLAYER_BIN}" \
        devcontainer-feature \
        "ghcr.io/devcontainers-extra/features/npm-package:1" \
        --option package='@biomejs/biome' --option version="$VERSION"

    echo "Done!"
    cleanup
}

main "$@"
