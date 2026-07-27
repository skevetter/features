#!/usr/bin/env bash

set -eo pipefail

main() {
    picolayer gh-release --owner Gentleman-Programming --repo engram --binary engram --version "$VERSION"
}

main "$@"
