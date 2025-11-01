#!/usr/bin/env bash

set -eo pipefail

main() {
    picolayer npm "@biomejs/biome@${VERSION}"
}

main "$@"
