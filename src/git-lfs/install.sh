#!/usr/bin/env bash

set -eo pipefail

main() {
    picolayer gh-release --owner git-lfs --repo git-lfs --binary git-lfs --version "$VERSION"

    if command -v git >/dev/null 2>&1; then
        git lfs install --system --skip-repo
    fi
}

main "$@"
