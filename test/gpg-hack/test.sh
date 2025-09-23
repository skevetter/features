#!/bin/bash

set -e

source dev-container-features-test-lib

# The 'check' command comes from the dev-container-features-test-lib.
check "verify /etc/gnupg/gpg.conf is present" test -f /etc/gnupg/gpg.conf
check "verify /etc/gnupg/gpg-agent.conf is present" test -f /etc/gnupg/gpg-agent.conf
check "verify GPG_TTY is set in bashrc" grep -q "export GPG_TTY=$(tty)" /etc/bash.bashrc
check "verify GPG_TTY is set in zshrc" grep -q "export GPG_TTY=$(tty)" /etc/zsh/zshrc

reportResults
