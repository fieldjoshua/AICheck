#!/bin/bash
# .aicheck/scripts/document_migration.sh
# Script for migrating process documentation to product documentation

# Colors for output
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Function to migrate documentation
migrate_document() {
    local action_name="$1"
    local source_doc="$2"
    local target_category="$3"
    
    # Validate input parameters
    if [[ -z "$action_name" || -z "$source_doc" || -z "$target_category" ]]; then
        echo -e "${RED}[migrate_document] Error: All parameters are required.${NC}" >&2
        echo "Usage: migrate_document [ACTION_NAME] [SOURCE_DOC] [TARGET_CATEGORY]" >&2
        return 1
    fi
    
    # Define paths
    local action_dir=".aicheck/actions/$action_name"
    local source_path="$action_dir/supporting_docs/$source_doc"
    local target_dir="documentation/$target_category"
    local target_path="$target_dir/$source_doc"
    
    # Validate existence of action and source document
    if [[ ! -d "$action_dir" ]]; then
        echo -e "${RED}[migrate_document] Error: Action '$action_name' does not exist.${NC}" >&2
        return 1
    fi
    
    if [[ ! -f "$source_path" ]]; then
        echo -e "${RED}[migrate_document] Error: Source document '$source_doc' not found in $action_dir/supporting_docs/.${NC}" >&2
        return 1
    fi
    
    # Validate target category exists
    if [[ ! -d "$target_dir" ]]; then
        echo -e "${YELLOW}[migrate_document] Target category directory '$target_dir' does not exist. Creating it now.${NC}"
        mkdir -p "$target_dir"
    fi
    
    # Check if target already exists
    if [[ -f "$target_path" ]]; then
        echo -e "${YELLOW}[migrate_document] Warning: Target document '$target_path' already exists.${NC}"
        echo -ne "${BOLD}Would you like to overwrite it? (y/n): ${NC}"
        read -r overwrite
        if [[ "$overwrite" != "y" ]]; then
            echo -e "${YELLOW}[migrate_document] Migration cancelled.${NC}"
            return 1
        fi
    fi
    
    # Display migration checklist reminder
    echo -e "${BOLD}${BLUE}Documentation Migration Checklist:${NC}"
    echo -e "${YELLOW}1. Have you removed ACTION-specific terminology?${NC}"
    echo -e "${YELLOW}2. Have you ensured technical accuracy and completeness?${NC}"
    echo -e "${YELLOW}3. Have you updated references to other documents?${NC}"
    echo -e "${YELLOW}4. Have you added appropriate metadata?${NC}"
    echo -ne "${BOLD}Have you completed these preparation steps? (y/n): ${NC}"
    read -r prepared
    
    if [[ "$prepared" != "y" ]]; then
        echo -e "${YELLOW}[migrate_document] Please prepare the document according to the checklist in documentation/technical/processes/documentation_migration.md before migrating.${NC}"
        return 1
    fi
    
    # Perform migration
    echo -e "${GREEN}[migrate_document] Migrating '$source_doc' to '$target_path'...${NC}"
    
    # Add metadata to the file if it's a markdown file
    if [[ "$source_doc" == *.md ]]; then
        # Create a temporary file with metadata
        local temp_file=$(mktemp)
        cat > "$temp_file" <<EOL
---
title: $(basename "$source_doc" .md)
origin_action: $action_name
date_migrated: $(date +"%Y-%m-%d")
---

EOL
        
        # Append the original content
        cat "$source_path" >> "$temp_file"
        
        # Copy the temp file to the target location
        cp "$temp_file" "$target_path"
        rm "$temp_file"
    else
        # For non-markdown files, just copy directly
        cp "$source_path" "$target_path"
    fi
    
    # Record the migration in the action's record
    local migration_record="$action_dir/document_migrations.md"
    
    # Create migration record file if it doesn't exist
    if [[ ! -f "$migration_record" ]]; then
        cat > "$migration_record" <<EOL
# Document Migrations for $action_name

| Document | Target Location | Date |
|----------|----------------|------|
EOL
    fi
    
    # Add the migration to the record
    echo "| $source_doc | $target_path | $(date +"%Y-%m-%d") |" >> "$migration_record"
    
    echo -e "${GREEN}[migrate_document] Successfully migrated '$source_doc' to '$target_path'.${NC}"
    echo -e "${BOLD}Migration has been recorded in '$migration_record'.${NC}"
    
    # Update migration status in source file if it's a markdown file
    if [[ "$source_doc" == *.md ]]; then
        local temp_file=$(mktemp)
        cat > "$temp_file" <<EOL
---
status: MIGRATED
migrated_to: $target_path
date_migrated: $(date +"%Y-%m-%d")
---

EOL
        
        # Append the original content
        cat "$source_path" >> "$temp_file"
        
        # Replace the original file
        cp "$temp_file" "$source_path"
        rm "$temp_file"
        
        echo -e "${GREEN}[migrate_document] Updated source document with migration status.${NC}"
    fi
    
    return 0
}

# Function to list available process documents for an action
list_process_documents() {
    local action_name="$1"
    local docs_dir=".aicheck/actions/$action_name/supporting_docs"
    
    if [[ -z "$action_name" ]]; then
        echo -e "${RED}[list_process_documents] Error: Action name required.${NC}" >&2
        return 1
    fi
    
    if [[ ! -d "$docs_dir" ]]; then
        echo -e "${RED}[list_process_documents] Error: Supporting documents directory not found for action '$action_name'.${NC}" >&2
        return 1
    fi
    
    echo -e "${BOLD}${BLUE}Process Documents for $action_name:${NC}"
    
    # Count files in directory
    local file_count=$(find "$docs_dir" -type f | wc -l)
    
    if [[ "$file_count" -eq 0 ]]; then
        echo -e "${YELLOW}No process documents found for this action.${NC}"
        return 0
    fi
    
    # List files with numbers
    local count=1
    for file in "$docs_dir"/*; do
        if [[ -f "$file" ]]; then
            local file_name=$(basename "$file")
            local file_type="${file_name##*.}"
            echo -e "${GREEN}$count.${NC} $file_name (${BLUE}$file_type${NC})"
            count=$((count + 1))
        fi
    done
    
    return 0
}

# Function to list all available target categories
list_target_categories() {
    local docs_dir="documentation"
    
    if [[ ! -d "$docs_dir" ]]; then
        echo -e "${RED}[list_target_categories] Error: Documentation directory not found.${NC}" >&2
        return 1
    fi
    
    echo -e "${BOLD}${BLUE}Available Target Categories:${NC}"
    
    # List directories with a description
    for dir in "$docs_dir"/*; do
        if [[ -d "$dir" ]]; then
            local dir_name=$(basename "$dir")
            case "$dir_name" in
                "technical")
                    echo -e "${GREEN}• $dir_name${NC} - Technical implementation details"
                    ;;
                "public")
                    echo -e "${GREEN}• $dir_name${NC} - User-facing documentation"
                    ;;
                "planning")
                    echo -e "${GREEN}• $dir_name${NC} - Strategic planning documents"
                    ;;
                "vision")
                    echo -e "${GREEN}• $dir_name${NC} - High-level vision documents"
                    ;;
                "architecture")
                    echo -e "${GREEN}• $dir_name${NC} - System design documents"
                    ;;
                "research")
                    echo -e "${GREEN}• $dir_name${NC} - Background research"
                    ;;
                "operations")
                    echo -e "${GREEN}• $dir_name${NC} - Deployment & operations"
                    ;;
                "implementation")
                    echo -e "${GREEN}• $dir_name${NC} - Implementation details"
                    ;;
                "deliverables")
                    echo -e "${GREEN}• $dir_name${NC} - Completion records"
                    ;;
                "status_updates")
                    echo -e "${GREEN}• $dir_name${NC} - Periodic status reports"
                    ;;
                "legal")
                    echo -e "${GREEN}• $dir_name${NC} - Legal documents"
                    ;;
                "configuration")
                    echo -e "${GREEN}• $dir_name${NC} - Configuration documentation"
                    ;;
                *)
                    echo -e "${GREEN}• $dir_name${NC}"
                    ;;
            esac
        fi
    done
    
    return 0
} 