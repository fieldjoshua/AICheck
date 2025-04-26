#!/bin/bash

# Session management functions for AICheck

source .aicheck/scripts/common.sh

# Function to start a new session
start_session() {
    local session_id=$(date +%Y%m%d%H%M%S)
    mkdir -p .aicheck/sessions/$session_id
    
    # Generate context from current repository state
    local git_branch=$(get_git_branch)
    local recent_commits=$(get_recent_commits)
    local current_action=$(cat .aicheck/current_action 2>/dev/null || echo "None")
    
    # Create session file with initial context
    cat > .aicheck/sessions/$session_id/context.md << EOC
# Session Context: $session_id
- Branch: $git_branch
- ActiveAction: $current_action
- Recent Commits:
$(echo "$recent_commits" | sed 's/^/  - /')

## ⚠️ CRITICAL: RULES.md COMPLIANCE ⚠️
This development MUST follow the rules defined in RULES.md, which is the controlling document.
IMPORTANT: AI editors DO NOT need to ask for approval for any work that complies with RULES.md and falls within the scope of the ActiveAction.
NO APPROVAL IS NEEDED for such work - proceed directly to implementation.

## Current Working Action
Action Name: $current_action
Action Plan: .aicheck/actions/$current_action/$current_action-PLAN.md
Actions Index: .aicheck/docs/actions_index.md (source of truth for statuses)
Supporting Docs: .aicheck/actions/$current_action/supporting_docs/

### Action Progress
To update action progress:
1. Run './ai status' to check current status
2. Use './ai update-status <action_name> <new_status>' to update status
3. Valid statuses: "Not Started", "ActiveAction", "Completed", "Blocked", "On Hold"
4. Progress is tracked in .aicheck/docs/actions_index.md

### Action Scope
The ActiveAction's scope is defined in:
- .aicheck/actions/$current_action/$current_action-PLAN.md
- Any supporting documents in .aicheck/actions/$current_action/supporting_docs/
- The action's entry in .aicheck/docs/actions_index.md

## Active Files
$(find . -type f -name "*.py" -o -name "*.js" -o -name "*.html" -o -name "*.css" -o -name "*.md" -o -name "*.json" | grep -v "node_modules" | grep -v ".git" | head -n 10 | sed 's/^/- /')

## Action Details
$(if [ "$current_action" != "None" ] && [ -f ".aicheck/actions/$current_action/$current_action-PLAN.md" ]; then
    cat ".aicheck/actions/$current_action/$current_action-PLAN.md" | head -n 20
    echo "..."
  else
    echo "No ActiveAction selected or plan file not found."
  fi)

## Supporting Documents
$(if [ "$current_action" != "None" ] && [ -d ".aicheck/actions/$current_action/supporting_docs" ]; then
    echo "Available supporting documents:"
    find ".aicheck/actions/$current_action/supporting_docs" -type f | sed 's/^/- /'
  else
    echo "No supporting documents found for this action."
  fi)

## Templates
Available templates in .aicheck/templates/:
$(find .aicheck/templates -type f | sed 's/^/- /')

## Reference Paths
- RULES.md: Project rules and guidelines (MUST READ)
- .aicheck/actions/: Action-specific directories
- .aicheck/docs/actions_index.md: Action tracking and status
- .aicheck/templates/: Template files
- .aicheck/sessions/: Session data
- .aicheck/current_action: ActiveAction tracking
- .aicheck/current_session: Current active session
EOC

    # Record session start
    echo "$(date +"%Y-%m-%d %H:%M:%S") - Session started: $session_id" >> .aicheck/sessions/session_log.txt
    echo $session_id > .aicheck/current_session
    
    log_info "Started new session: $session_id"
    echo "AI session started with ID: $session_id"
    echo "Context file created at .aicheck/sessions/$session_id/context.md"
}

# Function to generate a prompt template
generate_prompt() {
    local current_session=$(cat .aicheck/current_session 2>/dev/null || echo "")
    local current_action=$(cat .aicheck/current_action 2>/dev/null || echo "None")
    
    if [ -z "$current_session" ]; then
        log_error "No active session. Start a session first with './ai start'"
        echo "No active session. Start a session first with './ai start'"
        exit 1
    fi
    
    local prompt_file=".aicheck/sessions/$current_session/prompt_$(date +%H%M%S).md"
    
    cat > $prompt_file << EOT
# AI Prompt - $(date +"%Y-%m-%d %H:%M:%S")

## ⚠️ CRITICAL: RULES.md COMPLIANCE ⚠️
This development MUST follow the rules defined in RULES.md, which is the controlling document.
IMPORTANT: AI editors DO NOT need to ask for approval for any work that complies with RULES.md and falls within the scope of the ActiveAction.
You can proceed directly with implementation for:
- Code that implements the ActiveAction plan
- Documentation updates
- Bug fixes related to the ActiveAction
- Tests for ActiveAction functionality
- Refactoring within the ActiveAction scope

## Current Working Action
Action Name: $current_action
Action Plan: .aicheck/actions/$current_action/$current_action-PLAN.md
Actions Index: .aicheck/docs/actions_index.md (source of truth for statuses)
Supporting Docs: .aicheck/actions/$current_action/supporting_docs/

### Action Progress
To update action progress:
1. Run './ai status' to check current status
2. Use './ai update-status <action_name> <new_status>' to update status
3. Valid statuses: "Not Started", "ActiveAction", "Completed", "Blocked", "On Hold"
4. Progress is tracked in .aicheck/docs/actions_index.md

### Action Scope
The ActiveAction's scope is defined in:
- .aicheck/actions/$current_action/$current_action-PLAN.md
- Any supporting documents in .aicheck/actions/$current_action/supporting_docs/
- The action's entry in .aicheck/docs/actions_index.md

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

## Reference Paths
- RULES.md: Project rules and guidelines (MUST READ)
- .aicheck/actions/: Action-specific directories
- .aicheck/docs/actions_index.md: Action tracking and status
- .aicheck/templates/: Template files
- .aicheck/sessions/: Session data
- .aicheck/current_action: ActiveAction tracking
- .aicheck/current_session: Current active session
EOT

    log_info "Generated prompt template: $prompt_file"
    echo "Prompt template created at $prompt_file"
    if command -v code &> /dev/null; then
        code $prompt_file
    else
        echo "Open this file in your editor to complete the prompt"
    fi
} 