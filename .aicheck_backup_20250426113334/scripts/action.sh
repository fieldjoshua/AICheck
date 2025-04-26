#!/bin/bash

# Action management functions for AICheck

source .aicheck/scripts/common.sh

# Function to create administrative audit
create_administrative_audit() {
    local audit_id="AdminAudit_$(date +%Y%m%d%H%M%S)"
    
    # Check for human manager approval
    check_human_manager_approval "Create Administrative Audit" "$audit_id"
    
    # Create audit directory and structure
    mkdir -p ".aicheck/actions/$audit_id/supporting_docs"
    
    # Create audit plan from template
    if [ -f ".aicheck/templates/administrative_audit.md" ]; then
        cp .aicheck/templates/administrative_audit.md ".aicheck/actions/$audit_id/$audit_id-PLAN.md"
        sed -i.bak "s/AUDIT_ID/$audit_id/g" ".aicheck/actions/$audit_id/$audit_id-PLAN.md"
        rm -f ".aicheck/actions/$audit_id/$audit_id-PLAN.md.bak"
    else
        # Create basic audit plan if template doesn't exist
        cat > ".aicheck/actions/$audit_id/$audit_id-PLAN.md" << EOP
# $audit_id

## Overview
Administrative audit of the AICheck system.

## Status
Status: Not Started

## Created
Created: $(date +"%Y-%m-%d")

## Last Updated
Last Updated: $(date +"%Y-%m-%d")

## Description
This audit will review:
1. System configuration
2. Action statuses
3. Documentation completeness
4. Code quality
5. Compliance with RULES.md

## Requirements
- Complete system access
- Documentation review
- Code review
- Status verification

## Implementation Plan
1. Review system configuration
2. Check all action statuses
3. Verify documentation
4. Review code quality
5. Check RULES.md compliance

## Notes
<!-- Add any additional notes here -->
EOP
    fi
    
    # Add to actions index
    local created_date=$(date +"%Y-%m-%d")
    local last_updated=$(date +"%Y-%m-%d")
    
    if [ -f ".aicheck/docs/actions_index.md" ]; then
        sed -i.bak '/^| Action | Status/a\
| '"$audit_id"' | Not Started | 0% | AICheck Team | '"$created_date"' | '"$last_updated"' | Administrative | 1 |' .aicheck/docs/actions_index.md
        rm -f .aicheck/docs/actions_index.md.bak
    else
        # Create actions index if it doesn't exist
        mkdir -p .aicheck/docs
        cat > .aicheck/docs/actions_index.md << EOI
# AICheck Actions Index

| Action | Status | Progress | Owner | Started | Last Updated | Type | Priority |
|--------|--------|----------|-------|---------|-------------|------|----------|
| $audit_id | Not Started | 0% | AICheck Team | $created_date | $created_date | Administrative | 1 |
EOI
    fi
    
    # Set as ActiveAction
    echo "$audit_id" > .aicheck/current_action
    
    log_info "Created administrative audit: $audit_id"
    echo "Created administrative audit: $audit_id"
    echo "Audit plan: .aicheck/actions/$audit_id/$audit_id-PLAN.md"
    echo "Set as ActiveAction"
    
    # Open in editor if available
    if command -v code &> /dev/null; then
        code ".aicheck/actions/$audit_id/$audit_id-PLAN.md"
    else
        echo "Open this file in your editor to begin the audit"
    fi
}

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
    echo "⚠️ CRITICAL: RULES.md is the controlling document for this project ⚠️"
    echo "ActiveAction: $current_action"
    echo "Current Session: $current_session"
    echo "Actions Index: .aicheck/docs/actions_index.md (source of truth)"
    
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
            echo "3. Progress is tracked in .aicheck/docs/actions_index.md"
            
            # Show detailed status explanations
            show_status_explanations
        fi
    fi
    
    # Show action details
    if [ "$current_action" != "None" ] && [ -f ".aicheck/actions/$current_action/$current_action-PLAN.md" ]; then
        echo ""
        echo "=== Action Details ==="
        echo "Action Plan: .aicheck/actions/$current_action/$current_action-PLAN.md"
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
                    echo "Added $current_action to actions index with status: $action_file_status"
                fi
            fi
        fi
    fi
    
    # List supporting documents
    if [ "$current_action" != "None" ] && [ -d ".aicheck/actions/$current_action/supporting_docs" ]; then
        echo ""
        echo "=== Supporting Documents ==="
        echo "Supporting Documentation:"
        echo "Location: .aicheck/actions/$current_action/supporting_docs/"
        find ".aicheck/actions/$current_action/supporting_docs" -type f | sed 's/^/- /'
    fi
    
    # Show reference paths
    echo ""
    echo "=== Reference Paths ==="
    echo "- RULES.md: Project rules and guidelines (MUST READ)"
    echo "- .aicheck/actions/: Action-specific directories"
    echo "- .aicheck/docs/actions_index.md: Action tracking and status"
    echo "- .aicheck/templates/: Template files"
    echo "- .aicheck/sessions/: Session data"
    echo "- .aicheck/current_action: ActiveAction tracking"
    echo "- .aicheck/current_session: Current active session"
    
    # Show action scope
    echo ""
    echo "=== Action Scope ==="
    echo "The ActiveAction's scope is defined in:"
    echo "- .aicheck/actions/$current_action/$current_action-PLAN.md"
    echo "- Any supporting documents in .aicheck/actions/$current_action/supporting_docs/"
    echo "- The action's entry in .aicheck/docs/actions_index.md"
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
    
    echo "⚠️ REQUIRES HUMAN MANAGER APPROVAL ⚠️"
    echo "This action requires explicit human manager approval:"
    echo "- Action Type: $action_type"
    echo "- Action Name: $action_name"
    echo ""
    echo "Human manager: Please type 'y' in the chat to approve this action"
    read -r has_approval
    
    if [ "$has_approval" != "y" ]; then
        log_error "Human manager approval required for $action_type: $action_name"
        echo "Error: Human manager approval required"
        echo "Please get approval before proceeding"
        exit 1
    fi
    
    log_info "Human manager approval confirmed for $action_type: $action_name"
    echo "✅ Human manager approval confirmed"
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
    
    # Show action status
    check_action_status
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