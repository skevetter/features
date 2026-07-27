#!/bin/bash

set -e

source dev-container-features-test-lib

#------------------------------------------------------------------------------
# Environment
#------------------------------------------------------------------------------

echo "==================== Test Environment ===================="
env
echo "=========================================================="

#------------------------------------------------------------------------------
# Installation Checks
#------------------------------------------------------------------------------

echo "Testing go-task installation"

# Verify task command exists and is executable
check "task command exists" command -v task

# Verify task version works
check "task version works" task --version

#------------------------------------------------------------------------------
# Binary Location Verification
#------------------------------------------------------------------------------

echo "Testing binary locations and permissions"

# Get the actual path of task command
TASK_PATH=$(command -v task)
check "task binary is executable" test -x "${TASK_PATH}"

echo "=== Binary Locations ==="
echo "task is located at: ${TASK_PATH}"
echo "========================="

#------------------------------------------------------------------------------
# Functional Tests
#------------------------------------------------------------------------------

echo "Testing go-task functionality"

# Test help command works
check "task help works" task --help

#------------------------------------------------------------------------------
# Report Results
#------------------------------------------------------------------------------

echo "Tests completed!"

reportResults
