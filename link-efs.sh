#!/usr/bin/env sh
# Ona attaches the EFS share at /home/vscode/shared AFTER personal dotfiles run, so
# install.sh can't reliably create this link at provision time (the mount isn't there
# yet). Create it at shell startup instead: by the time a terminal opens, both the
# Obsidian workspace and the EFS mount exist. Idempotent — safe to source every shell.
#
# Result: /workspaces/obsidian/isabelle-ai-plans -> /home/vscode/shared (git-excluded).
# Sourced from ~/.zshrc and ~/.bashrc (the latter wired up by install.sh).
_obsidian_dir="/workspaces/obsidian"
_shared_dir="/home/vscode/shared"
_link_path="${_obsidian_dir}/isabelle-ai-plans"
if [ -d "$_obsidian_dir" ] && [ -d "$_shared_dir" ] && [ ! -e "$_link_path" ]; then
  ln -sfn "$_shared_dir" "$_link_path"
  # Keep the personal symlink out of git status.
  if [ -d "${_obsidian_dir}/.git/info" ]; then
    grep -qxF '/isabelle-ai-plans' "${_obsidian_dir}/.git/info/exclude" 2>/dev/null ||
      printf '%s\n' '/isabelle-ai-plans' >> "${_obsidian_dir}/.git/info/exclude"
  fi
fi
unset _obsidian_dir _shared_dir _link_path
