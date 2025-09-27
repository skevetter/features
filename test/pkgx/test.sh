#!/bin/bash

set -e

source dev-container-features-test-lib

# The 'check' command comes from the dev-container-features-test-lib.
check "pkgx exists on PATH" type pkgx
check "pkgx version" pkgx --version
check "pkgx get node@22 version" pkgx node@22 --version
check "pkgx run python@3.10 code" pkgx python@3.10 -c "import sys; print(sys.version)"

reportResults
