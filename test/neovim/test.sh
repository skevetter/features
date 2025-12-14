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

echo "Testing neovim installation"

# Verify nvim command exists and is executable
check "nvim command exists" command -v nvim

# Verify nvim version works
check "nvim version works" nvim --version

#------------------------------------------------------------------------------
# Binary Location Verification
#------------------------------------------------------------------------------

echo "Testing binary locations and permissions"

# Get the actual path of nvim command
NVIM_PATH=$(command -v nvim)
check "nvim binary is executable" test -x "${NVIM_PATH}"

echo "=== Binary Locations ==="
echo "nvim is located at: ${NVIM_PATH}"
echo "========================="

#------------------------------------------------------------------------------
# Functional Tests
#------------------------------------------------------------------------------

echo "Testing neovim functionality"

# Test help command works
check "nvim help works" nvim --help

#------------------------------------------------------------------------------
# Report Results
#------------------------------------------------------------------------------

echo "Tests completed!"

reportResults
