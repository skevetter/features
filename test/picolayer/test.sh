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

echo "Testing picolayer installation"

# Verify picolayer command exists and is executable
check "picolayer command exists" command -v picolayer

# Verify picolayer version works
check "picolayer version works" picolayer --version

#------------------------------------------------------------------------------
# Binary Location Verification
#------------------------------------------------------------------------------

echo "Testing binary locations and permissions"

# Get the actual path of picolayer command
PICOLAYER_PATH=$(command -v picolayer)
check "picolayer binary is executable" test -x "${PICOLAYER_PATH}"

echo "=== Binary Locations ==="
echo "picolayer is located at: ${PICOLAYER_PATH}"
echo "========================="

#------------------------------------------------------------------------------
# Functional Tests
#------------------------------------------------------------------------------

echo "Testing picolayer functionality"

# Test help command works
check "picolayer help works" picolayer --help

# Test that picolayer can show available commands
check "picolayer shows available commands" bash -c 'picolayer --help | grep -q "Commands:"'

#------------------------------------------------------------------------------
# Report Results
#------------------------------------------------------------------------------

echo "Tests completed!"

reportResults
