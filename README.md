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

## Installation

1. Clone the repository:

   ```sh

git clone <https://github.com/fieldjoshua/AICheck.git>
cd AICheck

```
2. Make all scripts executable:
   ```sh
chmod +x .aicheck/scripts/*.sh .aicheck/hooks/*
```

3. (Optional) Install pre-commit hook:

   ```sh

ln -sf ../../.aicheck/hooks/pre-commit .git/hooks/pre-commit

```

## Usage
- Run the full test suite:
  ```sh
  .aicheck/scripts/test_all.sh
  ```

- Manage actions:

  ```sh
  .aicheck/scripts/action.sh create <ActionName>
  .aicheck/scripts/action.sh status <ActionName>
  .aicheck/scripts/action.sh switch <ActionName>
  .aicheck/scripts/action.sh delete <ActionName>
  ```

- Style and security checks are run automatically on commit if the pre-commit hook is installed.

## Testing

Run all tests:

```sh
.aicheck/scripts/test_all.sh
```

## Contributing
Contributions are welcome! Please see `CONTRIBUTING.md` for guidelines.

## License
This project is licensed under the MIT License. See `LICENSE` for details.
