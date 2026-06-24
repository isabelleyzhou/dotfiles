#!/usr/bin/env sh
# Ona/Gitpod injects a GITHUB_TOKEN that is NOT valid for the GitHub API, and `gh`
# prefers it — so `gh` calls 401 even though `git` push/pull work. The Ona git
# credential helper does hold a VALID github.com token, so derive GH_TOKEN (which
# `gh` prefers over GITHUB_TOKEN) from that helper. The token value is never printed.
#
# Sourced from ~/.zshrc and ~/.bashrc (the latter wired up by install.sh).
if command -v gh >/dev/null 2>&1 && command -v git >/dev/null 2>&1 && [ -z "${GH_TOKEN:-}" ]; then
  __ona_gh_tok="$(printf 'protocol=https\nhost=github.com\n\n' | git credential fill 2>/dev/null | sed -n 's/^password=//p')"
  if [ -n "${__ona_gh_tok:-}" ]; then
    export GH_TOKEN="$__ona_gh_tok"
  fi
  unset __ona_gh_tok
fi
