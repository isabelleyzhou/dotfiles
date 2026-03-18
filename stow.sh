#!/usr/bin/env bash

set -e

DOT_FILES="${HOME}/dotfiles"

function run_stow() {
  for dir in "$@"; do
    stow -t "$HOME" "$dir"
  done
}

function run_stow_target() {
  local target="$1"
  shift
  for dir in "$@"; do
    if [ -d "${DOT_FILES}/${dir}" ]; then
      stow -t "$target" "$dir"
      echo "Stowed $dir -> $target"
    fi
  done
}

# Home-level claude config (~/.claude/)
run_stow claude

# Project-level skills for Obsidian/Ona
if [ -d "/workspaces/obsidian" ]; then
  run_stow_target "/workspaces/obsidian" obsidian
fi
