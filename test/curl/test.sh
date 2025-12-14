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

echo "Testing curl installation"

# Verify curl command exists and is executable
check "curl command exists" command -v curl

# Verify curl version works
check "curl version works" curl --version

#------------------------------------------------------------------------------
# Binary Location Verification
#------------------------------------------------------------------------------

echo "Testing binary locations and permissions"

# Get the actual path of curl command
CURL_PATH=$(command -v curl)
check "curl binary is executable" test -x "${CURL_PATH}"

echo "=== Binary Locations ==="
echo "curl is located at: ${CURL_PATH}"
echo "========================="

#------------------------------------------------------------------------------
# Functional Tests
#------------------------------------------------------------------------------

echo "Testing curl functionality"

# Test help command works
check "curl help works" curl --help

# Test basic HTTP request (using httpbin.org which is reliable for testing)
check "curl can make HTTP request" bash -c 'curl -s -o /dev/null -w "%{http_code}" https://httpbin.org/get | grep -q "200"'

#------------------------------------------------------------------------------
# Report Results
#------------------------------------------------------------------------------

echo "Tests completed!"

reportResults
