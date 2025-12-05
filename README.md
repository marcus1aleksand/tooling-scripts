# 🛠️ Tooling Setup Script

Automated macOS development environment setup script that intelligently
installs and updates essential tools, applications, and CLI utilities
using Homebrew.

## ✨ Features

- 🔍 **Smart Installation**: Checks for existing installations before proceeding
- ⬆️ **Auto-Update**: Automatically updates packages to their latest versions
- 🎨 **Color-Coded Output**: Clear visual feedback for all operations
- 🎯 **Interactive IDE Selection**: Choose between VS Code, Cursor, or both
- ⚙️ **Git Configuration**: Prompts for git username and email setup
- 🐚 **Shell Aliases**: Automatically configures useful Kubernetes aliases
- 📦 **Optional Apps**: Choose whether to install Grammarly and other optional tools

## 📋 Prerequisites

- **macOS 10.10 Yosemite or higher**
- **Internet connection**
- **Admin privileges** (for installation)

> **Note**: Homebrew will be installed automatically if not present

## 📦 Installed Applications

### GUI Applications (Casks)

| Application | Purpose |
|------------|---------|
| **iTerm2** | Advanced terminal emulator |
| **Docker** | Container platform |
| **VS Code / Cursor** | Code editors (choice-based) |
| **Google Chrome** | Web browser |
| **Firefox** | Web browser |
| **Zoom** | Video conferencing |
| **Slack** | Team communication |
| **Evernote** | Note-taking |
| **CotEditor** | Plain text editor |
| **OneDrive** | Cloud storage |
| **WhatsApp** | Messaging |
| **Bitwarden** | Password manager |
| **Krisp** | Noise cancellation |
| **Clipy** | Clipboard manager |
| **Grammarly** | Writing assistant (optional) |

### CLI Tools (Formulas)

#### Development Tools

- `git` - Version control
- `go` - Go programming language
- `python` - Python programming language
- `black` - Python code formatter
- `pre-commit` - Git hook framework
- `bats-core` - Bash testing framework

#### DevOps & Cloud Tools

- `terraform` - Infrastructure as Code
- `helm` - Kubernetes package manager
- `kubernetes-cli` (kubectl) - Kubernetes command-line
- `k9s` - Kubernetes TUI
- `azure-cli` - Azure CLI
- `awscli` - AWS CLI
- `google-cloud-sdk` - Google Cloud CLI
- `argocd` - GitOps CD tool

#### Utilities

- `jq` - JSON processor
- `yq` - YAML processor
- `zsh` - Z shell
- `mkdocs` - Documentation generator
- `mas` - Mac App Store CLI

## 🚀 Usage

### Basic Installation

```bash
# Make the script executable
chmod +x tooling_setup.sh

# Run the script
./tooling_setup.sh
```

### What to Expect

The script will:

1. **Check Homebrew** - Install if missing, update if present
2. **Display Progress** - Show color-coded status for each operation
3. **Install GUI Apps** - Install or update all GUI applications
4. **IDE Selection** - Prompt you to choose your preferred IDE(s)
5. **Install CLI Tools** - Install or update all command-line tools
6. **Configure Git** - Ask for username and email (skip if already configured)
7. **Install Oh My Zsh** - Install if not present
8. **Optional Apps** - Ask about Grammarly and other optional installations
9. **Set Up Aliases** - Configure helpful shell aliases
10. **Clean Up** - Run Homebrew cleanup
11. **Summary** - Display installation summary

## ⚙️ Configuration

### Git Configuration

The script will prompt for:

- **Git Username**: Your display name for commits
- **Git Email**: Email address for commits

If already configured, you can choose to keep existing settings.

### Shell Aliases

The following aliases are automatically added:

```bash
# Kubernetes shortcuts
alias k="kubectl"
alias ctx="kubectx"
alias pf-argocd="kubectl port-forward svc/argocd-server -n argocd 8082:443"
```

## 📝 Interactive Prompts

### IDE Selection

```text
Which IDE would you like to install/update?
  1) Visual Studio Code only
  2) Cursor only
  3) Both VS Code and Cursor
  4) Skip IDE installation
```

### Optional Applications

- **Grammarly Desktop**: Writing assistant
- **Hand Mirror**: Mac App Store app (requires Apple ID)

## 🔄 Update Existing Installation

The script is idempotent - you can run it multiple times safely:

```bash
./tooling_setup.sh
```

It will:

- ✅ Skip packages that are already up to date
- ⬆️ Upgrade outdated packages
- ⬇️ Install missing packages

## 🎯 Status Icons

| Icon | Meaning |
|------|---------|
| ✓ | Success / Already installed |
| ↻ | Checking for updates |
| ⬆ | Upgrading |
| ⬇ | Installing |
| ✗ | Failed |
| ⊘ | Skipped |

## 🐛 Troubleshooting

### Common Issues

#### Homebrew Permission Errors

```bash
sudo chown -R $(whoami) /usr/local/Cellar /usr/local/Homebrew
```

#### OneDrive Sync Issues with Git

- The script is located in OneDrive which can cause sync conflicts
- Consider moving to `~/Projects` or `~/Code` for better performance

**Rosetta 2 Required**
Some Intel-based apps (like Clipy) may require Rosetta 2 on Apple Silicon:

```bash
softwareupdate --install-rosetta --agree-to-license
```

### Getting Help

If you encounter issues:

1. Check the colored output for specific error messages
2. Review the Homebrew logs: `brew doctor`
3. Ensure you have sufficient disk space
4. Verify internet connectivity

## 📂 Repository Structure

```text
tooling-scripts/
├── tooling_setup.sh         # Main installation script
├── .pre-commit-config.yaml  # Pre-commit hooks configuration
└── README.md               # This file
```

## 🔒 Security Considerations

- The script requires admin privileges for some installations
- Review the script before running: `cat tooling_setup.sh`
- All packages are installed from official Homebrew repositories
- Credentials (Apple ID) are only used for Mac App Store

## 🤝 Contributing

Improvements and suggestions are welcome! When contributing:

1. Test changes on a clean macOS installation
2. Update this README with any new features
3. Ensure the script remains idempotent
4. Run pre-commit hooks before committing

## 📄 License

This script is provided as-is for internal use.

## 🙏 Acknowledgments

- Built on [Homebrew](https://brew.sh/)
- Inspired by various dotfiles repositories
- Community feedback and contributions
