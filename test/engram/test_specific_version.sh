#!/bin/bash

set -e

source dev-container-features-test-lib

echo "Testing engram installation (pinned version v1.18.0)"

check "engram command exists" command -v engram
check "engram version works" engram version
check "engram reports pinned version 1.18.0" bash -c "engram version 2>&1 | grep -F '1.18.0'"

reportResults
