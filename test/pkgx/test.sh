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

echo "Testing pkgx installation"

check "pkgx exists on PATH" type pkgx
check "pkgx version" pkgx --version

#------------------------------------------------------------------------------
# Binary Location Verification
#------------------------------------------------------------------------------

echo "Testing binary locations and permissions"

PKGX_PATH=$(command -v pkgx)
check "pkgx binary is executable" test -x "${PKGX_PATH}"

echo "=== Binary Locations ==="
echo "pkgx is located at: ${PKGX_PATH}"
echo "========================="

#------------------------------------------------------------------------------
# Functional Tests
#------------------------------------------------------------------------------

echo "Testing pkgx functionality"

check "pkgx get node@22 version" pkgx node@22 --version
check "pkgx run python@3.10 code" pkgx python@3.10 -c "import sys; print(sys.version)"

#------------------------------------------------------------------------------
# Report Results
#------------------------------------------------------------------------------

echo "Tests completed!"

reportResults
