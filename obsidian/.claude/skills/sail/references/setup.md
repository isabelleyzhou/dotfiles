# Setup: the agent connects to Ona

Run checks from the local knowledge-base session. Reuse a working connection
and choices from the current session; do not make the user SSH manually.
Planning needs only the Markdown inputs, plus remote code inspection when
needed. Check execution dependencies when execution is requested.

## Local inputs and tools

- Find the relevant Markdown specs/RFCs under `plans/` or the user's chosen
  directory. Read repository instructions and related plans, decisions,
  `backlog/`, and `onboarding/` context as applicable. Onboarding transcripts
  are dated evidence, not current code truth.
- Resolve conflicting specs or missing product decisions with the user. A
  missing original Google Doc, Jira ticket, or Slack thread is not a blocker
  when the supplied Markdown contains the requirements. Do not require their
  connectors, credentials, CLIs, or live synchronization.
- Inspect the current runtime's delegation tools and available slots. Native
  agents can operate through the same local SSH access. A second model family
  is useful when already available, but not required; record actual reviewers.
- Use connected GitHub tools when sufficient, or authenticated `gh`. Check
  publication access before the PR step. Do not install remote model CLIs or
  copy local service/model credentials into Ona to satisfy an optional reviewer.

## Select and verify the environment

Run these checks for every instance used by the voyage. Record connections per
task, rather than assuming all workers share a single default SSH target. Choose
worktrees within an instance or distinct instances using the [allocation
rules](worker.md#allocate-isolated-workspaces).

1. Reuse the environment explicitly named by the user or recorded for this
   task. Otherwise run locally:

   ```bash
   gitpod environment list
   gitpod environment ssh --help
   ```

   Prefer the user's available running Obsidian environment. If multiple
   environments are plausible and context does not distinguish them, ask which
   one; don't silently attach to unrelated work. Record the chosen environment
   ID and any non-default CLI context. Never hard-code a personal ID in this skill.

2. `gp-ssh` may be an interactive shell function using `fzf`, and may not be
   defined in the agent's shell. Do not invoke an interactive picker for an
   unattended task. Use the explicit-ID command supported by installed CLI help:

   ```bash
   gitpod environment ssh <environment-id> -- pwd
   ```

   If native SSH is already configured, reuse its verified host alias instead:

   ```bash
   ssh <verified-host-alias> 'pwd'
   ```

   Ona versions can use different host suffixes (`.ona.environment` or older
   `.gitpod.environment`). Inspect installed CLI help/config rather than guessing
   an alias or rewriting SSH configuration unnecessarily.

3. Inspect the remote working directory and locate its actual Obsidian checkout.
   Do not assume `/workspaces/obsidian` or a local path. Using the verified path,
   inspect remote `git remote -v`, `git status --short`, branch, HEAD, and
   `git worktree list`. Verify this is `VantaInc/obsidian`. Read the checkout's
   `AGENTS.md` and applicable parent/directory instructions before setup or edits.

4. Record the connection command/context, remote checkout, initial branch/HEAD
   and dirty paths, and the selected base ref for each instance/task in the
   local ship log. Inspect remote setup and worktree guidance. Do not switch,
   clean, reset, stash, or overwrite someone else's main checkout to make a
   pre-flight check pass.

If access fails, report the actual error and smallest user action required
(for example, authenticating the local Gitpod context). Do not print tokens,
change identities, or fall back to implementing product code locally. Continue
independent Markdown planning while connection-dependent work is blocked.

## Command boundary

Every code command must explicitly target the recorded remote worktree. A local
`cd` and a previous SSH call do not change a later command's remote directory.
Use quoted heredocs for multi-line scripts to avoid local shell expansion:

```bash
gitpod environment ssh <environment-id> -- bash -s <<'REMOTE'
set -euo pipefail
cd '<verified-remote-worktree>'
git rev-parse --show-toplevel
git branch --show-current
git status --short
REMOTE
```

Replace placeholders before execution, safely quoting actual values. With a
verified native alias, the equivalent transport is `ssh <alias> 'bash -s'`.
Run a read-only identity probe through the chosen transport before using it
for writes. Preserve remote exit codes; collect long-running command results
and logs rather than treating a dropped SSH connection as success. On reconnect,
inspect the worktree and running processes before retrying a command that may
still be running.

## CI access stays local

Read GitHub check state and Buildkite logs from the local environment. Buildkite
access is configured under `~/.config/buildkite`; use it without printing or
copying its token. Pass only relevant, redacted failures to Ona workers. Run
resulting fixes and validation remotely. Do not invoke a remote CI skill that
requires local-only credentials without adapting this boundary.
