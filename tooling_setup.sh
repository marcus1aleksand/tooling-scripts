#!/bin/bash

# Color codes for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to display progress bar
progressbar() {
  local duration=$1
  local columns
  columns=$(tput cols)
  while true; do
    for ((i = 0; i < columns; i++)); do
      printf "\e[44m "
    done
    sleep "$duration"
    printf "\r"
    for ((i = 0; i < columns; i++)); do
      printf " "
    done
    printf "\r"
    sleep "$duration"
  done
}

# Install Homebrew (if not installed)
echo -e "${BLUE}Checking Homebrew installation...${NC}"
if ! command -v brew &>/dev/null; then
  echo -e "${YELLOW}Homebrew not found. Installing...${NC}"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  (
    echo
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"'
  ) >>/Users/marcusaleksandravicius/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
  echo -e "${GREEN}✓ Homebrew installed successfully${NC}"
else
  echo -e "${GREEN}✓ Homebrew already installed${NC}"
  echo -e "${BLUE}Updating Homebrew...${NC}"
  brew update
fi

# Start progress bar in the background
progressbar 0.1 &

# Store the progress bar's PID
PROGRESS_BAR_PID=$!

# Function to check if a cask package is installed
is_cask_installed() {
  local package=$1
  brew list --cask "$package" &>/dev/null
}

# Function to check if a formula package is installed
is_formula_installed() {
  local package=$1
  brew list "$package" &>/dev/null
}

# Function to install or upgrade a cask package
install_or_upgrade_cask() {
  local package=$1
  echo -e "${BLUE}Processing cask: ${package}${NC}"

  if is_cask_installed "$package"; then
    echo -e "${YELLOW}  ↻ ${package} already installed, checking for updates...${NC}"
    if brew outdated --cask "$package" &>/dev/null; then
      echo -e "${YELLOW}  ⬆ Upgrading ${package}...${NC}"
      brew upgrade --cask "$package" && echo -e "${GREEN}  ✓ ${package} upgraded${NC}" || echo -e "${RED}  ✗ Failed to upgrade ${package}${NC}"
    else
      echo -e "${GREEN}  ✓ ${package} is up to date${NC}"
    fi
  else
    echo -e "${YELLOW}  ⬇ Installing ${package}...${NC}"
    brew install --cask "$package" && echo -e "${GREEN}  ✓ ${package} installed${NC}" || echo -e "${RED}  ✗ Failed to install ${package}${NC}"
  fi
}

# Function to install or upgrade a formula package
install_or_upgrade_formula() {
  local package=$1
  echo -e "${BLUE}Processing formula: ${package}${NC}"

  if is_formula_installed "$package"; then
    echo -e "${YELLOW}  ↻ ${package} already installed, checking for updates...${NC}"
    if brew outdated "$package" &>/dev/null; then
      echo -e "${YELLOW}  ⬆ Upgrading ${package}...${NC}"
      brew upgrade "$package" && echo -e "${GREEN}  ✓ ${package} upgraded${NC}" || echo -e "${RED}  ✗ Failed to upgrade ${package}${NC}"
    else
      echo -e "${GREEN}  ✓ ${package} is up to date${NC}"
    fi
  else
    echo -e "${YELLOW}  ⬇ Installing ${package}...${NC}"
    brew install "$package" && echo -e "${GREEN}  ✓ ${package} installed${NC}" || echo -e "${RED}  ✗ Failed to install ${package}${NC}"
  fi
}

echo -e "\n${BLUE}═══════════════════════════════════════════${NC}"
echo -e "${BLUE}  Installing GUI Applications (Casks)${NC}"
echo -e "${BLUE}═══════════════════════════════════════════${NC}\n"

# Install cask applications
install_or_upgrade_cask iterm2
install_or_upgrade_cask docker
install_or_upgrade_cask google-chrome
install_or_upgrade_cask firefox
install_or_upgrade_cask zoom
install_or_upgrade_cask slack
install_or_upgrade_cask evernote
install_or_upgrade_cask coteditor
install_or_upgrade_cask onedrive
install_or_upgrade_cask whatsapp
install_or_upgrade_cask bitwarden
install_or_upgrade_cask krisp
install_or_upgrade_cask clipy

# IDE Selection
echo -e "\n${BLUE}═══════════════════════════════════════════${NC}"
echo -e "${BLUE}  IDE Installation${NC}"
echo -e "${BLUE}═══════════════════════════════════════════${NC}\n"

vscode_installed=$(is_cask_installed visual-studio-code && echo "yes" || echo "no")
cursor_installed=$(is_cask_installed cursor && echo "yes" || echo "no")

if [ "$vscode_installed" = "yes" ] || [ "$cursor_installed" = "yes" ]; then
  echo -e "${GREEN}Current IDE installations:${NC}"
  [ "$vscode_installed" = "yes" ] && echo -e "  ✓ Visual Studio Code is installed"
  [ "$cursor_installed" = "yes" ] && echo -e "  ✓ Cursor is installed"
  echo ""
fi

echo -e "${YELLOW}Which IDE would you like to install/update?${NC}"
echo -e "  1) Visual Studio Code only"
echo -e "  2) Cursor only"
echo -e "  3) Both VS Code and Cursor"
echo -e "  4) Skip IDE installation"
read -p "Enter your choice (1-4): " ide_choice

case $ide_choice in
  1)
    echo -e "${BLUE}Installing/updating Visual Studio Code...${NC}"
    install_or_upgrade_cask visual-studio-code
    ;;
  2)
    echo -e "${BLUE}Installing/updating Cursor...${NC}"
    install_or_upgrade_cask cursor
    ;;
  3)
    echo -e "${BLUE}Installing/updating both Visual Studio Code and Cursor...${NC}"
    install_or_upgrade_cask visual-studio-code
    install_or_upgrade_cask cursor
    ;;
  4)
    echo -e "${YELLOW}⊘ Skipping IDE installation${NC}"
    ;;
  *)
    echo -e "${RED}✗ Invalid choice. Skipping IDE installation${NC}"
    ;;
esac

echo -e "\n${BLUE}═══════════════════════════════════════════${NC}"
echo -e "${BLUE}  Installing CLI Tools (Formulas)${NC}"
echo -e "${BLUE}═══════════════════════════════════════════${NC}\n"

# Install formula packages
install_or_upgrade_formula zsh
install_or_upgrade_formula jq
install_or_upgrade_formula yq
install_or_upgrade_formula go
install_or_upgrade_formula python
install_or_upgrade_formula helm
install_or_upgrade_formula kubernetes-cli
install_or_upgrade_formula pre-commit
install_or_upgrade_formula mkdocs
install_or_upgrade_formula terraform
install_or_upgrade_formula k9s
install_or_upgrade_formula azure-cli
install_or_upgrade_formula awscli
install_or_upgrade_formula google-cloud-sdk
install_or_upgrade_formula argocd
install_or_upgrade_formula black
install_or_upgrade_formula git
install_or_upgrade_formula bats-core
install_or_upgrade_formula mas

echo -e "\n${BLUE}═══════════════════════════════════════════${NC}"
echo -e "${BLUE}  Git Configuration${NC}"
echo -e "${BLUE}═══════════════════════════════════════════${NC}\n"

# Prompt to configure git username and email
current_git_user=$(git config --global user.name 2>/dev/null)
current_git_email=$(git config --global user.email 2>/dev/null)

if [ -n "$current_git_user" ] && [ -n "$current_git_email" ]; then
  echo -e "${GREEN}Git already configured:${NC}"
  echo -e "  Username: ${current_git_user}"
  echo -e "  Email: ${current_git_email}"
  read -p "Do you want to reconfigure? (y/n): " reconfigure_git

  if [[ $reconfigure_git != "y" ]]; then
    echo -e "${GREEN}✓ Keeping current git configuration${NC}"
  else
    read -p "Enter your git username: " git_username
    read -p "Enter your git email: " git_email
    git config --global user.name "$git_username"
    git config --global user.email "$git_email"
    echo -e "${GREEN}✓ Git configuration updated${NC}"
  fi
else
  read -p "Enter your git username: " git_username
  read -p "Enter your git email: " git_email
  git config --global user.name "$git_username"
  git config --global user.email "$git_email"
  echo -e "${GREEN}✓ Git configured successfully${NC}"
fi

echo -e "\n${BLUE}═══════════════════════════════════════════${NC}"
echo -e "${BLUE}  Oh My Zsh Installation${NC}"
echo -e "${BLUE}═══════════════════════════════════════════${NC}\n"

# Check if Oh My Zsh is already installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo -e "${YELLOW}Installing Oh My Zsh...${NC}"
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  echo -e "${GREEN}✓ Oh My Zsh installed${NC}"
else
  echo -e "${GREEN}✓ Oh My Zsh already installed${NC}"
fi

echo -e "\n${BLUE}═══════════════════════════════════════════${NC}"
echo -e "${BLUE}  Optional Applications${NC}"
echo -e "${BLUE}═══════════════════════════════════════════${NC}\n"

# Check if Grammarly is already installed
if ! is_cask_installed grammarly-desktop; then
  read -p "Do you want to install Grammarly? (y/n): " install_grammarly
  if [[ $install_grammarly == "y" ]]; then
    install_or_upgrade_cask grammarly-desktop
  fi
else
  echo -e "${GREEN}✓ Grammarly already installed${NC}"
fi

# Mac App Store applications
if command -v mas &>/dev/null; then
  echo -e "\n${BLUE}Checking Mac App Store login...${NC}"

  # Check if already signed in
  if mas account &>/dev/null; then
    current_account=$(mas account)
    echo -e "${GREEN}✓ Already signed in to Mac App Store: ${current_account}${NC}"

    # Prompt to ask if the user wants to install Hand Mirror
    read -p "Do you want to install Hand Mirror? (y/n): " install_hand_mirror

    if [[ $install_hand_mirror == "y" ]]; then
      echo -e "${BLUE}Searching for Hand Mirror...${NC}"
      hand_mirror_id=$(mas search "Hand Mirror" | awk '/Hand Mirror/ {print $1; exit}')

      if [ -n "$hand_mirror_id" ]; then
        # Check if already installed
        if mas list | grep -q "$hand_mirror_id"; then
          echo -e "${GREEN}✓ Hand Mirror already installed${NC}"
        else
          echo -e "${YELLOW}Installing Hand Mirror...${NC}"
          mas install "$hand_mirror_id" && echo -e "${GREEN}✓ Hand Mirror installed${NC}"
        fi
      else
        echo -e "${RED}✗ Could not find Hand Mirror in the Mac App Store${NC}"
      fi
    fi
  else
    echo -e "${YELLOW}Not signed in to Mac App Store${NC}"
    read -p "Enter your Apple ID to sign in (or press Enter to skip): " apple_id

    if [ -n "$apple_id" ]; then
      mas signin "$apple_id"
    else
      echo -e "${YELLOW}⊘ Skipping Mac App Store applications${NC}"
    fi
  fi
fi

# Stop the progress bar
kill $PROGRESS_BAR_PID &>/dev/null

echo -e "\n${BLUE}═══════════════════════════════════════════${NC}"
echo -e "${BLUE}  Setting up Shell Aliases${NC}"
echo -e "${BLUE}═══════════════════════════════════════════${NC}\n"

# Set up aliases (check if they already exist to avoid duplicates)
setup_alias() {
  local alias_line=$1
  local shell_rc=$2

  if ! grep -q "$alias_line" "$shell_rc" 2>/dev/null; then
    echo "$alias_line" >>"$shell_rc"
    echo -e "${GREEN}✓ Added alias to $shell_rc${NC}"
  else
    echo -e "${YELLOW}↻ Alias already exists in $shell_rc${NC}"
  fi
}

# Setup aliases for zsh
if [ -f ~/.zshrc ]; then
  setup_alias 'alias k="kubectl"' ~/.zshrc
  setup_alias 'alias ctx="kubectx"' ~/.zshrc
  setup_alias 'alias pf-argocd="kubectl port-forward svc/argocd-server -n argocd 8082:443"' ~/.zshrc
fi

# Setup aliases for bash
if [ -f ~/.bashrc ]; then
  setup_alias 'alias k="kubectl"' ~/.bashrc
  setup_alias 'alias ctx="kubectx"' ~/.bashrc
  setup_alias 'alias pf-argocd="kubectl port-forward svc/argocd-server -n argocd 8082:443"' ~/.bashrc
fi

# Final cleanup and update
echo -e "\n${BLUE}═══════════════════════════════════════════${NC}"
echo -e "${BLUE}  Final Cleanup${NC}"
echo -e "${BLUE}═══════════════════════════════════════════${NC}\n"

echo -e "${YELLOW}Running brew cleanup...${NC}"
brew cleanup
echo -e "${GREEN}✓ Cleanup complete${NC}"

# Notify completion
echo -e "\n${GREEN}═══════════════════════════════════════════${NC}"
echo -e "${GREEN}  ✓ Installation Complete!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════${NC}\n"

echo -e "${YELLOW}📋 Summary:${NC}"
echo -e "  • All applications have been installed or updated to their latest versions"
echo -e "  • Clipy has been installed for clipboard management"
echo -e "  • Git has been configured"
echo -e "  • Oh My Zsh has been installed"
echo -e "  • Shell aliases have been set up"

echo -e "\n${YELLOW}⚠️  Important:${NC}"
echo -e "  • Please restart your terminal to apply all changes"
echo -e "  • Don't forget to grant necessary permissions to installed apps"
echo -e "  • Clipy requires Accessibility permissions (System Settings > Privacy & Security > Accessibility)"

echo -e "\n${BLUE}🎉 Enjoy your newly configured system!${NC}\n"
