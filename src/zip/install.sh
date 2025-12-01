#!/usr/bin/env bash

set -eo pipefail

main() {
    if command -v zip >/dev/null 2>&1 && command -v unzip >/dev/null 2>&1; then
        return 0 # zip and unzip are already installed
    fi

    if command -v apt-get >/dev/null 2>&1; then
        apt-get update && apt-get install -y zip unzip && apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/*
    elif command -v apk >/dev/null 2>&1; then
        apk add --no-cache zip unzip
    else
        echo "No supported package manager found" >&2
        return 1
    fi
}

main "$@"
