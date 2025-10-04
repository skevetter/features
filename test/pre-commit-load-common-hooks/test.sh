#!/bin/bash

set -e

source dev-container-features-test-lib

#------------------------------------------------------------------------------
# Environment
#------------------------------------------------------------------------------

env

#------------------------------------------------------------------------------
# Basic Installation and Directory Checks
#------------------------------------------------------------------------------

echo "Testing pre-commit installation and cache directory..."

# Verify pre-commit cache directory exists and has correct ownership
check "/pre_commit_cache is present" test -d /pre_commit_cache
check "owner of /pre_commit_cache" stat -c '%U' /pre_commit_cache
check "/pre_commit_cache is owned by group pre-commit" stat -c '%G' /pre_commit_cache | grep pre-commit

# Verify pre-commit command is available
check "pre-commit is installed" command -v pre-commit

# Display cache directory contents
echo "Cache directory contents:"
ls -la /pre_commit_cache

#------------------------------------------------------------------------------
# Hook Installation Verification
#------------------------------------------------------------------------------

echo "Verifying pre-installed hooks..."
check "expect 9 hooks are installed" test "$(find /pre_commit_cache -maxdepth 1 -mindepth 1 -type d -name 'repo*' | wc -l)" -eq 9

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

echo "Setting up temporary git repository for testing..."

git init -q
git config user.name 'Dev Container Features'
git config user.email 'dev@container'
git config --local init.defaultBranch main

#------------------------------------------------------------------------------
# Pre-commit Functionality Tests
#------------------------------------------------------------------------------

echo "Testing pre-commit functionality..."

# Create sample configuration
echo "Creating sample pre-commit configuration..."
pre-commit sample-config > .pre-commit-config.yaml

# Test hook installation
check "user can install hooks" pre-commit install --install-hooks

# Test running hooks on all files
check "user can run all files" pre-commit run --all-files

#------------------------------------------------------------------------------
# Cleanup
#------------------------------------------------------------------------------

echo "Cleaning up test artifacts..."
rm -rf .git .pre-commit-config.yaml

#------------------------------------------------------------------------------
# Report Results
#------------------------------------------------------------------------------

echo "All tests completed!"
reportResults
