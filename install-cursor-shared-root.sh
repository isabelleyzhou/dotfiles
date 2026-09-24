#!/usr/bin/env bash

# Install the personal remote Cursor extension after Ona has mounted EFS.
# This script may start before Cursor has downloaded its remote server, so wait
# for the server-side extension installer instead of requiring a live window.

set -u

dotfiles_dir="${HOME}/dotfiles"
vsix_path="${dotfiles_dir}/cursor-shared-root/isabelleyzhou.cursor-shared-root-1.0.0.vsix"
cursor_data_dir="${HOME}/shared/.cursor-server"
extensions_dir="${cursor_data_dir}/extensions"
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

mkdir -p "$extensions_dir"

# Allow up to ten minutes for a first Cursor connection to download its server.
for _attempt in $(seq 1 120); do
  cursor_server="$(
    find "${cursor_data_dir}/bin" -path '*/bin/cursor-server' -type f -perm -u+x \
      -print 2>/dev/null | sort | tail -n 1
  )"

  if [ -n "$cursor_server" ]; then
    if "$cursor_server" --extensions-dir "$extensions_dir" \
      --list-extensions --show-versions 2>/dev/null | grep -qxF "$extension_version"; then
      printf 'Cursor shared-root extension is already installed.\n'
      exit 0
    fi

    "$cursor_server" --extensions-dir "$extensions_dir" \
      --install-extension "$vsix_path" --force
    exit $?
  fi

  sleep 5
done

printf 'Cursor server did not appear within ten minutes; extension was not installed.\n' >&2
exit 1
