#!/bin/bash

set -e

source dev-container-features-test-lib

# The 'check' command comes from the dev-container-features-test-lib.
check "verify /pre_commit_cache is present" test -d /pre_commit_cache
check "/etc/profile.d/pre_commit_cache.sh contains PRE_COMMIT_HOME" grep -q 'PRE_COMMIT_HOME=/pre_commit_cache' /etc/profile.d/pre_commit_cache.sh
check "/etc/bash.bashrc contains PRE_COMMIT_HOME" grep -q 'PRE_COMMIT_HOME=/pre_commit_cache' /etc/bash.bashrc
check "owner of /pre_commit_cache is not root" test "$(stat -c '%U' /pre_commit_cache)" != "root"

reportResults
