#!/usr/bin/env bash

set -eo pipefail

main() {
    picolayer gh-release --owner jesseduffield --repo lazygit --version "$VERSION"
}

main "$@"
