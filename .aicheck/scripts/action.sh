#!/bin/bash

# Action management functions for AICheck

source .aicheck/scripts/common.sh

# Function to show detailed status explanations
show_status_explanations() {
    echo ""
    echo "=== Detailed Status Explanations ==="
    echo ""
    echo "1. Not Started:"
    echo "   - Action is planned but not yet begun"
    echo "   - All requirements and scope are defined"
    echo "   - Dependencies are identified"
    echo "   - Example: 'Implement user authentication' when planning is complete but coding hasn't started"
    echo ""
    echo "2. ActiveAction:"
    echo "   - Action is the sole Action being worked on"
    echo "   - Action is controlling and in progress"
    echo "   - All work must be within this Action's scope"
    echo "   - Example: 'Implement user authentication' when actively coding the feature"
    echo ""
    echo "3. Completed:"
    echo "   - Action is finished and verified"
    echo "   - All requirements are met"
    echo "   - Tests are passing"
    echo "   - Documentation is updated"
    echo "   - Example: 'Implement user authentication' when feature is working and tested"
    echo ""
    echo "4. Blocked:"
    echo "   - Action is blocked by dependencies"
    echo "   - Cannot proceed until blocker is resolved"
    echo "   - Blocker should be documented"
    echo "   - Example: 'Implement user authentication' when waiting for API endpoints"
    echo ""
    echo "5. On Hold:"
    echo "   - Action is temporarily paused"
    echo "   - Not blocked, but intentionally paused"
    echo "   - Reason for pause should be documented"
    echo "   - Example: 'Implement user authentication' when waiting for design approval"
    echo ""
    echo "=== Status Update Guidelines ==="
    echo "1. Update status when:"
    echo "   - Starting work on an action"
    echo "   - Completing an action"
    echo "   - Encountering blockers"
    echo "   - Pausing work"
    echo "   - Resuming work"
    echo ""
    echo "2. Always document:"
    echo "   - Reason for status change"
    echo "   - Any blockers or dependencies"
    echo "   - Progress made"
    echo "   - Next steps"
    echo ""
    echo "3. Status should reflect:"
    echo "   - Current state of work"
    echo "   - Any blocking issues"
    echo "   - Progress towards completion"
    echo "   - Dependencies on other actions"
}

# Function to check action status
check_action_status() {
    local current_action=$(cat .aicheck/current_action 2>/dev/null || echo "None")
    local current_session=$(cat .aicheck/current_session 2>/dev/null || echo "None")
    
    echo "=== AICheck Status ==="
    echo "ActiveAction: $(format_aicheck_path "$current_action")"
    echo "Current Session: $(format_aicheck_path "$current_session")"
    echo "Actions Index: $(format_aicheck_path ".aicheck/docs/actions_index.md") (source of truth)"
    
    # Get status from actions_index.md (the source of truth)
    if [ "$current_action" != "None" ] && [ -f ".aicheck/docs/actions_index.md" ]; then
        local action_line=$(grep -E "^\| $current_action \|" .aicheck/docs/actions_index.md)
        if [ -n "$action_line" ]; then
            local action_status=$(echo "$action_line" | awk -F'|' '{print $3}' | xargs)
            local action_progress=$(echo "$action_line" | awk -F'|' '{print $4}' | xargs)
            local action_owner=$(echo "$action_line" | awk -F'|' '{print $5}' | xargs)
            
            echo ""
            echo "=== Action Status (from index) ==="
            echo "Status: $action_status"
            echo "Progress: $action_progress"
            echo "Owner: $action_owner"
            
            echo ""
            echo "=== Action Progress Instructions ==="
            echo "To update action progress:"
            echo "1. Use './ai update-status <action_name> <new_status>'"
            echo "2. Valid statuses:"
            echo "   - Not Started: Action is planned but not begun"
            echo "   - ActiveAction: Action is currently being worked on"
            echo "   - Completed: Action is finished and verified"
            echo "   - Blocked: Action is blocked by dependencies"
            echo "   - On Hold: Action is temporarily paused"
            echo "3. Progress is tracked in $(format_aicheck_path ".aicheck/docs/actions_index.md")"
            
            echo ""
            echo "⚠️ CRITICAL: RULES.md is the controlling document for this project ⚠️"
            
            # Show detailed status explanations
            show_status_explanations
        fi
    fi
    
    # Show action details
    if [ "$current_action" != "None" ] && [ -f ".aicheck/actions/$current_action/$current_action-PLAN.md" ]; then
        echo ""
        echo "=== Action Details ==="
        echo "Action Plan: $(format_aicheck_path ".aicheck/actions/$current_action/$current_action-PLAN.md")"
        head -n 10 ".aicheck/actions/$current_action/$current_action-PLAN.md"
        echo "..."
        
        # Check if action entry exists in index
        if [ -f ".aicheck/docs/actions_index.md" ]; then
            if ! grep -q "| $current_action |" ".aicheck/docs/actions_index.md"; then
                # Action exists but not in index - add it
                echo ""
                echo "Warning: Action $(format_aicheck_path "$current_action") exists but is not in the index."
                echo "Would you like to add it to the index? (y/n)"
                read -r add_to_index
                
                if [ "$add_to_index" == "y" ]; then
                    # Extract status from file
                    local action_file_status=$(grep -A 5 "## Status" ".aicheck/actions/$current_action/$current_action-PLAN.md" | grep "Status:" | sed 's/Status: //')
                    local created_date=$(grep -Eo "Created: [0-9]{4}-[0-9]{2}-[0-9]{2}" ".aicheck/actions/$current_action/$current_action-PLAN.md" | sed 's/Created: //')
                    local last_updated=$(date +"%Y-%m-%d")
                    
                    # If still empty, set defaults
                    if [ -z "$action_file_status" ]; then action_file_status="ActiveAction"; fi
                    if [ -z "$created_date" ]; then created_date=$(date +"%Y-%m-%d"); fi
                    
                    # Add action to index
                    sed -i.bak '/^| Action | Status/a\
| '"$current_action"' | '"$action_file_status"' | 0% | AICheck Team | '"$created_date"' | '"$last_updated"' | Standard Action | 3 |' .aicheck/docs/actions_index.md
                    rm -f .aicheck/docs/actions_index.md.bak
                    log_info "Added $current_action to actions index with status: $action_file_status"
                    echo "Added $(format_aicheck_path "$current_action") to actions index with status: $action_file_status"
                fi
            fi
        fi
    fi
    
    # List supporting documents
    if [ "$current_action" != "None" ] && [ -d ".aicheck/actions/$current_action/supporting_docs" ]; then
        echo ""
        echo "=== Supporting Documents ==="
        echo "Supporting Documentation:"
        echo "Location: $(format_aicheck_path ".aicheck/actions/$current_action/supporting_docs/")"
        find ".aicheck/actions/$current_action/supporting_docs" -type f | while read file; do
            echo "- $(format_aicheck_path "$file")"
        done
    fi
    
    # Show reference paths
    echo ""
    echo "=== Reference Paths ==="
    echo "- RULES.md: Project rules and guidelines (MUST READ)"
    echo "- $(format_aicheck_path ".aicheck/actions/") : Action-specific directories"
    echo "- $(format_aicheck_path ".aicheck/docs/actions_index.md") : Action tracking and status"
    echo "- $(format_aicheck_path ".aicheck/templates/") : Template files"
    echo "- $(format_aicheck_path ".aicheck/sessions/") : Session data"
    echo "- $(format_aicheck_path ".aicheck/current_action") : ActiveAction tracking"
    echo "- $(format_aicheck_path ".aicheck/current_session") : Current active session"
    
    # Show action scope
    echo ""
    echo "=== Action Scope ==="
    echo "The ActiveAction's scope is defined in:"
    echo "- $(format_aicheck_path ".aicheck/actions/$current_action/$current_action-PLAN.md")"
    echo "- Any supporting documents in $(format_aicheck_path ".aicheck/actions/$current_action/supporting_docs/")"
    echo "- The action's entry in $(format_aicheck_path ".aicheck/docs/actions_index.md")"
}

# Function to validate action name
validate_action_name() {
    local action_name=$1
    
    # Check if action name is provided
    if [ -z "$action_name" ]; then
        log_error "No action name provided"
        echo "Error: Action name is required"
        exit 1
    fi
    
    # Check if action name is valid
    if [[ ! "$action_name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        log_error "Invalid action name: $action_name"
        echo "Error: Action name must contain only letters, numbers, underscores, and hyphens"
        exit 1
    fi
    
    # Check if action exists
    if [ ! -d ".aicheck/actions/$action_name" ]; then
        log_error "Action not found: $action_name"
        echo "Error: Action '$action_name' does not exist"
        echo "Use './ai new $action_name' to create it"
        exit 1
    fi
    
    # Check if action is in index
    if [ -f ".aicheck/docs/actions_index.md" ]; then
        if ! grep -q "| $action_name |" ".aicheck/docs/actions_index.md"; then
            log_warning "Action exists but not in index: $action_name"
            echo "Warning: Action exists but is not in the index"
            echo "Would you like to add it to the index? (y/n)"
            read -r add_to_index
            
            if [ "$add_to_index" == "y" ]; then
                # Extract status from file
                local action_file_status=$(grep -A 5 "## Status" ".aicheck/actions/$action_name/$action_name-PLAN.md" | grep "Status:" | sed 's/Status: //')
                local created_date=$(grep -Eo "Created: [0-9]{4}-[0-9]{2}-[0-9]{2}" ".aicheck/actions/$action_name/$action_name-PLAN.md" | sed 's/Created: //')
                local last_updated=$(date +"%Y-%m-%d")
                
                # If still empty, set defaults
                if [ -z "$action_file_status" ]; then action_file_status="Not Started"; fi
                if [ -z "$created_date" ]; then created_date=$(date +"%Y-%m-%d"); fi
                
                # Add action to index
                sed -i.bak '/^| Action | Status/a\
| '"$action_name"' | '"$action_file_status"' | 0% | AICheck Team | '"$created_date"' | '"$last_updated"' | Standard Action | 3 |' .aicheck/docs/actions_index.md
                rm -f .aicheck/docs/actions_index.md.bak
                log_info "Added $action_name to actions index with status: $action_file_status"
                echo "Added $action_name to actions index with status: $action_file_status"
            else
                log_error "Action not in index: $action_name"
                echo "Error: Action must be in the index to proceed"
                exit 1
            fi
        fi
    else
        log_error "Actions index not found"
        echo "Error: Actions index file not found"
        exit 1
    fi
}

# Function to validate status
validate_status() {
    local status=$1
    
    # Check if status is provided
    if [ -z "$status" ]; then
        log_error "No status provided"
        echo "Error: Status is required"
        exit 1
    fi
    
    # Check if status is valid
    case "$status" in
        "Not Started"|"ActiveAction"|"Completed"|"Blocked"|"On Hold")
            return 0
            ;;
        *)
            log_error "Invalid status: $status"
            echo "Error: Status must be one of: Not Started, ActiveAction, Completed, Blocked, On Hold"
            exit 1
            ;;
    esac
}

# Function to validate progress
validate_progress() {
    local progress=$1
    
    # Check if progress is provided
    if [ -z "$progress" ]; then
        log_error "No progress provided"
        echo "Error: Progress is required"
        exit 1
    fi
    
    # Check if progress is valid
    if [[ ! "$progress" =~ ^[0-9]+%$ ]]; then
        log_error "Invalid progress format: $progress"
        echo "Error: Progress must be a number followed by % (e.g., 50%)"
        exit 1
    fi
    
    # Check if progress is within range
    local percentage=${progress%\%}
    if [ "$percentage" -lt 0 ] || [ "$percentage" -gt 100 ]; then
        log_error "Progress out of range: $progress"
        echo "Error: Progress must be between 0% and 100%"
        exit 1
    fi
}

# Function to check for human manager approval
check_human_manager_approval() {
    local action_type=$1
    local action_name=$2
    local current_action=$(cat .aicheck/current_action 2>/dev/null || echo "None")
    
    # If we're in AdminAudit and this is a new action, we need approval to create it
    if [ "$current_action" == "AdminAudit" ] && [ "$action_type" == "Create New Action" ]; then
        # Warning header in neon orange
        echo -e "${AICHECK_ORANGE}${AICHECK_BOLD}"
        echo "⚠️ ⚠️ ⚠️ APPROVAL REQUIRED ⚠️ ⚠️ ⚠️"
        echo -e "${AICHECK_RESET}"
        
        # Rest of the message in purple
        echo -e "${AICHECK_PURPLE}${AICHECK_BOLD}"
        echo "This action requires explicit human manager approval:"
        echo "- Action Type: Create New Action"
        echo "- Action Name: $action_name"
        echo -e "${AICHECK_RESET}"
        
        # Play alert sound if available (only once)
        if command -v afplay &> /dev/null; then
            afplay /System/Library/Sounds/Glass.aiff &
        elif command -v paplay &> /dev/null; then
            paplay /usr/share/sounds/freedesktop/stereo/complete.oga &
        fi
        
        # Human manager line in orange and caps
        echo -e "${AICHECK_ORANGE}${AICHECK_BOLD}"
        echo "HUMAN MANAGER: PLEASE TYPE 'y' TO APPROVE THIS ACTION"
        echo -e "${AICHECK_RESET}"
        read -r has_approval
        
        # Move cursor to new line
        tput cud1
        
        if [[ ! "$has_approval" =~ ^[Yy]$ ]]; then
            log_error "Human manager approval required for $action_type: $action_name"
            echo -e "${AICHECK_ORANGE}${AICHECK_BOLD}"
            echo "❌ APPROVAL REJECTED"
            echo "Please explain why this action was rejected."
            echo "The action will remain in its current state."
            echo -e "${AICHECK_RESET}"
            exit 1
        fi
        
        log_info "Human manager approval confirmed for $action_type: $action_name"
        
        # Clear visual separator
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        
        # Approval confirmation in orange
        echo -e "${AICHECK_ORANGE}${AICHECK_BOLD}"
        echo "✅ APPROVAL CONFIRMED"
        echo "Action: $action_name"
        echo "Type: $action_type"
        echo -e "${AICHECK_RESET}"
        
        # Return success instead of exiting
        return 0
    fi
    
    # Check if action requires human approval (excluding commits)
    if [ "$action_type" != "Commit" ] && grep -q "REQUIRES HUMAN MANAGER APPROVAL" ".aicheck/actions/$action_name/$action_name-PLAN.md" 2>/dev/null; then
        # Warning header in neon orange
        echo -e "${AICHECK_ORANGE}${AICHECK_BOLD}"
        echo "⚠️ ⚠️ ⚠️ APPROVAL REQUIRED ⚠️ ⚠️ ⚠️"
        echo -e "${AICHECK_RESET}"
        
        # Rest of the message in purple
        echo -e "${AICHECK_PURPLE}${AICHECK_BOLD}"
        echo "This action requires explicit human manager approval:"
        echo "- Action Type: $action_type"
        echo "- Action Name: $action_name"
        echo -e "${AICHECK_RESET}"
        
        # Play alert sound if available (only once)
        if command -v afplay &> /dev/null; then
            afplay /System/Library/Sounds/Glass.aiff &
        elif command -v paplay &> /dev/null; then
            paplay /usr/share/sounds/freedesktop/stereo/complete.oga &
        fi
        
        # Human manager line in orange and caps
        echo -e "${AICHECK_ORANGE}${AICHECK_BOLD}"
        echo "HUMAN MANAGER: PLEASE TYPE 'y' TO APPROVE THIS ACTION"
        echo -e "${AICHECK_RESET}"
        read -r has_approval
        
        # Move cursor to new line
        tput cud1
        
        if [[ ! "$has_approval" =~ ^[Yy]$ ]]; then
            log_error "Human manager approval required for $action_type: $action_name"
            echo -e "${AICHECK_ORANGE}${AICHECK_BOLD}"
            echo "❌ APPROVAL REJECTED"
            echo "Please explain why this action was rejected."
            echo "The action will remain in its current state."
            echo -e "${AICHECK_RESET}"
            exit 1
        fi
        
        log_info "Human manager approval confirmed for $action_type: $action_name"
        
        # Clear visual separator
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        
        # Approval confirmation in orange
        echo -e "${AICHECK_ORANGE}${AICHECK_BOLD}"
        echo "✅ APPROVAL CONFIRMED"
        echo "Action: $action_name"
        echo "Type: $action_type"
        echo -e "${AICHECK_RESET}"
        
        # Return success instead of exiting
        return 0
    fi
}

# Function to create a new action
create_new_action() {
    local action_name=$1
    local action_dir=".aicheck/actions/$action_name"
    
    # Check for human manager approval
    check_human_manager_approval "Create New Action" "$action_name"
    
    # Validate action name
    if [[ ! "$action_name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        log_error "Invalid action name: $action_name"
        echo "Error: Action name must contain only letters, numbers, underscores, and hyphens"
        exit 1
    fi
    
    # Check if action already exists
    if [ -d "$action_dir" ]; then
        log_error "Action already exists: $action_name"
        echo "Error: Action '$action_name' already exists"
        echo "Use './ai switch $action_name' to switch to it"
        exit 1
    fi
    
    # Create action directory and structure
    mkdir -p "$action_dir/supporting_docs"
    
    # Create action plan from template
    if [ -f ".aicheck/templates/action_plan.md" ]; then
        cp .aicheck/templates/action_plan.md "$action_dir/$action_name-PLAN.md"
        sed -i.bak "s/ACTION_NAME/$action_name/g" "$action_dir/$action_name-PLAN.md"
        rm -f "$action_dir/$action_name-PLAN.md.bak"
    else
        # Create basic plan if template doesn't exist
        cat > "$action_dir/$action_name-PLAN.md" << EOP
# $action_name

## Overview
<!-- Add action overview here -->

## Status
Status: Not Started

## Created
Created: $(date +"%Y-%m-%d")

## Last Updated
Last Updated: $(date +"%Y-%m-%d")

## Description
<!-- Add detailed description here -->

## Requirements
<!-- List requirements here -->

## Implementation Plan
<!-- Add implementation steps here -->

## Notes
<!-- Add any additional notes here -->
EOP
    fi
    
    # Add to actions index
    local created_date=$(date +"%Y-%m-%d")
    local last_updated=$(date +"%Y-%m-%d")
    
    if [ -f ".aicheck/docs/actions_index.md" ]; then
        sed -i.bak '/^| Action | Status/a\
| '"$action_name"' | Not Started | 0% | AICheck Team | '"$created_date"' | '"$last_updated"' | Standard Action | 3 |' .aicheck/docs/actions_index.md
        rm -f .aicheck/docs/actions_index.md.bak
    else
        # Create actions index if it doesn't exist
        mkdir -p .aicheck/docs
        cat > .aicheck/docs/actions_index.md << EOI
# AICheck Actions Index

| Action | Status | Progress | Owner | Started | Last Updated | Type | Priority |
|--------|--------|----------|-------|---------|-------------|------|----------|
| $action_name | Not Started | 0% | AICheck Team | $created_date | $created_date | Standard Action | 3 |
EOI
    fi
    
    # Set as ActiveAction
    echo "$action_name" > .aicheck/current_action
    
    log_info "Created new action: $action_name"
    echo "Created new action: $action_name"
    echo "Action plan: $action_dir/$action_name-PLAN.md"
    echo "Set as ActiveAction"
    
    # Open in editor if available
    if command -v code &> /dev/null; then
        code "$action_dir/$action_name-PLAN.md"
    else
        echo "Open this file in your editor to begin the action"
    fi
}

# Function to switch to an existing action
switch_to_action() {
    local action_name=$1
    local action_dir=".aicheck/actions/$action_name"
    local current_action=$(cat .aicheck/current_action 2>/dev/null || echo "None")
    
    # If we're in AdminAudit and switching to a different action, show a special message
    if [ "$current_action" == "AdminAudit" ] && [ "$action_name" != "AdminAudit" ]; then
        echo "=== Exiting Administrative Audit ==="
        echo "This will switch from system-level changes to working on a specific action."
        echo "Please confirm you want to switch to: $action_name"
        echo ""
        echo "Type 'y' to confirm, or any other key to stay in AdminAudit"
        read -r confirm_switch
        
        if [[ ! "$confirm_switch" =~ ^[Yy]$ ]]; then
            echo "Staying in AdminAudit mode"
            return 0
        fi
    fi
    
    # Check for human manager approval
    check_human_manager_approval "Change ActiveAction" "$action_name"
    
    # Validate action name and existence
    validate_action_name "$action_name"
    
    # Set as ActiveAction
    echo "$action_name" > .aicheck/current_action
    
    log_info "Switched to action: $action_name"
    echo "Switched to action: $action_name"
    echo "Action plan: $action_dir/$action_name-PLAN.md"
    echo "Set as ActiveAction"
}

# Function to update action status
update_action_status() {
    local action_name=$1
    local new_status=$2
    
    # Validate action name and existence
    validate_action_name "$action_name"
    
    # Validate status
    validate_status "$new_status"
    
    # Check for human manager approval for substantive changes
    if [ "$new_status" == "Completed" ] || [ "$new_status" == "Blocked" ]; then
        check_human_manager_approval "Update Action Status" "$action_name"
    fi
    
    # Get current progress
    local current_progress=$(grep -E "^\| $action_name \|" ".aicheck/docs/actions_index.md" | awk -F'|' '{print $4}' | xargs)
    
    # If status is Completed, set progress to 100%
    if [ "$new_status" == "Completed" ]; then
        current_progress="100%"
    fi
    
    # Update status and progress in index
    if grep -q "| $action_name |" ".aicheck/docs/actions_index.md"; then
        sed -i.bak "s/| $action_name | [^|]* | [^|]* |/| $action_name | $new_status | $current_progress |/" .aicheck/docs/actions_index.md
        rm -f .aicheck/docs/actions_index.md.bak
        log_info "Updated status for action $action_name to $new_status with progress $current_progress"
        echo "Updated status for action $action_name to $new_status with progress $current_progress"
        
        # Show status meanings
        show_status_explanations
    else
        log_error "Action $action_name not found in index"
        echo "Error: Action $action_name not found in index"
        exit 1
    fi
}

# Function to update action progress
update_action_progress() {
    local action_name=$1
    local new_progress=$2
    
    # Validate action name and existence
    validate_action_name "$action_name"
    
    # Validate progress
    validate_progress "$new_progress"
    
    # Update progress in index
    if grep -q "| $action_name |" ".aicheck/docs/actions_index.md"; then
        sed -i.bak "s/| $action_name | [^|]* | [^|]* |/| $action_name | $(grep -E "^\| $action_name \|" ".aicheck/docs/actions_index.md" | awk -F'|' '{print $3}' | xargs) | $new_progress |/" .aicheck/docs/actions_index.md
        rm -f .aicheck/docs/actions_index.md.bak
        log_info "Updated progress for action $action_name to $new_progress"
        echo "Updated progress for action $action_name to $new_progress"
    else
        log_error "Action $action_name not found in index"
        echo "Error: Action $action_name not found in index"
        exit 1
    fi
}

# Function to check if changes are substantive
is_substantive_change() {
    local file=$1
    # Get the diff content
    local diff_content=$(git diff -- "$file")
    
    # Check for changes to content (not just whitespace)
    if echo "$diff_content" | grep -q "^[+-][^+-]"; then
        return 0  # Substantive change found
    fi
    return 1  # No substantive change
}

# Function to validate actions index format
validate_actions_index() {
    local index_file=".aicheck/docs/actions_index.md"
    if [ -f "$index_file" ]; then
        # Check for required columns
        if ! grep -q "| Action | Status | Progress | Owner | Started | Last Updated | Type | Priority |" "$index_file"; then
            echo "❌ Error: Actions index is missing required columns"
            echo "Please ensure the index has all required columns"
            exit 1
        fi
        
        # Check for valid status values
        while IFS= read -r line; do
            # Skip header and separator lines
            if [[ "$line" == *"| Action |"* ]] || [[ "$line" == *"|--------|"* ]]; then
                continue
            fi
            
            if [[ "$line" =~ \|[[:space:]]*[^|]+[[:space:]]*\|[[:space:]]*([^|]+)[[:space:]]*\| ]]; then
                local status="${BASH_REMATCH[1]}"
                status=$(echo "$status" | xargs)  # Trim whitespace
                case "$status" in
                    "Not Started"|"ActiveAction"|"Completed"|"Blocked"|"On Hold")
                        continue
                        ;;
                    *)
                        echo "❌ Error: Invalid status in actions index: $status"
                        echo "Status must be one of: Not Started, ActiveAction, Completed, Blocked, On Hold"
                        exit 1
                        ;;
                esac
            fi
        done < "$index_file"
    fi
}

# Function to commit changes with approval
commit_changes() {
    local commit_message=$1
    local current_action=$(cat .aicheck/current_action 2>/dev/null || echo "None")
    local action_plan=".aicheck/actions/$current_action/$current_action-PLAN.md"
    
    # Get list of files that would be committed
    local files=$(git diff --name-only)
    
    # Check for changes to critical files
    local critical_files=(
        "RULES.md"
        ".aicheck/docs/actions_index.md"
        ".aicheck/current_action"
    )
    
    for file in "${critical_files[@]}"; do
        if echo "$files" | grep -q "^$file$"; then
            if is_substantive_change "$file"; then
                # Check for human manager approval
                check_human_manager_approval "Commit" "$file"
            fi
        fi
    done
    
    # Check for changes to action plans
    if [ "$current_action" != "None" ]; then
        if [ -f "$action_plan" ] && echo "$files" | grep -q "^$action_plan$"; then
            if is_substantive_change "$action_plan"; then
                check_human_manager_approval "Commit" "$current_action"
            fi
        fi
    fi
    
    # Check for changes to templates
    if echo "$files" | grep -q "^.aicheck/templates/"; then
        for template in $(echo "$files" | grep "^.aicheck/templates/"); do
            if is_substantive_change "$template"; then
                check_human_manager_approval "Commit" "$template"
            fi
        done
    fi
    
    # Check if action requires human approval
    if [ "$current_action" != "None" ] && [ -f "$action_plan" ]; then
        if grep -q "REQUIRES HUMAN MANAGER APPROVAL" "$action_plan"; then
            check_human_manager_approval "Commit" "$current_action"
        fi
    fi
    
    # Validate actions index before committing
    validate_actions_index
    
    # All checks passed, stage and commit
    git add .
    git commit -m "$commit_message"
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        log_info "Successfully committed changes: $commit_message"
        echo "✅ Successfully committed changes"
    else
        log_error "Failed to commit changes: $commit_message"
        echo "❌ Failed to commit changes"
        exit $exit_code
    fi
} 