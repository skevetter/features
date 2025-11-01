#!/bin/bash

set -e

source dev-container-features-test-lib

echo "Testing picolayer with temp directory creation..."

# Verify the custom directory was created
check "custom directory exists" test -d "/tmp/custom/picolayer"

# Verify picolayer is installed in the custom directory
check "picolayer installed in custom temp dir" test -x "/tmp/custom/picolayer/picolayer"

# Verify picolayer command works from custom location
check "picolayer works from temp dir" /tmp/custom/picolayer/picolayer --version

echo "Temp directory tests completed!"

reportResults
