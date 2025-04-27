#!/bin/bash

# Colors for output
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Test results tracking
PASSED_TESTS=0
FAILED_TESTS=0
TOTAL_TESTS=0

# Function to test documentation detection
test_documentation_detection() {
    echo -e "\n${YELLOW}Testing Documentation Detection...${NC}"
    
    # Test 1: Create a test action
    local test_action="DocDetectionTestAction"
    .aicheck/scripts/action.sh create "$test_action"
    
    # Test 2: Create a test document
    mkdir -p ".aicheck/actions/$test_action/supporting_docs"
    echo "# Test Document for Detection" > ".aicheck/actions/$test_action/supporting_docs/test-detection.md"
    
    # Test 3: Stage the file
    git add ".aicheck/actions/$test_action/supporting_docs/test-detection.md"
    
    # Test 4: Run the detection hook with 'yes' input (add to index)
    # Save the original index
    if [ -f ".aicheck/docs/documentation_index.md" ]; then
        cp .aicheck/docs/documentation_index.md .aicheck/docs/documentation_index.md.bak
    fi
    
    # Run hook with 'yes' input and a description
    (echo "y"; echo "Test document description") | .aicheck/scripts/doc_detection_hook.sh > /dev/null
    
    # Check if document was detected and added to index
    if [ -f ".aicheck/docs/documentation_index.md" ] && 
       grep -q "DocDetectionTestAction" ".aicheck/docs/documentation_index.md" && 
       grep -q "test-detection.md" ".aicheck/docs/documentation_index.md"; then
        echo -e "${GREEN}✓ Document detection and addition to index test passed${NC}"
        ((PASSED_TESTS++))
    else
        echo -e "${RED}✗ Document detection and addition to index test failed${NC}"
        ((FAILED_TESTS++))
    fi
    
    # Reset for next test
    git reset ".aicheck/actions/$test_action/supporting_docs/test-detection.md" > /dev/null
    if [ -f ".aicheck/docs/documentation_index.md.bak" ]; then
        mv .aicheck/docs/documentation_index.md.bak .aicheck/docs/documentation_index.md
    fi
    
    # Test 5: Create a second action
    local test_action2="DocDetectionTestAction2"
    .aicheck/scripts/action.sh create "$test_action2"
    
    # Test 6: Create another document
    mkdir -p ".aicheck/actions/$test_action2/supporting_docs"
    echo "# Test Document 2" > ".aicheck/actions/$test_action2/supporting_docs/test-detection-2.md"
    
    # Test 7: Stage the second file
    git add ".aicheck/actions/$test_action2/supporting_docs/test-detection-2.md"
    
    # Test 8: Run the detection hook with 'no' input (reject adding to index)
    # Save the original index
    if [ -f ".aicheck/docs/documentation_index.md" ]; then
        cp .aicheck/docs/documentation_index.md .aicheck/docs/documentation_index.md.bak
    fi
    
    # Run hook with 'no' input
    echo "n" | .aicheck/scripts/doc_detection_hook.sh > /dev/null
    
    # Check if document was detected but NOT added to index
    if [ -f ".aicheck/docs/documentation_index.md" ] && 
       ! grep -q "test-detection-2.md" ".aicheck/docs/documentation_index.md"; then
        echo -e "${GREEN}✓ Document detection rejection test passed${NC}"
        ((PASSED_TESTS++))
    else
        echo -e "${RED}✗ Document detection rejection test failed${NC}"
        ((FAILED_TESTS++))
    fi
    
    # Test 9: Test manual document addition to index
    ./ai docs add "$test_action2" "Test Document 2" ".aicheck/actions/$test_action2/supporting_docs/test-detection-2.md" "Manually added test document" > /dev/null
    
    # Check if document was added to index manually
    if [ -f ".aicheck/docs/documentation_index.md" ] && 
       grep -q "$test_action2" ".aicheck/docs/documentation_index.md" && 
       grep -q "test-detection-2.md" ".aicheck/docs/documentation_index.md"; then
        echo -e "${GREEN}✓ Manual document addition test passed${NC}"
        ((PASSED_TESTS++))
    else
        echo -e "${RED}✗ Manual document addition test failed${NC}"
        ((FAILED_TESTS++))
    fi
    
    # Cleanup
    git reset ".aicheck/actions/$test_action2/supporting_docs/test-detection-2.md" > /dev/null
    if [ -f ".aicheck/docs/documentation_index.md.bak" ]; then
        mv .aicheck/docs/documentation_index.md.bak .aicheck/docs/documentation_index.md
    fi
    .aicheck/scripts/action.sh delete "$test_action"
    .aicheck/scripts/action.sh delete "$test_action2"
    
    ((TOTAL_TESTS+=3))
}

# Run the test
test_documentation_detection

# Print summary
echo -e "\n${YELLOW}=== Test Results ===${NC}"
echo -e "Total tests: $TOTAL_TESTS"
echo -e "${GREEN}Tests passed: $PASSED_TESTS${NC}"
echo -e "${RED}Tests failed: $FAILED_TESTS${NC}"

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "\n${GREEN}All documentation detection tests passed!${NC}"
    exit 0
else
    echo -e "\n${RED}Some documentation detection tests failed!${NC}"
    exit 1
fi 