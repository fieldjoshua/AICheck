#!/bin/bash

# Master test script for AICheck
# This script runs all test suites and generates a comprehensive report

# Exit on error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test results
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Create necessary directories
mkdir -p .aicheck/test_reports
mkdir -p .aicheck/sessions
mkdir -p .aicheck/hooks
mkdir -p .aicheck/scripts

# Function to run a test suite and update counts
run_test_suite() {
    local suite_name="$1"
    local script_path="$2"
    
    echo -e "\n${YELLOW}Running $suite_name...${NC}"
    
    if bash "$script_path"; then
        ((PASSED_TESTS++))
        echo -e "${GREEN}✓ $suite_name passed${NC}"
    else
        ((FAILED_TESTS++))
        echo -e "${RED}✗ $suite_name failed${NC}"
    fi
    
    ((TOTAL_TESTS++))
}

# Function to test action management
test_action_management() {
    local test_action="TestAction"
    
    # Test action creation
    if .aicheck/scripts/action.sh create "$test_action"; then
        echo -e "${GREEN}✓ Action creation test passed${NC}"
        ((PASSED_TESTS++))
    else
        echo -e "${RED}✗ Action creation test failed${NC}"
        ((FAILED_TESTS++))
    fi
    
    # Test action status
    if .aicheck/scripts/action.sh status "$test_action"; then
        echo -e "${GREEN}✓ Action status test passed${NC}"
        ((PASSED_TESTS++))
    else
        echo -e "${RED}✗ Action status test failed${NC}"
        ((FAILED_TESTS++))
    fi
    
    # Test action switching
    if .aicheck/scripts/action.sh switch "$test_action"; then
        echo -e "${GREEN}✓ Action switching test passed${NC}"
        ((PASSED_TESTS++))
    else
        echo -e "${RED}✗ Action switching test failed${NC}"
        ((FAILED_TESTS++))
    fi
    
    # Cleanup test action
    .aicheck/scripts/action.sh delete "$test_action"
    
    ((TOTAL_TESTS+=3))
}

# Run all test suites
echo "Starting AICheck test suite..."
echo "================================"

# Run security tests
run_test_suite "Security Tests" ".aicheck/scripts/test_security.sh"

# Run pre-commit tests
run_test_suite "Pre-commit Tests" ".aicheck/scripts/test_pre_commit.sh"

# Run action management tests
echo -e "\n${YELLOW}Running Action Management Tests...${NC}"
test_action_management

# Generate test report
REPORT_FILE=".aicheck/test_reports/test_report_$(date +%Y%m%d_%H%M%S).txt"
{
    echo "AICheck Test Report"
    echo "==================="
    echo "Date: $(date)"
    echo ""
    echo "Test Summary:"
    echo "-------------"
    echo "Total Tests: $TOTAL_TESTS"
    echo "Passed: $PASSED_TESTS"
    echo "Failed: $FAILED_TESTS"
    echo ""
    echo "Test Suites:"
    echo "- Security Tests"
    echo "- Pre-commit Tests"
    echo "- Action Management Tests"
} > "$REPORT_FILE"

# Print summary
echo -e "\n================================"
echo -e "Test Summary:"
echo -e "${GREEN}Tests passed: $PASSED_TESTS${NC}"
echo -e "${RED}Tests failed: $FAILED_TESTS${NC}"
echo -e "Total tests: $TOTAL_TESTS"
echo -e "\nTest report generated: $REPORT_FILE"

# Exit with status
if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "\n${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "\n${RED}Some tests failed!${NC}"
    exit 1
fi 