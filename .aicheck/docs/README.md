# AICheck Documentation

<p align="center">
  <img src="../assets/AICheck.png" alt="AICheck Logo" width="250">
</p>

## Documentation Overview

This directory contains the documentation for the AICheck system. Documentation is organized as follows:

- **Project-level documentation**: Found in the root directory (`TESTING.md`, `README.md`)
- **Action-specific documentation**: Located in each action's `supporting_docs` directory
- **Documentation index**: Maintained in `documentation_index.md` for easy lookup

All documentation files in action directories are automatically backed up to `.aicheck/docs/backup` to prevent accidental loss.

## Using the Documentation System

Documentation can be managed using the `ai docs` command:

```sh
./ai docs list               # List all documentation
./ai docs add                # Add a document to the index
./ai docs search <keyword>   # Search documentation for keywords
```

When new markdown files are added to action directories, the pre-commit hook will automatically:

1. Create a backup copy in `.aicheck/docs/backup`
2. Alert you about the new documentation
3. Offer to add it to the documentation index

## Documentation Backup System

All documentation files are automatically backed up to `.aicheck/docs/backup/<action_name>/` directory whenever:

- A new documentation file is committed
- The `./ai docs` command is used
- The `.aicheck/scripts/doc_detection_hook.sh --scan-all` command is run

This ensures documentation is preserved even if original files are accidentally modified or deleted.
