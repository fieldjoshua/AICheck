#!/bin/bash

# Test environment variables
TEST_DIR=".aicheck_test"
HOOK_DIR="$TEST_DIR/.aicheck/hooks"
TEMPLATE_DIR="$TEST_DIR/.aicheck/templates"
ACTION_DIR="$TEST_DIR/actions"
CRITICAL_DIR="$TEST_DIR"

# Test categories
TEMPLATE_CATEGORY="Template Change Tests"
ACTION_CATEGORY="Action Plan Tests"
CRITICAL_CATEGORY="Critical File Tests"
MULTIPLE_CATEGORY="Multiple Change Tests"
COLOR_CATEGORY="Color Support Tests"
DEBUG_CATEGORY="Debug Mode Tests"
ERROR_CATEGORY="Error Handling Tests"

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Test results
total_tests=0
passed_tests=0

# Test script for AICheck pre-commit hook
# This script tests various scenarios for the pre-commit hook

# Colors for output
YELLOW='\033[1;33m'
CYAN='\033[0;36m'

# Test coverage tracking
template_new=0
template_modify=0
template_invalid=0
action_new=0
action_modify=0
action_invalid=0
critical_modify=0
critical_invalid=0
multiple_changes=0
multiple_invalid=0
color_support=0
non_terminal_color=0
debug_mode=0
error_handling=0

# Function to print test header
print_test_header() {
    echo -e "\n${YELLOW}=== Testing: $1 ===${NC}"
}

# Function to analyze error output
analyze_error() {
    local output=$1
    local test_name=$2
    
    echo -e "${CYAN}Error Analysis for $test_name:${NC}"
    
    # Check for common error patterns
    if echo "$output" | grep -q "permission denied"; then
        echo "  • Permission error detected"
    fi
    if echo "$output" | grep -q "not a git repository"; then
        echo "  • Git repository error detected"
    fi
    if echo "$output" | grep -q "hook failed"; then
        echo "  • Hook execution error detected"
    fi
    if echo "$output" | grep -q "invalid"; then
        echo "  • Invalid input detected"
    fi
    
    # Check for specific test-related errors
    case $test_name in
        template_*)
            if echo "$output" | grep -q "template"; then
                echo "  • Template-specific error detected"
            fi
            ;;
        action_*)
            if echo "$output" | grep -q "action"; then
                echo "  • Action-specific error detected"
            fi
            ;;
        critical_*)
            if echo "$output" | grep -q "critical"; then
                echo "  • Critical file error detected"
            fi
            ;;
    esac
    
    # Check for color-related issues
    if [[ $test_name == *"color"* ]]; then
        if echo "$output" | grep -q "\[0;35m"; then
            echo "  • Color code detected in output"
        fi
    fi
}

# Function to print test result with detailed error reporting
print_test_result() {
    local test_name=$2
    local error_msg=$3
    local output=$4
    
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓ $test_name${NC}"
        eval "$test_name=1"
    else
        echo -e "${RED}✗ $test_name${NC}"
        echo -e "${RED}Error: $error_msg${NC}"
        if [ -n "$output" ]; then
            echo -e "${BLUE}Output:${NC}"
            echo "$output"
            analyze_error "$output" "$test_name"
        fi
    fi
}

# Function to setup test environment
setup_test_env() {
    echo -e "${BLUE}Setting up test environment...${NC}"
    
    # Clean up any existing test directory
    rm -rf "$TEST_DIR"
    
    # Create test directory structure
    mkdir -p "$HOOK_DIR"
    mkdir -p "$TEMPLATE_DIR"
    mkdir -p "$ACTION_DIR"
    
    # Initialize git repository
    cd "$TEST_DIR" || exit 1
    git init
    
    # Copy pre-commit hook and make it executable
    cp ../.aicheck/hooks/pre-commit "$HOOK_DIR/"
    chmod +x "$HOOK_DIR/pre-commit"
    
    # Configure git to use our hooks
    git config core.hooksPath .aicheck/hooks
    
    # Create initial template and action files
    echo "# Initial Template" > .aicheck/templates/test_template.md
    echo "# Initial Action Plan" > actions/Initial-PLAN.md
    echo "# Initial Rules" > RULES.md
    
    # Add and commit initial files
    git add .
    git -c user.name='Test User' -c user.email='test@example.com' commit -m "Initial commit"
    
    echo -e "${GREEN}Test environment setup complete${NC}"
}

# Function to cleanup test environment
cleanup_test_env() {
    print_test_header "Cleaning up test environment"
    cd .. || exit 1
    rm -rf "$TEST_DIR"
    print_test_result $? "environment_cleanup" "Failed to cleanup test environment" ""
}

# Function to test template changes
test_template_changes() {
    print_test_header "$TEMPLATE_CATEGORY"
    
    # Test 1: Non-substantive template change
    echo -e "\n${BLUE}Testing non-substantive template change...${NC}"
    echo "# Initial Template  " > .aicheck/templates/test_template.md  # Added space at end
    git add .aicheck/templates/test_template.md
    if git commit -m "Non-substantive template change" > /dev/null 2>&1; then
        ((passed_tests++))
        echo -e "${GREEN}✓ Non-substantive template change allowed${NC}"
    else
        echo -e "${RED}✗ Non-substantive template change blocked${NC}"
    fi
    ((total_tests++))
    
    # Test 2: Substantive template change
    echo -e "\n${BLUE}Testing substantive template change...${NC}"
    echo "# Modified Template Content" > .aicheck/templates/test_template.md
    git add .aicheck/templates/test_template.md
    if ! git commit -m "Substantive template change" > /dev/null 2>&1; then
        ((passed_tests++))
        echo -e "${GREEN}✓ Substantive template change blocked${NC}"
    else
        echo -e "${RED}✗ Substantive template change allowed${NC}"
    fi
    ((total_tests++))
    
    # Reset changes
    git reset --hard HEAD
}

# Function to test action plan changes
test_action_plan_changes() {
    print_test_header "$ACTION_CATEGORY"
    
    # Test 1: Non-substantive action plan change
    echo -e "\n${BLUE}Testing non-substantive action plan change...${NC}"
    echo "# Initial Action Plan  " > .aicheck/actions/test-PLAN.md  # Added space at end
    git add .aicheck/actions/test-PLAN.md
    if git commit -m "Non-substantive action plan change" > /dev/null 2>&1; then
        ((passed_tests++))
        echo -e "${GREEN}✓ Non-substantive action plan change allowed${NC}"
    else
        echo -e "${RED}✗ Non-substantive action plan change blocked${NC}"
    fi
    ((total_tests++))
    
    # Test 2: Substantive action plan change
    echo -e "\n${BLUE}Testing substantive action plan change...${NC}"
    echo "# Modified Action Plan Content" > .aicheck/actions/test-PLAN.md
    git add .aicheck/actions/test-PLAN.md
    if ! git commit -m "Substantive action plan change" > /dev/null 2>&1; then
        ((passed_tests++))
        echo -e "${GREEN}✓ Substantive action plan change blocked${NC}"
    else
        echo -e "${RED}✗ Substantive action plan change allowed${NC}"
    fi
    ((total_tests++))
    
    # Test 3: New action plan
    echo -e "\n${BLUE}Testing new action plan creation...${NC}"
    echo "# New Action Plan" > .aicheck/actions/new-PLAN.md
    git add .aicheck/actions/new-PLAN.md
    if ! git commit -m "Add new action plan" > /dev/null 2>&1; then
        ((passed_tests++))
        echo -e "${GREEN}✓ New action plan creation blocked${NC}"
    else
        echo -e "${RED}✗ New action plan creation allowed${NC}"
    fi
    ((total_tests++))
    
    # Reset changes
    git reset --hard HEAD
}

# Function to test critical file changes
test_critical_file_changes() {
    print_test_header "$CRITICAL_CATEGORY"
    
    # Test 1: Non-substantive critical file change
    echo -e "\n${BLUE}Testing non-substantive critical file change...${NC}"
    echo "#!/bin/bash  " > .aicheck/hooks/pre-commit  # Added space at end
    git add .aicheck/hooks/pre-commit
    if git commit -m "Non-substantive critical file change" > /dev/null 2>&1; then
        ((passed_tests++))
        echo -e "${GREEN}✓ Non-substantive critical file change allowed${NC}"
    else
        echo -e "${RED}✗ Non-substantive critical file change blocked${NC}"
    fi
    ((total_tests++))
    
    # Test 2: Substantive critical file change
    echo -e "\n${BLUE}Testing substantive critical file change...${NC}"
    echo "#!/bin/bash\necho 'Modified hook'" > .aicheck/hooks/pre-commit
    git add .aicheck/hooks/pre-commit
    if ! git commit -m "Substantive critical file change" > /dev/null 2>&1; then
        ((passed_tests++))
        echo -e "${GREEN}✓ Substantive critical file change blocked${NC}"
    else
        echo -e "${RED}✗ Substantive critical file change allowed${NC}"
    fi
    ((total_tests++))
    
    # Test 3: New critical file
    echo -e "\n${BLUE}Testing new critical file creation...${NC}"
    echo "#!/bin/bash" > .aicheck/hooks/new-hook
    git add .aicheck/hooks/new-hook
    if ! git commit -m "Add new critical file" > /dev/null 2>&1; then
        ((passed_tests++))
        echo -e "${GREEN}✓ New critical file creation blocked${NC}"
    else
        echo -e "${RED}✗ New critical file creation allowed${NC}"
    fi
    ((total_tests++))
    
    # Reset changes
    git reset --hard HEAD
}

# Function to test multiple changes
test_multiple_changes() {
    print_test_header "$MULTIPLE_CATEGORY"
    
    # Test 1: Template + Action Plan changes
    echo -e "\n${BLUE}Testing template + action plan changes...${NC}"
    echo "# Modified Template" > .aicheck/templates/test_template.md
    echo "# Modified Plan" > test-PLAN.md
    git add .aicheck/templates/test_template.md test-PLAN.md
    if ! git commit -m "Template and plan changes" > /dev/null 2>&1; then
        ((passed_tests++))
        echo -e "${GREEN}✓ Template + action plan changes blocked${NC}"
    else
        echo -e "${RED}✗ Template + action plan changes allowed${NC}"
    fi
    ((total_tests++))
    
    # Test 2: Critical file + Action Plan changes
    echo -e "\n${BLUE}Testing critical file + action plan changes...${NC}"
    echo "#!/bin/bash\necho 'Modified hook'" > .aicheck/hooks/pre-commit
    echo "# Modified Plan" > test-PLAN.md
    git add .aicheck/hooks/pre-commit test-PLAN.md
    if ! git commit -m "Critical and plan changes" > /dev/null 2>&1; then
        ((passed_tests++))
        echo -e "${GREEN}✓ Critical file + action plan changes blocked${NC}"
    else
        echo -e "${RED}✗ Critical file + action plan changes allowed${NC}"
    fi
    ((total_tests++))
    
    # Test 3: Template + Critical file changes
    echo -e "\n${BLUE}Testing template + critical file changes...${NC}"
    echo "# Modified Template" > .aicheck/templates/test_template.md
    echo "#!/bin/bash\necho 'Modified hook'" > .aicheck/hooks/pre-commit
    git add .aicheck/templates/test_template.md .aicheck/hooks/pre-commit
    if ! git commit -m "Template and critical changes" > /dev/null 2>&1; then
        ((passed_tests++))
        echo -e "${GREEN}✓ Template + critical file changes blocked${NC}"
    else
        echo -e "${RED}✗ Template + critical file changes allowed${NC}"
    fi
    ((total_tests++))
    
    # Test 4: All types of changes
    echo -e "\n${BLUE}Testing all types of changes together...${NC}"
    echo "# Modified Template" > .aicheck/templates/test_template.md
    echo "#!/bin/bash\necho 'Modified hook'" > .aicheck/hooks/pre-commit
    echo "# Modified Plan" > test-PLAN.md
    git add .aicheck/templates/test_template.md .aicheck/hooks/pre-commit test-PLAN.md
    if ! git commit -m "All types of changes" > /dev/null 2>&1; then
        ((passed_tests++))
        echo -e "${GREEN}✓ All types of changes blocked${NC}"
    else
        echo -e "${RED}✗ All types of changes allowed${NC}"
    fi
    ((total_tests++))
    
    # Reset changes
    git reset --hard HEAD
}

# Function to test color support
test_color_support() {
    print_test_header "$COLOR_CATEGORY"
    
    # Test with terminal output
    output=$(git commit -m "Test colors" 2>&1)
    echo "$output" | grep -q "\[0;35m"
    result=$?
    print_test_result $result "color_support" "Failed to detect terminal color support" "$output"
    
    # Test without terminal output
    output=$(git commit -m "Test colors" 2>&1 | cat)
    echo "$output" | grep -q "\[0;35m"
    result=$?
    print_test_result $result "non_terminal_color" "Failed to handle non-terminal output correctly" "$output"
}

# Function to test debug mode
test_debug_mode() {
    print_test_header "$DEBUG_CATEGORY"
    
    # Test with debug enabled
    output=$(AICHECK_DEBUG=true git commit -m "Test debug" 2>&1)
    echo "$output" | grep -q "Debug:"
    result=$?
    print_test_result $result "debug_mode" "Failed to show debug output" "$output"
}

# Function to test error handling
test_error_handling() {
    print_test_header "$ERROR_CATEGORY"
    
    # Test with invalid hook
    mv ".aicheck/hooks/pre-commit" ".aicheck/hooks/pre-commit.bak"
    output=$(git commit -m "Test error handling" 2>&1)
    result=$?
    print_test_result $result "error_handling" "Failed to handle missing hook" "$output"
    mv ".aicheck/hooks/pre-commit.bak" ".aicheck/hooks/pre-commit"
}

# Function to print test coverage report
print_coverage_report() {
    echo -e "\n${YELLOW}=== Test Coverage Report ===${NC}"
    local total_tests=14
    local passed_tests=0
    
    # Print by category
    echo -e "\n${CYAN}$TEMPLATE_CATEGORY:${NC}"
    if [ $template_new -eq 1 ]; then echo -e "${GREEN}✓ template_new${NC}"; ((passed_tests++)); else echo -e "${RED}✗ template_new${NC}"; fi
    if [ $template_modify -eq 1 ]; then echo -e "${GREEN}✓ template_modify${NC}"; ((passed_tests++)); else echo -e "${RED}✗ template_modify${NC}"; fi
    if [ $template_invalid -eq 1 ]; then echo -e "${GREEN}✓ template_invalid${NC}"; ((passed_tests++)); else echo -e "${RED}✗ template_invalid${NC}"; fi
    
    echo -e "\n${CYAN}$ACTION_CATEGORY:${NC}"
    if [ $action_new -eq 1 ]; then echo -e "${GREEN}✓ action_new${NC}"; ((passed_tests++)); else echo -e "${RED}✗ action_new${NC}"; fi
    if [ $action_modify -eq 1 ]; then echo -e "${GREEN}✓ action_modify${NC}"; ((passed_tests++)); else echo -e "${RED}✗ action_modify${NC}"; fi
    if [ $action_invalid -eq 1 ]; then echo -e "${GREEN}✓ action_invalid${NC}"; ((passed_tests++)); else echo -e "${RED}✗ action_invalid${NC}"; fi
    
    echo -e "\n${CYAN}$CRITICAL_CATEGORY:${NC}"
    if [ $critical_modify -eq 1 ]; then echo -e "${GREEN}✓ critical_modify${NC}"; ((passed_tests++)); else echo -e "${RED}✗ critical_modify${NC}"; fi
    if [ $critical_invalid -eq 1 ]; then echo -e "${GREEN}✓ critical_invalid${NC}"; ((passed_tests++)); else echo -e "${RED}✗ critical_invalid${NC}"; fi
    
    echo -e "\n${CYAN}$MULTIPLE_CATEGORY:${NC}"
    if [ $multiple_changes -eq 1 ]; then echo -e "${GREEN}✓ multiple_changes${NC}"; ((passed_tests++)); else echo -e "${RED}✗ multiple_changes${NC}"; fi
    if [ $multiple_invalid -eq 1 ]; then echo -e "${GREEN}✓ multiple_invalid${NC}"; ((passed_tests++)); else echo -e "${RED}✗ multiple_invalid${NC}"; fi
    
    echo -e "\n${CYAN}$COLOR_CATEGORY:${NC}"
    if [ $color_support -eq 1 ]; then echo -e "${GREEN}✓ color_support${NC}"; ((passed_tests++)); else echo -e "${RED}✗ color_support${NC}"; fi
    if [ $non_terminal_color -eq 1 ]; then echo -e "${GREEN}✓ non_terminal_color${NC}"; ((passed_tests++)); else echo -e "${RED}✗ non_terminal_color${NC}"; fi
    
    echo -e "\n${CYAN}$DEBUG_CATEGORY:${NC}"
    if [ $debug_mode -eq 1 ]; then echo -e "${GREEN}✓ debug_mode${NC}"; ((passed_tests++)); else echo -e "${RED}✗ debug_mode${NC}"; fi
    
    echo -e "\n${CYAN}$ERROR_CATEGORY:${NC}"
    if [ $error_handling -eq 1 ]; then echo -e "${GREEN}✓ error_handling${NC}"; ((passed_tests++)); else echo -e "${RED}✗ error_handling${NC}"; fi
    
    local coverage_percent=$((passed_tests * 100 / total_tests))
    echo -e "\n${BLUE}Coverage: $coverage_percent% ($passed_tests/$total_tests tests passed)${NC}"
}

# Main test execution
echo -e "${YELLOW}Starting AICheck pre-commit hook tests...${NC}"

setup_test_env
test_template_changes
test_action_plan_changes
test_critical_file_changes
test_multiple_changes
test_color_support
test_debug_mode
test_error_handling
cleanup_test_env

print_coverage_report

echo -e "\n${YELLOW}All tests completed!${NC}" 