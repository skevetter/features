#!/usr/bin/env bash

set -euo pipefail

DEFAULT_VERSION="latest"
DEFAULT_BASH_COMPLETION="true"

VERSION="${VERSION:-$DEFAULT_VERSION}"
BASH_COMPLETION="${BASHCOMPLETION:-$DEFAULT_BASH_COMPLETION}"
TARGET_USER="${_REMOTE_USER:-${_CONTAINER_USER:-${USERNAME:-vscode}}}"

check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
        exit 1
    fi
}

check_packages() {
    if ! dpkg -s "$@" >/dev/null 2>&1; then
        if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
            echo "Running apt-get update..."
            apt-get update -y
        fi
        apt-get -y install --no-install-recommends "$@"
    fi
}

setup_symlink() {
    if ! command -v pulumi >/dev/null 2>&1 && [ -x "$HOME/.pulumi/bin/pulumi" ]; then
        sudo ln -sf "$HOME/.pulumi/bin/pulumi" /usr/local/bin/pulumi
    fi
}

setup_completion() {
    if [ "$BASH_COMPLETION" = "true" ] && command -v pulumi >/dev/null 2>&1; then
        pulumi gen-completion bash | sudo tee /etc/bash_completion.d/pulumi > /dev/null
    elif [ "$BASH_COMPLETION" = "true" ] && [ -x "$HOME/.pulumi/bin/pulumi" ]; then
        "$HOME/.pulumi/bin/pulumi" gen-completion bash | sudo tee /etc/bash_completion.d/pulumi > /dev/null
    fi
}

main() {
    check_root
    check_packages ca-certificates curl

    sudo -iu "$TARGET_USER" <<EOF
        set -eo pipefail

        if [ ! -f "\$HOME/.bashrc" ] || [ ! -s "\$HOME/.bashrc" ]; then
            cp /etc/skel/.bashrc "\$HOME/.bashrc"
        fi
        if [ ! -f "\$HOME/.profile" ] || [ ! -s "\$HOME/.profile" ]; then
            cp /etc/skel/.profile "\$HOME/.profile"
        fi

        if [ "\$VERSION" = "latest" ]; then
            curl --retry 3 --retry-delay 5 -fsSL https://get.pulumi.com | sh
        else
            curl --retry 3 --retry-delay 5 -fsSL https://get.pulumi.com | sh -s -- --version "\$VERSION"
        fi
EOF

    setup_symlink
    setup_completion
    rm -rf /var/lib/apt/lists/*
}

main
