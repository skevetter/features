#!/usr/bin/env bash

set -eo pipefail

main() {
    picolayer gh-release --owner pulumi --repo pulumi --version "$VERSION"
}

main "$@"
