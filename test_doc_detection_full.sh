#!/bin/bash

# Documentation Detection Hook - Complete Test Script
# This script tests all scenarios outlined in TESTING.md for the documentation detection hook

# Colors for output
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Test results tracking
PASSED=0
FAILED=0
TOTAL=0

# Helper function to track test results
track_test_result() {
    local result=$1
    local test_name=$2
    
    ((TOTAL++))
    
    if [ "$result" = "pass" ]; then
        ((PASSED++))
        echo -e "${GREEN}✓ Test passed: $test_name${NC}"
    else
        ((FAILED++))
        echo -e "${RED}✗ Test failed: $test_name${NC}"
    fi
}

# Begin tests
echo -e "${YELLOW}=== Documentation Detection Hook Testing ===${NC}"

# Test 1: Create a new action
echo -e "\n${YELLOW}Test 1: Creating test action${NC}"
./ai new TestDocAction > /dev/null 2>&1
if [ -d ".aicheck/actions/TestDocAction" ]; then
    track_test_result "pass" "Action creation"
else
    track_test_result "fail" "Action creation"
    exit 1  # Cannot continue without action
fi

# Test 2: Create a markdown file in supporting_docs
echo -e "\n${YELLOW}Test 2: Creating test document${NC}"
mkdir -p .aicheck/actions/TestDocAction/supporting_docs
echo "# Test Document" > .aicheck/actions/TestDocAction/supporting_docs/test-document.md
if [ -f ".aicheck/actions/TestDocAction/supporting_docs/test-document.md" ]; then
    track_test_result "pass" "Document creation"
else
    track_test_result "fail" "Document creation"
fi

# Test 3: Adding document to git staging
echo -e "\n${YELLOW}Test 3: Staging document${NC}"
git add .aicheck/actions/TestDocAction/supporting_docs/test-document.md
if git status --porcelain | grep -q "A.*test-document.md"; then
    track_test_result "pass" "Document staging"
else
    track_test_result "fail" "Document staging"
fi

# Test 4: Running doc detection hook with 'yes' response
echo -e "\n${YELLOW}Test 4: Testing doc detection hook (adding to index)${NC}"
# Save the original index
if [ -f ".aicheck/docs/documentation_index.md" ]; then
    cp .aicheck/docs/documentation_index.md .aicheck/docs/documentation_index.md.bak
fi

# Run hook with 'yes' input and a description
(echo "y"; echo "Test document description") | .aicheck/scripts/doc_detection_hook.sh > /dev/null

# Check if document was detected and added to index
if [ -f ".aicheck/docs/documentation_index.md" ] && grep -q "TestDocAction" ".aicheck/docs/documentation_index.md" && grep -q "test-document.md" ".aicheck/docs/documentation_index.md"; then
    track_test_result "pass" "Document detection and addition to index"
else
    track_test_result "fail" "Document detection and addition to index"
fi

# Reset for next test
git reset .aicheck/actions/TestDocAction/supporting_docs/test-document.md > /dev/null
if [ -f ".aicheck/docs/documentation_index.md.bak" ]; then
    mv .aicheck/docs/documentation_index.md.bak .aicheck/docs/documentation_index.md
fi

# Test 5: Create a second action
echo -e "\n${YELLOW}Test 5: Creating second test action${NC}"
./ai new TestDocAction2 > /dev/null 2>&1
if [ -d ".aicheck/actions/TestDocAction2" ]; then
    track_test_result "pass" "Second action creation"
else
    track_test_result "fail" "Second action creation"
    exit 1  # Cannot continue without action
fi

# Test 6: Create another markdown file
echo -e "\n${YELLOW}Test 6: Creating second test document${NC}"
mkdir -p .aicheck/actions/TestDocAction2/supporting_docs
echo "# Test Document 2" > .aicheck/actions/TestDocAction2/supporting_docs/test-document-2.md
if [ -f ".aicheck/actions/TestDocAction2/supporting_docs/test-document-2.md" ]; then
    track_test_result "pass" "Second document creation"
else
    track_test_result "fail" "Second document creation"
fi

# Test 7: Stage second file
echo -e "\n${YELLOW}Test 7: Staging second document${NC}"
git add .aicheck/actions/TestDocAction2/supporting_docs/test-document-2.md
if git status --porcelain | grep -q "A.*test-document-2.md"; then
    track_test_result "pass" "Second document staging"
else
    track_test_result "fail" "Second document staging"
fi

# Test 8: Running doc detection hook with 'no' response
echo -e "\n${YELLOW}Test 8: Testing doc detection hook (rejecting addition to index)${NC}"
# Save the original index
if [ -f ".aicheck/docs/documentation_index.md" ]; then
    cp .aicheck/docs/documentation_index.md .aicheck/docs/documentation_index.md.bak
fi

# Run hook with 'no' input
echo "n" | .aicheck/scripts/doc_detection_hook.sh > /dev/null

# Check if document was detected but NOT added to index
if [ -f ".aicheck/docs/documentation_index.md" ] && ! grep -q "test-document-2.md" ".aicheck/docs/documentation_index.md"; then
    track_test_result "pass" "Document detection but rejection from index"
else
    track_test_result "fail" "Document detection but rejection from index"
fi

# Test 9: Manual document addition to index
echo -e "\n${YELLOW}Test 9: Testing manual document addition${NC}"
./ai docs add "TestDocAction2" "Test Document 2" ".aicheck/actions/TestDocAction2/supporting_docs/test-document-2.md" "Manually added test document" > /dev/null

# Check if document was added to index manually
if [ -f ".aicheck/docs/documentation_index.md" ] && grep -q "TestDocAction2" ".aicheck/docs/documentation_index.md" && grep -q "test-document-2.md" ".aicheck/docs/documentation_index.md"; then
    track_test_result "pass" "Manual document addition to index"
else
    track_test_result "fail" "Manual document addition to index"
fi

# Clean up
echo -e "\n${YELLOW}Cleaning up...${NC}"
git reset .aicheck/actions/TestDocAction2/supporting_docs/test-document-2.md > /dev/null
if [ -f ".aicheck/docs/documentation_index.md.bak" ]; then
    mv .aicheck/docs/documentation_index.md.bak .aicheck/docs/documentation_index.md
fi
./ai delete TestDocAction > /dev/null 2>&1
./ai delete TestDocAction2 > /dev/null 2>&1

# Print test results
echo -e "\n${YELLOW}=== Test Results ===${NC}"
echo -e "Total tests: $TOTAL"
echo -e "${GREEN}Tests passed: $PASSED${NC}"
echo -e "${RED}Tests failed: $FAILED${NC}"

if [ $FAILED -eq 0 ]; then
    echo -e "\n${GREEN}All documentation detection hook tests passed!${NC}"
    exit 0
else
    echo -e "\n${RED}Some documentation detection hook tests failed!${NC}"
    exit 1
fi 