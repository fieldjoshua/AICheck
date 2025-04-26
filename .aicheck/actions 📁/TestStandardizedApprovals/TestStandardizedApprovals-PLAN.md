# TestStandardizedApprovals

## Overview

Test and validate the standardized approval system in AICheck, ensuring all required approvals are properly enforced and documented.

## Status

Status: Not Started

## Created

Created: 2025-04-26

## Last Updated

Last Updated: 2025-04-26

## Description

This action will test the approval system to ensure:

1. All required approvals are properly enforced
2. Approval prompts are consistent and clear
3. Approval state is properly tracked
4. Changes requiring approval are properly blocked until approved
5. The system maintains proper documentation of approvals

## Requirements

1. Test all approval-requiring actions:
   - Changing ActiveAction
   - Creating new Actions
   - Making substantive changes to Actions
   - Modifying Action Plans
   - Creating/modifying Templates
2. Verify approval prompts are:
   - Clear and informative
   - Consistent across all commands
   - Properly documented
3. Test approval state tracking:
   - Proper storage of approval state
   - Correct handling of approval expiration
   - Proper cleanup of old approvals
4. Test approval enforcement:
   - Changes are blocked without approval
   - Changes proceed with approval
   - Proper error messages for rejected changes

## Implementation Plan

1. Test ActiveAction Changes
   - Test switching to existing action
   - Test creating new action
   - Verify approval requirements
   - Check error handling

2. Test Action Modifications
   - Test substantive changes to actions
   - Test action plan modifications
   - Verify approval requirements
   - Check error handling

3. Test Template Management
   - Test template creation
   - Test template modification
   - Verify approval requirements
   - Check error handling

4. Test Approval State
   - Test approval storage
   - Test approval expiration
   - Test approval cleanup
   - Verify state consistency

5. Test Error Handling
   - Test rejection scenarios
   - Test invalid approvals
   - Test system state during errors
   - Verify error messages

## Notes

- All tests should be documented in supporting_docs
- Each test should include expected and actual results
- Any issues found should be documented with steps to reproduce
- Test results should be tracked in the action's progress

## Files in Scope

- .aicheck/scripts/action.sh
- .aicheck/scripts/common.sh
- .aicheck/hooks/pre-commit
- .aicheck/docs/actions_index.md
- All action plan files
- All template files
