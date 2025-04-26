#!/bin/bash

# UltraAICheck Installer
# A standalone version of AICheck with UltraAI-optimized directory structure
# Each action has its own directory with plan file and supporting docs

echo "┌─────────────────────────────────────────────────────────┐"
echo "│                                                         │"
echo "│             UltraAICheck Installer                      │"
echo "│                                                         │"
echo "└─────────────────────────────────────────────────────────┘"

# Verify if git is installed
if ! command -v git &> /dev/null; then
    echo "Error: git is not installed. Please install git first."
    exit 1
fi

# Check if we're in a git repository
if ! git rev-parse --is-inside-work-tree &> /dev/null; then
    echo "Warning: Not in a git repository. Initializing git repository..."
    git init
fi

# Function to create directory if it doesn't exist
create_dir() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
        echo "  Created directory: $1"
    else
        echo "  Directory already exists: $1"
    fi
}

# Create the UltraAICheck directory structure
echo ""
echo "=== Creating UltraAICheck Directory Structure ==="
create_dir ".aicheck"
create_dir ".aicheck/templates"
create_dir ".aicheck/sessions"
create_dir ".aicheck/docs"
create_dir ".aicheck/insights"
create_dir ".aicheck/hooks"
create_dir ".aicheck/actions"
create_dir ".aicheck/actions/Initial"
create_dir ".aicheck/actions/Initial/supporting_docs"
create_dir ".aicheck/cursor"

# Create the main AI command script with UltraAI structure
echo ""
echo "=== Creating AI Command Script ==="
cat > ./ai << 'EOF'
#!/bin/bash

# UltraAICheck command interface
# Provides a unified interface for all UltraAICheck functionality
# Adapted for UltraAI directory structure with action directories

# Include common functions
source .aicheck/common.sh

command=$1
shift

case "$command" in
    start)
        # Start a new AI session with context
        session_id=$(date +%Y%m%d%H%M%S)
        mkdir -p .aicheck/sessions/$session_id
        
        # Generate context from current repository state
        git_branch=$(git branch --show-current)
        recent_commits=$(git log -n 5 --oneline)
        current_action=$(cat .aicheck/current_action 2>/dev/null || echo "None")
        
        # Add Rules reference
        echo "=== UltraAICheck Session Start ==="
        echo "Reference: RULES.md is the controlling document for this project"
        echo "Current Action: $current_action"
        echo "Actions Index: .aicheck/docs/actions_index.md"
        echo "Check/Update Status: ./ai status"
        echo "IMPORTANT: AI editors DO NOT need to ask for approval for any work that complies with RULES.md and is within the current Action scope"
        
        # Create session file with initial context
        cat > .aicheck/sessions/$session_id/context.md << EOC
# Session Context: $session_id
- Branch: $git_branch
- Current Action: $current_action
- Recent Commits:
$(echo "$recent_commits" | sed 's/^/  - /')

## RULES Reference
This development follows the rules defined in RULES.md, which is the controlling document.
NOTE: AI editors should assume that approval is given for any work that complies with RULES.md and falls within the scope of the current Action.
NO APPROVAL IS NEEDED for such work - proceed directly to implementation.

## Action Status
Current Action: $current_action
Actions Index: .aicheck/docs/actions_index.md (source of truth for statuses)
Update Status: Run './ai status'

## Active Files
$(find . -type f -name "*.py" -o -name "*.js" -o -name "*.html" -o -name "*.css" -o -name "*.md" -o -name "*.json" | grep -v "node_modules" | grep -v ".git" | head -n 10 | sed 's/^/- /')

## Action Details
$(if [ "$current_action" != "None" ] && [ -f ".aicheck/actions/$current_action/$current_action-PLAN.md" ]; then
    cat ".aicheck/actions/$current_action/$current_action-PLAN.md" | head -n 20
    echo "..."
  else
    echo "No current action selected or plan file not found."
  fi)
EOC

        # Record session start
        echo "$(date +"%Y-%m-%d %H:%M:%S") - Session started: $session_id" >> .aicheck/sessions/session_log.txt
        echo $session_id > .aicheck/current_session
        
        echo "AI session started with ID: $session_id"
        echo "Context file created at .aicheck/sessions/$session_id/context.md"
        ;;
        
    prompt)
        # Generate a prompt template
        current_session=$(cat .aicheck/current_session 2>/dev/null || echo "")
        current_action=$(cat .aicheck/current_action 2>/dev/null || echo "None")
        
        if [ -z "$current_session" ]; then
            echo "No active session. Start a session first with './ai start'"
            exit 1
        fi
        
        prompt_file=".aicheck/sessions/$current_session/prompt_$(date +%H%M%S).md"
        
        cat > $prompt_file << EOT
# AI Prompt - $(date +"%Y-%m-%d %H:%M:%S")

## RULES Reference
This development follows the rules defined in RULES.md, which is the controlling document.
IMPORTANT: AI editors DO NOT need to ask for approval for any work that complies with RULES.md and is within the current Action scope.
You can proceed directly with implementation for:
- Code that implements the current Action plan
- Documentation updates
- Bug fixes related to the current Action
- Tests for current Action functionality
- Refactoring within the current Action scope

## Current Action: $current_action
Action Details: .aicheck/actions/$current_action/$current_action-PLAN.md
Actions Index: .aicheck/docs/actions_index.md (source of truth for statuses)

## Context
<!-- Add any relevant context here -->

## Task
<!-- Describe what you want the AI to do -->

## Requirements
<!-- List specific requirements -->
- 
- 
- 

## Expected Output
<!-- Describe what output you expect -->

EOT

        echo "Prompt template created at $prompt_file"
        if command -v code &> /dev/null; then
            code $prompt_file
        else
            echo "Open this file in your editor to complete the prompt"
        fi
        ;;
        
    status)
        # Check current action status
        current_action=$(cat .aicheck/current_action 2>/dev/null || echo "None")
        current_session=$(cat .aicheck/current_session 2>/dev/null || echo "None")
        
        echo "=== UltraAICheck Status ==="
        echo "RULES Reference: RULES.md is the controlling document"
        echo "Current Action: $current_action"
        echo "Current Session: $current_session"
        echo "Actions Index: .aicheck/docs/actions_index.md (source of truth)"
        
        # Get status from actions_index.md (the source of truth)
        if [ "$current_action" != "None" ] && [ -f ".aicheck/docs/actions_index.md" ]; then
            action_line=$(grep -E "^\| $current_action \|" .aicheck/docs/actions_index.md)
            if [ -n "$action_line" ]; then
                action_status=$(echo "$action_line" | awk -F'|' '{print $3}' | xargs)
                action_progress=$(echo "$action_line" | awk -F'|' '{print $4}' | xargs)
                action_owner=$(echo "$action_line" | awk -F'|' '{print $5}' | xargs)
                
                echo ""
                echo "=== Action Status (from index) ==="
                echo "Status: $action_status"
                echo "Progress: $action_progress"
                echo "Owner: $action_owner"
            fi
        fi
        
        # Show action details
        if [ "$current_action" != "None" ] && [ -f ".aicheck/actions/$current_action/$current_action-PLAN.md" ]; then
            echo ""
            echo "=== Action Details ==="
            head -n 10 ".aicheck/actions/$current_action/$current_action-PLAN.md"
            echo "..."
            
            # Check if action entry exists in index
            if [ -f ".aicheck/docs/actions_index.md" ]; then
                if ! grep -q "| $current_action |" ".aicheck/docs/actions_index.md"; then
                    # Action exists but not in index - add it
                    echo ""
                    echo "Warning: Action $current_action exists but is not in the index."
                    echo "Would you like to add it to the index? (y/n)"
                    read -r add_to_index
                    
                    if [ "$add_to_index" == "y" ]; then
                        # Extract status from file
                        action_file_status=$(grep -A 5 "## Status" ".aicheck/actions/$current_action/$current_action-PLAN.md" | grep "Status:" | sed 's/Status: //')
                        created_date=$(grep -Eo "Created: [0-9]{4}-[0-9]{2}-[0-9]{2}" ".aicheck/actions/$current_action/$current_action-PLAN.md" | sed 's/Created: //')
                        last_updated=$(date +"%Y-%m-%d")
                        
                        # If still empty, set defaults
                        if [ -z "$action_file_status" ]; then action_file_status="In Progress"; fi
                        if [ -z "$created_date" ]; then created_date=$(date +"%Y-%m-%d"); fi
                        
                        # Add action to index
                        sed -i.bak '/^| Action | Status/a\
| '"$current_action"' | '"$action_file_status"' | 0% | UltraAI Team | '"$created_date"' | '"$last_updated"' | Standard Action | 3 |' .aicheck/docs/actions_index.md
                        rm -f .aicheck/docs/actions_index.md.bak
                        echo "Added $current_action to actions index with status: $action_file_status"
                    fi
                fi
            fi
        fi
        
        # List supporting documents
        if [ "$current_action" != "None" ] && [ -d ".aicheck/actions/$current_action/supporting_docs" ]; then
            echo ""
            echo "=== Supporting Documents ==="
            find ".aicheck/actions/$current_action/supporting_docs" -type f | sed 's/^/- /'
        fi
        ;;
    
    update-status)
        # Update action status
        action_name=$1
        new_status=$2
        
        if [ -z "$action_name" ] || [ -z "$new_status" ]; then
            echo "Error: Both action name and new status required"
            echo "Usage: ./ai update-status ActionName \"New Status\""
            exit 1
        fi
        
        # Update status in the index (source of truth)
        if [ -f ".aicheck/docs/actions_index.md" ]; then
            if grep -q "| $action_name |" ".aicheck/docs/actions_index.md"; then
                # Action exists in index, update it
                last_updated=$(date +"%Y-%m-%d")
                sed -i.bak "s/| $action_name |[^|]*|/| $action_name | $new_status |/" .aicheck/docs/actions_index.md
                rm -f .aicheck/docs/actions_index.md.bak
                echo "Updated status for $action_name to '$new_status' in actions index"
            else
                echo "Error: Action '$action_name' not found in actions index"
                exit 1
            fi
        else
            echo "Error: actions_index.md not found"
            exit 1
        fi
        
        # Also update status in the action file
        if [ -f ".aicheck/actions/$action_name/$action_name-PLAN.md" ]; then
            sed -i.bak "s/Status: .*/Status: $new_status/" ".aicheck/actions/$action_name/$action_name-PLAN.md"
            rm -f ".aicheck/actions/$action_name/$action_name-PLAN.md.bak"
            echo "Updated status in action plan to '$new_status'"
        else
            echo "Warning: Action plan .aicheck/actions/$action_name/$action_name-PLAN.md not found"
        fi
        ;;
        
    update-progress)
        # Update action progress percentage
        action_name=$1
        new_progress=$2
        
        if [ -z "$action_name" ] || [ -z "$new_progress" ]; then
            echo "Error: Both action name and progress percentage required"
            echo "Usage: ./ai update-progress ActionName \"50%\""
            exit 1
        fi
        
        # Update progress in the index
        if [ -f ".aicheck/docs/actions_index.md" ]; then
            if grep -q "| $action_name |" ".aicheck/docs/actions_index.md"; then
                # Action exists in index, update it
                last_updated=$(date +"%Y-%m-%d")
                
                # Extract the line
                action_line=$(grep -E "^\| $action_name \|" .aicheck/docs/actions_index.md)
                status=$(echo "$action_line" | awk -F'|' '{print $3}' | xargs)
                
                # Replace the progress field (field 4)
                sed -i.bak "s/| $action_name | $status |[^|]*|/| $action_name | $status | $new_progress |/" .aicheck/docs/actions_index.md
                rm -f .aicheck/docs/actions_index.md.bak
                echo "Updated progress for $action_name to '$new_progress' in actions index"
            else
                echo "Error: Action '$action_name' not found in actions index"
                exit 1
            fi
        else
            echo "Error: actions_index.md not found"
            exit 1
        fi
        ;;
        
    end)
        # End session with summary
        current_session=$(cat .aicheck/current_session 2>/dev/null || echo "")
        summary=$1
        
        if [ -z "$current_session" ]; then
            echo "No active session to end"
            exit 1
        fi
        
        # Record session end with summary
        end_time=$(date +"%Y-%m-%d %H:%M:%S")
        echo "$end_time - Session ended: $current_session" >> .aicheck/sessions/session_log.txt
        echo "Summary: $summary" >> .aicheck/sessions/session_log.txt
        echo "" >> .aicheck/sessions/session_log.txt
        
        # Get current action
        current_action=$(cat .aicheck/current_action 2>/dev/null || echo "None")
        
        # Create session summary file
        cat > .aicheck/sessions/$current_session/summary.md << EOS
# Session Summary: $current_session
- End Time: $end_time
- Summary: $summary

## Actions Worked On
$current_action

## Files Modified
$(git diff --name-only | sed 's/^/- /')
EOS

        # Ask if progress should be updated
        if [ "$current_action" != "None" ]; then
            echo "Would you like to update the progress for $current_action? (y/n)"
            read -r update_progress
            
            if [ "$update_progress" == "y" ]; then
                echo "Enter new progress percentage (e.g., 75%):"
                read -r new_progress
                
                # Update progress in index
                if [ -f ".aicheck/docs/actions_index.md" ] && grep -q "| $current_action |" ".aicheck/docs/actions_index.md"; then
                    action_line=$(grep -E "^\| $current_action \|" .aicheck/docs/actions_index.md)
                    status=$(echo "$action_line" | awk -F'|' '{print $3}' | xargs)
                    
                    sed -i.bak "s/| $current_action | $status |[^|]*|/| $current_action | $status | $new_progress |/" .aicheck/docs/actions_index.md
                    rm -f .aicheck/docs/actions_index.md.bak
                    echo "Updated progress for $current_action to $new_progress"
                fi
            fi
        fi
        
        # Clear current session
        rm .aicheck/current_session
        
        echo "Session $current_session ended"
        echo "Summary saved to .aicheck/sessions/$current_session/summary.md"
        ;;
        
    focus)
        # Show focus rules and Action list
        echo "=== UltraAICheck Focus Protocol ==="
        echo "The Focus Protocol helps maintain concentration on the current Action"
        echo "and prevents context-switching that reduces productivity."
        
        echo "Current Action: $(cat .aicheck/current_action 2>/dev/null || echo "None")"
        
        echo ""
        echo "=== Available Actions ==="
        
        if [ -f ".aicheck/docs/actions_index.md" ]; then
            grep -E "^\| [^|]+ \|" .aicheck/docs/actions_index.md | grep -v "Action | Status" | while read -r line; do
                action_name=$(echo "$line" | awk -F'|' '{print $2}' | xargs)
                action_status=$(echo "$line" | awk -F'|' '{print $3}' | xargs)
                action_progress=$(echo "$line" | awk -F'|' '{print $4}' | xargs)
                echo "$action_name: $action_status ($action_progress)"
            done
        else
            # Fallback if index doesn't exist
            find .aicheck/actions -type d -maxdepth 1 -mindepth 1 | sort | while read action_dir; do
                action_name=$(basename "$action_dir")
                if [ -f "$action_dir/$action_name-PLAN.md" ]; then
                    action_status=$(grep -A 5 "## Status" "$action_dir/$action_name-PLAN.md" | grep "Status:" | sed 's/Status: //')
                    if [ -z "$action_status" ]; then action_status="Unknown"; fi
                    echo "$action_name: $action_status"
                fi
            done
        fi
        
        echo ""
        echo "=== Focus Rules ==="
        echo "1. Stay focused on one Action at a time"
        echo "2. Document context-switching with explicit Action identification"
        echo "3. Create a new Action when starting a new task area"
        echo "4. Complete or pause an Action before switching"
        echo "5. AI editors have pre-approval for work within the current Action scope"
        ;;
        
    insights)
        # Generate productivity insights
        echo "=== UltraAICheck Productivity Insights ==="
        
        # Count sessions
        session_count=$(find .aicheck/sessions -maxdepth 1 -type d | wc -l)
        session_count=$((session_count - 1)) # Subtract parent directory
        
        # Count actions
        action_count=$(find .aicheck/actions -maxdepth 1 -type d | wc -l)
        action_count=$((action_count - 1)) # Subtract parent directory
        
        # Count supporting docs
        supporting_doc_count=$(find .aicheck/actions -path "*/supporting_docs/*" -type f | wc -l)
        
        # Calculate activity
        echo "Sessions: $session_count"
        echo "Actions: $action_count"
        echo "Supporting Documents: $supporting_doc_count"
        
        # Most active day analysis
        if [ -f ".aicheck/sessions/session_log.txt" ]; then
            echo ""
            echo "=== Activity Patterns ==="
            echo "Most active days (last 2 weeks):"
            grep "Session started" .aicheck/sessions/session_log.txt | cut -d' ' -f1 | sort | uniq -c | sort -nr | head -n 5 | 
            while read count date; do
                echo "$date: $count sessions"
            done
        fi
        
        # Action status breakdown
        if [ -f ".aicheck/docs/actions_index.md" ]; then
            echo ""
            echo "=== Action Status Breakdown ==="
            grep -E "^\| [^|]+ \|" .aicheck/docs/actions_index.md | grep -v "Action | Status" | awk -F'|' '{print $3}' | sort | uniq -c | 
            while read count status; do
                echo "$status: $count actions"
            done
        fi
        
        # Generate insights file
        mkdir -p .aicheck/insights
        insight_file=".aicheck/insights/insight_$(date +%Y%m%d).md"
        cat > "$insight_file" << EOI
# UltraAICheck Insights - $(date +"%Y-%m-%d")

## Summary
- Total Sessions: $session_count
- Total Actions: $action_count
- Supporting Documents: $supporting_doc_count

## Action Status Summary
$(if [ -f ".aicheck/docs/actions_index.md" ]; then
    echo "| Status | Count |"
    echo "|--------|-------|"
    grep -E "^\| [^|]+ \|" .aicheck/docs/actions_index.md | grep -v "Action | Status" | awk -F'|' '{print $3}' | sort | uniq -c | while read count status; do
        echo "| $status | $count |"
    done
fi)

## Most Active Actions
$(if [ -f ".aicheck/sessions/session_log.txt" ]; then
    echo "| Action | Sessions |"
    echo "|--------|----------|"
    grep "Current Action:" .aicheck/sessions/session_log.txt | cut -d':' -f2 | sort | uniq -c | sort -nr | head -n 5 | 
    while read count action; do
        echo "| $action | $count |"
    done
fi)

## Recommendations
- Review documentation for most active Actions
- Consider refactoring Actions with multiple sessions
- Schedule focused time for the most complex Actions
EOI

        echo ""
        echo "Detailed insights saved to $insight_file"
        ;;
        
    new)
        # Create a new Action with UltraAI directory structure
        action_name=$1
        
        if [ -z "$action_name" ]; then
            echo "Error: Action name required"
            echo "Usage: ./ai new ActionName"
            exit 1
        fi
        
        # Check if action already exists
        if [ -d ".aicheck/actions/$action_name" ]; then
            echo "Error: Action '$action_name' already exists"
            exit 1
        fi
        
        # Create action directory and structure
        mkdir -p ".aicheck/actions/$action_name/supporting_docs"
        
        # Create action plan file
        cat > ".aicheck/actions/$action_name/$action_name-PLAN.md" << EOA
# Action: $action_name
Created: $(date +"%Y-%m-%d %H:%M:%S")

## Objective
<!-- What is the goal of this Action? -->

## Context
<!-- What is the background and why is this Action needed? -->

## Requirements
<!-- What are the specific requirements for this Action? -->

## Implementation Plan
<!-- How will this Action be implemented? -->

## Status
Status: In Progress
EOA

        # Update current action
        echo "$action_name" > .aicheck/current_action
        
        # Add to actions_index.md
        if [ -f ".aicheck/docs/actions_index.md" ]; then
            created_date=$(date +"%Y-%m-%d")
            
            # Check if the table has "Progress" and "Owner" columns (UltraAI format)
            if grep -q "Progress" ".aicheck/docs/actions_index.md"; then
                # UltraAI format with more columns
                sed -i.bak '/^| Action | Status/a\
| '"$action_name"' | 🟡 WORKING | 0% | UltraAI Team | '"$created_date"' | '"$created_date"' | Standard Action | 3 |' .aicheck/docs/actions_index.md
            else
                # Standard format
                sed -i.bak '/^| Action | Status/a\
| '"$action_name"' | In Progress | '"$created_date"' | '"$created_date"' |' .aicheck/docs/actions_index.md
            fi
            rm -f .aicheck/docs/actions_index.md.bak
            echo "Added $action_name to actions index"
        else
            # Create a new index if it doesn't exist
            mkdir -p .aicheck/docs
            cat > .aicheck/docs/actions_index.md << EOI
# AICheck Actions Index

This document serves as a central reference for all Actions in the project.
This is the source of truth for action statuses.

## Active Actions

| Action | Status | Progress | Owner | Started | Last Updated | Authority | Priority |
|--------|--------|----------|-------|---------|-------------|-----------|----------|
| $action_name | 🟡 WORKING | 0% | UltraAI Team | $created_date | $created_date | Standard Action | 3 |

## Action States

The following status indicators are used throughout the system:
- 🔴 **QUEUED**: Action is scheduled but waiting to start
- 🟡 **WORKING**: Action is currently in progress
- 🟡 **REVIEW**: Action is complete and awaiting review
- ✅ **ACCEPTED**: Action has been completed and accepted
- ⏸️ **PAUSED**: Action is temporarily on hold
- ❌ **ABANDONED**: Action has been discontinued

## How to Update This Index

This index can be updated using the AICheck commands:
\`\`\`bash
./ai update-status ActionName "Status"
./ai status
\`\`\`

You can also manually update it by editing this file directly.

## Action Paths

All action documents are stored in \`.aicheck/actions/[ACTION_NAME]/[ACTION_NAME]-PLAN.md\` where each action has its own directory containing the plan and all supporting documents.

## Last Updated: $created_date
EOI
            echo "Created new actions index with $action_name"
        fi
        
        echo "Created new Action: $action_name"
        echo "Action directory: .aicheck/actions/$action_name/"
        echo "Action plan: .aicheck/actions/$action_name/$action_name-PLAN.md"
        echo "Supporting docs: .aicheck/actions/$action_name/supporting_docs/"
        echo "Current action set to: $action_name"
        
        # Open in editor if available
        if command -v code &> /dev/null; then
            code ".aicheck/actions/$action_name/$action_name-PLAN.md"
        else
            echo "Open this file in your editor to complete the Action details"
        fi
        ;;
        
    list)
        # List all actions and their status
        echo "=== UltraAICheck Actions ==="
        
        if [ -f ".aicheck/docs/actions_index.md" ]; then
            echo "Listing actions from actions_index.md (source of truth):"
            echo ""
            
            # Check if the table has UltraAI format with progress and owner
            if grep -q "Progress" ".aicheck/docs/actions_index.md"; then
                # UltraAI format
                grep -E "^\| [^|]+ \|" .aicheck/docs/actions_index.md | grep -v "Action | Status" | 
                while read -r line; do
                    action_name=$(echo "$line" | awk -F'|' '{print $2}' | xargs)
                    action_status=$(echo "$line" | awk -F'|' '{print $3}' | xargs)
                    action_progress=$(echo "$line" | awk -F'|' '{print $4}' | xargs)
                    action_owner=$(echo "$line" | awk -F'|' '{print $5}' | xargs)
                    started_date=$(echo "$line" | awk -F'|' '{print $6}' | xargs)
                    updated_date=$(echo "$line" | awk -F'|' '{print $7}' | xargs)
                    priority=$(echo "$line" | awk -F'|' '{print $9}' | xargs)
                    echo "- $action_name: $action_status ($action_progress) - Owner: $action_owner, Priority: $priority"
                done
            else
                # Standard format
                grep -E "^\| [^|]+ \|" .aicheck/docs/actions_index.md | grep -v "Action | Status" | 
                while read -r line; do
                    action_name=$(echo "$line" | awk -F'|' '{print $2}' | xargs)
                    action_status=$(echo "$line" | awk -F'|' '{print $3}' | xargs)
                    created_date=$(echo "$line" | awk -F'|' '{print $4}' | xargs)
                    updated_date=$(echo "$line" | awk -F'|' '{print $5}' | xargs)
                    echo "- $action_name: $action_status (Created: $created_date, Updated: $updated_date)"
                done
            fi
        else
            echo "Error: actions_index.md not found"
            echo "Falling back to action directories:"
            echo ""
            find .aicheck/actions -type d -maxdepth 1 -mindepth 1 | sort | while read action_dir; do
                action_name=$(basename "$action_dir")
                if [ -f "$action_dir/$action_name-PLAN.md" ]; then
                    action_status=$(grep -A 5 "## Status" "$action_dir/$action_name-PLAN.md" | grep "Status:" | sed 's/Status: //')
                    created_date=$(grep -Eo "Created: [0-9]{4}-[0-9]{2}-[0-9]{2}" "$action_dir/$action_name-PLAN.md" | sed 's/Created: //')
                    if [ -z "$action_status" ]; then action_status="Unknown"; fi
                    if [ -z "$created_date" ]; then created_date="Unknown"; fi
                    echo "- $action_name: $action_status (Created: $created_date)"
                fi
            done
        fi
        ;;
        
    docs)
        # Create or manage supporting documents for an action
        action_name=$1
        doc_name=$2
        
        if [ -z "$action_name" ]; then
            # If no action specified, use current action
            action_name=$(cat .aicheck/current_action 2>/dev/null || echo "")
            if [ -z "$action_name" ]; then
                echo "Error: No current action set and no action specified"
                echo "Usage: ./ai docs ActionName [DocumentName]"
                exit 1
            fi
        fi
        
        # Check if action exists
        if [ ! -d ".aicheck/actions/$action_name" ]; then
            echo "Error: Action '$action_name' not found"
            exit 1
        fi
        
        # If no doc name provided, list existing docs
        if [ -z "$doc_name" ]; then
            echo "=== Supporting Documents for $action_name ==="
            if [ -d ".aicheck/actions/$action_name/supporting_docs" ]; then
                find ".aicheck/actions/$action_name/supporting_docs" -type f | sed 's/^/- /'
                
                # Offer to create a new document
                echo ""
                echo "Would you like to create a new supporting document? (y/n)"
                read -r create_new
                
                if [ "$create_new" == "y" ]; then
                    echo "Enter document name (e.g., architecture_diagram.md):"
                    read -r new_doc_name
                    
                    # Create the document
                    mkdir -p ".aicheck/actions/$action_name/supporting_docs"
                    supporting_doc=".aicheck/actions/$action_name/supporting_docs/$new_doc_name"
                    
                    cat > "$supporting_doc" << EOD
# $action_name: ${new_doc_name%.*}
Created: $(date +"%Y-%m-%d %H:%M:%S")

## Overview

<!-- Document content here -->

## Related Documents
- $action_name-PLAN.md (Main plan)

## Last Updated: $(date +"%Y-%m-%d")
EOD
                    
                    echo "Created new supporting document: $supporting_doc"
                    if command -v code &> /dev/null; then
                        code "$supporting_doc"
                    else
                        echo "Open this file in your editor to add content"
                    fi
                fi
            else
                echo "No supporting documents found. Use './ai docs $action_name document_name.md' to create one."
            fi
        else
            # Create a new supporting document
            mkdir -p ".aicheck/actions/$action_name/supporting_docs"
            supporting_doc=".aicheck/actions/$action_name/supporting_docs/$doc_name"
            
            # Check if it already exists
            if [ -f "$supporting_doc" ]; then
                echo "Supporting document already exists: $supporting_doc"
                if command -v code &> /dev/null; then
                    code "$supporting_doc"
                else
                    echo "Open this file in your editor to edit it"
                fi
                exit 0
            fi
            
            # Create the document
            cat > "$supporting_doc" << EOD
# $action_name: ${doc_name%.*}
Created: $(date +"%Y-%m-%d %H:%M:%S")

## Overview

<!-- Document content here -->

## Related Documents
- $action_name-PLAN.md (Main plan)

## Last Updated: $(date +"%Y-%m-%d")
EOD
            
            echo "Created new supporting document: $supporting_doc"
            if command -v code &> /dev/null; then
                code "$supporting_doc"
            else
                echo "Open this file in your editor to add content"
            fi
        fi
        ;;
        
    switch)
        # Switch to a different action
        action_name=$1
        
        if [ -z "$action_name" ]; then
            echo "Error: Action name required"
            echo "Usage: ./ai switch ActionName"
            exit 1
        fi
        
        # Check if action exists
        if [ ! -d ".aicheck/actions/$action_name" ]; then
            echo "Error: Action '$action_name' not found"
            echo "Available actions:"
            find .aicheck/actions -type d -maxdepth 1 -mindepth 1 | sort | while read action_dir; do
                basename "$action_dir"
            done
            exit 1
        fi
        
        # Update current action
        previous_action=$(cat .aicheck/current_action 2>/dev/null || echo "None")
        echo "$action_name" > .aicheck/current_action
        
        echo "Switched from '$previous_action' to '$action_name'"
        echo "Run './ai start' to begin a new session with this action"
        ;;
        
    *)
        echo "UltraAICheck Command Interface"
        echo "Usage: ./ai <command> [options]"
        echo ""
        echo "Available commands:"
        echo "  start                Start a new AI session with context"
        echo "  prompt               Generate a prompt template"
        echo "  status               Check current action status"
        echo "  update-status        Update action status in the index and file"
        echo "  update-progress      Update action progress percentage"
        echo "  end \"summary\"        End session with summary"
        echo "  focus                Show focus rules and Action list"
        echo "  insights             Generate productivity insights"
        echo "  new ActionName       Create a new Action"
        echo "  list                 List all actions and their status"
        echo "  docs ActionName [Doc] Create or list supporting documents"
        echo "  switch ActionName    Switch to a different action"
        ;;
esac
EOF

chmod +x ./ai

# Create the cursor integration script with UltraAI structure
echo ""
echo "=== Creating Cursor Integration Script ==="
cat > ./cursor-ai << 'EOF'
#!/bin/bash

# UltraAICheck Cursor Integration
# Provides special commands for Cursor editor integration

# Include common functions
source .aicheck/common.sh

command=$1
shift

case "$command" in
    context)
        # Generate AI context for Cursor
        current_action=$(cat .aicheck/current_action 2>/dev/null || echo "None")
        current_session=$(cat .aicheck/current_session 2>/dev/null || echo "None")
        
        # Get action status and progress from index (source of truth)
        action_status="Unknown"
        action_progress="Unknown"
        if [ -f ".aicheck/docs/actions_index.md" ]; then
            action_line=$(grep -E "^\| $current_action \|" .aicheck/docs/actions_index.md)
            if [ -n "$action_line" ]; then
                action_status=$(echo "$action_line" | awk -F'|' '{print $3}' | xargs)
                # Check if we have progress column (UltraAI format)
                if grep -q "Progress" ".aicheck/docs/actions_index.md"; then
                    action_progress=$(echo "$action_line" | awk -F'|' '{print $4}' | xargs)
                fi
            fi
        fi
        
        # Create a temporary context file
        mkdir -p .aicheck/cursor
        context_file=".aicheck/cursor/context_$(date +%H%M%S).md"
        
        # Generate rich context including:
        # - Current action details
        # - Recently modified files
        # - Related documentation
        cat > "$context_file" << EOC
# Cursor AI Context - $(date +"%Y-%m-%d %H:%M:%S")

## RULES Reference
This development follows the rules defined in RULES.md, which is the controlling document.
IMPORTANT: AI editors DO NOT need to ask for approval for any work that complies with RULES.md and falls within the scope of the current Action.
You can proceed directly with implementation for:
- Code that implements the current Action plan
- Documentation updates related to the Action
- Bug fixes within the Action scope
- Tests for current Action functionality
- Refactoring within the current Action scope

## Current State
- Action: $current_action
- Action Status: $action_status
- Action Progress: $action_progress
- Session: $current_session
- Actions Index: .aicheck/docs/actions_index.md (source of truth for statuses)
- Update Status: Run './ai status'

## Current Action Details
$(if [ "$current_action" != "None" ] && [ -f ".aicheck/actions/$current_action/$current_action-PLAN.md" ]; then
    cat ".aicheck/actions/$current_action/$current_action-PLAN.md"
  else
    echo "No current action selected or plan file not found."
  fi)

## Supporting Documents
$(if [ "$current_action" != "None" ] && [ -d ".aicheck/actions/$current_action/supporting_docs" ]; then
    echo "Available supporting documents:"
    find ".aicheck/actions/$current_action/supporting_docs" -type f | while read -r doc; do
        echo "- $(basename "$doc"): $doc"
        echo "  $(head -n 1 "$doc" | sed 's/^# //')"
    done
  else
    echo "No supporting documents found for this action."
  fi)

## Recently Modified Files
$(git diff --name-only | head -n 10 | sed 's/^/- /')

## Project Structure
$(find . -type f -name "*.py" -o -name "*.js" -o -name "*.html" -o -name "*.css" -o -name "*.md" -o -name "*.json" | grep -v "node_modules" | grep -v ".git" | head -n 20 | sed 's/^/- /')
EOC

        # Copy to clipboard if xclip/pbcopy is available
        if command -v xclip &> /dev/null; then
            cat "$context_file" | xclip -selection clipboard
            echo "Context copied to clipboard"
        elif command -v pbcopy &> /dev/null; then
            cat "$context_file" | pbcopy
            echo "Context copied to clipboard"
        fi
        
        echo "Context file created at $context_file"
        echo "Use this context in your Cursor AI prompts"
        ;;
        
    log)
        # Log a Cursor AI session
        summary=$1
        current_session=$(cat .aicheck/current_session 2>/dev/null || echo "")
        
        if [ -z "$current_session" ]; then
            echo "No active session, creating temporary session"
            session_id=$(date +%Y%m%d%H%M%S)
            mkdir -p .aicheck/sessions/$session_id
            echo "$session_id" > .aicheck/current_session
            current_session=$session_id
        fi
        
        # Get current action
        current_action=$(cat .aicheck/current_action 2>/dev/null || echo "None")
        
        # Create cursor log file
        mkdir -p .aicheck/sessions/$current_session
        cursor_log=".aicheck/sessions/$current_session/cursor_log_$(date +%H%M%S).md"
        
        cat > "$cursor_log" << EOL
# Cursor AI Session Log - $(date +"%Y-%m-%d %H:%M:%S")

## Summary
$summary

## Current Action
$current_action

## Files Affected
$(git diff --name-only | sed 's/^/- /')

## Knowledge Gained
<!-- Add any important insights or learning points -->

## Work Completed
- Work was completed under pre-approval per RULES.md
- Current Action: $current_action

## Supporting Documents Created
<!-- List any supporting documents created during this session -->

EOL

        echo "Cursor session logged to $cursor_log"
        echo "Edit the file to add additional details"
        
        # Ask if progress should be updated
        if [ "$current_action" != "None" ]; then
            echo "Would you like to update the progress for $current_action? (y/n)"
            read -r update_progress
            
            if [ "$update_progress" == "y" ]; then
                echo "Enter new progress percentage (e.g., 75%):"
                read -r new_progress
                
                # Update progress in index
                if [ -f ".aicheck/docs/actions_index.md" ] && grep -q "| $current_action |" ".aicheck/docs/actions_index.md"; then
                    # Check format - UltraAI or standard
                    if grep -q "Progress" ".aicheck/docs/actions_index.md"; then
                        # UltraAI format
                        action_line=$(grep -E "^\| $current_action \|" .aicheck/docs/actions_index.md)
                        status=$(echo "$action_line" | awk -F'|' '{print $3}' | xargs)
                        
                        sed -i.bak "s/| $current_action | $status |[^|]*|/| $current_action | $status | $new_progress |/" .aicheck/docs/actions_index.md
                        rm -f .aicheck/docs/actions_index.md.bak
                        echo "Updated progress for $current_action to $new_progress"
                    fi
                fi
            fi
        fi
        ;;
        
    docs)
        # Create supporting document for the current action
        current_action=$(cat .aicheck/current_action 2>/dev/null || echo "None")
        doc_name=$1
        
        if [ "$current_action" == "None" ]; then
            echo "Error: No current action set"
            exit 1
        fi
        
        if [ -z "$doc_name" ]; then
            echo "Error: Document name required"
            echo "Usage: ./cursor-ai docs document_name.md"
            exit 1
        fi
        
        # Create supporting document
        mkdir -p ".aicheck/actions/$current_action/supporting_docs"
        supporting_doc=".aicheck/actions/$current_action/supporting_docs/$doc_name"
        
        # Check if it already exists
        if [ -f "$supporting_doc" ]; then
            echo "Supporting document already exists: $supporting_doc"
            if command -v code &> /dev/null; then
                code "$supporting_doc"
            else
                echo "Open this file in your editor to edit it"
            fi
            exit 0
        fi
        
        # Create the document
        cat > "$supporting_doc" << EOD
# $current_action: ${doc_name%.*}
Created: $(date +"%Y-%m-%d %H:%M:%S")

## Overview

<!-- Document content here -->

## Related Documents
- $current_action-PLAN.md (Main plan)

## Last Updated: $(date +"%Y-%m-%d")
EOD
        
        echo "Created new supporting document: $supporting_doc"
        if command -v code &> /dev/null; then
            code "$supporting_doc"
        else
            echo "Open this file in your editor to add content"
        fi
        ;;
        
    *)
        echo "UltraAICheck Cursor Integration"
        echo "Usage: ./cursor-ai <command> [options]"
        echo ""
        echo "Available commands:"
        echo "  context             Generate AI context for Cursor"
        echo "  log \"summary\"       Log a Cursor AI session"
        echo "  docs document.md    Create a supporting document for current action"
        ;;
esac
EOF

chmod +x ./cursor-ai

# Create common functions file
echo ""
echo "=== Creating Common Functions Library ==="
mkdir -p .aicheck
cat > .aicheck/common.sh << 'EOF'
#!/bin/bash

# UltraAICheck Common Functions
# Shared functions used by multiple scripts

# Function to check if a session is active
check_session() {
    current_session=$(cat .aicheck/current_session 2>/dev/null || echo "")
    if [ -z "$current_session" ]; then
        return 1
    fi
    return 0
}

# Function to check if an action is active
check_action() {
    current_action=$(cat .aicheck/current_action 2>/dev/null || echo "")
    if [ -z "$current_action" ]; then
        return 1
    fi
    return 0
}

# Function to get action status from index
get_action_status() {
    action_name=$1
    default_status=${2:-Unknown}
    
    if [ -f ".aicheck/docs/actions_index.md" ]; then
        action_line=$(grep -E "^\| $action_name \|" .aicheck/docs/actions_index.md)
        if [ -n "$action_line" ]; then
            status=$(echo "$action_line" | awk -F'|' '{print $3}' | xargs)
            if [ -n "$status" ]; then
                echo "$status"
                return 0
            fi
        fi
    fi
    
    # Fallback to checking action file
    if [ -f ".aicheck/actions/$action_name/$action_name-PLAN.md" ]; then
        status=$(grep -A 5 "## Status" ".aicheck/actions/$action_name/$action_name-PLAN.md" | grep "Status:" | sed 's/Status: //')
        if [ -n "$status" ]; then
            echo "$status"
            return 0
        fi
    fi
    
    echo "$default_status"
    return 1
}

# Function to get action progress from index
get_action_progress() {
    action_name=$1
    default_progress=${2:-0%}
    
    if [ -f ".aicheck/docs/actions_index.md" ] && grep -q "Progress" ".aicheck/docs/actions_index.md"; then
        action_line=$(grep -E "^\| $action_name \|" .aicheck/docs/actions_index.md)
        if [ -n "$action_line" ]; then
            progress=$(echo "$action_line" | awk -F'|' '{print $4}' | xargs)
            if [ -n "$progress" ]; then
                echo "$progress"
                return 0
            fi
        fi
    fi
    
    echo "$default_progress"
    return 1
}

# Function to list supporting documents for an action
list_supporting_docs() {
    action_name=$1
    
    if [ -d ".aicheck/actions/$action_name/supporting_docs" ]; then
        find ".aicheck/actions/$action_name/supporting_docs" -type f | while read -r doc; do
            basename "$doc"
        done
        return 0
    fi
    
    return 1
}

# Function to generate a documentation index
generate_doc_index() {
    output_file=".aicheck/docs/doc_index.md"
    
    echo "# UltraAICheck Documentation Index" > "$output_file"
    echo "Generated: $(date +"%Y-%m-%d %H:%M:%S")" >> "$output_file"
    echo "" >> "$output_file"
    
    echo "## Action Plans" >> "$output_file"
    find .aicheck/actions -type d -maxdepth 1 -mindepth 1 | sort | while read action_dir; do
        action_name=$(basename "$action_dir")
        if [ -f "$action_dir/$action_name-PLAN.md" ]; then
            action_title=$(head -n 1 "$action_dir/$action_name-PLAN.md" | sed 's/^# //')
            echo "- [$action_name]($action_dir/$action_name-PLAN.md) - $action_title" >> "$output_file"
        fi
    done
    
    echo "" >> "$output_file"
    echo "## Supporting Documents" >> "$output_file"
    find .aicheck/actions -path "*/supporting_docs/*" -type f | sort | while read doc_file; do
        doc_name=$(basename "$doc_file")
        action_name=$(echo "$doc_file" | awk -F'/' '{print $(NF-2)}')
        doc_title=$(head -n 1 "$doc_file" | sed 's/^# //')
        echo "- [$action_name: $doc_name]($doc_file) - $doc_title" >> "$output_file"
    done
    
    echo "" >> "$output_file"
    echo "## Sessions" >> "$output_file"
    find .aicheck/sessions -maxdepth 1 -type d | sort | tail -n +2 | while read session_dir; do
        session_id=$(basename "$session_dir")
        summary_file="$session_dir/summary.md"
        if [ -f "$summary_file" ]; then
            summary=$(grep "Summary:" "$summary_file" | sed 's/- Summary: //')
            echo "- [$session_id]($session_dir) - $summary" >> "$output_file"
        else
            echo "- [$session_id]($session_dir)" >> "$output_file"
        fi
    done
    
    echo "Documentation index generated at $output_file"
}
EOF

chmod +x .aicheck/common.sh

# Create RULES.md with UltraAI focus
echo ""
echo "=== Creating RULES.md Document ==="
cat > RULES.md << 'EOF'
# AICheck Development Rules

This document serves as the controlling reference for all development work managed by the AICheck system.

## Core Principles

1. **Documentation First**: All Actions must be documented before implementation begins
2. **Single Action Focus**: Work on one Action at a time to maintain focus and clarity
3. **Explicit Context Switching**: When changing focus, explicitly document the context switch
4. **Structured AI Interactions**: Use the provided templates for all AI interactions
5. **Regular Session Logging**: Document all AI sessions with clear summaries

## General AI Editor Guidelines

**Approval Assumption**: AI editors DO NOT need to ask for approval for any work that:
1. Complies with the rules in this document
2. Falls within the scope of the currently active Action as defined in the action index
3. Follows established patterns and conventions for the project

AI editors can proceed directly with implementation for:
- Code that implements the current Action plan
- Documentation updates related to the Action
- Bug fixes within the Action scope
- Tests for current Action functionality
- Refactoring within the current Action scope

This rule is designed to streamline the development process by eliminating the need for explicit approval of compliant work.

## Directory Structure Note

In this implementation, each action has its own directory structure:
```
.aicheck/actions/
└── [ACTION_NAME]/
    ├── [ACTION_NAME]-PLAN.md  # Main plan document
    └── supporting_docs/       # Action-specific documentation
```

## Reference Paths

- **Actions Index**: `.aicheck/docs/actions_index.md` (source of truth for Action status)
- **Session Logs**: `.aicheck/sessions/session_log.txt`
- **Current Action**: Check with `./ai status`
- **Documentation**: `.aicheck/docs/README.md`

## Workflow Requirements

1. Start every development session with `./ai start`
2. Check your current focus with `./ai status`
3. Create new Actions for new work with `./ai new ActionName`
4. End sessions with meaningful summaries using `./ai end "summary"`
5. Review insights regularly with `./ai insights`

## Cursor Integration Guidelines

1. Generate context before starting Cursor AI interactions
2. Log all significant Cursor interactions after completion
3. Maintain focus on the current Action in all Cursor sessions

Remember: The AICheck system is designed to improve focus and documentation quality in AI-assisted development. Follow these rules to maximize its benefits.
EOF

# Create an actions index document for UltraAI
echo ""
echo "=== Creating UltraAI Actions Index ==="
mkdir -p .aicheck/docs
cat > .aicheck/docs/actions_index.md << 'EOF'
# UltraAICheck Actions Index

> **Visualizer-Ready**: This file is parsed by the UltraAI Visualizer. Do not change column headers. Maintain consistent formatting to ensure parsing is successful.

This document serves as the central reference for all Actions in the project and is the source of truth for action statuses.

## Core Principle: Every Action Must Have a Plan

The UltraAI Framework operates on the fundamental principle that **every action must have a plan**:

- All substantive work is defined as an action
- Each action requires a formal, documented plan before implementation begins
- All active actions must be listed in this index
- Action plans are stored in the Actions directory with the action name
- No substantive work can proceed without being listed here as an action with a corresponding plan

## Active Actions

| Action | Status | Progress | Owner | Started | Last Updated | Authority | Priority |
|--------|--------|----------|-------|---------|-------------|-----------|----------|
| Initial | 🟡 WORKING | 0% | UltraAI Team | 2025-04-25 | 2025-04-25 | Standard Action | 3 |

## Action States

The following status indicators are used throughout the system:
- 🔴 **QUEUED**: Action is scheduled but waiting to start
- 🟡 **WORKING**: Action is currently in progress
- 🟡 **REVIEW**: Action is complete and awaiting review
- ✅ **ACCEPTED**: Action has been completed and accepted
- ⏸️ **PAUSED**: Action is temporarily on hold
- ❌ **ABANDONED**: Action has been discontinued

## Implementation Priorities

| Priority | Action Type | Description |
|----------|-------------|-------------|
| 1 | Core Architecture | Foundation for all components |
| 2 | Essential Features | Core functionality requirements |
| 3 | Standard Features | Normal priority work |
| 4 | Enhancement | Nice-to-have improvements |
| 5 | Experimental | Exploratory or research work |

## Recent Activities

| Date | Action | Activity | Author |
|------|--------|----------|--------|
| 2025-04-25 | Initial | UltraAICheck system installation | UltraAI Team |

## How to Update This Index

This index can be updated using the UltraAICheck commands:
```bash
./ai update-status ActionName "Status"
./ai update-progress ActionName "50%"
./ai status
```

You can also manually update it by editing this file directly.

## Action Paths

All action documents are stored in `.aicheck/actions/[ACTION_NAME]/[ACTION_NAME]-PLAN.md` where each action has its own directory containing the plan and all supporting documents.

## Last Updated: 2025-04-25
EOF

# Create template files for UltraAI
echo ""
echo "=== Creating Templates ==="
mkdir -p .aicheck/templates
cat > .aicheck/templates/action.md << 'EOF'
# Action: {ACTION_NAME}
Created: {DATE}

## Objective
<!-- What is the goal of this Action? -->

## Context
<!-- What is the background and why is this Action needed? -->

## Requirements
<!-- What are the specific requirements for this Action? -->

## Implementation Plan
<!-- How will this Action be implemented? -->

## Status
Status: In Progress
EOF

cat > .aicheck/templates/prompt.md << 'EOF'
# AI Prompt - {DATE}
## Current Action: {ACTION_NAME}

## RULES Reference
This development follows the rules defined in RULES.md, which is the controlling document.
IMPORTANT: AI editors DO NOT need to ask for approval for any work that complies with RULES.md and is within the current Action scope.

## Context
<!-- Add any relevant context here -->

## Task
<!-- Describe what you want the AI to do -->

## Requirements
<!-- List specific requirements -->
- 
- 
- 

## Expected Output
<!-- Describe what output you expect -->
EOF

cat > .aicheck/templates/session_summary.md << 'EOF'
# Session Summary: {SESSION_ID}
- End Time: {END_TIME}
- Summary: {SUMMARY}

## Actions Worked On
{ACTIONS}

## Files Modified
{FILES}

## Progress Made
<!-- Describe specific progress made during this session -->

## Next Steps
<!-- List next steps for this action -->
EOF

cat > .aicheck/templates/supporting_doc.md << 'EOF'
# {ACTION_NAME}: {DOCUMENT_TITLE}
Created: {DATE}

## Overview
<!-- Brief overview of what this document covers -->

## Content
<!-- Main content of the document -->

## Related Documents
- {ACTION_NAME}-PLAN.md (Main plan)
<!-- List any other related documents -->

## Last Updated: {DATE}
EOF

# Create an initial action with UltraAI structure
echo ""
echo "=== Creating Initial Action ==="
mkdir -p .aicheck/actions/Initial/supporting_docs
cat > .aicheck/actions/Initial/Initial-PLAN.md << EOF
# Action: Initial
Created: $(date +"%Y-%m-%d %H:%M:%S")

## Objective
Set up the project structure and establish the UltraAICheck workflow.

## Context
This is the first Action in the project, created during the installation of the UltraAICheck system.

## Requirements
- Initialize the UltraAICheck system
- Set up directory structure
- Create baseline documentation
- Establish action directory structure with supporting docs

## Implementation Plan
1. Run the UltraAICheck installer
2. Review documentation
3. Create project-specific Actions
4. Begin development with AI assistance

## Status
Status: In Progress
EOF

# Create a template index in the docs directory
echo ""
echo "=== Creating Template Index ==="
cat > .aicheck/docs/template_index.md << 'EOF'
# UltraAICheck Template Index

This document serves as a central reference for all templates available in the UltraAICheck system.

## Available Templates

| Template Name | Purpose | Location | Usage Command |
|---------------|---------|----------|---------------|
| Action | Standard structure for creating a new action | `.aicheck/templates/action.md` | `./ai new ActionName` |
| Prompt | Template for AI interaction prompts | `.aicheck/templates/prompt.md` | `./ai prompt` |
| Session Summary | Format for summarizing completed sessions | `.aicheck/templates/session_summary.md` | `./ai end "summary"` |
| Supporting Document | Template for action-specific documentation | `.aicheck/templates/supporting_doc.md` | `./ai docs ActionName document.md` |

## Action Template

The action template creates a standardized structure for all action plans:

- **Objective**: Clear statement of the action's goal
- **Context**: Background information on why the action is needed
- **Requirements**: Specific requirements that must be met
- **Implementation Plan**: Step-by-step approach to completing the action
- **Status**: Current state of the action

## Prompt Template

The prompt template structures AI interactions:

- **RULES Reference**: Reminder of the project's rules
- **Current Action**: The action being worked on
- **Context**: Relevant background information
- **Task**: Clear description of what the AI should do
- **Requirements**: Specific requirements for the task
- **Expected Output**: Description of the desired result

## Session Summary Template

The session summary template standardizes how completed work sessions are documented:

- **End Time**: When the session was completed
- **Summary**: Brief description of what was accomplished
- **Actions Worked On**: Which actions were addressed
- **Files Modified**: Which files were changed
- **Progress Made**: Specific progress made during this session
- **Next Steps**: List of next steps for this action

## Supporting Document Template

The supporting document template provides a structure for action-specific documentation:

- **Overview**: Brief overview of what the document covers
- **Content**: Main content of the document
- **Related Documents**: List of related documents
- **Last Updated**: Date of last update

## Creating New Templates

To create a new template:

1. Create a file in the `.aicheck/templates/` directory
2. Structure the template with clear sections and placeholders
3. Add the template to this index for reference
4. Update the UltraAICheck scripts to use the new template if needed

## How to Use Templates

Templates are automatically used by the UltraAICheck system when running commands like `./ai new` or `./ai prompt`. You can also manually copy templates from the `.aicheck/templates/` directory as needed.

## Last Updated: 2025-04-25
EOF

echo "Initial" > .aicheck/current_action

# Create git hooks for UltraAI
echo ""
echo "=== Creating Git Hooks ==="
mkdir -p .git/hooks
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash

# UltraAICheck Pre-commit Hook
# Enforces documentation standards and rules

# Source
# Source common functions
source .aicheck/common.sh

echo "Running UltraAICheck pre-commit checks..."

# Check if current action exists
current_action=$(cat .aicheck/current_action 2>/dev/null || echo "")
if [ -z "$current_action" ]; then
    echo "Error: No current action set"
    echo "Please set a current action using './ai new ActionName' or './ai switch ActionName'"
    exit 1
fi

# Check if action has documentation
if [ ! -f ".aicheck/actions/$current_action/$current_action-PLAN.md" ]; then
    echo "Error: No plan file found for current action"
    echo "Please create action plan first at .aicheck/actions/$current_action/$current_action-PLAN.md"
    exit 1
fi

# Check if action is registered in the index
if [ -f ".aicheck/docs/actions_index.md" ] && ! grep -q "| $current_action |" ".aicheck/docs/actions_index.md"; then
    echo "Warning: Current action is not registered in the actions index"
    echo "Please update .aicheck/docs/actions_index.md or run './ai status' to register it"
fi

# Check for modified files
modified_files=$(git diff --cached --name-only)
if [ -z "$modified_files" ]; then
    echo "Warning: No files staged for commit"
fi

# All checks passed
echo "UltraAICheck pre-commit checks passed"
exit 0
EOF

chmod +x .git/hooks/pre-commit

# Create a basic README.md for the repository
echo ""
echo "=== Creating Repository README ==="
cat > README.md << 'EOF'
# Project with UltraAICheck Integration

This project uses the UltraAICheck system for AI-assisted development. UltraAICheck helps maintain focus, documentation, and productivity in your development workflow.

## UltraAICheck Features

- **Action-Oriented Development**: All work is organized into clear actions with plans
- **Directory-Based Structure**: Each action has its own directory with supporting documents
- **AI Autonomy**: AI editors are pre-approved for work within the current action scope
- **Documentation First**: All work begins with documentation 
- **Centralized Action Tracking**: All actions are tracked in a central index

## Getting Started

### Basic Commands

```bash
./ai start              # Start a new AI session with context
./ai prompt             # Generate a prompt template
./ai status             # Check current action status
./ai end "summary"      # End session with summary
./ai focus              # Show focus rules and Action list
./ai insights           # Generate productivity insights
./ai new ActionName     # Create a new Action
./ai list               # List all actions and their status
./ai docs ActionName    # Manage supporting documents for an action
./ai switch ActionName  # Switch to a different action
```

### Updating Action Status

```bash
./ai update-status ActionName "Status"    # Update action status
./ai update-progress ActionName "50%"     # Update action progress
```

### Cursor Integration

```bash
./cursor-ai context     # Generate AI context for Cursor
./cursor-ai log "summary" # Log a Cursor AI session
./cursor-ai docs document.md # Create a supporting document
```

## Documentation

For more information, see the documentation in [.aicheck/docs/](/.aicheck/docs/).

## Core Principles

1. **Documentation First**: All Actions must be documented before implementation begins
2. **Single Action Focus**: Work on one Action at a time to maintain focus and clarity
3. **Explicit Context Switching**: When changing focus, explicitly document the context switch
4. **Structured AI Interactions**: Use the provided templates for all AI interactions
5. **Regular Session Logging**: Document all AI sessions with clear summaries
6. **Centralized Action Directory**: All actions must be registered in the actions_index.md file
7. **Supporting Documentation**: All action-specific documentation must be stored with the action

## Action Directory Structure

Each action has its own directory with the following structure:

```
.aicheck/actions/ACTION_NAME/
├── ACTION_NAME-PLAN.md         # The main plan document
└── supporting_docs/            # Directory for supporting documents
    ├── architecture.md
    ├── api_spec.md
    └── ... (other supporting docs)
```

This structure ensures that all documentation related to an action stays with that action.
EOF

# Installation complete message
echo ""
echo "┌─────────────────────────────────────────────────────────┐"
echo "│                                                         │"
echo "│          UltraAICheck Installation Complete             │"
echo "│                                                         │"
echo "└─────────────────────────────────────────────────────────┘"

# Usage instructions
echo ""
echo "=== Getting Started ==="
echo "1. Start your first AI session: ./ai start"
echo "2. Generate a prompt template: ./ai prompt"
echo "3. Check the current status: ./ai status"
echo "4. Create a new action: ./ai new YourActionName"
echo "5. Create supporting documents: ./ai docs YourActionName document.md"
echo "6. Generate context for Cursor: ./cursor-ai context"

echo ""
echo "=== Documentation ==="
echo "Full documentation available at: .aicheck/docs/"

# Create a first-run flag
touch .aicheck/.installed

echo ""
echo "UltraAICheck is ready to use! Happy developing!"