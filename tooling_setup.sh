#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# 🛠️  Tooling Setup Script — Interactive Edition
# ═══════════════════════════════════════════════════════════════════════════════
# Scans for existing tools, presents an interactive checkbox UI, then installs
# or updates only what you select.  Uses `gum` (Charm) for the TUI.
# Works on macOS and Linux (Homebrew required on both).
# ═══════════════════════════════════════════════════════════════════════════════
set -euo pipefail

# ── Colours ───────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# ── Helpers ───────────────────────────────────────────────────────────────────
info() { printf "${BLUE}%s${NC}\n" "$*"; }
success() { printf "${GREEN}✓ %s${NC}\n" "$*"; }
warn() { printf "${YELLOW}⚠ %s${NC}\n" "$*"; }
fail() { printf "${RED}✗ %s${NC}\n" "$*"; }
header() {
  echo ""
  printf '%s═══════════════════════════════════════════%s\n' "$CYAN" "$NC"
  printf '%s  %s%s\n' "$CYAN" "$*" "$NC"
  printf '%s═══════════════════════════════════════════%s\n' "$CYAN" "$NC"
  echo ""
}

# ── Ensure Homebrew ───────────────────────────────────────────────────────────
ensure_homebrew() {
  if command -v brew &>/dev/null; then
    success "Homebrew found"
    return
  fi
  info "Installing Homebrew…"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # shellcheck disable=SC2016
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    grep -q 'brew shellenv' "$HOME/.zprofile" 2>/dev/null ||
      echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>"$HOME/.zprofile"
  elif [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  fi
  success "Homebrew installed"
}

# ── Ensure gum (our TUI dependency) ──────────────────────────────────────────
ensure_gum() {
  if command -v gum &>/dev/null; then return; fi
  info "Installing gum (interactive TUI toolkit)…"
  brew install gum >/dev/null 2>&1
  success "gum installed"
}

# ── Tool registry ────────────────────────────────────────────────────────────
# Format: "type|brew_name|display_name|version_cmd"
# type = cask | formula
TOOLS=(
  # GUI Applications (casks)
  "cask|iterm2|iTerm2|"
  "cask|docker|Docker Desktop|docker --version"
  "cask|google-chrome|Google Chrome|"
  "cask|firefox|Firefox|"
  "cask|zoom|Zoom|"
  "cask|slack|Slack|"
  "cask|evernote|Evernote|"
  "cask|coteditor|CotEditor|"
  "cask|onedrive|OneDrive|"
  "cask|whatsapp|WhatsApp|"
  "cask|bitwarden|Bitwarden|"
  "cask|krisp|Krisp|"
  "cask|clipy|Clipy|"
  "cask|visual-studio-code|VS Code|code --version"
  "cask|cursor|Cursor|"
  "cask|grammarly-desktop|Grammarly|"
  # CLI Tools (formulas)
  "formula|git|Git|git --version"
  "formula|zsh|Zsh|zsh --version"
  "formula|jq|jq|jq --version"
  "formula|yq|yq|yq --version"
  "formula|go|Go|go version"
  "formula|python|Python|python3 --version"
  "formula|helm|Helm|helm version --short"
  "formula|kubernetes-cli|kubectl|kubectl version --client --short 2>/dev/null || kubectl version --client"
  "formula|pre-commit|pre-commit|pre-commit --version"
  "formula|mkdocs|mkdocs|mkdocs --version"
  "formula|terraform|Terraform|terraform --version"
  "formula|k9s|k9s|k9s version --short 2>/dev/null || k9s version"
  "formula|azure-cli|Azure CLI|az --version"
  "formula|awscli|AWS CLI|aws --version"
  "formula|google-cloud-sdk|Google Cloud SDK|gcloud --version"
  "formula|argocd|ArgoCD CLI|argocd version --client --short 2>/dev/null || argocd version --client"
  "formula|black|Black (Python)|black --version"
  "formula|bats-core|bats-core|bats --version"
  "formula|mas|mas (App Store CLI)|mas version"
)

# ── Detect installed tools ───────────────────────────────────────────────────
declare -A INSTALLED_VERSION # brew_name → version string
declare -A IS_INSTALLED      # brew_name → 1/0

detect_tools() {
  header "🔍  Scanning installed tools"
  local type brew_name display version_cmd ver
  for entry in "${TOOLS[@]}"; do
    IFS='|' read -r type brew_name display version_cmd <<<"$entry"

    # Check via brew
    local installed=0
    if [[ "$type" == "cask" ]]; then
      brew list --cask "$brew_name" &>/dev/null 2>&1 && installed=1
    else
      brew list "$brew_name" &>/dev/null 2>&1 && installed=1
    fi

    IS_INSTALLED[$brew_name]=$installed

    # Try to get version
    ver=""
    if [[ $installed -eq 1 && -n "$version_cmd" ]]; then
      ver=$(eval "$version_cmd" 2>/dev/null | head -1 | sed 's/^[^0-9]*//' | cut -d' ' -f1 | tr -d ',' || true)
    fi
    if [[ $installed -eq 1 && -z "$ver" ]]; then
      # Fallback: get version from brew info
      if [[ "$type" == "cask" ]]; then
        ver=$(brew info --cask "$brew_name" 2>/dev/null | head -1 | awk '{print $NF}' || true)
      else
        ver=$(brew info "$brew_name" 2>/dev/null | head -1 | awk '{print $NF}' || true)
      fi
    fi
    INSTALLED_VERSION[$brew_name]="${ver:-unknown}"

    if [[ $installed -eq 1 ]]; then
      printf "  ${GREEN}✓${NC} %-25s ${DIM}v%s${NC}\n" "$display" "${INSTALLED_VERSION[$brew_name]}"
    else
      printf "  ${DIM}☐${NC} %-25s ${DIM}not installed${NC}\n" "$display"
    fi
  done
  echo ""
}

# ── Build gum choices & present interactive picker ───────────────────────────
interactive_select() {
  header "📋  Select tools to install / update"
  info "Use arrow keys to navigate, SPACE to toggle, a to select all, ENTER to confirm"
  echo ""

  local choices=()
  local preselected=()
  local type brew_name display version_cmd label

  for entry in "${TOOLS[@]}"; do
    IFS='|' read -r type brew_name display version_cmd <<<"$entry"

    if [[ "${IS_INSTALLED[$brew_name]}" -eq 1 ]]; then
      label="$display  (v${INSTALLED_VERSION[$brew_name]} installed)"
      preselected+=("$label")
    else
      label="$display  (not installed)"
    fi
    choices+=("$label")
  done

  # Build gum command
  local gum_args=("gum" "choose" "--no-limit"
    "--header=Toggle with SPACE · Select all: a · Confirm: ENTER"
    "--cursor.foreground=4"
    "--selected.foreground=2"
    "--height=25"
  )

  # Add pre-selected items
  for s in "${preselected[@]}"; do
    gum_args+=("--selected=$s")
  done

  # Add all choices
  for c in "${choices[@]}"; do
    gum_args+=("$c")
  done

  # Run gum and capture selections
  SELECTED_LABELS=()
  while IFS= read -r line; do
    SELECTED_LABELS+=("$line")
  done < <("${gum_args[@]}" || true)

  if [[ ${#SELECTED_LABELS[@]} -eq 0 ]]; then
    warn "Nothing selected. Exiting."
    exit 0
  fi
}

# ── Map selections back to brew names ────────────────────────────────────────
declare -A SELECTED_MAP # brew_name → 1

resolve_selections() {
  local type brew_name display version_cmd
  for entry in "${TOOLS[@]}"; do
    IFS='|' read -r type brew_name display version_cmd <<<"$entry"
    SELECTED_MAP[$brew_name]=0
    for label in "${SELECTED_LABELS[@]}"; do
      if [[ "$label" == "$display "* ]]; then
        SELECTED_MAP[$brew_name]=1
        break
      fi
    done
  done
}

# ── Confirmation ─────────────────────────────────────────────────────────────
confirm_plan() {
  header "📝  Execution Plan"

  local to_install=() to_update=() skipped=0
  local type brew_name display version_cmd

  for entry in "${TOOLS[@]}"; do
    IFS='|' read -r type brew_name display version_cmd <<<"$entry"
    if [[ "${SELECTED_MAP[$brew_name]}" -eq 1 ]]; then
      if [[ "${IS_INSTALLED[$brew_name]}" -eq 1 ]]; then
        to_update+=("$display")
        printf "  ${YELLOW}⬆${NC}  %s  ${DIM}(update)${NC}\n" "$display"
      else
        to_install+=("$display")
        printf "  ${GREEN}⬇${NC}  %s  ${DIM}(install)${NC}\n" "$display"
      fi
    else
      ((skipped++)) || true
    fi
  done

  echo ""
  printf "  ${BOLD}Install:${NC} %d  ${BOLD}Update:${NC} %d  ${BOLD}Skip:${NC} %d\n" \
    "${#to_install[@]}" "${#to_update[@]}" "$skipped"
  echo ""

  if ! gum confirm "Proceed with the above plan?"; then
    warn "Aborted by user."
    exit 0
  fi
}

# ── Execute installs / updates ───────────────────────────────────────────────
execute_plan() {
  header "🚀  Installing & Updating"

  local type brew_name display version_cmd
  local total=0 done_count=0 fail_count=0

  # Count selected
  for entry in "${TOOLS[@]}"; do
    IFS='|' read -r type brew_name display version_cmd <<<"$entry"
    [[ "${SELECTED_MAP[$brew_name]}" -eq 1 ]] && ((total++))
  done

  for entry in "${TOOLS[@]}"; do
    IFS='|' read -r type brew_name display version_cmd <<<"$entry"
    [[ "${SELECTED_MAP[$brew_name]}" -eq 0 ]] && continue

    ((done_count++))
    printf "${BOLD}[%d/%d]${NC} " "$done_count" "$total"

    if [[ "${IS_INSTALLED[$brew_name]}" -eq 1 ]]; then
      printf "Updating ${CYAN}%s${NC}…" "$display"
      if [[ "$type" == "cask" ]]; then
        if brew upgrade --cask "$brew_name" 2>/dev/null; then
          printf "\r${BOLD}[%d/%d]${NC} ${GREEN}✓${NC} %s updated\n" "$done_count" "$total" "$display"
        else
          printf "\r${BOLD}[%d/%d]${NC} ${GREEN}✓${NC} %s already latest\n" "$done_count" "$total" "$display"
        fi
      else
        if brew upgrade "$brew_name" 2>/dev/null; then
          printf "\r${BOLD}[%d/%d]${NC} ${GREEN}✓${NC} %s updated\n" "$done_count" "$total" "$display"
        else
          printf "\r${BOLD}[%d/%d]${NC} ${GREEN}✓${NC} %s already latest\n" "$done_count" "$total" "$display"
        fi
      fi
    else
      printf "Installing ${CYAN}%s${NC}…" "$display"
      if [[ "$type" == "cask" ]]; then
        if brew install --cask "$brew_name" 2>/dev/null; then
          printf "\r${BOLD}[%d/%d]${NC} ${GREEN}✓${NC} %s installed\n" "$done_count" "$total" "$display"
        else
          printf "\r${BOLD}[%d/%d]${NC} ${RED}✗${NC} %s failed\n" "$done_count" "$total" "$display"
          ((fail_count++))
        fi
      else
        if brew install "$brew_name" 2>/dev/null; then
          printf "\r${BOLD}[%d/%d]${NC} ${GREEN}✓${NC} %s installed\n" "$done_count" "$total" "$display"
        else
          printf "\r${BOLD}[%d/%d]${NC} ${RED}✗${NC} %s failed\n" "$done_count" "$total" "$display"
          ((fail_count++))
        fi
      fi
    fi
  done

  echo ""
  if [[ $fail_count -eq 0 ]]; then
    success "All $done_count tools processed successfully!"
  else
    warn "$fail_count of $done_count tools had issues"
  fi
}

# ── Post-install: Git config ────────────────────────────────────────────────
configure_git() {
  # Only if git was selected
  [[ "${SELECTED_MAP[git]:-0}" -eq 0 ]] && return

  header "⚙️  Git Configuration"

  local current_user current_email
  current_user=$(git config --global user.name 2>/dev/null || true)
  current_email=$(git config --global user.email 2>/dev/null || true)

  if [[ -n "$current_user" && -n "$current_email" ]]; then
    success "Git already configured: $current_user <$current_email>"
    if ! gum confirm "Reconfigure git?"; then
      return
    fi
  fi

  local new_user new_email
  new_user=$(gum input --placeholder "Your Name" --header "Git username:" --value "$current_user")
  new_email=$(gum input --placeholder "you@example.com" --header "Git email:" --value "$current_email")

  if [[ -n "$new_user" && -n "$new_email" ]]; then
    git config --global user.name "$new_user"
    git config --global user.email "$new_email"
    success "Git configured: $new_user <$new_email>"
  fi
}

# ── Post-install: Oh My Zsh ─────────────────────────────────────────────────
setup_ohmyzsh() {
  [[ "${SELECTED_MAP[zsh]:-0}" -eq 0 ]] && return

  header "🐚  Oh My Zsh"

  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    success "Oh My Zsh already installed"
  else
    if gum confirm "Install Oh My Zsh?"; then
      sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
      success "Oh My Zsh installed"
    fi
  fi
}

# ── Post-install: Shell aliases ──────────────────────────────────────────────
setup_aliases() {
  [[ "${SELECTED_MAP["kubernetes-cli"]:-0}" -eq 0 ]] && return

  header "🔗  Shell Aliases"

  local aliases=(
    'alias k="kubectl"'
    'alias ctx="kubectx"'
    'alias pf-argocd="kubectl port-forward svc/argocd-server -n argocd 8082:443"'
  )

  for rc in "$HOME/.zshrc" "$HOME/.bashrc"; do
    [[ ! -f "$rc" ]] && continue
    for a in "${aliases[@]}"; do
      if ! grep -qF "$a" "$rc" 2>/dev/null; then
        echo "$a" >>"$rc"
        printf "  ${GREEN}+${NC} Added to %s: ${DIM}%s${NC}\n" "$(basename "$rc")" "$a"
      fi
    done
  done
  success "Aliases configured"
}

# ── Cleanup ──────────────────────────────────────────────────────────────────
cleanup() {
  header "🧹  Cleanup"
  brew cleanup 2>/dev/null
  success "Brew cleanup complete"
}

# ── Summary ──────────────────────────────────────────────────────────────────
summary() {
  echo ""
  printf '%s═══════════════════════════════════════════%s\n' "$GREEN" "$NC"
  printf '%s  ✅  All done!%s\n' "$GREEN" "$NC"
  printf '%s═══════════════════════════════════════════%s\n' "$GREEN" "$NC"
  echo ""
  echo -e "  ${YELLOW}⚠️  Restart your terminal to apply all changes${NC}"
  echo -e "  ${YELLOW}⚠️  Grant permissions to newly installed apps as needed${NC}"
  echo ""
}

# ── Main ─────────────────────────────────────────────────────────────────────
main() {
  header "🛠️  Tooling Setup — Interactive Edition"

  ensure_homebrew
  info "Updating Homebrew…"
  brew update --quiet

  ensure_gum
  detect_tools
  interactive_select
  resolve_selections
  confirm_plan
  execute_plan
  configure_git
  setup_ohmyzsh
  setup_aliases
  cleanup
  summary
}

main "$@"
