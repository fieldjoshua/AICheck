# AICheck

AICheck is a modular, security-focused shell-based framework for managing, testing, and automating code quality and project workflows. It provides robust utilities for path validation, permission checks, secure logging, configuration encryption, and more.

## Features

- Secure path and permission validation
- Action and session management
- Security event logging
- Config encryption/decryption
- Input sanitization
- Comprehensive test suite
- Git pre-commit hook integration
- **Unified command interface via `ai` script**

## Installation

1. Clone the repository:

   ```sh
   git clone https://github.com/fieldjoshua/AICheck.git
   cd AICheck
   ```

2. Make all scripts executable:

   ```sh
   chmod +x .aicheck/scripts/*.sh .aicheck/hooks/*
   chmod +x ai
   ```

3. (Optional) Install pre-commit hook:

   ```sh
   ln -sf ../../.aicheck/hooks/pre-commit .git/hooks/pre-commit
   ```

4. (Optional) Run the setup script:

   ```sh
   ./setup_aicheck.sh
   ```

## Usage

- **Unified interface:** Use the `ai` script for all major operations:

  ```sh
  ./ai start                      # Start a new session
  ./ai new <ActionName>           # Create a new action
  ./ai switch <ActionName>        # Switch to an action
  ./ai status                     # Show status of current action
  ./ai update-status <Action> <Status>    # Update action status
  ./ai update-progress <Action> <Progress> # Update action progress
  ./ai commit "Commit message"    # Commit changes
  ```

- **Run the full test suite:**
  ```sh
  .aicheck/scripts/test_all.sh
  ```

- **Style and security checks** are run automatically on commit if the pre-commit hook is installed.

## Example Workflow

```sh
./ai start
./ai new FeatureX
./ai switch FeatureX
./ai update-status FeatureX "In Progress"
./ai update-progress FeatureX "50%"
./ai commit "Started FeatureX and updated progress"
```

## Contributing
Contributions are welcome! Please see `CONTRIBUTING.md` for guidelines.

## License
This project is licensed under the MIT License. See `LICENSE` for details.
