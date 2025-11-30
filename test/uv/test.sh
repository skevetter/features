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

echo "Testing uv installation"

# Verify uv command exists and is executable
check "uv command exists" command -v uv

# Verify uvx command exists and is executable
check "uvx command exists" command -v uvx

# Verify uv version works
check "uv version works" uv --version

# Verify uvx version works
check "uvx version works" uvx --version

#------------------------------------------------------------------------------
# Binary Location Verification
#------------------------------------------------------------------------------

echo "Testing binary locations and permissions"

# Get the actual path of uv command
UV_PATH=$(command -v uv)
check "uv binary is executable" test -x "${UV_PATH}"

# Get the actual path of uvx command
UVX_PATH=$(command -v uvx)
check "uvx binary is executable" test -x "${UVX_PATH}"

echo "=== Binary Locations ==="
echo "uv is located at: ${UV_PATH}"
echo "uvx is located at: ${UVX_PATH}"
echo "========================="

#------------------------------------------------------------------------------
# Functional Tests
#------------------------------------------------------------------------------

echo "Testing uv functionality"

# Test help command works
check "uv help works" uv --help

# Test uvx help command works
check "uvx help works" uvx --help

#------------------------------------------------------------------------------
# Report Results
#------------------------------------------------------------------------------

echo "Tests completed!"

reportResults
