#!/bin/bash

set -e

source dev-container-features-test-lib

# The 'check' command comes from the dev-container-features-test-lib.
check "bash histfile is /shellhistory/.bash_history" bash -lc "echo \$HISTFILE | grep \"/shellhistory/.bash_history\""
check "zsh histfile is /shellhistory/.zsh_history" zsh -lc "echo \$HISTFILE | grep \"/shellhistory/.zsh_history\""

reportResults
