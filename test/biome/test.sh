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

echo "Testing Biome installation..."

# Verify biome command exists and is executable
check "biome command exists" command -v biome

# Verify biome version works
check "biome version works" biome version

#------------------------------------------------------------------------------
# Binary Location Verification
#------------------------------------------------------------------------------

echo "Testing binary locations and permissions..."

# Get the actual path of biome command
BIOME_PATH=$(command -v biome)
check "biome binary is executable" test -x "${BIOME_PATH}"

echo "=== Binary Locations ==="
echo "biome is located at: ${BIOME_PATH}"
echo "========================="

#------------------------------------------------------------------------------
# Functional Tests
#------------------------------------------------------------------------------

echo "Testing Biome functionality..."

# Test help command works
check "biome help works" biome --help

# Test that biome can check a simple file
echo '{"test": true}' > /tmp/test.json
check "biome check works" biome check /tmp/test.json

#------------------------------------------------------------------------------
# Report Results
#------------------------------------------------------------------------------

echo "Tests completed!"

reportResults
