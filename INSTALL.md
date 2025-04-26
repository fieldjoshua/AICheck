# AICheck Installation Guide

This guide provides detailed instructions for installing and configuring AICheck on your system.

## Prerequisites

- Git
- Bash or Zsh shell
- Python 3.8 or higher
- pip (Python package manager)

## Installation Steps

### 1. Clone the Repository

```bash
git clone https://github.com/fieldjoshua/AICheck.git
cd AICheck
```

### 2. Set Up the Environment

#### 2.1 Create a Python Virtual Environment (Recommended)

```bash
python -m venv .venv
source .venv/bin/activate  # On Unix/macOS
# OR
.venv\Scripts\activate     # On Windows
```

#### 2.2 Install Dependencies

```bash
pip install -r requirements.txt
```

### 3. Configure AICheck

#### 3.1 Set Up Directory Structure

The installer will create the following structure in your project:

```
.aicheck/
├── actions/     # Action management
├── docs/        # Documentation
├── hooks/       # Git hooks
├── insights/    # AI insights
├── scripts/     # Utility scripts
├── sessions/    # Session data
└── templates/   # Templates
```

#### 3.2 Install Git Hooks

```bash
chmod +x .aicheck/hooks/pre-commit
git config core.hooksPath .aicheck/hooks
```

#### 3.3 Configure Shell Integration

Add the following line to your shell configuration file:

For Bash (~/.bashrc):

```bash
echo 'source ~/.aicheck/scripts/aicheck_style.sh' >> ~/.bashrc
```

For Zsh (~/.zshrc):

```bash
echo 'source ~/.aicheck/scripts/aicheck_style.sh' >> ~/.zshrc
```

### 4. Verify Installation

Run the following commands to verify your installation:

```bash
# Test the pre-commit hook
.aicheck/scripts/test_pre_commit.sh

# Check directory styling
ls -la .aicheck/  # Directories should appear in purple
```

### 5. First-Time Setup

1. Create your first action:

```bash
./ai create-action MyFirstAction
```

2. Check the status:

```bash
./ai status
```

## Troubleshooting

### Common Issues

1. **Purple Directory Styling Not Working**
   - Make sure you've added the source line to your shell config
   - Try restarting your terminal

2. **Pre-commit Hook Not Running**
   - Verify hooks path: `git config core.hooksPath`
   - Check hook permissions: `ls -l .aicheck/hooks/pre-commit`

3. **Permission Denied**
   - Run: `chmod +x aicheck.sh`
   - Run: `chmod +x .aicheck/scripts/*.sh`

### Getting Help

If you encounter any issues:

1. Check the error logs in `.aicheck/error.log`
2. Consult the documentation in `.aicheck/docs/`
3. Open an issue on GitHub

## Updating AICheck

To update to the latest version:

```bash
git pull origin main
./ai update
```

## Next Steps

- Read the [README.md](README.md) for usage instructions
- Review [RULES.md](RULES.md) for project guidelines
- Create your first action and start managing your development workflow
