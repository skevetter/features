#!/bin/bash

set -e

source dev-container-features-test-lib

echo "Testing picolayer with version option"

# Verify picolayer command exists
check "picolayer command exists" command -v picolayer

# Verify picolayer shows a version (format may vary)
check "picolayer shows version" bash -c 'picolayer --version | grep -E "[0-9]+\.[0-9]+\.[0-9]+"'

# Test functionality with installed version
check "picolayer help works" picolayer --help

echo "Version-specific tests completed!"

reportResults
