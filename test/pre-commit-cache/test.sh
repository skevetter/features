#!/bin/bash

set -e

source dev-container-features-test-lib

EXPECTED_HOOKS=9
PRE_COMMIT_CACHE_DIR="/pre_commit_cache"

#------------------------------------------------------------------------------
# Environment
#------------------------------------------------------------------------------

echo "==================== Test Environment ===================="
env
echo "=========================================================="

#------------------------------------------------------------------------------
# Installation Checks
#------------------------------------------------------------------------------

echo "Testing pre-commit installation and cache directory"

echo "Cache directory contents:"
ls -la ${PRE_COMMIT_CACHE_DIR}

# Verify pre-commit cache directory exists and has correct ownership
check "${PRE_COMMIT_CACHE_DIR} is present" test -d ${PRE_COMMIT_CACHE_DIR}

# Verify pre-commit cache directory ownership
check "owner of ${PRE_COMMIT_CACHE_DIR}" stat -c '%U' ${PRE_COMMIT_CACHE_DIR}

# Verify pre-commit cache directory is owned by group pre-commit
check "${PRE_COMMIT_CACHE_DIR} is owned by group pre-commit" stat -c '%G' ${PRE_COMMIT_CACHE_DIR} | grep pre-commit

# Verify pre-commit command is available
check "pre-commit is installed" command -v pre-commit

#------------------------------------------------------------------------------
# RC File Checks
#------------------------------------------------------------------------------

check "PRE_COMMIT_HOME is set" test -n "$PRE_COMMIT_HOME"

check "PRE_COMMIT_HOME is set to ${PRE_COMMIT_CACHE_DIR}" test "$PRE_COMMIT_HOME" = "${PRE_COMMIT_CACHE_DIR}"

check "profile.d file exists" test -f /etc/profile.d/pre_commit_cache.sh

check "profile.d contains PRE_COMMIT_HOME" grep -q "PRE_COMMIT_HOME=${PRE_COMMIT_CACHE_DIR}" /etc/profile.d/pre_commit_cache.sh

check "bashrc contains PRE_COMMIT_HOME" grep -q "PRE_COMMIT_HOME=${PRE_COMMIT_CACHE_DIR}" /etc/bash.bashrc

if [ -f /etc/zsh/zshrc ]; then
    check "zshrc contains PRE_COMMIT_HOME" grep -q "PRE_COMMIT_HOME=${PRE_COMMIT_CACHE_DIR}" /etc/zsh/zshrc
fi

#------------------------------------------------------------------------------
# Hook Installation Verification
#------------------------------------------------------------------------------

echo "Verifying pre-installed hooks"

actual_hooks=$(find ${PRE_COMMIT_CACHE_DIR} -maxdepth 1 -mindepth 1 -type d -name 'repo*' | wc -l)

echo "Found $actual_hooks pre-installed hooks (expected $EXPECTED_HOOKS)"

check "expect $EXPECTED_HOOKS hooks are installed" test "$actual_hooks" -eq $EXPECTED_HOOKS

#------------------------------------------------------------------------------
# User and Group Verification
#------------------------------------------------------------------------------

if [ "$(id -u)" -eq 0 ]; then
    echo "Running as root, skipping user checks."
    reportResults
    exit 0
fi

echo "Testing user permissions and group membership"

# Verify vscode user exists and has correct group membership
check "user vscode exists" id -u vscode

check "user vscode is in group pre-commit" id -nG vscode | grep -qw pre-commit

echo "=== Current User Context ==="
echo "Current user is $(whoami)"
echo "Current user id is $(id -u)"
echo "Current group id is $(id -g)"
echo "Current groups are $(id -nG)"
echo "================================"

#------------------------------------------------------------------------------
# Git Repository Setup
#------------------------------------------------------------------------------

echo "Setting up temporary git repository for testing"

git init -q
git config user.name 'Dev Container Features'
git config user.email 'dev@container'
git config --local init.defaultBranch main

#------------------------------------------------------------------------------
# Pre-commit Functionality Tests
#------------------------------------------------------------------------------

echo "Testing pre-commit functionality"

# Create sample configuration
echo "Creating sample pre-commit configuration"
pre-commit sample-config >.pre-commit-config.yaml
pre-commit autoupdate

# Test hook installation
check "user can install hooks" env PRE_COMMIT_HOME="${PRE_COMMIT_CACHE_DIR}" pre-commit install --install-hooks

# Test running hooks on all files
check "user can run all files" env PRE_COMMIT_HOME="${PRE_COMMIT_CACHE_DIR}" pre-commit run --all-files

#------------------------------------------------------------------------------
# Cleanup
#------------------------------------------------------------------------------

echo "Cleaning up test artifacts"
rm -rf .git .pre-commit-config.yaml

#------------------------------------------------------------------------------
# Report Results
#------------------------------------------------------------------------------

echo "Tests completed!"

reportResults
