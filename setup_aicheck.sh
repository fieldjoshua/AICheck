#!/bin/bash

# AICheck Setup Script
# This script sets up AICheck by making scripts executable and installing the pre-commit hook.

set -e

# Make all scripts executable
echo "Making .aicheck scripts and hooks executable..."
chmod +x .aicheck/scripts/*.sh .aicheck/hooks/*

echo "Scripts and hooks are now executable."

# Install pre-commit hook
if [ -d .git ]; then
    echo "Installing pre-commit hook..."
    ln -sf ../../.aicheck/hooks/pre-commit .git/hooks/pre-commit
    echo "Pre-commit hook installed."
else
    echo "Warning: .git directory not found. Please run this script from the root of a git repository."
fi

echo "AICheck setup complete!" 