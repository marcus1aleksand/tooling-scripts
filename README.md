# 🛠️ Tooling Setup Script — Interactive Edition

Automated macOS/Linux development environment setup with an **interactive checkbox UI**. Scans your system for existing tools, shows what's installed and what's available, lets you pick exactly what to install or update, then executes — all from the terminal.

![Interactive UI powered by gum](https://vhs.charm.sh/vhs-2JnkEzIiyNJZikGp4wRXQT.gif)

## ✨ Features

- 🔍 **Pre-flight scan** — detects installed tools and their versions before anything happens
- ☑️ **Interactive checkbox UI** — toggle tools on/off with arrow keys + space (powered by [gum](https://github.com/charmbracelet/gum))
  - Already installed tools are **pre-checked** with version info
  - Not-installed tools are **unchecked**
  - Press `a` to select/deselect all
- 📝 **Execution plan** — shows exactly what will be installed/updated before confirming
- ⬆️ **Smart actions** — selected + installed → update; selected + missing → install; deselected → skip
- 🎨 **Polished output** — colour-coded progress with `[1/N]` counters
- 🔧 **Post-install setup** — Git config, Oh My Zsh, shell aliases (only when relevant tools are selected)
- 🌍 **Cross-platform** — macOS + Linux (via Homebrew)

## 📋 Prerequisites

- **macOS 10.10+** or **Linux** with Homebrew (or it will be installed for you)
- **Internet connection**
- **Admin privileges**

> **Note**: Both Homebrew and `gum` are auto-installed if not present.

## 🚀 Quick Start

```bash
chmod +x tooling_setup.sh
./tooling_setup.sh
```

### What Happens

1. **Homebrew check** — installs/updates Homebrew
2. **gum check** — installs the TUI toolkit if missing
3. **System scan** — detects all tools and versions
4. **Interactive picker** — you choose what to install/update
5. **Confirmation** — review the plan before executing
6. **Install/update** — progress output for each tool
7. **Post-install** — Git config, Oh My Zsh, aliases (contextual)
8. **Cleanup** — `brew cleanup`

## 📦 Available Tools

### GUI Applications (Casks)

| Application | Description |
|---|---|
| iTerm2 | Terminal emulator |
| Docker Desktop | Container platform |
| Google Chrome | Web browser |
| Firefox | Web browser |
| Zoom | Video conferencing |
| Slack | Team communication |
| Evernote | Note-taking |
| CotEditor | Text editor |
| OneDrive | Cloud storage |
| WhatsApp | Messaging |
| Bitwarden | Password manager |
| Krisp | Noise cancellation |
| Clipy | Clipboard manager |
| VS Code | Code editor |
| Cursor | AI code editor |
| Grammarly | Writing assistant |

### CLI Tools (Formulas)

| Tool | Description |
|---|---|
| git | Version control |
| zsh | Z shell |
| jq / yq | JSON / YAML processors |
| go | Go language |
| python | Python language |
| helm | Kubernetes package manager |
| kubectl | Kubernetes CLI |
| pre-commit | Git hooks |
| mkdocs | Documentation |
| terraform | Infrastructure as Code |
| k9s | Kubernetes TUI |
| azure-cli | Azure CLI |
| awscli | AWS CLI |
| google-cloud-sdk | GCP CLI |
| argocd | GitOps CD |
| black | Python formatter |
| bats-core | Bash testing |
| mas | Mac App Store CLI |

## ⚙️ Post-Install Configuration

### Git (when selected)
Prompts for username and email. Skips if already configured (offers to reconfigure).

### Oh My Zsh (when zsh selected)
Installs Oh My Zsh if not present.

### Shell Aliases (when kubectl selected)
```bash
alias k="kubectl"
alias ctx="kubectx"
alias pf-argocd="kubectl port-forward svc/argocd-server -n argocd 8082:443"
```

## 🔧 Adding New Tools

Edit the `TOOLS` array in `tooling_setup.sh`:

```bash
# Format: "type|brew_name|display_name|version_cmd"
TOOLS+=(
  "formula|ripgrep|ripgrep|rg --version"
  "cask|raycast|Raycast|"
)
```

## 🐛 Troubleshooting

- **Homebrew permissions**: `sudo chown -R $(whoami) /usr/local/Cellar /usr/local/Homebrew`
- **Rosetta 2** (Apple Silicon): `softwareupdate --install-rosetta --agree-to-license`
- **Diagnostics**: `brew doctor`

## 📄 License

MIT — see [LICENSE](LICENSE).
