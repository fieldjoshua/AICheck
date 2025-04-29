# AICheck Documentation Guidelines

## Overview

This document explains how AICheck-specific documentation relates to the overall project documentation structure and provides guidelines for maintaining consistent documentation.

## Documentation Structure

AICheck documentation is organized into several key areas:

1. **Project-Level Documentation**
   - `README.md` - Project overview and getting started guide
   - `RULES.md` - Core project rules and guidelines
   - `CONTRIBUTING.md` - Contribution guidelines

2. **AICheck System Documentation**
   - `.aicheck/docs/actions_index.md` - Central index of all actions and their status
   - `.aicheck/docs/aicheck_usage.md` - Usage guide for AICheck commands
   - `.aicheck/docs/documentation_guidelines.md` - This file

3. **Action-Specific Documentation**
   - `.aicheck/actions/[ACTION_NAME]/[ACTION_NAME]-PLAN.md` - Action plan
   - `.aicheck/actions/[ACTION_NAME]/supporting_docs/` - Supporting documentation for actions

## Documentation Paths

All AICheck documentation should use relative paths determined at runtime to ensure scripts and documentation work regardless of their location in the repository. This means:

- Scripts should use the `$AICHECK_DIR` variable to locate files
- Documentation should use relative paths when linking to other documents

## Documentation Standards

When creating or updating documentation:

1. **Consistency**: Maintain consistent formatting and structure
2. **Accuracy**: Ensure all paths and commands are accurate
3. **Completeness**: Include all necessary information
4. **Clarity**: Write in clear, concise language
5. **Cross-linking**: Link related documents to improve discoverability

## Adding New Documentation

When adding new documentation:

1. **For action-specific documentation**:
   - Place in `.aicheck/actions/[ACTION_NAME]/supporting_docs/`
   - Add to the documentation index

2. **For system-wide documentation**:
   - Place in `.aicheck/docs/`
   - Update references to the new document

## Maintaining Documentation

Documentation maintenance should be:

1. **Regular**: Update documentation when changes are made
2. **Comprehensive**: Ensure all changes are documented
3. **Backward-compatible**: Maintain links and references

## References

- [GitHub Markdown Guide](https://guides.github.com/features/mastering-markdown/)
- [Documentation Best Practices](https://www.writethedocs.org/guide/writing/beginners-guide-to-docs/)
