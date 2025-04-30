# AICheck Documentation

This directory contains the centralized documentation for the AICheck project. Documentation is organized by category to ensure information is easy to find and maintain.

## Documentation Types

AICheck defines two main types of documentation:

1. **Process Documentation**
   - Temporary documents relevant only during an ACTION's lifecycle
   - Stored in `.aicheck/actions/[ACTION_NAME]/supporting_docs/`
   - Includes implementation notes, research, and action-specific planning

2. **Product Documentation**
   - Enduring documents with relevance beyond an ACTION's completion
   - Stored in `/documentation/[CATEGORY]/`
   - Provides lasting value to the project and its users

## Directory Structure

```
/documentation/
├── technical/     # Technical implementation details
├── public/        # User-facing documentation
├── planning/      # Strategic planning documents
├── vision/        # High-level vision documents
├── architecture/  # System design documents
├── research/      # Background research
├── operations/    # Deployment & operations
├── implementation/# Implementation details
├── deliverables/  # Completion records
├── status_updates/# Periodic status reports
├── legal/         # Legal documents
└── configuration/ # Configuration documentation
```

## Documentation Migration Process

When an ACTION is completed, process documentation with enduring value must be migrated to the appropriate product documentation directory.

### Migration Steps

1. Evaluate all documentation for enduring value
2. Prepare documents for migration:
   - Update ACTION-specific terminology
   - Ensure completeness and accuracy
   - Add appropriate metadata
3. Move relevant documents to appropriate `/documentation/` subdirectories
4. Update references and documentation indexes
5. Note migrations in the ACTION completion record

For the complete migration checklist, see [Documentation Migration Checklist](technical/processes/documentation_migration.md).
