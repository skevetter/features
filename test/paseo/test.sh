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

echo "Testing Paseo installation"

# Verify paseo command exists and is executable
check "paseo command exists" command -v paseo

# Verify paseo version works
check "paseo version works" paseo --version

#------------------------------------------------------------------------------
# Binary Location Verification
#------------------------------------------------------------------------------

echo "Testing binary locations and permissions"

# Get the actual path of paseo command
PASEO_PATH=$(command -v paseo)
check "paseo binary is executable" test -x "${PASEO_PATH}"

echo "=== Binary Locations ==="
echo "paseo is located at: ${PASEO_PATH}"
echo "========================="

#------------------------------------------------------------------------------
# Functional Tests
#------------------------------------------------------------------------------

echo "Testing Paseo functionality"

# Test help command works
check "paseo help works" paseo --help

#------------------------------------------------------------------------------
# Report Results
#------------------------------------------------------------------------------

echo "Tests completed!"

reportResults
