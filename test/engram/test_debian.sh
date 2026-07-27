#!/bin/bash

set -e

source dev-container-features-test-lib

echo "Testing engram installation (debian)"

check "engram command exists" command -v engram
check "engram version works" engram version

ENGRAM_PATH=$(command -v engram)
check "engram binary is executable" test -x "${ENGRAM_PATH}"

reportResults
