---
name: isabelle-pr-review
description: Self-review your PR before sending to reviewers — adds categorized inline TODO comments to flag issues
---

# PR Self-Review

Perform a first-pass review of the current branch's PR so it's ready for a human reviewer. The goal is to catch issues before they reach the reviewer's eyes.

## Workflow

1. **Identify changed files**: Run `git diff main...HEAD --name-only` to get the list of files changed on this branch.
2. **Read each changed file** and review the diff (`git diff main...HEAD -- <file>`) for the categories below.
3. **Add inline comments** directly in the source code at the relevant line. Every comment MUST follow this exact format:

```
// TODO-ISABELLE-PR-REVIEW #<id> [<category>]: <message>
```

Where `<id>` is a unique sequential integer starting at 1 (incremented per comment across all files), and `<category>` is one of `nit`, `suggest`, or `disc` (see below). The ID makes each comment individually referenceable (e.g. "fix #3", "drop #7").

4. **After reviewing all files**, print a summary listing:
   - Total comments added, broken down by category
   - Files that were commented on
   - Any files that lack unit test coverage for the changes made
5. **Generate a PR description** using the format in the "PR Description Output" section below. Print it as the very last thing in the skill output, after the review summary.

## Comment Categories

### `[nit]` — Small, easy fixes
Formatting issues, typos, naming inconsistencies, minor style problems, unused imports, trailing whitespace, etc. These should be quick to resolve.

**Example:**
```ts
// TODO-ISABELLE-PR-REVIEW #1 [nit]: Variable name `d` is not descriptive — consider `durationMs` or similar
const d = Date.now() - start;
```

### `[suggest]` — Substantive improvements with a proposed fix
Harder issues where you have a concrete idea of how to fix them. Include the suggestion in the comment. Covers things like missing error handling, better abstractions, performance improvements, or clearer logic.

**Example:**
```ts
// TODO-ISABELLE-PR-REVIEW #2 [suggest]: This block duplicates the logic in `validateInput()` above — consider extracting a shared helper
if (input.length > 0 && input !== 'default') {
```

### `[disc]` — Needs discussion
Architectural questions, trade-off decisions, or unclear requirements where you don't have a clear fix. These flag areas where the author should think more or discuss with the team.

**Example:**
```ts
// TODO-ISABELLE-PR-REVIEW #3 [disc]: Should this silently swallow the error? The caller may need to know about failures here
} catch (e) {
  return null;
}
```

## What to Review

### Code Correctness
- Variables that are declared but never used
- Variables that are used but never declared or imported
- Code paths that are unreachable under certain conditions (dead code)
- Off-by-one errors, missing null checks, incorrect boolean logic
- Race conditions or async issues (missing `await`, unhandled promises)

### Code Readability
- Unclear variable or function names
- Overly complex expressions that could be simplified
- Missing or misleading comments on non-obvious logic
- Long functions that should be broken up
- Magic numbers or strings that should be named constants

### Encapsulation
- Implementation details leaking through public interfaces
- Functions doing too many things (violating single responsibility)
- Tight coupling between modules that should be independent
- State being mutated from unexpected places

### Unit Test Coverage
- New functions or methods that lack corresponding tests
- Changed logic paths that aren't covered by existing tests
- Edge cases that should be tested but aren't
- If test files exist for the changed modules, check they cover the new/changed code

## Rules

- Do NOT modify any code other than adding `// TODO-ISABELLE-PR-REVIEW #<id>` comments.
- Do NOT remove or change existing code, comments, or formatting.
- Place each comment on the line directly above the code it refers to.
- Be specific and actionable in every comment — vague feedback is not helpful.
- When in doubt about severity, prefer `[suggest]` over `[disc]`. Only use `[disc]` when genuinely uncertain.
- For test files, only flag issues if the test itself is incorrect or misleading — don't flag test style nits.

## PR Description Output

After the review summary, always emit a PR description for the current branch in the exact markdown format below. Derive the content from `git log main..HEAD`, the cumulative diff, and the user's prompts in the current conversation — keep it succinct, prefer the imperative voice for changes, and don't pad. Print it as a fenced ` ```markdown ` block so the user can copy/paste cleanly into GitHub.

```markdown
## Changes
- <one bullet per meaningful change; refer to specific files/symbols where it helps the reviewer>

## Motivation
<1–3 sentences. Why this PR exists. If it's part of a larger plan/migration, name the plan and where this PR fits.>

## Testing
- <new/updated tests, what they cover, and pass count if relevant>
- <typecheck / lint scope and result>

## Deployment
<Plain rollout steps. Note any feature flag, migration, or staging concerns. If unflagged and uneventful, say "Standard deploy — no flag, no migration.">

**Feature Flag Name:** `<flag_name_or_n/a>`

## AI Model used and major prompts used
<Model name and "(1M context)" if applicable, e.g. "Opus 4.7 (1M context)".>

- "<verbatim or near-verbatim user prompt>" — <one-line summary of what it produced>
- <repeat for each major prompt that shaped the PR; skip trivial back-and-forth>
```

**Filling rules:**
- **Changes**: enumerate from the commit log + diff, grouping related commits into a single bullet. Don't list every commit verbatim.
- **Feature Flag Name**: pull from the branch's diff (look for `StatsigFeatureFlag.X` additions or new `Statsig`/feature-flag enum entries). If the PR doesn't introduce or rely on a flag, write `n/a`.
- **AI Model**: read the current model from the runtime ("You are powered by..." line in the system prompt). Include the context-window suffix when present.
- **Major prompts**: pick the user prompts in this conversation that drove substantive direction changes (initial implementation request, refactor requests, structural decisions). Skip pure mechanics ("force push", "yes", "ok"). Each entry: short quote of the prompt, em-dash, what it produced.
- If any section genuinely has nothing to say, omit the bullet but keep the heading and write `n/a`.
