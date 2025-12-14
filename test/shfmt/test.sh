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

echo "Testing shfmt installation"

# Verify shfmt command exists and is executable
check "shfmt command exists" command -v shfmt

# Verify shfmt version works
check "shfmt version works" shfmt --version

#------------------------------------------------------------------------------
# Binary Location Verification
#------------------------------------------------------------------------------

echo "Testing binary locations and permissions"

# Get the actual path of shfmt command
SHFMT_PATH=$(command -v shfmt)
check "shfmt binary is executable" test -x "${SHFMT_PATH}"

echo "=== Binary Locations ==="
echo "shfmt is located at: ${SHFMT_PATH}"
echo "========================="

#------------------------------------------------------------------------------
# Functional Tests
#------------------------------------------------------------------------------

echo "Testing shfmt functionality"

# Test help command works
check "shfmt help works" shfmt --help

# Test basic formatting functionality
echo -e '#!/bin/bash\necho "test"' >/tmp/test.sh
check "shfmt can format shell script" shfmt /tmp/test.sh

#------------------------------------------------------------------------------
# Report Results
#------------------------------------------------------------------------------

echo "Tests completed!"

reportResults
