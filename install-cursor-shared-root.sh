#!/usr/bin/env bash

# Install the personal remote Cursor extension after Ona has mounted EFS.
# Fresh environments can use a per-instance ~/.cursor-server directory instead
# of the EFS copy. Pre-create its extension directory and install into both
# profiles before Cursor first connects; this does not require a live window IPC
# socket. If EFS has no Cursor binary yet, wait for the first connection to
# download one and then install for the next reload.

set -u

dotfiles_dir="${HOME}/dotfiles"
vsix_path="${dotfiles_dir}/cursor-shared-root/isabelleyzhou.cursor-shared-root-1.0.0.vsix"
live_data_dir="${HOME}/.cursor-server"
efs_data_dir="${HOME}/shared/.cursor-server"
extension_version="isabelleyzhou.cursor-shared-root@1.0.0"
lock_dir="/tmp/isabelleyzhou-cursor-shared-root-install.lock"

if ! mkdir "$lock_dir" 2>/dev/null; then
  exit 0
fi
trap 'rmdir "$lock_dir" 2>/dev/null || true' EXIT

if [ ! -f "$vsix_path" ]; then
  printf 'Cursor shared-root VSIX is missing: %s\n' "$vsix_path" >&2
  exit 1
fi

find_cursor_server() {
  find "${live_data_dir}/bin" "${efs_data_dir}/bin" \
    -path '*/bin/cursor-server' -type f -perm -u+x -print 2>/dev/null |
    sort | tail -n 1
}

install_into() {
  local cursor_server="$1"
  local data_dir="$2"
  local extensions_dir="${data_dir}/extensions"

  mkdir -p "$extensions_dir"
  if "$cursor_server" --extensions-dir "$extensions_dir" \
    --list-extensions --show-versions 2>/dev/null | grep -qxF "$extension_version"; then
    printf 'Cursor shared-root extension is already installed in %s.\n' "$data_dir"
    return 0
  fi

  "$cursor_server" --extensions-dir "$extensions_dir" \
    --install-extension "$vsix_path" --force
}

efs_installed=0

# On the normal path, the existing EFS Cursor binary installs into the fresh
# local profile immediately. Wait up to 24 hours only for a brand-new EFS volume
# that has never downloaded a Cursor server.
for _attempt in $(seq 1 17280); do
  cursor_server="$(
    find_cursor_server
  )"

  if [ -n "$cursor_server" ]; then
    if [ "$efs_installed" -eq 0 ]; then
      install_into "$cursor_server" "$efs_data_dir"
      efs_installed=1
    fi

    install_into "$cursor_server" "$live_data_dir"
    exit 0
  fi

  sleep 5
done

printf 'The live Cursor server did not appear within 24 hours; extension was not installed there.\n' >&2
exit 1
