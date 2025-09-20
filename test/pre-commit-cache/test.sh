#!/bin/bash

set -e

source dev-container-features-test-lib

# The 'check' command comes from the dev-container-features-test-lib.
check "verify /pre-commit-cache is present" test -d /pre-commit-cache
check "PRE_COMMIT_HOME is set to /pre-commit-cache" test "$PRE_COMMIT_HOME" = "/pre-commit-cache"
check "/etc/zsh/zshrc contains PRE_COMMIT_HOME" grep -q 'PRE_COMMIT_HOME=/pre-commit-cache' /etc/zsh/zshrc
check "/etc/profile.d/pre_commit.sh contains PRE_COMMIT_HOME" grep -q 'PRE_COMMIT_HOME=/pre-commit-cache' /etc/profile.d/pre_commit.sh
check "/etc/bash.bashrc contains PRE_COMMIT_HOME" grep -q 'PRE_COMMIT_HOME=/pre-commit-cache' /etc/bash.bashrc

reportResults
