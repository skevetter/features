#!/usr/bin/env bash

set -eo pipefail

main() {
    if command -v apt-get >/dev/null 2>&1; then
        apt-get update && apt-get install -y curl && apt-get autoremove -y && apt-get clean
    elif command -v apk >/dev/null 2>&1; then
        apk add --no-cache curl
    else
        echo "No supported package manager found" >&2; return 1
    fi
}

main "$@"
