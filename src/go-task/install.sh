#!/usr/bin/env bash

set -eo pipefail

main() {
    picolayer gh-release --owner go-task --repo task --binary task --version "$VERSION"
}

main "$@"
