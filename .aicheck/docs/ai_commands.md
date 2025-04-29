# AICheck Command Reference

## Overview

AICheck now provides two command interfaces:

1. **ai** - Full command set with all functionality (legacy)
2. **ai-core** - Streamlined command set with essential functionality

## Initial Setup vs. New Sessions

AICheck now distinguishes between:

- **Initial Setup**: When AICheck is first used with a project, presenting an introduction to the system
- **Regular Sessions**: Standard workflow for ongoing development

## Initial Setup Process

When you first run `./ai start` or `./ai-core start` on a new project:

1. A welcome message introduces AICheck
2. A ProductVision action is automatically created
3. Templates are loaded for:
   - Product vision document
   - Initialization guide with:
     - Recommended settings
     - Extension recommendations
     - Key AICheck commands
     - Standard actions

## Core Commands

The streamlined `ai-core` script provides these essential commands:

| Command | Description |
|---------|-------------|
| start | Start a new session |
| end | End the current session |
| new | Create a new action |
| switch | Switch to an existing action |
| list | List all actions with status |
| status | Show current action status |
| update | Update action status or progress |
| context | Generate context for Cursor chat |
| help | Show command help |

## Using ai-core

Example workflow:

```bash
# Start a session
./ai-core start

# Create a new action
./ai-core new MyAction

# Switch to an action
./ai-core switch MyAction

# Update action progress
./ai-core update progress MyAction 50%

# Update action status
./ai-core update status MyAction "In Progress"

# End session
./ai-core end
```

## Full Command Set

The original `ai` script still provides all commands, including:

- Documentation management (docs, add-doc, create-doc)
- Code creation (create-code)
- Security and audit functions (audit)
- Project summary (summary, view)
- And more

## Migration Recommendations

If you're already using AICheck:

1. Try the streamlined `ai-core` commands for day-to-day work
2. Use the full `ai` command set for specialized operations
3. When introducing new team members, have them run through the initial setup process
