#!/usr/bin/env bash

set -eo pipefail

main() {
    picolayer npm "@getpaseo/cli@${VERSION}"
}

main "$@"
