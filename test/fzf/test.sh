#!/bin/bash

set -e

source dev-container-features-test-lib

USERNAME="${_REMOTE_USER:-"vscode"}"

#------------------------------------------------------------------------------
# Environment
#------------------------------------------------------------------------------

echo "==================== Test Environment ===================="
env
echo "=========================================================="

#------------------------------------------------------------------------------
# Check Installation
#------------------------------------------------------------------------------

echo "Testing fzf installation"

check "fzf is installed" command -v fzf

check "fzf version" fzf --version

# If VERSION is set and not "latest", check that the installed version matches
if [ -n "$VERSION" ] && [ "$VERSION" != "latest" ]; then
    echo "VERSION is set to '$VERSION', checking fzf version"
    check "fzf version is correct" fzf --version | grep -F "$VERSION"
else
    echo "VERSION is unset or set to 'latest'; skipping exact version check"
fi

#------------------------------------------------------------------------------
# Check RC Files (/etc/bash.bashrc and /etc/zsh/zshrc)
#------------------------------------------------------------------------------

check "bashrc includes fzf" grep -F "fzf" /etc/bash.bashrc

if [ -f /etc/zsh/zshrc ]; then
    echo "zshrc file exists; checking for fzf configuration"
    check "zshrc includes fzf" grep -F "fzf" /etc/zsh/zshrc
else
    echo "zshrc file does not exist; skipping fzf configuration check for zshrc"
fi

#------------------------------------------------------------------------------
# Check User .zshrc (when oh-my-zsh is installed)
#------------------------------------------------------------------------------

HOME_DIR="/home/${USERNAME}"
if [ -d "${HOME_DIR}/.oh-my-zsh" ]; then
    echo "oh-my-zsh is installed; checking user .zshrc for fzf configuration"
    ZSHRC="${HOME_DIR}/.zshrc"
    check "user .zshrc includes fzf" grep -F "fzf --zsh" "${ZSHRC}"
else
    echo "oh-my-zsh is not installed; skipping user .zshrc check"
fi

#------------------------------------------------------------------------------
# Results
#------------------------------------------------------------------------------

echo "Tests completed!"

reportResults
