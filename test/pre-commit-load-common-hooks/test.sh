#!/bin/bash

set -e

source dev-container-features-test-lib

# The 'check' command comes from the dev-container-features-test-lib.
check "verify /pre_commit_cache is present" test -d /pre_commit_cache
check "verify pre-commit is installed" command -v pre-commit
check "contents of /pre_commit_cache" ls -la /pre_commit_cache

reportResults
