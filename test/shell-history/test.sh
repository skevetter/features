#!/bin/bash

set -e

source dev-container-features-test-lib

SHELLHISTORY_DIR="/shellhistory"
BASH_HISTFILE="/shellhistory/.bash_history"
ZSH_HISTFILE="/shellhistory/.zsh_history"

#------------------------------------------------------------------------------
# Environment
#------------------------------------------------------------------------------

echo "==================== Test Environment ===================="
env
echo "=========================================================="

#------------------------------------------------------------------------------
# Installation Checks
#------------------------------------------------------------------------------

echo "Testing shell history installation and directory..."

# Verify shell history directory exists
check "${SHELLHISTORY_DIR} is present" test -d ${SHELLHISTORY_DIR}

# Verify shell history directory is owned by group shellhistory
check "${SHELLHISTORY_DIR} is owned by group shellhistory" stat -c '%G' ${SHELLHISTORY_DIR} | grep shellhistory

# Verify bash history file exists
check "${BASH_HISTFILE} is present" test -f ${BASH_HISTFILE}

# Verify bash history file is owned by group shellhistory
check "${BASH_HISTFILE} is owned by group shellhistory" stat -c '%G' ${BASH_HISTFILE} | grep shellhistory

# Verify zsh history file exists
check "${ZSH_HISTFILE} is present" test -f ${ZSH_HISTFILE}

# Verify zsh history file is owned by group shellhistory
check "${ZSH_HISTFILE} is owned by group shellhistory" stat -c '%G' ${ZSH_HISTFILE} | grep shellhistory

#------------------------------------------------------------------------------
# RC File Checks
#------------------------------------------------------------------------------

check "bashrc contains HISTFILE" grep -q 'HISTFILE=/shellhistory/.bash_history' /etc/bash.bashrc

check "profile.d file exists" test -f /etc/profile.d/shell_history.sh

check "profile.d contains HISTFILE" grep -q "HISTFILE=/shellhistory/.zsh_history" /etc/profile.d/shell_history.sh

if [ -f /etc/zsh/zshrc ]; then
    check "zshrc contains HISTFILE" grep -q "HISTFILE=/shellhistory/.zsh_history" /etc/zsh/zshrc
fi

#------------------------------------------------------------------------------
# User and Group Verification
#------------------------------------------------------------------------------

if [ "$(id -u)" -eq 0 ]; then
    echo "Running as root, skipping user checks."
    reportResults
    exit 0
fi

echo "Testing user permissions and group membership..."

# Verify vscode user exists and has correct group membership
check "user vscode exists" id -u vscode

check "user vscode is in group shellhistory" id -nG vscode | grep -qw shellhistory

echo "=== Current User Context ==="
echo "Current user is $(whoami)"
echo "Current user id is $(id -u)"
echo "Current group id is $(id -g)"
echo "Current groups are $(id -nG)"
echo "================================"

#------------------------------------------------------------------------------
# Write Permission Tests
#------------------------------------------------------------------------------

echo "Testing write permissions to history files..."

# Test that the current user can write to the bash history file
check "can write to ${BASH_HISTFILE}" bash -c "echo '# test' >> ${BASH_HISTFILE}"

# Test that the current user can write to the zsh history file
check "can write to ${ZSH_HISTFILE}" bash -c "echo '# test' >> ${ZSH_HISTFILE}"

#------------------------------------------------------------------------------
# Report Results
#------------------------------------------------------------------------------

echo "Tests completed!"

reportResults
