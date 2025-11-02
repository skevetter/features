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

echo "Testing pulumi installation..."

# Verify pulumi command exists and is executable
check "pulumi command exists" command -v pulumi

# Verify pulumi version works
check "pulumi version works" pulumi version

#------------------------------------------------------------------------------
# Binary Location Verification
#------------------------------------------------------------------------------

echo "Testing binary locations and permissions..."

# Get the actual path of pulumi command
PULUMI_PATH=$(command -v pulumi)
check "pulumi binary is executable" test -x "${PULUMI_PATH}"

echo "=== Binary Locations ==="
echo "pulumi is located at: ${PULUMI_PATH}"
echo "========================="

#------------------------------------------------------------------------------
# Functional Tests
#------------------------------------------------------------------------------

echo "Testing pulumi functionality..."

# Test help command works
check "pulumi help works" pulumi --help

#------------------------------------------------------------------------------
# Report Results
#------------------------------------------------------------------------------

echo "Tests completed!"

reportResults
