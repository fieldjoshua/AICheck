# Contributing to AICheck

Thank you for your interest in contributing to AICheck! This document provides guidelines and instructions for contributing.

## Code of Conduct

By participating in this project, you agree to maintain a respectful and inclusive environment for everyone.

## How to Contribute

### 1. Fork and Clone

```bash
git clone https://github.com/your-username/AICheck.git
cd AICheck
```

### 2. Set Up Development Environment

```bash
# Create virtual environment
python -m venv .venv
source .venv/bin/activate  # Unix/macOS
# OR
.venv\Scripts\activate     # Windows

# Install development dependencies
pip install -r requirements.txt
```

### 3. Development Workflow

1. Create a new branch:

   ```bash
   git checkout -b feature/your-feature-name
   ```

2. Make your changes

3. Run tests:

   ```bash
   pytest
   ```

4. Format code:

   ```bash
   black .
   ```

5. Check types:

   ```bash
   mypy .
   ```

6. Lint code:

   ```bash
   flake8
   ```

### 4. Commit Guidelines

- Use clear, descriptive commit messages
- Reference issues and pull requests in commit messages
- Keep commits focused and atomic

### 5. Pull Request Process

1. Update documentation for any new features
2. Add tests for new functionality
3. Ensure all tests pass
4. Update the changelog
5. Submit a pull request

## Development Standards

### Code Style

- Follow PEP 8 guidelines
- Use type hints
- Write docstrings for all functions
- Keep functions small and focused

### Testing

- Write unit tests for new features
- Maintain test coverage
- Include both positive and negative test cases

### Documentation

- Update README.md for major changes
- Document new features
- Keep code comments clear and helpful

## Getting Help

- Open an issue for bugs
- Use discussions for questions
- Join our community chat

## License

By contributing, you agree that your contributions will be licensed under the project's MIT License.
