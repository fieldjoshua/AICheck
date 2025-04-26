#!/bin/bash

# Action management script for AICheck
# This script handles action creation, status, and switching

# Exit on error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Source security utilities
source .aicheck/scripts/security_utils.sh

# Function to validate action name
validate_action_name() {
    local action_name="$1"
    
    # Check if action name is provided
    if [ -z "$action_name" ]; then
        echo -e "${RED}Error: Action name is required${NC}" >&2
        return 1
    fi
    
    # Check for invalid characters
    if [[ "$action_name" =~ [/\\] ]]; then
        echo -e "${RED}Error: Action name contains invalid characters${NC}" >&2
        return 1
    fi
    
    return 0
}

# Function to create a new action
create_action() {
    local action_name="$1"
    local action_dir=".aicheck/actions/$action_name"
    local plan_file="$action_dir/$action_name-PLAN.md"
    
    # Validate action name
    if ! validate_action_name "$action_name"; then
        return 1
    fi
    
    # Check if action already exists
    if [ -d "$action_dir" ]; then
        echo -e "${RED}Error: Action '$action_name' already exists${NC}" >&2
        return 1
    fi
    
    # Validate paths
    validate_path "$action_dir"
    validate_path "$plan_file"
    
    # Create action directory
    mkdir -p "$action_dir"
    
    # Create plan file
    cat > "$plan_file" << EOL
# $action_name Action Plan

## Purpose
[Purpose of the action]

## Implementation Steps
1. [First step]
2. [Second step]
3. [Third step]

## Success Criteria
- [First criterion]
- [Second criterion]
- [Third criterion]
EOL
    
    echo -e "${GREEN}✓ Action '$action_name' created successfully${NC}"
    return 0
}

# Function to check action status
check_status() {
    local action_name="$1"
    local action_dir=".aicheck/actions/$action_name"
    local plan_file="$action_dir/$action_name-PLAN.md"
    
    # Validate action name
    if ! validate_action_name "$action_name"; then
        return 1
    fi
    
    # Validate paths
    validate_path "$action_dir"
    validate_path "$plan_file"
    
    # Check if action exists
    if [ -d "$action_dir" ] && [ -f "$plan_file" ]; then
        echo -e "${GREEN}✓ Action '$action_name' exists${NC}"
        echo -e "\nPlan contents:"
        cat "$plan_file"
        return 0
    else
        echo -e "${RED}✗ Action '$action_name' not found${NC}" >&2
        return 1
    fi
}

# Function to switch to an action
switch_action() {
    local action_name="$1"
    local action_dir=".aicheck/actions/$action_name"
    
    # Validate action name
    if ! validate_action_name "$action_name"; then
        return 1
    fi
    
    # Validate path
    validate_path "$action_dir"
    
    # Check if action exists
    if [ -d "$action_dir" ]; then
        # Create/update current action symlink
        ln -sf "$action_name" .aicheck/current_action
        echo -e "${GREEN}✓ Switched to action '$action_name'${NC}"
        return 0
    else
        echo -e "${RED}✗ Action '$action_name' not found${NC}" >&2
        return 1
    fi
}

# Function to delete an action
delete_action() {
    local action_name="$1"
    local action_dir=".aicheck/actions/$action_name"
    
    # Validate action name
    if ! validate_action_name "$action_name"; then
        return 1
    fi
    
    # Validate path
    validate_path "$action_dir"
    
    # Check if action exists
    if [ -d "$action_dir" ]; then
        rm -rf "$action_dir"
        echo -e "${GREEN}✓ Action '$action_name' deleted${NC}"
        return 0
    else
        echo -e "${RED}✗ Action '$action_name' not found${NC}" >&2
        return 1
    fi
}

# Main script
case "$1" in
    create)
        create_action "$2"
        ;;
    status)
        check_status "$2"
        ;;
    switch)
        switch_action "$2"
        ;;
    delete)
        delete_action "$2"
        ;;
    *)
        echo "Usage: $0 {create|status|switch|delete} action_name" >&2
        exit 1
        ;;
esac 