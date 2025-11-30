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

echo "Testing lazygit installation"

# Verify lazygit command exists and is executable
check "lazygit command exists" command -v lazygit

# Verify lazygit version works
check "lazygit version works" lazygit --version

#------------------------------------------------------------------------------
# Binary Location Verification
#------------------------------------------------------------------------------

echo "Testing binary locations and permissions"

# Get the actual path of lazygit command
LAZYGIT_PATH=$(command -v lazygit)
check "lazygit binary is executable" test -x "${LAZYGIT_PATH}"

echo "=== Binary Locations ==="
echo "lazygit is located at: ${LAZYGIT_PATH}"
echo "========================="

#------------------------------------------------------------------------------
# Functional Tests
#------------------------------------------------------------------------------

echo "Testing lazygit functionality"

# Test help command works
check "lazygit help works" lazygit --help

#------------------------------------------------------------------------------
# Report Results
#------------------------------------------------------------------------------

echo "Tests completed!"

reportResults
