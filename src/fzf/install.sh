#!/usr/bin/env bash

set -eo pipefail

. ./lib.sh

NANOLAYER_VERSION="v0.5.6"

main() {
    echo "Ensuring nanolayer CLI (${NANOLAYER_VERSION}) is available"
    ensure_nanolayer nanolayer_location "${NANOLAYER_VERSION}"

    # shellcheck disable=SC2154
    "${nanolayer_location}" \
        install \
        devcontainer-feature \
        "ghcr.io/devcontainers-extra/features/gh-release:1" \
        --option repo='junegunn/fzf' --option binaryNames='fzf' --option version="$VERSION"

    {
        echo ""
        echo "# fzf Configuration"
        echo "eval \"\$(fzf --bash)\""
    } >> /etc/bash.bashrc

    {
        echo ""
        echo "# fzf Configuration"
        echo "source <(fzf --zsh)"
    } >> /etc/zsh/zshrc

    echo "Done!"
}

main "$@"
