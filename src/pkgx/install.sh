#!/usr/bin/env bash

set -eo pipefail

setup() {
    if command -v apt-get >/dev/null 2>&1; then
        apt-get update && apt-get install -y curl
    elif command -v apk >/dev/null 2>&1; then
        apk add --no-cache curl
    else
        echo "No supported package manager found" >&2; return 1
    fi
}

main() {
    setup

    curl https://pkgx.sh | sh

    echo "Done!"
}

main "$@"
