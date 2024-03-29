#!/usr/bin/env bats

@test "Check if Homebrew is installed" {
  run command -v brew
  [ "$status" -eq 0 ]
}

@test "Check if a package is installed" {
  run brew list --cask iterm2
  [ "$status" -eq 0 ]
}

@test "Check if a package is outdated" {
  run brew outdated --cask iterm2
  # If the package is not outdated, the command should return a non-zero status
  [ "$status" -ne 0 ]
}

@test "Check if Oh My Zsh is installed" {
  run test -d "$HOME/.oh-my-zsh"
  [ "$status" -eq 0 ]
}

@test "Check if aliases are set up correctly" {
  run grep -q 'alias k="kubectl"' ~/.zshrc
  [ "$status" -eq 0 ]
}