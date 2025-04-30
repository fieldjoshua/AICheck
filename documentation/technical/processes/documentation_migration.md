# Documentation Migration Checklist

This checklist provides a comprehensive guide for migrating process documentation (from an ACTION) to product documentation when an ACTION is completed.

## Pre-Migration Evaluation

- [ ] Review all documents in `.aicheck/actions/[ACTION_NAME]/supporting_docs/`
- [ ] Identify documents with enduring value beyond the ACTION lifecycle
- [ ] Determine appropriate target locations in `/documentation/[CATEGORY]/`
- [ ] Confirm that migration will not duplicate existing documentation

## Document Preparation

- [ ] Remove ACTION-specific terminology and replace with generalized terms
- [ ] Ensure technical accuracy and completeness
- [ ] Update references to other documents or code
- [ ] Add appropriate metadata:
  - [ ] Creation date
  - [ ] Last updated date
  - [ ] Origin (source ACTION)
  - [ ] Authors/contributors
  - [ ] Version number (if applicable)
- [ ] Format document according to AICheck documentation standards
- [ ] Review for sensitive information that should not be migrated

## Migration Process

- [ ] Create target directories if they don't exist
- [ ] Copy the prepared documents to appropriate `/documentation/[CATEGORY]/` locations
- [ ] Update internal links and references
- [ ] Add the document to relevant indices or tables of contents
- [ ] Note the migration in the ACTION completion record

## Post-Migration Verification

- [ ] Verify all links and references are correct
- [ ] Confirm document is in the correct location
- [ ] Test any referenced scripts or code snippets
- [ ] Update any existing documentation that refers to the migrated content
- [ ] Notify relevant team members about new/updated documentation

## Common Target Categories

Use this guide to determine the appropriate category for migrated documents:

| Content Type | Target Category |
|-------------|----------------|
| Architecture diagrams | `/documentation/architecture/` |
| API references | `/documentation/technical/` |
| User guides | `/documentation/public/` |
| Implementation details | `/documentation/implementation/` |
| Research findings | `/documentation/research/` |
| Deployment guides | `/documentation/operations/` |
| Configuration instructions | `/documentation/configuration/` |
| Status reports | `/documentation/status_updates/` |
| Completion records | `/documentation/deliverables/` |

## Migration Command

The AICheck system provides a built-in command to assist with documentation migration:

```bash
./ai migrate-docs [ACTION_NAME] [SOURCE_DOC] [TARGET_CATEGORY]
```

Example:

```bash
./ai migrate-docs AuthImplementation auth-architecture.md architecture
```

This command will:

1. Prompt for confirmation of the migration
2. Assist with document preparation
3. Copy the document to the appropriate location
4. Update the ACTION record
