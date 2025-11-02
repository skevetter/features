#!/usr/bin/env bash

set -eo pipefail

main() {
    if [ -n "$INSTALLDIRECTORY" ]; then
        mkdir -p "$INSTALLDIRECTORY"
        export PICOLAYER_INSTALL_DIR="$INSTALLDIRECTORY"
    fi

    if [ -n "$VERSION" ]; then
        export PICOLAYER_VERSION="$VERSION"
    fi

    curl -fsSL https://raw.githubusercontent.com/skevetter/picolayer/main/install.sh | bash
}

main "$@"
