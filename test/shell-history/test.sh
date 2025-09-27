#!/bin/bash

set -e

source dev-container-features-test-lib

# The 'check' command comes from the dev-container-features-test-lib.
check "verify /shellhistory is present" test -d /shellhistory
check "bash histfile is /shellhistory/.bash_history" grep -q 'HISTFILE=/shellhistory/.bash_history' /etc/bash.bashrc

reportResults
