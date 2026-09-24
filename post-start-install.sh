#!/usr/bin/env bash

# Ona runs this after persistent EFS is mounted. Installation continues in the
# background because Cursor may not have connected (and downloaded its server)
# yet. The extension itself activates on editor connection.

set -u

installer="${HOME}/dotfiles/install-cursor-shared-root.sh"
log_file="${HOME}/.cursor-shared-root-install.log"

if [ -x "$installer" ]; then
  nohup "$installer" >>"$log_file" 2>&1 </dev/null &
fi

# Remove the exact symlink created by the previous shell-startup workaround.
old_link="/workspaces/obsidian/isabelle-ai-plans"
if [ -L "$old_link" ] && [ "$(readlink "$old_link")" = "/home/vscode/shared" ]; then
  rm "$old_link"
fi
