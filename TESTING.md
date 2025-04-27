# AICheck Testing Procedure

This document outlines the testing procedure for AICheck. Each test should be performed in sequence to ensure system integrity.

## 1. Basic System Tests

### 1.1 Installation

```bash
# Test fresh installation
./aicheck.sh

# Verify directory structure
ls -la .aicheck/

# Check file permissions
ls -l .aicheck/scripts/
ls -l .aicheck/hooks/
```

### 1.2 Git Integration

```bash
# Test pre-commit hook
git add .
git commit -m "test: testing pre-commit hook"

# Verify hook enforcement
# Try to modify critical files
# Try to make changes outside ActiveAction scope
```

## 2. Action Management Tests

### 2.1 Action Creation

```bash
# Test new action creation
./ai new TestAction1

# Verify:
# - Action directory created
# - Plan file created
# - Added to actions index
# - Set as ActiveAction
```

### 2.2 Action Switching

```bash
# Create another action
./ai new TestAction2

# Switch between actions
./ai switch TestAction1
./ai switch TestAction2

# Verify:
# - ActiveAction updates correctly
# - Status shows correct action
```

### 2.3 Status Updates

```bash
# Test status updates
./ai update-status TestAction1 Not Started
./ai update-status TestAction1 ActiveAction
./ai update-status TestAction1 Blocked
./ai update-status TestAction1 On Hold
./ai update-status TestAction1 Completed

# Verify:
# - Status changes in index
# - Progress updates correctly
# - Human manager approval when required
```

### 2.4 Progress Updates

```bash
# Test progress updates
./ai update-progress TestAction1 25%
./ai update-progress TestAction1 50%
./ai update-progress TestAction1 75%
./ai update-progress TestAction1 100%

# Verify:
# - Progress updates in index
# - Progress validation (0-100%)
```

## 3. Administrative Tests

### 3.1 Audit Creation

```bash
# Test audit functionality
./ai audit

# Verify:
# - AdminAudit action exists or is created
# - Set as ActiveAction
# - Plan file exists
# - Human manager approval required
```

### 3.2 Admin Mode

```bash
# Test admin mode
./ai admin

# Verify:
# - Switches to AdminAudit action
# - Maintains single AdminAudit instance
# - Preserves audit history
# - Human manager approval required
```

### 3.3 Session Management

```bash
# Test session creation
./ai start

# Verify:
# - Session created
# - Context file created
# - Session ID generated
```

### 3.4 Prompt Generation

```bash
# Test prompt generation
./ai prompt

# Verify:
# - Prompt template created
# - Context included
# - ActiveAction referenced
```

## 4. Compliance Tests

### 4.1 RULES.md Enforcement

```bash
# Test rule enforcement
# Try to:
# - Modify RULES.md without approval
# - Create action without approval
# - Switch action without approval
# - Update status without approval
```

### 4.2 Scope Enforcement

```bash
# Test scope enforcement
# Try to:
# - Modify files outside ActiveAction scope
# - Create files outside ActiveAction scope
# - Commit changes outside ActiveAction scope
```

## 5. Error Handling Tests

### 5.1 Invalid Inputs

```bash
# Test invalid inputs
./ai new "Invalid Action Name"
./ai update-status "NonExistentAction" "Invalid Status"
./ai update-progress "NonExistentAction" 150%

# Verify:
# - Proper error messages
# - System state maintained
# - No partial changes
```

### 5.2 File System Errors

```bash
# Test file system errors
# Try to:
# - Create action in read-only directory
# - Modify files without permissions
# - Delete critical files
```

## 6. Integration Tests

### 6.1 Git Integration

```bash
# Test git integration
git init
git add .
git commit -m "Initial commit"

# Verify:
# - Pre-commit hook works
# - Status tracking works
# - Action history maintained
```

### 6.2 Editor Integration

```bash
# Test editor integration
# Verify:
# - Files open in editor when available
# - Templates are properly formatted
# - Documentation is readable
```

### 6.3 Documentation Detection Hook

```bash
# Test documentation detection hook
# Create a new action
./ai new TestDocAction

# Create a new markdown file in the supporting_docs directory
mkdir -p .aicheck/actions/TestDocAction/supporting_docs
echo "# Test Document" > .aicheck/actions/TestDocAction/supporting_docs/test-document.md

# Stage the new file
git add .aicheck/actions/TestDocAction/supporting_docs/test-document.md

# Attempt to commit (should trigger doc_detection_hook.sh)
git commit -m "test: add test document"

# Verify:
# - Hook detects the new document
# - Displays the mandatory documentation alert
# - Creates a backup copy in .aicheck/docs/backup
# - Prompts to add to documentation index (indexing is optional)
# - Document is added to index when 'y' is selected using default description
# - Check documentation_index.md for the new entry
# - Both backup file and index are included in the commit

# Test rejection scenario
./ai new TestDocAction2

# Create another markdown file
mkdir -p .aicheck/actions/TestDocAction2/supporting_docs
echo "# Test Document 2" > .aicheck/actions/TestDocAction2/supporting_docs/test-document-2.md

# Stage the new file
git add .aicheck/actions/TestDocAction2/supporting_docs/test-document-2.md

# Attempt to commit (should trigger doc_detection_hook.sh again)
# Select 'n' when prompted
git commit -m "test: add second test document"

# Verify:
# - Hook detects the new document
# - Displays the mandatory documentation alert
# - Creates a backup copy in .aicheck/docs/backup
# - Prompts to add to documentation index
# - Document is NOT added to index when 'n' is selected
# - Check backup directory to confirm document was backed up
# - Backup file is included in the commit
# - Document can still be added manually later using './ai docs add'

# Test manual document addition
# Add the document manually to the index
./ai docs add "TestDocAction2" "Test Document 2" ".aicheck/actions/TestDocAction2/supporting_docs/test-document-2.md" "Manually added test document"

# Verify:
# - Document is properly added to the index
# - New entry appears in documentation_index.md
# - Correct formatting of the entry in the index

# Test bulk documentation scanning
# Run the detection hook with the scan-all option
.aicheck/scripts/doc_detection_hook.sh --scan-all

# Verify:
# - All documentation files are detected
# - All files are backed up to .aicheck/docs/backup
# - Files not in the index are identified
# - Option to add all detected files to the index
# - Default descriptions are used without prompting
```

### 6.4 Documentation Backup System

```bash
# Test documentation backup system
# Create a new markdown file
mkdir -p .aicheck/actions/BackupTestAction/supporting_docs
echo "# Backup Test Document" > .aicheck/actions/BackupTestAction/supporting_docs/backup-test.md

# Stage and commit
git add .aicheck/actions/BackupTestAction/supporting_docs/backup-test.md
git commit -m "test: add document for backup testing"

# Verify backup was created
ls -la .aicheck/docs/backup/BackupTestAction/

# Test backup integrity by modifying the original file
echo "Modified content" > .aicheck/actions/BackupTestAction/supporting_docs/backup-test.md

# Verify the backup remains unchanged
cat .aicheck/docs/backup/BackupTestAction/backup-test.md

# Test backup during scan-all operation
.aicheck/scripts/doc_detection_hook.sh --scan-all

# Verify all documentation is backed up
find .aicheck/docs/backup -type f | wc -l
find .aicheck/actions -path "*/supporting_docs/*.md" -type f | wc -l
```

## 7. Performance Tests

### 7.1 Large Scale

```bash
# Test with many actions
# Create 10+ actions
# Switch between them
# Update statuses
# Update progress

# Verify:
# - System remains responsive
# - Index updates quickly
# - Status checks are fast
```

### 7.2 Concurrent Operations

```bash
# Test concurrent operations
# Try to:
# - Create multiple actions simultaneously
# - Update statuses simultaneously
# - Switch actions rapidly
```

## 8. Recovery Tests

### 8.1 Backup/Restore

```bash
# Test backup/restore
# Create backup
# Make changes
# Restore from backup

# Verify:
# - All files restored
# - State maintained
# - No data loss
```

### 8.2 Error Recovery

```bash
# Test error recovery
# Simulate failures
# Check system state
# Verify recovery
```

## Test Results

For each test:

1. Document the expected behavior
2. Record the actual behavior
3. Note any discrepancies
4. Document any issues found
5. Track resolution status

## Test Environment

- OS: [Your OS]
- Shell: [Your Shell]
- Git Version: [Git Version]
- AICheck Version: [Version]

## Notes

- Run tests in sequence
- Document all results
- Report issues immediately
- Verify fixes
- Update tests as needed
