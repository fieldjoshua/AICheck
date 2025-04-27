# Documentation Management in AICheck

This document explains the documentation management features in AICheck, including the documentation detection hook and related commands.

## Documentation Index

AICheck maintains a centralized documentation index at `.aicheck/docs/documentation_index.md` to improve discoverability of all documentation across actions. This index contains links to documentation files with their descriptions, making it easy to find relevant documentation.

## Documentation Detection Hook

The documentation detection hook (`.aicheck/scripts/doc_detection_hook.sh`) is a pre-commit hook that automatically detects when new documentation files are added to action directories and offers to add them to the documentation index.

### How It Works

1. When you stage a new Markdown file in an action's `supporting_docs` directory for commit, the hook detects it during the pre-commit process.
2. The hook prompts you asking if you want to add the document to the documentation index.
3. If you select "yes", you'll be asked to provide a brief description for the document.
4. The document is then automatically added to the documentation index with proper formatting and linking.
5. If you select "no", the document won't be added to the index, but you can always add it later manually.

### Benefits

- Ensures all documentation is discoverable through the centralized index
- Automates the process of updating the documentation index
- Maintains consistent documentation structure and organization
- Reduces risk of "lost" or forgotten documentation

## Documentation Commands

AICheck provides several commands to manage documentation:

### View Documentation Index

```sh
./ai docs list
```

### Add Document to Index Manually

```sh
./ai docs add <ActionName> "Document Name" "path/to/document" "Brief description"
```

### Search Documentation

```sh
./ai docs find <search_term>
```

### Create a New Documentation File

```sh
./ai create-doc <file_path> ["Document Title"]
```

### Add Supporting Documentation to an Action

```sh
./ai add-doc <ActionName> "Document Title" [file_path]
```

## Testing Documentation Features

AICheck includes comprehensive tests for the documentation detection hook and related features. These tests can be found in the following files:

- `test_doc_detection.sh`: Basic test for documentation detection
- `test_doc_detection_full.sh`: Comprehensive test suite covering all documentation detection scenarios
- `test_doc_detection_updated.sh`: Updated test implementation for integration with the main test suite

The tests verify:

1. Document detection when new markdown files are added
2. The prompt to add detected documents to the documentation index
3. Adding documents when answering "yes" to the prompt
4. Not adding documents when answering "no" to the prompt
5. Manual addition of documents using the `./ai docs add` command

To run the documentation tests:

```sh
./test_doc_detection_full.sh
```

## Best Practices

1. **Use Action-Specific Directories**: Always store documentation in the appropriate action's `supporting_docs` directory.
2. **Descriptive Titles**: Use clear, descriptive titles for documents that indicate their content.
3. **Detailed Descriptions**: Provide informative descriptions when adding documents to the index.
4. **Consistent Format**: Follow Markdown formatting conventions for documentation files.
5. **Regular Updates**: Keep documentation updated as the project evolves.
