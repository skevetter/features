#!/bin/bash

set -e

source dev-container-features-test-lib

mkdir -p /workspaces/test-pre-commit-hooks-init
cd /workspaces/test-pre-commit-hooks-init

pre-commit sample-config > .pre-commit-config.yaml
git config --global user.name "Test User"
git config --global user.email "test@example.com"
git init
git add .pre-commit-config.yaml
git commit -m "Add pre-commit config"

ls -la
git ls-files

# The 'check' command comes from the dev-container-features-test-lib.
check "run" cd /workspaces/test-pre-commit-hooks-init && pre-commit run --all-files

reportResults
