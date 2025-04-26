# Approval System Issues

## Current Implementation Issues

1. **Missing Approval Prompts**
   - Switching ActiveAction doesn't show approval prompt
   - Creating new actions only shows prompt in AdminAudit mode
   - Modifying action plans doesn't show approval prompt
   - Template modifications don't show approval prompt

2. **Inconsistent Approval Requirements**
   - Some actions require approval based on plan file content
   - Others require approval based on AdminAudit mode
   - No consistent enforcement of RULES.md requirements

3. **Approval State Tracking**
   - No tracking of approval state
   - No expiration of approvals
   - No cleanup of old approvals

4. **Error Handling**
   - Error messages are inconsistent
   - Some errors don't provide clear next steps
   - Some errors don't log properly

## Required Changes

1. **Update check_human_manager_approval Function**
   - Always show approval for ActiveAction changes
   - Always show approval for new action creation
   - Always show approval for action plan modifications
   - Always show approval for template modifications
   - Add approval state tracking
   - Add approval expiration
   - Add approval cleanup

2. **Update Pre-commit Hook**
   - Add approval checks for critical files
   - Add approval checks for action plans
   - Add approval checks for templates
   - Improve error messages

3. **Add Approval State Management**
   - Create approval state storage
   - Add approval expiration logic
   - Add approval cleanup process
   - Add approval logging

## Test Cases to Add

1. **Approval State Tests**
   - Test approval storage
   - Test approval expiration
   - Test approval cleanup
   - Test approval logging

2. **Error Handling Tests**
   - Test rejection scenarios
   - Test invalid approvals
   - Test system state during errors
   - Test error messages

3. **Integration Tests**
   - Test approval flow with git operations
   - Test approval flow with action changes
   - Test approval flow with template changes
   - Test approval flow with critical file changes

## Next Steps

1. Update check_human_manager_approval function
2. Add approval state management
3. Update pre-commit hook
4. Add new test cases
5. Execute test cases
6. Document results
