#!/bin/bash

set -e

source dev-container-features-test-lib

echo "Testing Paseo installation (debian)"

check "paseo command exists" command -v paseo
check "paseo version works" paseo --version

PASEO_PATH=$(command -v paseo)
check "paseo binary is executable" test -x "${PASEO_PATH}"

check "paseo help works" paseo --help

reportResults
