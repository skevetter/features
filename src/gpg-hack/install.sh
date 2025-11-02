#!/usr/bin/env bash

set -eo pipefail

main() {
    {
        echo ""
        echo "# GPG Configuration"
        echo "export GPG_TTY=\$(tty)"
    } >>/etc/bash.bashrc

    if [ -f /etc/zsh/zshrc ]; then
        {
            echo ""
            echo "# GPG Configuration"
            echo "export GPG_TTY=\$(tty)"
        } >>/etc/zsh/zshrc
    fi

    mkdir -p /etc/gnupg

    {
        echo "use-agent"
        echo "pinentry-mode loopback"
    } >>/etc/gnupg/gpg.conf

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
    } >>/etc/gnupg/gpg-agent.conf

    echo "Done!"
}

main "$@"
