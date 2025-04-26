#!/bin/bash

# AICheck Installer
# A standalone version of AICheck with optimized directory structure
# Each action has its own directory with plan file and supporting docs

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

# Source common functions
source .aicheck/scripts/common.sh

# Check git installation and repository
check_git
check_git_repo

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

# Create the main AI command script
echo ""
echo "=== Creating AI Command Script ==="
cat > ./ai << 'EOF'
#!/bin/bash

# AICheck command interface
# Provides a unified interface for all AICheck functionality
# Adapted for directory structure with action directories

# Source component scripts
source .aicheck/scripts/common.sh
source .aicheck/scripts/session.sh
source .aicheck/scripts/action.sh

command=$1
shift

case "$command" in
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
        update_action_status "$1" "$2"
        ;;
        
    *)
        echo "Usage: ./ai <command> [args]"
        echo "Commands:"
        echo "  start           - Start a new AI session"
        echo "  prompt          - Generate a prompt template"
        echo "  status          - Check ActiveAction status"
        echo "  update-status   - Update action status"
        exit 1
        ;;
esac
EOF

# Make the AI command script executable
chmod +x ./ai

echo ""
echo "=== Installation Complete ==="
echo "AICheck has been installed successfully!"
echo "Use './ai' to interact with the system."
echo "See README.md for more information."