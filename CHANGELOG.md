# Changelog

All notable changes to AICheck will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Initial public release
- Directory styling with purple color scheme
- Pre-commit hook system
- Action management system
- Test infrastructure
- Installation guide
- Contributing guidelines
- Documentation detection hook to automatically track action-specific documentation
- Comprehensive tests for documentation detection hook

### Changed

- Improved documentation structure
- Enhanced error handling
- Updated dependency versions

### Fixed

- Directory structure cleanup
- Git hook permissions
- Shell integration issues

## [0.1.0] - 2024-04-26

### Added

- Basic project structure
- Core functionality
- Initial documentation

## [1.0.0] - 2024-04-27

### Added

- Full compliance with project rules and documentation-first workflow
- Automated project objective prompting at session start
- Standardized, compliant action plan template (Purpose, Value, Steps, Notes)
- Automated session summary and chat context generation at session end (clipboard + editor)
- Action plan compliance check and audit command
- Unified prompt generation (purpose, value, steps)
- Expanded and automated test suite covering all workflows, compliance, and security
- Clipboard and editor automation for chat context handoff

### Changed

- Improved README with step-by-step installation and usage guide
- Enhanced session and action management scripts for compliance and automation
- Security utilities now enforce path and permission validation

### Fixed

- All security, compliance, and workflow tests now pass
- Pre-commit and test scripts fully integrated
