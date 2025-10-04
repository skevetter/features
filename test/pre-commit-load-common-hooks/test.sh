#!/bin/bash

set -e

source dev-container-features-test-lib

# The 'check' command comes from the dev-container-features-test-lib.
check "/pre_commit_cache is present" test -d /pre_commit_cache
check "pre-commit is installed" command -v pre-commit
check "owner of /pre_commit_cache" stat -c '%U' /pre_commit_cache
check "/pre_commit_cache is owned by group pre-commit" stat -c '%G' /pre_commit_cache | grep pre-commit
check "13 hooks are installed" test "$(find /pre_commit_cache -maxdepth 1 -mindepth 1 -type d -name 'repo*' | wc -l)" -eq 13
check "user vscode exists" id -u vscode
check "user vscode is in group pre-commit" id -nG vscode | grep -qw pre-commit

reportResults
