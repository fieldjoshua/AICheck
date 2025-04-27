#!/bin/bash
# Documentation detection hook
# Detects newly added documentation files and offers to add them to the documentation index

# Colors for output
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Check for new documentation files
detect_documentation() {
    # Get files being committed
    local files=$(git diff --cached --name-only)
    local new_docs=()
    
    # Look for documentation files in action directories
    for file in $files; do
        # Check if it's a markdown file in an action supporting_docs directory
        if [[ "$file" == .aicheck/actions/*/supporting_docs/*.md ]]; then
            # Extract action name from path
            action_name=$(echo "$file" | sed -n 's|.aicheck/actions/\([^/]*\)/.*|\1|p')
            
            # Skip if it's a plan file
            if [[ "$file" == *"$action_name-PLAN.md" ]]; then
                continue
            fi
            
            # Get file name for the document title
            doc_title=$(basename "$file" .md)
            # Convert kebab-case to Title Case
            doc_title=$(echo "$doc_title" | sed -E 's/(^|-)([a-z])/\U\2/g' | sed 's/-/ /g')
            
            new_docs+=("$action_name:$doc_title:$file")
        fi
    done
    
    # If we found new documentation files, ask if user wants to add them to the index
    if [ ${#new_docs[@]} -gt 0 ]; then
        echo -e "${YELLOW}Found ${#new_docs[@]} new documentation file(s) in action directories:${NC}"
        for i in "${!new_docs[@]}"; do
            IFS=':' read -ra DOC_INFO <<< "${new_docs[$i]}"
            action_name="${DOC_INFO[0]}"
            doc_title="${DOC_INFO[1]}"
            file_path="${DOC_INFO[2]}"
            echo -e "${YELLOW}$((i+1)). $doc_title (Action: $action_name)${NC}"
        done
        
        echo -e "${YELLOW}Would you like to add these documents to the documentation index for future reference? (y/n)${NC}"
        read -r add_to_index
        
        if [ "$add_to_index" = "y" ]; then
            for doc_info in "${new_docs[@]}"; do
                IFS=':' read -ra DOC_INFO <<< "$doc_info"
                action_name="${DOC_INFO[0]}"
                doc_title="${DOC_INFO[1]}"
                file_path="${DOC_INFO[2]}"
                
                echo -e "Adding '$doc_title' to documentation index..."
                echo -e "Enter a brief description for this document (or press Enter for default):"
                read -r doc_desc
                
                if [ -z "$doc_desc" ]; then
                    doc_desc="Supporting documentation for $action_name"
                fi
                
                # Add to documentation index
                ./ai docs add "$action_name" "$doc_title" "$file_path" "$doc_desc"
            done
            
            echo -e "${GREEN}Documents added to documentation index.${NC}"
            echo -e "${YELLOW}Note: Changes to the documentation index will be included in your commit.${NC}"
            git add .aicheck/docs/documentation_index.md
        else
            echo -e "${YELLOW}Documents not added to index. You can add them later with './ai docs add'.${NC}"
        fi
    fi
    
    return 0
}

# Run the detection
detect_documentation 