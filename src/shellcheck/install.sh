#!/usr/bin/env bash

set -eo pipefail

main() {
    picolayer gh-release --owner koalaman --repo shellcheck --version "$VERSION"
}

main "$@"
