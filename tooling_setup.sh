#!/bin/bash
# Function to display progress bar
progressbar() {
  local duration=$1
  local columns=$(tput cols)
  local progress
  while true; do
    for ((i=0; i<columns; i++)); do
      printf "\e[44m "
    done
    sleep $duration
    printf "\r"
    for ((i=0; i<columns; i++)); do
      printf " "
    done
    printf "\r"
    sleep $duration
  done
}

# Install Homebrew (if not installed)
if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Start progress bar in the background
progressbar 0.1 &

# Store the progress bar's PID
PROGRESS_BAR_PID=$!

# Function to check if a package is installed
is_package_installed() {
  local package=$1
  brew list --cask $package &> /dev/null
}

# Function to check if a package is outdated
is_package_outdated() {
  local package=$1
  brew outdated --cask $package &> /dev/null
}

# Function to upgrade a package
upgrade_package() {
  local package=$1
  brew upgrade --cask $package
}

# Install applications and tools
install_package() {
  local package=$1
  if ! is_package_installed $package; then
    brew install --cask $package
  elif is_package_outdated $package; then
    upgrade_package $package
  fi
}

# Install packages
install_package iterm2
install_package zsh
install_package docker
install_package visual-studio-code
install_package google-chrome
install_package firefox
install_package zoom
install_package slack
install_package evernote
install_package coteditor
install_package onedrive
install_package whatsapp
install_package bitwarden
install_package jq
install_package yq
install_package helm
install_package terraform
install_package kubernetes-cli
install_package kubectx
install_package python
install_package pre-commit
install_package mkdocs
install_package terraform-docs
install_package k9s
install_package azure-cli
install_package awscli
install_package google-cloud-sdk
install_package argocd-cli
install_package helmlint
install_package krisp
install_package black
install_package go
install_package git
install_package bats

# Prompt to configure git username and email
read -p "Enter your git username: " git_username
read -p "Enter your git email: " git_email

# Configure git username and email
git config --global user.name "$git_username"
git config --global user.email "$git_email"


# Check if Oh My Zsh is already installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  # Install Oh My Zsh
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Prompt to ask if the user wants to install Grammarly
read -p "Do you want to install Grammarly? (y/n): " install_grammarly

if [[ $install_grammarly == "y" ]]; then
  # Install Grammarly
  brew install --cask grammarly-desktop
fi

# Install mas (Mac App Store CLI)
brew install mas

# Prompt to ask for Apple ID
read -p "Enter your Apple ID: " apple_id

# Sign in to the Mac App Store
mas account signin $apple_id

# Prompt to ask if the user wants to install Hand Mirror
read -p "Do you want to install Hand Mirror? (y/n): " install_hand_mirror

if [[ $install_hand_mirror == "y" ]]; then
  # Find Hand Mirror ID
  hand_mirror_id=$(mas search "Hand Mirror" | awk '/Hand Mirror/ {print $1}')

  # Install Hand Mirror
  mas install $hand_mirror_id
fi

# Stop the progress bar
kill $PROGRESS_BAR_PID &> /dev/null

# Set up aliases
echo 'alias k="kubectl"' >> ~/.zshrc
echo 'alias ctx="kubectx"' >> ~/.zshrc
echo 'alias pf-argocd="kubectl port-forward svc/argocd-server -n argocd 8082:443"' >> ~/.zshrc
echo 'alias k="kubectl"' >> ~/.bashrc
echo 'alias ctx="kubectx"' >> ~/.bashrc
echo 'alias pf-argocd="kubectl port-forward svc/argocd-server -n argocd 8082:443"' >> ~/.bashrc

# Notify completion
echo "Installation complete. Please restart your terminal to apply changes."
