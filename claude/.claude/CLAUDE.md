# User-level instructions

These rules apply across all Ona instances and override defaults from any installed skills (including superpowers).

## Plans

When any superpowers planning skill activates (`writing-plans`, `write-plan`, `brainstorming`, `executing-plans`, etc.) or the user asks for a plan / spec / design doc, write the file to `.claude/plans/<kebab-case-name>.md` at the project root. In the obsidian workspace this resolves to `/workspaces/obsidian/.claude/plans/`, which is symlinked from `~/dotfiles/obsidian/.claude/plans/` and shared across instances.

Do **not** write plans to `docs/superpowers/specs/` — that directory is off-limits even though several superpowers skills default to it. If a skill instructs you to write there, override and use `.claude/plans/` instead.

Follow the structure documented in the `isabelle-plan` skill: title and goal, PR breakdown table, TDD commit breakdown per PR, and concrete before/after code examples for every proposed change.
