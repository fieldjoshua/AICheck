# AICheck Development Rules

This document serves as the controlling reference for all development work managed by the AICheck system.

## ⚠️ CRITICAL: AI Editor Guidelines ⚠️

### Pre-Approval Scope

AI editors DO NOT need to ask for approval for any work that:

1. Complies with the rules in this document
2. Falls within the scope of the ActiveAction
3. Follows established patterns and conventions
4. Maintains code quality standards

### Direct Implementation Allowed For

- Code that implements the ActiveAction plan
- Documentation updates related to the ActiveAction
- Bug fixes within the ActiveAction scope
- Tests for ActiveAction functionality
- Refactoring within the ActiveAction scope

### ⚠️ REQUIRES HUMAN MANAGER APPROVAL ⚠️

The following actions ALWAYS require explicit human manager approval:

1. Changing the ActiveAction
2. Creating a new Action
3. Making substantive changes to any Action
4. Modifying any Action Plan
5. Creating or modifying Templates

These changes must be approved before implementation, regardless of other rules.

## Core Principles

### 1. Documentation First

- All Actions must be documented before implementation
- Documentation must be kept up to date
- Changes must be reflected in relevant docs
- Supporting documentation must be maintained

### 2. Single Action Focus

- Work on one Action at a time
- Document context switches explicitly
- Complete or pause ActiveAction before switching
- Maintain clear Action boundaries

### 3. Structured Development

- Follow the AICheck directory structure
- Use provided templates
- Maintain consistent file organization
- Follow naming conventions

### 4. Regular Status Updates

- Update action status promptly
- Document progress clearly
- Report blockers immediately
- Keep action index current

### 5. Code Quality Standards

- Follow language-specific best practices
- Maintain consistent formatting
- Write clear, documented code
- Include appropriate tests

## Action Management

### Action Creation and Documentation

1. Create action directory in `.aicheck/actions/`
2. Create action plan using template
3. Add to actions index
4. Set initial status
5. Create supporting docs directory

Required documentation for each action:

- Action plan (PLAN.md)
- Supporting documentation
- Status updates
- Progress tracking

### Action Status

Valid statuses:

- Not Started: Action is planned but not begun
- ActiveAction: Action is the sole Action being worked on and is controlling
- Completed: Action is finished and verified
- Blocked: Action is blocked by dependencies
- On Hold: Any work on an Action is temporarily paused

## Directory Structure

```
.aicheck/
├── actions/           # Action-specific directories
│   └── [ACTION_NAME]/
│       ├── [ACTION_NAME]-PLAN.md
│       └── supporting_docs/
├── cursor/           # Cursor-specific configurations
├── docs/             # Documentation files
├── hooks/            # Git hooks
├── insights/         # AI-generated insights
├── sessions/         # AI session data
└── templates/        # Template files
```

## Reference Paths

### Critical Files

- `RULES.md`: This document (controlling reference)
- `.aicheck/docs/actions_index.md`: Action tracking
- `.aicheck/current_action`: ActiveAction tracking
- `.aicheck/current_session`: Current session tracking

### Action Files

- `.aicheck/actions/[ACTION_NAME]/[ACTION_NAME]-PLAN.md`
- `.aicheck/actions/[ACTION_NAME]/supporting_docs/`

## Workflow Requirements

### Session and Action Management

1. Start every development session with `./ai start`
2. Check ActiveAction with `./ai status`
3. Generate prompts with `./ai prompt`
4. End sessions with meaningful summaries

Action Management:

1. Create new Actions with `./ai new ActionName`
2. Update status with `./ai update-status`
3. Review insights with `./ai insights`
4. Create audits with `./ai audit`

### AI Editor Checks

1. Use `./ai check!` to verify context
2. Review RULES.md compliance
3. Confirm ActiveAction scope
4. Check supporting documentation

## Compliance and Implementation

### Required Reviews

Before starting work, AI editors must confirm:

1. ActiveAction plan review
2. RULES.md compliance
3. ActiveAction scope
4. Supporting documentation

During implementation:

1. Follow ActiveAction plan
2. Maintain documentation
3. Update status regularly
4. Report issues promptly

## Administrative Tasks

### Audit Requirements

Regular audits should check:

1. Documentation completeness
2. Action status accuracy
3. Code quality standards
4. RULES.md compliance

### Backup Procedures

1. Regular system backups
2. Action state preservation
3. Session history maintenance
4. Configuration backups

## Style Requirements

### Documentation Style

1. **Markdown Formatting**
   - Use ATX-style headers (# for h1, ## for h2, etc.)
   - Use fenced code blocks with language specification
   - Use bullet points for lists
   - Use bold for emphasis, not italics

2. **File Naming**
   - Use PascalCase for Action names
   - Use kebab-case for file names
   - Use .md extension for documentation
   - Use -PLAN.md suffix for action plans

3. **Code Style**
   - Follow language-specific style guides
   - Use consistent indentation (4 spaces)
   - Include appropriate comments
   - Follow naming conventions

4. **Directory Structure**
   - Use lowercase for directory names
   - Use descriptive names
   - Follow established hierarchy
   - Maintain consistent organization

5. **Commit Messages**
   - Use present tense
   - Start with a verb
   - Keep under 50 characters
   - Include action reference

6. **Status Updates**
   - Use predefined status values
   - Include progress percentage
   - Document blockers clearly
   - Update timestamps

7. **Error Messages**
   - Be clear and specific
   - Include error codes
   - Provide resolution steps
   - Log appropriately

## Last Updated

Date: $(date +"%Y-%m-%d")
Version: 1.0.0
