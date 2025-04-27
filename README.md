# AICheck

## Quick Start

1. **Clone and enter the repo:**

   ```sh
   git clone https://github.com/fieldjoshua/AICheck.git
   cd AICheck
   ```

2. **Make scripts executable:**

   ```sh
   chmod +x .aicheck/scripts/*.sh .aicheck/hooks/*
   chmod +x ai
   ```

3. **(Optional) Install pre-commit hook:**

   ```sh
   ln -sf ../../.aicheck/hooks/pre-commit .git/hooks/pre-commit
   ```

4. **(Recommended) Run all tests:**

   ```sh
   .aicheck/scripts/test_all.sh
   ```

5. **Start using AICheck:**

   ```sh
   ./ai start                # Start a session (define project objective if prompted)
   ./ai new MyAction         # Create a new action (compliant template)
   ./ai end                  # End session (auto-generates chat context)
   ```

---

AICheck is a modular, security-focused shell-based framework for managing, testing, and automating code quality and project workflows. It provides robust utilities for path validation, permission checks, secure logging, configuration encryption, and more.

## Features

- Secure path and permission validation
- Action and session management with compliance enforcement
- Automated project objective prompting and documentation
- Security event logging
- Config encryption/decryption
- Input sanitization
- Comprehensive, automated test suite
- Git pre-commit hook integration
- **Unified command interface via `ai` script**
- Automated session summary and chat context generation
- Action plan compliance checks

## Installation & Setup

1. **Clone the repository:**

   ```sh
   git clone https://github.com/fieldjoshua/AICheck.git
   cd AICheck
   ```

2. **Make all scripts executable:**

   ```sh
   chmod +x .aicheck/scripts/*.sh .aicheck/hooks/*
   chmod +x ai
   ```

3. **(Optional) Install pre-commit hook:**

   ```sh
   ln -sf ../../.aicheck/hooks/pre-commit .git/hooks/pre-commit
   ```

4. **(Optional) Run the setup script:**

   ```sh
   ./setup_aicheck.sh
   ```

5. **(Recommended) Run the full test suite:**

   ```sh
   .aicheck/scripts/test_all.sh
   ```

## Usage

- **Unified interface:** Use the `ai` script for all major operations:

  ```sh
  ./ai start                      # Start a new session (prompts for project objective if not set)
  ./ai new <ActionName>           # Create a new action (compliant template)
  ./ai switch <ActionName>        # Switch to an action
  ./ai status                     # Show status of current action
  ./ai update-status <Action> <Status>    # Update action status
  ./ai update-progress <Action> <Progress> # Update action progress
  ./ai commit "Commit message"    # Commit changes
  ./ai prompt                     # Generate a context prompt (purpose, value, steps)
  ./ai end                        # End session (auto-generates chat context, copies to clipboard, opens in editor)
  ./ai audit                      # Run compliance and audit checks
  ./ai catchup                    # Generate project overview for new editors
  ./ai update                     # Update AICheck to the latest version
  ./ai list                       # List all actions with status and progress
  ./ai view                       # View project objective
  ./ai summary                    # Show project summary and statistics 
  ./ai version                    # Show AICheck version information
  ./ai help                       # Show detailed help for all commands
  ./ai docs                       # Manage and view documentation index
  ./ai add-doc                    # Add supporting documentation to an action
  ./ai create-doc                 # Create a new documentation file
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
./ai end   # Ends session, generates chat context, ready for next session or chat
```

## Compliance & Automation Highlights

- **Session start** prompts for project objective if not set, ensuring clear project scope.
- **Action plans** use a standardized, compliant template (Purpose, Value, Steps, Notes).
- **Session end** auto-generates a summary context for chat, copies it to clipboard, and opens it in your editor.
- **Compliance checks** ensure all plans and documentation meet project rules.
- **Automated tests** cover all workflows, security, and compliance features.

## Contributing
Contributions are welcome! Please see `CONTRIBUTING.md` for guidelines.

## License
This project is licensed under the MIT License. See `LICENSE` for details.
