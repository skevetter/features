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

echo "Testing engram installation"

# Verify engram command exists and is executable
check "engram command exists" command -v engram

# Verify engram version works
check "engram version works" engram version

#------------------------------------------------------------------------------
# Binary Location Verification
#------------------------------------------------------------------------------

echo "Testing binary locations and permissions"

# Get the actual path of engram command
ENGRAM_PATH=$(command -v engram)
check "engram binary is executable" test -x "${ENGRAM_PATH}"

echo "=== Binary Locations ==="
echo "engram is located at: ${ENGRAM_PATH}"
echo "========================="

#------------------------------------------------------------------------------
# Report Results
#------------------------------------------------------------------------------

echo "Tests completed!"

reportResults
