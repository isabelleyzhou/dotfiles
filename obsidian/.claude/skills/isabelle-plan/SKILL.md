---
name: isabelle-plan
description: Create and store project plans in the shared plans directory with required code examples
---

# Plan Creation

All plans must be stored in `/workspaces/obsidian/.claude/plans/`. This directory is symlinked from dotfiles and shared across all Ona instances.

## File format

- Use markdown (`.md`) files
- Name files descriptively in kebab-case (e.g., `auth-migration-plan.md`, `risk-dashboard-refactor.md`)

## Required structure

Every plan must include:

1. **Title and goal** — what this plan accomplishes
2. **Steps** — ordered list of changes to make
3. **Code examples** — every proposed change must include a concrete code example showing what the code looks like before and after, or what new code will be added. Do not describe changes in prose alone.

## Tips

- All changes must have a code example. Show the actual code that will be written or modified, not just a description of what to do. Use fenced code blocks with the appropriate language tag.
- When modifying existing code, show a before/after pair so the diff is clear.
- When adding new code, show the full snippet in context (include surrounding lines or the file path).
