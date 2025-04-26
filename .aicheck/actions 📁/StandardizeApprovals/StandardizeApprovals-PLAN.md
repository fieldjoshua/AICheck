# StandardizeApprovals

## Overview
Standardize the human manager approval process across all commands and hooks in the AICheck system.

## Status
Status: ActiveAction

## Created
Created: 2025-04-26

## Last Updated
Last Updated: 2025-04-26

## Description
This action standardizes how human manager approvals work across the AICheck system:

1. Move approval process to happen before git operations
2. Update commit_changes function to check for approval before staging
3. Move common functions to action.sh
4. Update pre-commit hook to use shared functions
5. Ensure consistent approval messaging and behavior

## Requirements

- System-wide access to modify core files
- Permission to update git hooks
- Ability to modify action scripts
- Documentation management

## Implementation Plan

1. Update action.sh script to standardize approval prompts
2. Update pre-commit hook to handle action plan files and AdminAudit mode correctly
3. Update documentation to reflect changes
4. Test all approval scenarios

## Notes

This action is focused on standardizing the approval process across the system. All changes are within the scope of this action.

## Files in Scope

- `.aicheck/scripts/action.sh`
- `.aicheck/scripts/common.sh`
- `.aicheck/hooks/pre-commit`
- `.aicheck/actions/AdminAudit/AdminAudit-PLAN.md`
- `.aicheck/docs/actions_index.md`
- `.aicheck/current_action`
- `.aicheck/actions/TestApproval/TestApproval-PLAN.md`
- `.aicheck/actions/TestNewAction/TestNewAction-PLAN.md`
- `.aicheck/actions/StandardizeApprovals/StandardizeApprovals-PLAN.md`
- `RULES.md`
- `TESTING.md`
- `ai`
- `aicheck.sh`
- `test_sounds.sh`
