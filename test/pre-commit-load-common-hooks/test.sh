#!/bin/bash

set -e

source dev-container-features-test-lib

# The 'check' command comes from the dev-container-features-test-lib.
check "verify /pre_commit_cache is present" test -d /pre_commit_cache

reportResults
