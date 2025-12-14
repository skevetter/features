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

echo "Testing Kiro-CLI installation"

# Verify main kiro-cli command exists and is executable
check "kiro-cli command exists" command -v kiro-cli

# Verify kiro-cli command returns version
check "kiro-cli version works" kiro-cli --version

#------------------------------------------------------------------------------
# Binary Location Verification
#------------------------------------------------------------------------------

echo "Testing binary locations and permissions"

# Get the actual path of kiro-cli command
KIRO_PATH=$(command -v kiro-cli)
check "kiro-cli binary is executable" test -x "${KIRO_PATH}"

echo "=== Binary Locations ==="
echo "kiro-cli is located at: ${KIRO_PATH}"
echo "========================="

#------------------------------------------------------------------------------
# Functional Tests
#------------------------------------------------------------------------------

echo "Testing Kiro CLI functionality"

# Test help command works
check "kiro-cli help works" kiro-cli --help

check "kiro-cli inline suggestions enabled" kiro-cli inline enable

check "kiro-cli inline status" kiro-cli inline status

#------------------------------------------------------------------------------
# Report Results
#------------------------------------------------------------------------------

echo "Tests completed!"

reportResults
