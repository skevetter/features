#!/usr/bin/env bash

set -eo pipefail

CONFIG_DIR="$(git rev-parse --show-toplevel)/src/pre-commit-cache/config"

main() {
    for config_file in "$CONFIG_DIR"/*.yaml; do
        if [ -f "$config_file" ]; then
            pre-commit autoupdate --config "$config_file"
        fi
    done
}

main "$@"
