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
// TODO-ISABELLE-PR-REVIEW [<category>]: <message>
```

Where `<category>` is one of `nit`, `suggest`, or `disc` (see below).

4. **After reviewing all files**, print a summary listing:
   - Total comments added, broken down by category
   - Files that were commented on
   - Any files that lack unit test coverage for the changes made

## Comment Categories

### `[nit]` — Small, easy fixes
Formatting issues, typos, naming inconsistencies, minor style problems, unused imports, trailing whitespace, etc. These should be quick to resolve.

**Example:**
```ts
// TODO-ISABELLE-PR-REVIEW [nit]: Variable name `d` is not descriptive — consider `durationMs` or similar
const d = Date.now() - start;
```

### `[suggest]` — Substantive improvements with a proposed fix
Harder issues where you have a concrete idea of how to fix them. Include the suggestion in the comment. Covers things like missing error handling, better abstractions, performance improvements, or clearer logic.

**Example:**
```ts
// TODO-ISABELLE-PR-REVIEW [suggest]: This block duplicates the logic in `validateInput()` above — consider extracting a shared helper
if (input.length > 0 && input !== 'default') {
```

### `[disc]` — Needs discussion
Architectural questions, trade-off decisions, or unclear requirements where you don't have a clear fix. These flag areas where the author should think more or discuss with the team.

**Example:**
```ts
// TODO-ISABELLE-PR-REVIEW [disc]: Should this silently swallow the error? The caller may need to know about failures here
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

- Do NOT modify any code other than adding `// TODO-ISABELLE-PR-REVIEW` comments.
- Do NOT remove or change existing code, comments, or formatting.
- Place each comment on the line directly above the code it refers to.
- Be specific and actionable in every comment — vague feedback is not helpful.
- When in doubt about severity, prefer `[suggest]` over `[disc]`. Only use `[disc]` when genuinely uncertain.
- For test files, only flag issues if the test itself is incorrect or misleading — don't flag test style nits.
