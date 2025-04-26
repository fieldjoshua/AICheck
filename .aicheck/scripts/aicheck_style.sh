#!/bin/bash

# AICheck directory styling script
# This script adds custom styling for AICheck directories in your shell

# Check if LS_COLORS is already set
if [ -z "$LS_COLORS" ]; then
    export LS_COLORS=""
fi

# Add purple color for AICheck directories
export LS_COLORS="$LS_COLORS:di=0;35:*.md=0;35"

# Add to your shell's configuration file
# For bash: ~/.bashrc
# For zsh: ~/.zshrc
# For fish: ~/.config/fish/config.fish

# Example for bash/zsh:
# echo 'source ~/.aicheck/scripts/aicheck_style.sh' >> ~/.bashrc
# echo 'source ~/.aicheck/scripts/aicheck_style.sh' >> ~/.zshrc

# Example for fish:
# echo 'source ~/.aicheck/scripts/aicheck_style.sh' >> ~/.config/fish/config.fish

echo "AICheck directory styling has been set up."
echo "Please add the following line to your shell's configuration file:"
echo "source ~/.aicheck/scripts/aicheck_style.sh" 