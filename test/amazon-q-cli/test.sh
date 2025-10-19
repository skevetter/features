#!/bin/bash

set -e

source dev-container-features-test-lib

COMPLETION_FILE="/etc/bash_completion.d/q"

#------------------------------------------------------------------------------
# Environment
#------------------------------------------------------------------------------

echo "==================== Test Environment ===================="
env
echo "=========================================================="

#------------------------------------------------------------------------------
# Installation Checks
#------------------------------------------------------------------------------

echo "Testing Amazon Q CLI installation..."

# Verify main q command exists and is executable
check "q command exists" command -v q

# Verify qchat command exists and is executable
check "qchat command exists" command -v qchat

# Verify qterm command exists and is executable
check "qterm command exists" command -v qterm

# Verify q command returns version
check "q version works" q --version

#------------------------------------------------------------------------------
# Completion and Integration Checks
#------------------------------------------------------------------------------

echo "Testing bash completion and shell integrations..."

# Verify bash completion file exists
check "bash completion file exists" test -f ${COMPLETION_FILE}

# Verify bash completion file is readable
check "bash completion file is readable" test -r ${COMPLETION_FILE}

# Verify Q_TERM environment variable is set in profile.d
check "Q_TERM in profile.d" grep -q 'Q_TERM=1' /etc/profile.d/amazon-q.sh

# Verify bash completion is sourced in profile.d
check "bash completion sourced in profile.d" grep -q 'source /etc/bash_completion.d/q' /etc/profile.d/amazon-q.sh

#------------------------------------------------------------------------------
# Binary Location Verification
#------------------------------------------------------------------------------

echo "Testing binary locations and permissions..."

# Get the actual path of q command
Q_PATH=$(command -v q)
check "q binary is executable" test -x "${Q_PATH}"

# Get the actual path of qchat command
QCHAT_PATH=$(command -v qchat)
check "qchat binary is executable" test -x "${QCHAT_PATH}"

# Get the actual path of qterm command
QTERM_PATH=$(command -v qterm)
check "qterm binary is executable" test -x "${QTERM_PATH}"

echo "=== Binary Locations ==="
echo "q is located at: ${Q_PATH}"
echo "qchat is located at: ${QCHAT_PATH}"
echo "qterm is located at: ${QTERM_PATH}"
echo "========================="

#------------------------------------------------------------------------------
# Functional Tests
#------------------------------------------------------------------------------

echo "Testing Amazon Q CLI functionality..."

# Test help command works
check "q help works" q --help

# Test completion generation works
check "q completion bash works" q completion bash

#------------------------------------------------------------------------------
# Report Results
#------------------------------------------------------------------------------

echo "Tests completed!"

reportResults
