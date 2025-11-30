#!/bin/bash

set -e

source dev-container-features-test-lib

#------------------------------------------------------------------------------
# Environment
#------------------------------------------------------------------------------

echo "==================== Test Environment ===================="
env
echo "=========================================================="

#------------------------------------------------------------------------------
# Configuration File Checks
#------------------------------------------------------------------------------

echo "Testing GPG configuration files"

check "verify /etc/gnupg/gpg.conf is present" test -f /etc/gnupg/gpg.conf
check "verify /etc/gnupg/gpg-agent.conf is present" test -f /etc/gnupg/gpg-agent.conf

#------------------------------------------------------------------------------
# Shell Configuration Checks
#------------------------------------------------------------------------------

echo "Testing shell configuration"

check "verify GPG_TTY is set in bashrc" grep -q "export GPG_TTY=\$(tty)" /etc/bash.bashrc

#------------------------------------------------------------------------------
# Report Results
#------------------------------------------------------------------------------

echo "Tests completed!"

reportResults
