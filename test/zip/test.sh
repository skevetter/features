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

echo "Testing zip installation"

# Verify zip command exists and is executable
check "zip command exists" command -v zip

# Verify zip version works
check "zip version works" zip --version

#------------------------------------------------------------------------------
# Binary Location Verification
#------------------------------------------------------------------------------

echo "Testing binary locations and permissions"

# Get the actual path of zip command
ZIP_PATH=$(command -v zip)
check "zip binary is executable" test -x "${ZIP_PATH}"

echo "=== Binary Locations ==="
echo "zip is located at: ${ZIP_PATH}"
echo "========================="

#------------------------------------------------------------------------------
# Functional Tests
#------------------------------------------------------------------------------

echo "Testing zip functionality"

# Test help command works
check "zip help works" zip --help

# Test basic zip functionality (create a test archive)
check "zip can create archive" bash -c 'echo "test content" > /tmp/test.txt && zip /tmp/test.zip /tmp/test.txt && test -f /tmp/test.zip'

# Test unzip command exists (usually bundled with zip)
check "unzip command exists" command -v unzip

# Test unzip functionality
check "unzip can extract archive" bash -c 'mkdir -p /tmp/extract && unzip -q /tmp/test.zip -d /tmp/extract && test -f /tmp/extract/tmp/test.txt'

#------------------------------------------------------------------------------
# Report Results
#------------------------------------------------------------------------------

echo "Tests completed!"

reportResults
