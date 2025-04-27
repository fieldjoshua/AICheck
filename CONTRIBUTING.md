# Contributing to AICheck

Thank you for your interest in contributing to AICheck! Your help is appreciated.

## Onboarding for New Contributors

1. **Read the README.md and RULES.md** to understand the project structure, compliance requirements, and workflow.
2. **Clone the repository and set up your environment:**

   ```sh
   git clone https://github.com/fieldjoshua/AICheck.git
   cd AICheck
   chmod +x .aicheck/scripts/*.sh .aicheck/hooks/*
   chmod +x ai
   ./setup_aicheck.sh   # optional
   .aicheck/scripts/test_all.sh   # recommended: run all tests
   ```

3. **Familiarize yourself with the `ai` script** for all major operations (session, action, compliance, and audit).
4. **Review the action plan template** in `.aicheck/templates/action_plan_template.md` to ensure all new actions are compliant.

## How to Contribute

1. **Fork the repository**
2. **Create a new branch** for your feature or bugfix:

   ```sh
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes** and add tests as appropriate.
4. **Run the test suite** to ensure all tests pass:

   ```sh
   .aicheck/scripts/test_all.sh
   ```

5. **Commit your changes** with a clear message:

   ```sh
   git commit -am 'Add feature/fix: description'
   ```

6. **Push to your fork** and open a Pull Request (PR) against the `main` branch.

## Pull Request Checklist

- [ ] All new or modified actions use the compliant action plan template (Purpose, Value, Steps, Notes)
- [ ] Project objective is clearly defined and up to date
- [ ] All tests pass (`.aicheck/scripts/test_all.sh`)
- [ ] Pre-commit hook passes (if installed)
- [ ] Documentation is updated (README.md, CHANGELOG.md, etc.)
- [ ] Commit messages are clear and descriptive

## Code Style

- Use clear, descriptive commit messages.
- Keep shell scripts POSIX-compliant where possible.
- Use functions for modularity and reuse.
- Run [ShellCheck](https://www.shellcheck.net/) on all shell scripts before submitting.

## Reporting Issues

- Please use the GitHub Issues tab to report bugs or request features.
- Include as much detail as possible (steps to reproduce, environment, etc).

## Code of Conduct

- Be respectful and constructive in all interactions.
- See [Contributor Covenant](https://www.contributor-covenant.org/) for a standard code of conduct.

Thank you for helping make AICheck better!

## Development Standards

### Code Style

- Follow PEP 8 guidelines (for Python code)
- Use type hints
- Write docstrings for all functions
- Keep functions small and focused

### Testing

- Write unit tests for new features
- Maintain test coverage
- Include both positive and negative test cases
- Use `.aicheck/scripts/test_all.sh` to verify all workflows, compliance, and security

### Documentation

- Update README.md and CHANGELOG.md for major changes
- Document new features and workflows
- Keep code comments clear and helpful
- Ensure all documentation matches the current rules and templates

## Getting Help

- Open an issue for bugs
- Use discussions for questions
- Join our community chat

## License

By contributing, you agree that your contributions will be licensed under the project's MIT License.
