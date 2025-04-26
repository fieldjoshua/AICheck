#!/bin/bash

# Test script for pre-commit hooks
# This script verifies that the pre-commit hooks are working correctly

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Function to check if a file exists
check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} $1 exists"
        return 0
    else
        echo -e "${RED}✗${NC} $1 does not exist"
        return 1
    fi
}

# Function to check if a file is executable
check_executable() {
    if [ -x "$1" ]; then
        echo -e "${GREEN}✓${NC} $1 is executable"
        return 0
    else
        echo -e "${RED}✗${NC} $1 is not executable"
        return 1
    fi
}

# Main test function
run_tests() {
    echo "Running pre-commit hook tests..."
    echo "--------------------------------"

    # Check if pre-commit hook exists
    check_file ".aicheck/hooks/pre-commit"
    
    # Check if pre-commit hook is executable
    check_executable ".aicheck/hooks/pre-commit"
    
    # Check if style script exists
    check_file ".aicheck/scripts/aicheck_style.sh"
    
    # Check if style script is executable
    check_executable ".aicheck/scripts/aicheck_style.sh"

    echo "--------------------------------"
    echo "Tests completed"
}

# Run the tests
run_tests 