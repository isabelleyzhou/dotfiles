# User-level instructions

These rules apply across all Ona instances and override defaults from any installed skills (including superpowers).

## Plans

When any superpowers planning skill activates (`writing-plans`, `write-plan`, `brainstorming`, `executing-plans`, etc.) or the user asks for a plan / spec / design doc, write the file to `.claude/plans/<kebab-case-name>.md` at the project root. In the obsidian workspace this resolves to `/workspaces/obsidian/.claude/plans/`, which is symlinked from `~/dotfiles/obsidian/.claude/plans/` and shared across instances.

Do **not** write plans to `docs/superpowers/specs/` — that directory is off-limits even though several superpowers skills default to it. If a skill instructs you to write there, override and use `.claude/plans/` instead.

Follow the structure documented in the `isabelle-plan` skill: title and goal, PR breakdown table, TDD commit breakdown per PR, and concrete before/after code examples for every proposed change.

## Implementing plans (subagent-driven development)

When executing a plan with the `subagent-driven-development` skill (or any subagent-driven implementation loop):

- **Run all tasks on a single branch.** Do not create per-PR branches during execution — keeping everything on one branch surfaces integration issues as the work progresses. Slice the branch into stacked per-PR branches only at the **end**, once the work has settled.
- **Make every implementer and fix subagent lint before committing.** Each dispatch prompt must require `yarn eslint <changed files>` → 0 errors (pre-existing warnings are OK) before the commit. Lint is on-demand in this repo, so subagents won't run it by default; requiring it per task keeps the single branch continuously lint-clean and easy to slice into clean stacked PRs afterward (otherwise lint debt pools into a cross-cutting commit that muddies the split).
