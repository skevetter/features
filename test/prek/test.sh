#!/bin/bash

set -e

source dev-container-features-test-lib

# The 'check' command comes from the dev-container-features-test-lib.
check "prek exists on PATH" type prek
check "prek version" prek --version

reportResults
