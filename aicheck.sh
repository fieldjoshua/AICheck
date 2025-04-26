#!/bin/bash

# AICheck Installer
# A standalone version of AICheck with optimized directory structure
# Each action has its own directory with plan file and supporting docs

# Source common functions
source .aicheck/scripts/common.sh

# Display logo
show_aicheck_logo

echo "┌─────────────────────────────────────────────────────────┐"
echo "│                                                         │"
echo "│             AICheck Installer                           │"
echo "│                                                         │"
echo "└─────────────────────────────────────────────────────────┘"

# Run system requirements test
echo ""
echo "=== Running System Requirements Test ==="
if ! ./test-requirements.sh; then
    echo "❌ System requirements test failed. Please resolve the issues before continuing."
    exit 1
fi

# Check git installation and repository
check_git
check_git_repo

# Check for existing installation
if [ -d ".aicheck" ]; then
    echo ""
    echo "=== Existing AICheck Installation Found ==="
    echo "Found existing $(format_aicheck_path ".aicheck") directory. This installation will:"
    echo "1. Preserve all existing actions"
    echo "2. Keep all existing sessions"
    echo "3. Maintain ActiveAction and session states"
    echo "4. Update only the core system files"
    
    # Backup existing installation
    echo ""
    echo "=== Creating Backup ==="
    backup_dir=".aicheck_backup_$(date +%Y%m%d%H%M%S)"
    mkdir -p "$backup_dir"
    cp -r .aicheck/* "$backup_dir/"
    echo "Created backup in $(format_aicheck_path "$backup_dir")"
    
    # Preserve existing actions
    echo ""
    echo "=== Preserving Existing Actions ==="
    if [ -d ".aicheck/actions" ]; then
        echo "Found existing actions:"
        find .aicheck/actions -maxdepth 1 -mindepth 1 -type d | while read action_dir; do
            action_name=$(basename "$action_dir")
            echo "  - $(format_aicheck_path "$action_name")"
        done
    fi
    
    # Preserve existing sessions
    echo ""
    echo "=== Preserving Existing Sessions ==="
    if [ -d ".aicheck/sessions" ]; then
        echo "Found existing sessions:"
        find .aicheck/sessions -maxdepth 1 -mindepth 1 -type d | while read session_dir; do
            session_id=$(basename "$session_dir")
            echo "  - $(format_aicheck_path "$session_id")"
        done
    fi
    
    # Preserve current state
    echo ""
    echo "=== Preserving Current State ==="
    if [ -f ".aicheck/current_action" ]; then
        current_action=$(cat .aicheck/current_action)
        echo "ActiveAction: $(format_aicheck_path "$current_action")"
    fi
    if [ -f ".aicheck/current_session" ]; then
        current_session=$(cat .aicheck/current_session)
        echo "Current session: $(format_aicheck_path "$current_session")"
    fi
    
    # Ask for confirmation
    echo ""
    echo "Would you like to proceed with the update? (y/n)"
    read -r proceed
    if [ "$proceed" != "y" ]; then
        echo "Installation cancelled. Your existing installation remains unchanged."
        exit 0
    fi
fi

# Create the AICheck directory structure
echo ""
echo "=== Creating AICheck Directory Structure ==="
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
create_dir ".aicheck/scripts"

# Install Git hooks
echo ""
echo "=== Installing Git Hooks ==="
if [ -d ".git" ]; then
    # Make pre-commit hook executable
    chmod +x .aicheck/hooks/pre-commit
    
    # Install pre-commit hook
    if [ -f ".git/hooks/pre-commit" ]; then
        echo "Backing up existing pre-commit hook"
        mv .git/hooks/pre-commit .git/hooks/pre-commit.bak
    fi
    ln -s ../../.aicheck/hooks/pre-commit .git/hooks/pre-commit
    echo "Git hooks installed successfully"
else
    echo "⚠️ Warning: Not a Git repository. Git hooks not installed."
    echo "Run 'git init' to initialize a Git repository, then run this installer again."
fi

# Create the main AI command script
echo ""
echo "=== Creating AI Command Script ==="
cat > ./ai << EOF
#!/bin/bash

# AICheck command interface
# Provides a unified interface for all AICheck functionality
# Adapted for directory structure with action directories

# Source component scripts
source .aicheck/scripts/common.sh
source .aicheck/scripts/session.sh
source .aicheck/scripts/action.sh

command=\$1
shift

case "\$command" in
    start)
        start_session
        ;;
        
    prompt)
        generate_prompt
        ;;
        
    status)
        check_action_status
        ;;
    
    update-status)
        update_action_status "\$1" "\$2"
        ;;
        
    update-progress)
        update_action_progress "\$1" "\$2"
        ;;
        
    new)
        if [ -z "\$1" ]; then
            echo "Error: Action name required"
            echo "Usage: ./ai new <action_name>"
            exit 1
        fi
        create_new_action "\$1"
        ;;
        
    switch)
        if [ -z "\$1" ]; then
            echo "Error: Action name required"
            echo "Usage: ./ai switch <action_name>"
            exit 1
        fi
        switch_to_action "\$1"
        ;;
        
    audit)
        # Check for human manager approval
        check_human_manager_approval "Change ActiveAction" "AdminAudit"
        
        # Check if AdminAudit exists
        if [ ! -d ".aicheck/actions/AdminAudit" ]; then
            echo "Creating new AdminAudit action..."
            create_new_action "AdminAudit"
        else
            echo "Switching to existing AdminAudit..."
            switch_to_action "AdminAudit"
        fi
        ;;
        
    admin)
        # Check for human manager approval
        check_human_manager_approval "Change ActiveAction" "AdminAudit"
        
        # Check if AdminAudit exists
        if [ ! -d ".aicheck/actions/AdminAudit" ]; then
            echo "Creating new AdminAudit action..."
            create_new_action "AdminAudit"
        else
            echo "Switching to existing AdminAudit..."
            switch_to_action "AdminAudit"
        fi
        ;;
        
    cursor)
        # Prepare for Cursor chat
        echo "=== Preparing for Cursor Chat ==="
        
        # Get current action and session
        current_action=$(cat .aicheck/current_action 2>/dev/null || echo "None")
        current_session=$(cat .aicheck/current_session 2>/dev/null || echo "None")
        
        # Create context file
        context_file=".aicheck/cursor/chat_context_$(date +%Y%m%d%H%M%S).md"
        mkdir -p .aicheck/cursor
        
        # Generate context
        cat > "$context_file" << EOC
# Cursor Chat Context - $(date +"%Y-%m-%d %H:%M:%S")

## ⚠️ CRITICAL: RULES.md COMPLIANCE ⚠️
This development MUST follow the rules defined in RULES.md, which is the controlling document.
IMPORTANT: AI editors DO NOT need to ask for approval for any work that complies with RULES.md and falls within the scope of the ActiveAction.

## Current State
- ActiveAction: $current_action
- Current Session: $current_session
- Actions Index: .aicheck/docs/actions_index.md

## Action Details
$(if [ "$current_action" != "None" ] && [ -f ".aicheck/actions/$current_action/$current_action-PLAN.md" ]; then
    cat ".aicheck/actions/$current_action/$current_action-PLAN.md" | head -n 20
    echo "..."
  else
    echo "No ActiveAction selected or plan file not found."
  fi)

## Recent Changes
$(git diff --name-only | head -n 10 | sed 's/^/- /')

## Project Structure
$(find . -type f -name "*.py" -o -name "*.js" -o -name "*.html" -o -name "*.css" -o -name "*.md" -o -name "*.json" | grep -v "node_modules" | grep -v ".git" | head -n 20 | sed 's/^/- /')

## Reference Paths
- RULES.md: Project rules and guidelines (MUST READ)
- .aicheck/actions/: Action-specific directories
- .aicheck/docs/actions_index.md: Action tracking and status
- .aicheck/templates/: Template files
- .aicheck/sessions/: Session data
- .aicheck/current_action: ActiveAction tracking
- .aicheck/current_session: Current active session
EOC

        echo "Context file created: $context_file"
        echo "Use this context in your Cursor chat"
        
        # Copy to clipboard if available
        if command -v pbcopy &> /dev/null; then
            cat "$context_file" | pbcopy
            echo "Context copied to clipboard"
        elif command -v xclip &> /dev/null; then
            cat "$context_file" | xclip -selection clipboard
            echo "Context copied to clipboard"
        fi
        ;;
        
    "check!")
        # Generate a quick check prompt for AI editors
        echo "=== Generating AI Editor Check Prompt ==="
        
        # Get current action and session
        current_action=$(cat .aicheck/current_action 2>/dev/null || echo "None")
        current_session=$(cat .aicheck/current_session 2>/dev/null || echo "None")
        
        # Generate check prompt
        check_prompt=$(cat << EOF
⚠️ AI Editor Check - AICheck Project ⚠️

Please specify which action you are working on and confirm compliance with project guidelines.

Current State:
- ActiveAction: $current_action
- Current Session: $current_session

Important Documents:
1. Action Plan: .aicheck/actions/$current_action/$current_action-PLAN.md
2. Actions Index: .aicheck/docs/actions_index.md
3. RULES.md: Project rules and guidelines (CONTROLLING DOCUMENT)
4. Supporting Docs: .aicheck/actions/$current_action/supporting_docs/

Required Confirmations:
□ I have reviewed RULES.md and confirm compliance
□ I have reviewed the current action plan
□ I understand the action scope and boundaries
□ I have checked supporting documentation
□ I am aware of the current action status and progress

Action Scope:
- The scope is defined in the action plan
- All work must comply with RULES.md
- Changes must be within the current action scope
- Documentation must be kept up to date

Reminders:
- You can proceed with implementation if work complies with RULES.md
- Stay within the defined action scope
- Update progress using './ai update-progress'
- Update status using './ai update-status'
- Document all significant changes

Please proceed with your task while maintaining compliance with these guidelines.
EOF
)
        # Display the prompt
        echo "$check_prompt"
        echo ""
        
        # Copy to clipboard based on OS
        if command -v pbcopy &> /dev/null; then
            echo "$check_prompt" | pbcopy
            echo "✓ Check prompt copied to clipboard (macOS)"
        elif command -v xclip &> /dev/null; then
            echo "$check_prompt" | xclip -selection clipboard
            echo "✓ Check prompt copied to clipboard (Linux)"
        else
            echo "⚠️ Clipboard tools not found. Please copy the above prompt manually."
            echo "Tip: Select the text above and use Ctrl+C/Cmd+C to copy"
        fi
        ;;
        
    *)
        echo "Usage: ./ai <command> [args]"
        echo "Commands:"
        echo "  start           - Start a new AI session"
        echo "  prompt          - Generate a prompt template"
        echo "  status          - Check ActiveAction status"
        echo "  update-status   - Update action status"
        echo "  update-progress - Update action progress"
        echo "  new            - Create a new action"
        echo "  switch         - Switch to an existing action"
        echo "  audit          - Create administrative audit"
        echo "  admin           - Enter admin mode"
        echo "  cursor          - Prepare for Cursor chat"
        echo "  check!          - Generate AI editor check prompt"
        exit 1
        ;;
esac
EOF

# Make the AI command script executable
chmod +x ./ai

# If this was an update, restore preserved state
if [ -d "$backup_dir" ]; then
    echo ""
    echo "=== Restoring Preserved State ==="
    
    # Restore current action and session
    if [ -n "$current_action" ]; then
        echo "$current_action" > .aicheck/current_action
        echo "Restored ActiveAction: $current_action"
    fi
    if [ -n "$current_session" ]; then
        echo "$current_session" > .aicheck/current_session
        echo "Restored current session: $current_session"
    fi
    
    # Switch to AdminAudit for update review
    echo ""
    echo "=== Switching to AdminAudit for Update Review ==="
    if [ ! -d ".aicheck/actions/AdminAudit" ]; then
        echo "Creating new AdminAudit action..."
        create_new_action "AdminAudit"
    else
        echo "Switching to existing AdminAudit..."
        switch_to_action "AdminAudit"
    fi
    
    echo ""
    echo "=== Update Complete ==="
    echo "Your existing actions and sessions have been preserved."
    echo "Switched to AdminAudit for update review."
    echo "Backup of previous installation is available in: $backup_dir"
else
    echo ""
    echo "=== Installation Complete ==="
    echo "AICheck has been installed successfully!"
    echo "Use './ai' to interact with the system."
    echo "See README.md for more information."
    
    # Create initial AdminAudit action
    echo ""
    echo "=== Creating Initial AdminAudit ==="
    create_new_action "AdminAudit"
    echo "Created AdminAudit action for system management."
fi