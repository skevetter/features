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
# Check Installation
#------------------------------------------------------------------------------

echo "Testing shellcheck installation"

check "shellcheck is installed" command -v shellcheck

check "shellcheck version" shellcheck --version

# If VERSION is set and not "latest", check that the installed version matches
if [ -n "$VERSION" ] && [ "$VERSION" != "latest" ]; then
    echo "VERSION is set to '$VERSION', checking shellcheck version"
    check "shellcheck version is correct" shellcheck --version | grep -F "$VERSION"
else
    echo "VERSION is unset or set to 'latest'; skipping exact version check"
fi

#------------------------------------------------------------------------------
# Results
#------------------------------------------------------------------------------

echo "Tests completed!"

reportResults
