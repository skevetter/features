#!/bin/bash

set -e

source dev-container-features-test-lib

# The 'check' command comes from the dev-container-features-test-lib.
check "verify /pre-commit-cache is present" test -d /pre-commit-cache
check "PRE_COMMIT_HOME is set to /pre-commit-cache" test "$PRE_COMMIT_HOME" = "/pre-commit-cache"

reportResults
