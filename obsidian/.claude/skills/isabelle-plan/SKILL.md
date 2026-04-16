---
name: isabelle-plan
description: Create and store project plans in the shared plans directory with required code examples
---

# Plan Creation

**Do NOT enter plan mode.** Write the plan directly as a markdown file. Do not edit any code or make any changes to the codebase until the user explicitly gives the OK to proceed with implementation.

All plans must be stored in `/workspaces/obsidian/.claude/plans/`. This directory is symlinked from dotfiles and shared across all Ona instances.

## Workflow

1. Research the codebase as needed to inform the plan (read files, search, etc.)
2. Write the plan to a `.md` file in `/workspaces/obsidian/.claude/plans/`
3. Output only the file path — do not display plan content in chat
4. **Stop and wait.** Do not edit any code until the user says to proceed.

## File format

- Use markdown (`.md`) files
- Name files descriptively in kebab-case (e.g., `auth-migration-plan.md`, `risk-dashboard-refactor.md`)

## Required plan structure

Every plan must include:

1. **Title and goal** — what this plan accomplishes
2. **PR breakdown** — every plan must be broken into multiple PRs (see below)
3. **TDD commit breakdown within each PR** — every PR must begin with a tests-first commit (see below)
4. **Code examples** — every proposed change must include a concrete code example showing what the code looks like before and after, or what new code will be added. Do not describe changes in prose alone.

## PR breakdown

Always break the work into multiple PRs. Each PR should be a reviewable, shippable unit. Include:

1. **PR summary table** at the top — a table with columns: PR number, short title, and dependencies (which PRs must land first). Example:

   | PR | Title | Dependencies |
   |----|-------|-------------|
   | PR 1 | Add fields to schema and entity | None |
   | PR 2 | Wire up writers with dual-write | PR 1 |
   | PR 3 | Switch readers to new source with fallback | PR 2 |

2. **Per-PR sections** — for each PR, list everything that needs to happen:
   - All files that will be created or modified
   - Code examples (before/after) for each change
   - The TDD commit breakdown (see below)
   - Any migration scripts, feature flags, or deployment considerations

Think about ordering PRs to minimize risk: additive/data-layer changes first, then writers (dual-write when transitioning), then readers (with fallback), then migrations, then cleanup.

## TDD commit breakdown (required for every PR)

Every PR must be developed test-first. Structure each PR as a sequence of commits, where **the first commit adds the tests that define the behavior** and subsequent commits make those tests pass.

For every PR, include a **Commit plan** subsection with at minimum:

1. **Commit 1 — Tests defining behavior** (always first)
   - List every test file that will be created or modified
   - Show the full test code (cases, assertions, fixtures) using fenced code blocks
   - State which tests are expected to fail initially, and what failure mode proves the behavior isn't yet implemented (e.g., "expect 404, gets 200" or "throws TypeError: fn is not a function")
   - If the behavior requires new types, interfaces, or function signatures to be importable for the tests to even compile, call out the minimal stubs needed (empty implementations / `throw new Error('not implemented')`) and put those in this same commit — the tests must still fail at runtime
   - Note the exact command to run the tests (e.g., `just unit-test path/to/file.test.ts`)

2. **Commit 2+ — Implementation** (makes the tests from commit 1 pass)
   - List every non-test file that will be created or modified
   - Show before/after code examples
   - Map each implementation change back to which test(s) from commit 1 it satisfies
   - If the implementation is large, split into multiple commits — each one should make a specific subset of the failing tests pass, and the test suite should be strictly greener after each commit

3. **Commit N (optional) — Refactor**
   - Only if the implementation warrants cleanup after tests pass
   - Tests must remain green; no behavior changes

### Example commit plan section

```markdown
### PR 2 commit plan

**Commit 1: Add tests for dual-write behavior**
- Modify: `packages/foo/src/writer.test.ts`
- Add cases: writes to both old and new stores; rolls back new store on old-store failure; emits metric on divergence
- Expected failure: `TypeError: dualWrite is not a function` (function doesn't exist yet)
- Run: `just unit-test packages/foo/src/writer.test.ts`

**Commit 2: Implement dualWrite**
- Modify: `packages/foo/src/writer.ts` — add `dualWrite` satisfying the three test cases above
- Modify: `packages/foo/src/metrics.ts` — add `divergenceCounter` used by the third test case
```

## Tips

- All changes must have a code example. Show the actual code that will be written or modified, not just a description of what to do. Use fenced code blocks with the appropriate language tag.
- When modifying existing code, show a before/after pair so the diff is clear.
- When adding new code, show the full snippet in context (include surrounding lines or the file path).
- Tests are not an afterthought — they are the specification. Write the test code in the plan with the same care as the implementation code.
