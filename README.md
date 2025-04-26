# AICheck

A powerful AI-powered development workflow management system that helps teams track, manage, and execute development tasks with AI assistance.

## Features

- **AI Session Management**: Create and manage AI-assisted development sessions
- **Action Tracking**: Track development actions with detailed status and progress
- **Context Awareness**: Maintain context across development sessions
- **Documentation Management**: Organize and track project documentation
- **Git Integration**: Seamless integration with Git repositories
- **Customizable Workflow**: Adaptable to different development methodologies

## Installation

1. Clone this repository:

```bash
git clone https://github.com/fieldjoshua/AICheck.git
cd AICheck
```

2. Make the script executable:

```bash
chmod +x aicheck.sh
```

3. Run the installer:

```bash
./aicheck.sh
```

## Usage

### Basic Commands

- Start a new AI session:

```bash
./ai start
```

- Generate a prompt template:

```bash
./ai prompt
```

- Check current status:

```bash
./ai status
```

- Update action status:

```bash
./ai update-status <action_name> <new_status>
```

### ActiveAction Management

For complete details on ActiveAction management, please refer to `RULES.md`. This is the authoritative source for all rules and guidelines, including:

- ActiveAction designation and tracking
- Action creation and management
- Status updates and progress tracking
- Documentation requirements
- Implementation guidelines

### Directory Structure

```
.aicheck/
├── actions/           # Action-specific directories
├── cursor/           # Cursor-specific configurations
├── docs/             # Documentation files
├── hooks/            # Git hooks
├── insights/         # AI-generated insights
├── sessions/         # AI session data
└── templates/        # Template files
```

## Configuration

The system uses several configuration files:

- `RULES.md`: Project rules and guidelines (controlling document)
- `.aicheck/docs/actions_index.md`: Action tracking and status
- `.aicheck/current_action`: ActiveAction tracking
- `.aicheck/current_session`: Current active session

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support, please open an issue in the GitHub repository.
