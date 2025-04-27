#!/bin/bash

# Colors for output
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Test documentation detection
echo -e "\n${YELLOW}Testing Documentation Detection...${NC}"

# Create a test action
test_action="DocDetectionTestAction"
.aicheck/scripts/action.sh create "$test_action"

# Create a test document
mkdir -p ".aicheck/actions/$test_action/supporting_docs"
echo "# Test Document for Detection" > ".aicheck/actions/$test_action/supporting_docs/test-detection.md"

# Stage the file
git add ".aicheck/actions/$test_action/supporting_docs/test-detection.md"

# Run the detection hook with 'no' input (don't add to index)
if echo "n" | .aicheck/scripts/doc_detection_hook.sh | grep -q "Found 1 new documentation file"; then
    echo -e "${GREEN}✓ Documentation detection test passed${NC}"
else
    echo -e "${RED}✗ Documentation detection test failed${NC}"
fi

# Cleanup
git reset ".aicheck/actions/$test_action/supporting_docs/test-detection.md"
.aicheck/scripts/action.sh delete "$test_action"

echo -e "\nTest completed." 