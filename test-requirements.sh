#!/bin/bash

# AICheck System Requirements Test
# This script verifies that the system meets all requirements for installation

echo "┌─────────────────────────────────────────────────────────┐"
echo "│                                                         │"
echo "│         AICheck System Requirements Test                │"
echo "│                                                         │"
echo "└─────────────────────────────────────────────────────────┘"

# Function to check if a command exists
check_command() {
    local cmd=$1
    local required=$2
    local message=$3
    
    if ! command -v "$cmd" &> /dev/null; then
        if [ "$required" = "true" ]; then
            echo "❌ Error: Required command '$cmd' not found. $message"
            exit 1
        else
            echo "⚠️  Warning: Optional command '$cmd' not found. $message"
        fi
    else
        echo "✅ Found command: $cmd"
    fi
}

# Function to check file permissions
check_permissions() {
    local dir=$1
    if [ ! -w "$dir" ]; then
        echo "❌ Error: No write permission in directory: $dir"
        exit 1
    fi
    echo "✅ Write permission verified in: $dir"
}

# Function to check available disk space
check_disk_space() {
    local required_space=100 # Required space in MB
    local available_space=$(df -m . | awk 'NR==2 {print $4}')
    
    if [ "$available_space" -lt "$required_space" ]; then
        echo "❌ Error: Insufficient disk space. Required: ${required_space}MB, Available: ${available_space}MB"
        exit 1
    fi
    echo "✅ Sufficient disk space available: ${available_space}MB"
}

# Function to check system memory
check_memory() {
    local required_memory=512 # Required memory in MB
    local available_memory=$(free -m | awk '/^Mem:/{print $2}')
    
    if [ "$available_memory" -lt "$required_memory" ]; then
        echo "❌ Error: Insufficient system memory. Required: ${required_memory}MB, Available: ${available_memory}MB"
        exit 1
    fi
    echo "✅ Sufficient system memory available: ${available_memory}MB"
}

# Function to check OS compatibility
check_os() {
    local os=$(uname -s)
    case "$os" in
        Linux|Darwin)
            echo "✅ OS compatibility verified: $os"
            ;;
        *)
            echo "❌ Error: Unsupported operating system: $os"
            echo "AICheck currently supports Linux and macOS"
            exit 1
            ;;
    esac
}

# Function to check shell compatibility
check_shell() {
    local shell=$(basename "$SHELL")
    case "$shell" in
        bash|zsh)
            echo "✅ Shell compatibility verified: $shell"
            ;;
        *)
            echo "⚠️  Warning: Unsupported shell: $shell"
            echo "AICheck is tested with bash and zsh"
            ;;
    esac
}

# Function to check Python version (if available)
check_python() {
    if command -v python3 &> /dev/null; then
        local python_version=$(python3 --version 2>&1 | awk '{print $2}')
        echo "✅ Python version: $python_version"
    else
        echo "⚠️  Warning: Python 3 not found. Some features may be limited."
    fi
}

# Function to check Node.js version (if available)
check_node() {
    if command -v node &> /dev/null; then
        local node_version=$(node --version 2>&1)
        echo "✅ Node.js version: $node_version"
    else
        echo "⚠️  Warning: Node.js not found. Some features may be limited."
    fi
}

# Run all checks
echo ""
echo "=== Running System Checks ==="

# Check OS and shell
check_os
check_shell

# Check required commands
echo ""
echo "=== Checking Required Commands ==="
check_command "git" "true" "Git is required for version control"
check_command "bash" "true" "Bash is required for script execution"
check_command "sed" "true" "sed is required for text processing"
check_command "awk" "true" "awk is required for text processing"

# Check optional commands
echo ""
echo "=== Checking Optional Commands ==="
check_command "python3" "false" "Python 3 is optional but recommended"
check_command "node" "false" "Node.js is optional but recommended"
check_command "code" "false" "VS Code is optional for editing"

# Check system resources
echo ""
echo "=== Checking System Resources ==="
check_disk_space
check_memory

# Check permissions
echo ""
echo "=== Checking Permissions ==="
check_permissions "."

# Check Python and Node.js if available
echo ""
echo "=== Checking Development Tools ==="
check_python
check_node

echo ""
echo "┌─────────────────────────────────────────────────────────┐"
echo "│                                                         │"
echo "│         System Requirements Test Complete               │"
echo "│                                                         │"
echo "└─────────────────────────────────────────────────────────┘"
echo ""
echo "If all checks passed, you can proceed with installation."
echo "If there are any errors, please resolve them before continuing." 