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

echo "Testing prek installation..."

# Verify prek command exists and is executable
check "prek command exists" command -v prek

# Verify prek version works
check "prek version works" prek --version

#------------------------------------------------------------------------------
# Binary Location Verification
#------------------------------------------------------------------------------

echo "Testing binary locations and permissions..."

# Get the actual path of prek command
PREK_PATH=$(command -v prek)
check "prek binary is executable" test -x "${PREK_PATH}"

echo "=== Binary Locations ==="
echo "prek is located at: ${PREK_PATH}"
echo "========================="

#------------------------------------------------------------------------------
# Functional Tests
#------------------------------------------------------------------------------

echo "Testing prek functionality..."

# Test help command works
check "prek help works" prek --help

#------------------------------------------------------------------------------
# Report Results
#------------------------------------------------------------------------------

echo "Tests completed!"

reportResults
