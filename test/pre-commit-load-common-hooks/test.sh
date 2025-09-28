#!/bin/bash

set -e

source dev-container-features-test-lib

# The 'check' command comes from the dev-container-features-test-lib.
check "/pre_commit_cache is present" test -d /pre_commit_cache
check "pre-commit is installed" command -v pre-commit
check "owner of /pre_commit_cache" stat -c '%U' /pre_commit_cache

reportResults
