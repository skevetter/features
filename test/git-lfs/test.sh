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
# Installation Checks
#------------------------------------------------------------------------------

echo "Testing git-lfs installation"

# Verify git-lfs command exists and is executable
check "git-lfs command exists" command -v git-lfs

# Verify git-lfs version works
check "git-lfs version works" git-lfs --version

#------------------------------------------------------------------------------
# Binary Location Verification
#------------------------------------------------------------------------------

echo "Testing binary locations and permissions"

# Get the actual path of git-lfs command
GIT_LFS_PATH=$(command -v git-lfs)
check "git-lfs binary is executable" test -x "${GIT_LFS_PATH}"

echo "=== Binary Locations ==="
echo "git-lfs is located at: ${GIT_LFS_PATH}"
echo "========================="

#------------------------------------------------------------------------------
# Functional Tests
#------------------------------------------------------------------------------

echo "Testing git-lfs functionality"

# Test git lfs subcommand is wired up
check "git lfs subcommand works" git lfs version

# Test env command works
check "git-lfs env works" git-lfs env

#------------------------------------------------------------------------------
# Report Results
#------------------------------------------------------------------------------

echo "Tests completed!"

reportResults
