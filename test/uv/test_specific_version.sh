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

echo "Testing uv installation..."

# Verify uv command exists and is executable
check "uv command exists" command -v uv

# Verify uv version works
check "uv version works" uv --version

# Verify specific version is installed
check "uv version is 0.9.7" sh -c "uv --version | grep '0.9.7'"

#------------------------------------------------------------------------------
# Binary Location Verification
#------------------------------------------------------------------------------

echo "Testing binary locations and permissions..."

# Get the actual path of uv command
UV_PATH=$(command -v uv)
check "uv binary is executable" test -x "${UV_PATH}"

echo "=== Binary Locations ==="
echo "uv is located at: ${UV_PATH}"
echo "========================="

#------------------------------------------------------------------------------
# Functional Tests
#------------------------------------------------------------------------------

echo "Testing uv functionality..."

# Test help command works
check "uv help works" uv --help

#------------------------------------------------------------------------------
# Report Results
#------------------------------------------------------------------------------

echo "Tests completed!"

reportResults
