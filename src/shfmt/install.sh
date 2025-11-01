#!/usr/bin/env bash

set -eo pipefail

main() {
    picolayer gh-release --owner mvdan --repo sh --binary shfmt --version "$VERSION"
}

main "$@"
