#!/usr/bin/env bash

set -eo pipefail

. ./lib.sh

NANOLAYER_VERSION="v0.5.6"

gpg_setup() {
    {
        echo ""
        echo "# GPG Configuration"
        echo "export GPG_TTY=\$(tty)"
    } >> /etc/bash.bashrc

    {
        echo ""
        echo "# GPG Configuration"
        echo "export GPG_TTY=\$(tty)"
    } >> /etc/zsh/zshrc

    mkdir -p /etc/gnupg

    {
        echo "use-agent"
        echo "pinentry-mode loopback"
    } >> /etc/gnupg/gpg.conf

    {
        echo "allow-loopback-pinentry"
        echo ""
        echo "# Cache settings"
        echo "default-cache-ttl 3600       # Default timeout for cache entries (in seconds)"
        echo "max-cache-ttl 28800          # Maximum time a cache entry is valid (8 hours)"
        echo ""
        echo "# For SSH keys managed by gpg-agent"
        echo "default-cache-ttl-ssh 3600   # Default timeout for SSH keys"
        echo "max-cache-ttl-ssh 28800      # Maximum timeout for SSH keys"
        echo ""
        echo "# Enable SSH support"
        echo "enable-ssh-support"
    } >> /etc/gnupg/gpg-agent.conf
}

main() {
    echo "Ensuring nanolayer CLI (${NANOLAYER_VERSION}) is available"
    ensure_nanolayer nanolayer_location "${NANOLAYER_VERSION}"

    # shellcheck disable=SC2154
    "${nanolayer_location}" \
        install \
        devcontainer-feature \
        "ghcr.io/devcontainers-extra/features/bash-command:1" \
        --option command="$(gpg_setup)"

    echo "Done!"
}

main "$@"
