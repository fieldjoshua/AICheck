#!/bin/bash

# Common functions for UltraAICheck

# Function to create directory if it doesn't exist
create_dir() {
    if [ -z "$1" ]; then
        log_error "Directory path is required"
        echo "Error: Directory path is required"
        exit 1
    fi
    
    if [ ! -d "$1" ]; then
        if ! mkdir -p "$1" 2>/dev/null; then
            log_error "Failed to create directory: $1"
            echo "Error: Failed to create directory: $1"
            exit 1
        fi
        echo "  Created directory: $1"
    else
        echo "  Directory already exists: $1"
    fi
}

# Function to check if git is installed
check_git() {
    if ! command -v git &> /dev/null; then
        log_error "git is not installed"
        echo "Error: git is not installed. Please install git first."
        exit 1
    fi
}

# Function to check if we're in a git repository
check_git_repo() {
    if ! git rev-parse --is-inside-work-tree &> /dev/null; then
        log_info "Initializing git repository"
        echo "Warning: Not in a git repository. Initializing git repository..."
        if ! git init &> /dev/null; then
            log_error "Failed to initialize git repository"
            echo "Error: Failed to initialize git repository"
            exit 1
        fi
    fi
}

# Function to get current git branch
get_git_branch() {
    if ! git rev-parse --is-inside-work-tree &> /dev/null; then
        log_error "Not in a git repository"
        echo "Error: Not in a git repository"
        exit 1
    fi
    
    local branch
    branch=$(git branch --show-current 2>/dev/null)
    if [ $? -ne 0 ]; then
        log_error "Failed to get current git branch"
        echo "Error: Failed to get current git branch"
        exit 1
    fi
    echo "$branch"
}

# Function to get recent commits
get_recent_commits() {
    if ! git rev-parse --is-inside-work-tree &> /dev/null; then
        log_error "Not in a git repository"
        echo "Error: Not in a git repository"
        exit 1
    fi
    
    local commits
    commits=$(git log -n 5 --oneline 2>/dev/null)
    if [ $? -ne 0 ]; then
        log_error "Failed to get recent commits"
        echo "Error: Failed to get recent commits"
        exit 1
    fi
    echo "$commits"
}

# Function to validate action name
validate_action_name() {
    local action_name=$1
    if [ -z "$action_name" ]; then
        log_error "Action name is required"
        echo "Error: Action name is required"
        exit 1
    fi
    if [[ ! "$action_name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        log_error "Invalid action name: $action_name"
        echo "Error: Action name can only contain letters, numbers, underscores, and hyphens"
        exit 1
    fi
}

# Function to validate status
validate_status() {
    local status=$1
    local valid_statuses=("Not Started" "ActiveAction" "Completed" "Blocked" "On Hold")
    if [ -z "$status" ]; then
        log_error "Status is required"
        echo "Error: Status is required"
        exit 1
    fi
    if [[ ! " ${valid_statuses[@]} " =~ " ${status} " ]]; then
        log_error "Invalid status: $status"
        echo "Error: Invalid status. Must be one of: ${valid_statuses[*]}"
        exit 1
    fi
}

# Function to log errors
log_error() {
    local message=$1
    local log_file=".aicheck/error.log"
    
    # Create log directory if it doesn't exist
    mkdir -p "$(dirname "$log_file")"
    
    echo "$(date +"%Y-%m-%d %H:%M:%S") - ERROR: $message" >> "$log_file"
}

# Function to log info
log_info() {
    local message=$1
    local log_file=".aicheck/info.log"
    
    # Create log directory if it doesn't exist
    mkdir -p "$(dirname "$log_file")"
    
    echo "$(date +"%Y-%m-%d %H:%M:%S") - INFO: $message" >> "$log_file"
}

# Function to check if a file exists
check_file_exists() {
    local file=$1
    if [ ! -f "$file" ]; then
        log_error "File not found: $file"
        echo "Error: File not found: $file"
        exit 1
    fi
}

# Function to check if a directory exists
check_dir_exists() {
    local dir=$1
    if [ ! -d "$dir" ]; then
        log_error "Directory not found: $dir"
        echo "Error: Directory not found: $dir"
        exit 1
    fi
}

# Function to validate file permissions
check_file_permissions() {
    local file=$1
    local required_permission=$2
    
    if [ ! -f "$file" ]; then
        log_error "File not found: $file"
        echo "Error: File not found: $file"
        exit 1
    fi
    
    if [ ! -"$required_permission" "$file" ]; then
        log_error "Insufficient permissions for file: $file"
        echo "Error: Insufficient permissions for file: $file"
        exit 1
    fi
} 