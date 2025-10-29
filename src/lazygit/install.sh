#!/usr/bin/env bash

set -eo pipefail

. ./lib.sh

main() {
     echo "Ensuring picolayer CLI is available"
    ensure_picolayer

    echo "Installing Lazygit (version: ${VERSION})"
    "${PICOLAYER_BIN}" gh-release --owner jesseduffield --repo lazygit --version "$VERSION"

    echo "Done!"
}

main "$@"
