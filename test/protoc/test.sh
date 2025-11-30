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

echo "Testing protoc installation"

# Verify protoc command exists and is executable
check "protoc command exists" command -v protoc

# Verify protoc version works
check "protoc version works" protoc --version

#------------------------------------------------------------------------------
# Binary Location Verification
#------------------------------------------------------------------------------

echo "Testing binary locations and permissions"

# Get the actual path of protoc command
PROTOC_PATH=$(command -v protoc)
check "protoc binary is executable" test -x "${PROTOC_PATH}"

echo "=== Binary Locations ==="
echo "protoc is located at: ${PROTOC_PATH}"
echo "========================="

#------------------------------------------------------------------------------
# Functional Tests
#------------------------------------------------------------------------------

echo "Testing protoc functionality"

# Test help command works
check "protoc help works" protoc --help

#------------------------------------------------------------------------------
# Report Results
#------------------------------------------------------------------------------

echo "Tests completed!"

reportResults
