# AICheck Usage Guide

## Overview

AICheck is a system for managing AI-assisted development that ensures compliance with project rules. This guide explains how to use the AICheck commands and understand its structure.

## Command Interfaces

AICheck provides two command interfaces:

1. **Full Command Set** - `ai`
   - Provides all AICheck functionality
   - Primary location is in the root directory (`./ai`)
   - Copy also available in `.aicheck/scripts/ai`

2. **Streamlined Command Set** - `ai-core`
   - Provides essential functionality with fewer commands
   - Primary location is in the root directory (`./ai-core`)
   - Copy also available in `.aicheck/scripts/ai-core`

## Basic Workflow

### Starting a Session

```bash
./ai start
```

This:

- Creates a new session
- Sets up a session file
- Prompts for project objectives if not defined

### Creating an Action

```bash
./ai new ActionName
```

This:

- Creates a new action directory
- Uses an action plan template
- Sets initial status and progress

### Switching Actions

```bash
./ai switch ActionName
```

This:

- Changes the active action
- Updates the current_action file

### Updating Status and Progress

```bash
./ai update-status ActionName "In Progress"
./ai update-progress ActionName "50%"
```

### Ending a Session

```bash
./ai end
```

This:

- Ends the current session
- Generates a summary context file

## Directory Structure

AICheck follows this directory structure:

```
/
├── ai                # Primary AICheck interface script (full command set)
├── ai-core           # Streamlined AICheck interface script
└── .aicheck/         # AICheck system
    ├── actions/      # Action-specific directories
    │   └── [ACTION_NAME]/
    │       ├── [ACTION_NAME]-PLAN.md
    │       └── supporting_docs/
    ├── cursor/       # Cursor-specific configurations
    ├── docs/         # AICheck-specific documentation
    ├── hooks/        # Git hooks
    ├── insights/     # AI-generated insights
    ├── sessions/     # AI session data
    ├── scripts/      # AICheck scripts
    │   ├── ai        # Copy of AICheck interface
    │   ├── ai-core   # Copy of streamlined interface
    │   └── ...       # Component scripts
    └── templates/    # Template files
```

## Advanced Commands

For a complete list of commands, run:

```bash
./ai help
```

## Path Handling

AICheck uses runtime path detection to ensure scripts work regardless of their location:

- Scripts determine their location relative to the repository
- Files are located using variables rather than hardcoded paths
- Main scripts work from both root and script directories

## References

- [Documentation Guidelines](documentation_guidelines.md)
- [RULES.md](../../RULES.md) - Core project rules
