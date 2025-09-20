#!/bin/bash

set -e

source dev-container-features-test-lib

printenv

pre-commit sample-config > .pre-commit-config.yaml
git config user.name "Test User"
git config user.email "test@example.com"
git init
git add .pre-commit-config.yaml
git commit -m "Add pre-commit config"

# The 'check' command comes from the dev-container-features-test-lib.
check "run" pre-commit run --all-files

reportResults
