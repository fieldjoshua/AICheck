#!/bin/bash
# install_aicheck.sh - Safe installer/upgrader for AICheck core scripts
# This script deletes old/legacy scripts, installs/updates core scripts from local files, and preserves all user data.

set -e

BACKUP_DIR=".aicheck/backup/$(date +%Y%m%d%H%M%S)"
CORE_SCRIPTS=(ai .aicheck/scripts/action.sh .aicheck/scripts/session.sh .aicheck/scripts/common.sh .aicheck/scripts/security_utils.sh)
TEMPLATE_FILES=(.aicheck/templates/action_plan_template.md)

# 1. Identify old/legacy scripts
find_old_scripts() {
    find . \
        -type f \
        \( \
            -name 'ai.old' -o \
            -name 'ai.bak' -o \
            -name 'ai~' -o \
            -name 'ai_backup*' -o \
            -name 'old_*.sh' -o \
            -name 'legacy_*.sh' -o \
            -name '*.bak' -o \
            -name '*.old' \
        \) \
        -not -path './.aicheck/actions/*' \
        -not -path './.aicheck/templates/*' \
        -not -path './.aicheck/docs/*'
}

# 2. Backup and delete old scripts
backup_and_delete() {
    local file="$1"
    mkdir -p "$BACKUP_DIR"
    cp "$file" "$BACKUP_DIR/"
    rm "$file"
}

# 3. Install/update core scripts from local source
install_core_scripts() {
    echo "Installing/updating core scripts from local files..."
    cp -f ./ai ./ai
    cp -f .aicheck/scripts/action.sh .aicheck/scripts/action.sh
    cp -f .aicheck/scripts/session.sh .aicheck/scripts/session.sh
    cp -f .aicheck/scripts/common.sh .aicheck/scripts/common.sh
    cp -f .aicheck/scripts/security_utils.sh .aicheck/scripts/security_utils.sh
    cp -f .aicheck/templates/action_plan_template.md .aicheck/templates/action_plan_template.md
    chmod +x ai .aicheck/scripts/*.sh
}

# 4. Add and commit updated scripts to git
commit_core_scripts() {
    echo "Adding and committing updated scripts to git..."
    git add ai .aicheck/scripts/action.sh .aicheck/scripts/session.sh .aicheck/scripts/common.sh .aicheck/scripts/security_utils.sh .aicheck/templates/action_plan_template.md
    git commit -m "Update AICheck core scripts and templates via installer. Remove legacy scripts."
}

# 5. Print summary
print_summary() {
    echo "\nAICheck Installer Summary:"
    if [ -d "$BACKUP_DIR" ]; then
        echo "- Old scripts backed up to: $BACKUP_DIR"
        echo "- Deleted scripts:"
        ls "$BACKUP_DIR" | sed 's/^/    - /'
    else
        echo "- No old scripts found/deleted."
    fi
    echo "- Preserved user data:"
    echo "    - .aicheck/actions/ (all actions, plans, supporting_docs)"
    echo "    - .aicheck/templates/ (all templates)"
    echo "    - .aicheck/docs/ (all documentation)"
    echo "- Installed/updated core scripts:"
    for f in "${CORE_SCRIPTS[@]}"; do
        echo "    - $f"
    done
    for f in "${TEMPLATE_FILES[@]}"; do
        echo "    - $f"
    done
    echo "\nAICheck is now up to date and ready to use!"
}

# Check for uncommitted changes
check_uncommitted_changes() {
    if [ -n "$(git status --porcelain)" ]; then
        echo "Warning: You have uncommitted changes. Please commit or stash them before proceeding."
        exit 1
    fi
}

# Handle untracked files
handle_untracked_files() {
    UNTRACKED_FILES=$(git ls-files --others --exclude-standard)
    if [ -n "$UNTRACKED_FILES" ]; then
        echo "Warning: You have untracked files. Consider adding them to version control or ignoring them."
        echo "$UNTRACKED_FILES"
    fi
}

# Verify directory structure
verify_directory_structure() {
    if [ ! -d ".aicheck/hooks/" ]; then
        echo "Creating missing .aicheck/hooks/ directory."
        mkdir -p .aicheck/hooks/
    fi
}

# Main
check_uncommitted_changes
handle_untracked_files
verify_directory_structure
OLD_SCRIPTS=$(find_old_scripts)
if [ -n "$OLD_SCRIPTS" ]; then
    echo "Backing up and deleting old scripts..."
    while IFS= read -r file; do
        backup_and_delete "$file"
    done <<< "$OLD_SCRIPTS"
else
    echo "No old scripts found."
fi

install_core_scripts
commit_core_scripts
print_summary 