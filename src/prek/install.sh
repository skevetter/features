#!/usr/bin/env bash

set -eo pipefail

main() {
    picolayer gh-release --owner j178 --repo prek --version "$VERSION"
}

main "$@"
