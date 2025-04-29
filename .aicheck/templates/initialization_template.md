# AICheck Initial Setup

## Product Vision Statement

{{PRODUCT_VISION}}

## Key Objectives

- {{OBJECTIVE_1}}
- {{OBJECTIVE_2}}
- {{OBJECTIVE_3}}

## Cursor Settings and Extensions

### Recommended Settings

```json
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.codeActionsOnSave": {
    "source.fixAll": true
  }
}
```

### Recommended Extensions

- Cursor AI Assistant
- ESLint
- Prettier
- Git Lens
- Code Spell Checker

## AICheck Commands

AICheck provides the following core commands:

| Command | Description |
|---------|-------------|
| ./ai start | Start a new session |
| ./ai end | End the current session |
| ./ai new ActionName | Create a new action |
| ./ai switch ActionName | Switch to an existing action |
| ./ai list | List all actions |
| ./ai status | Show current action status |
| ./ai catchup | Get project overview |

## Standard Actions

When setting up a new project, consider creating these standard actions:

1. **ProductVision** - Define the product vision, scope, and goals
2. **DevSetup** - Set up development environment and tools
3. **Documentation** - Create core documentation structure
4. **Testing** - Establish testing framework and strategy

## References

For complete documentation, refer to:

- [RULES.md](RULES.md) - Core project rules
- [README.md](README.md) - Project overview
