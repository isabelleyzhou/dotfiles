---
name: isabelle-merge-main
description: Merge latest origin/main into the current branch, resolve conflicts correctly, verify with tests, and leave changes unstaged for review
---

# Merge Main Into Current Branch

Fetch the latest `origin/main`, merge it into the current branch, resolve conflicts in a way that preserves both the PR's intent and correctness against the new main, verify with tests, and leave the final changes unstaged so the user can review before committing.

## Workflow

### 1. Ensure origin is up to date

```bash
git fetch origin
```

Then check for any pre-existing merge state (aborted/in-progress merges from past attempts):

```bash
git status
cat .git/MERGE_MSG .git/MERGE_HEAD 2>/dev/null
```

If a merge is already in progress, surface this to the user and ask whether to (a) complete it and then merge latest, or (b) abort and restart against latest `origin/main`. Do NOT silently abort — the in-progress state may contain hand-resolved conflicts the user wants to keep.

### 2. Merge origin/main into the current branch

```bash
git merge origin/main --no-edit
```

If the merge succeeds cleanly with no conflicts, skip to step 4 (tests).

### 3. Resolve each conflict preserving PR integrity AND correctness

For each conflicted file:

1. **Locate all conflict markers**:
   ```
   Grep pattern: "<<<<<<<|=======|>>>>>>>"
   ```

2. **Read enough surrounding context** (15-30 lines each side) to understand what each hunk is doing — not just the conflict chunk itself.

3. **Classify each conflict** before picking a resolution:
   - **Complementary additions** (both sides add different things at the same location): usually keep both, but verify neither side makes the other redundant.
   - **Same intent, different implementations**: pick whichever fits the surrounding code and the current codebase conventions.
   - **One side removed what the other modified**: check whether the removal was intentional (graduation, deprecation, rename). If origin/main removed something, that's usually authoritative — your branch's reference to it is stale.
   - **Your branch renamed/moved something that main modified**: apply main's modification to the renamed location.

4. **After textual resolution, check for semantic duplication**. The common trap: your branch added helper A that internally does X, and origin/main added an explicit call to X. Keeping both causes double-execution (duplicate key errors, double side effects, etc.). Search the surrounding test/function body for any call that would subsume what you just kept.

5. **Check for stale references**. If your branch references a symbol (feature flag, function, type, file) that origin/main modified or removed:
   - Grep the source for the symbol's current definition — don't trust `dist/` or generated files, which may be stale until `just post-pull` rebuilds.
   - If the symbol is gone, remove your branch's usage of it (don't try to resurrect it unless you confirm with the user).

6. **Verify imports**. If a resolution introduces a new symbol (e.g., you keep a call from main that uses a helper not previously imported in your branch's file), add the import. Check the package's public exports to find the right source.

7. **Eliminate conflict markers** and confirm:
   ```bash
   Grep pattern: "<<<<<<<|=======|>>>>>>>"
   ```
   Should return zero matches.

### 4. Run the environment sync and tests

New files from main may reference generated artifacts that don't exist in your local `dist/`. Before running tests:

```bash
just post-pull  # 10-minute timeout; rebuilds generated types and dist files
```

Then run tests for the affected files:

```bash
just unit-test <relative-path-to-changed-test-file>
```

Per the user's memory: use `--output-logs=new-only` for turbo test runs, not `errors-only` (which hides mocha results).

If tests fail:
- **Duplicate key errors / duplicate side effects**: look for the semantic-duplication trap from step 3.4.
- **`MODULE_NOT_FOUND` errors**: run `just post-pull` once more, then retry. Per AGENTS.md, this is the most common cause of build failures after a merge.
- **Type errors (TS2339 etc.)**: the referenced symbol likely moved/was removed in main — see step 3.5.

Iterate on the conflict resolution until tests pass. Do NOT proceed to step 5 with failing tests.

### 5. Lint and format the resolved files

```bash
npx eslint --fix <resolved-files>
npx oxfmt --write <resolved-files>
```

### 6. Commit the merge, then unstage the conflict-resolution fixes

The merge commit itself should be committed so the git history remains coherent (the working tree can't stay mid-merge). But leave any **post-merge correctness fixes** (changes you made that went beyond the initial textual conflict resolution) unstaged for the user to review.

Practically:
- If you only did textual conflict resolution → stage the resolved files and commit the merge.
- If you made additional correctness changes after discovering test failures → commit the initial merge resolution, then leave the follow-up fixes unstaged:
  ```bash
  git reset HEAD -- <files-with-correctness-fixes>
  # Files remain modified in working tree but not staged
  ```

Alternative interpretation if the user prefers: leave EVERYTHING unstaged (abort the merge, reapply resolutions manually). Confirm with the user which they want before committing the merge if substantial correctness fixes were needed.

### 7. Summary

Print a structured summary covering:
- **Commits pulled in**: `git log --oneline HEAD^1..HEAD^2 | wc -l` commits from origin/main
- **Files with conflicts**: list each file
- **For each conflict file**: a 1-2 sentence description of the resolution strategy (kept both / preferred main / preferred HEAD / removed stale reference / etc.)
- **Correctness fixes beyond textual resolution**: what was changed and why (e.g., "removed 3 redundant `createVendorDomainConfig` calls — the adjacent `createSecurityAssessmentType` factory now creates one internally")
- **Stale references removed**: any symbols/flags/functions from your branch that no longer exist in main
- **Tests run and their results**
- **What is staged vs. unstaged**: so the user knows exactly what to review

## Common traps

- **Auto-merge is not semantic merge**: git's auto-merge succeeds at the text level but may produce broken code (duplicate calls, missing imports, stale references). Always run tests.
- **Dist files lie**: `dist/` and `__generated__/` directories may contain stale symbols after a merge. Check source (`src/`) to verify what actually exists.
- **Feature flag graduations**: if your branch gates behavior behind a flag and main has graduated/removed that flag, remove the gate — don't reintroduce the flag.
- **Factory-level side effects**: test factories often create related records (e.g., `createSecurityAssessmentType` also creates `VendorDomainConfig`). If your branch introduced a factory call and main added an explicit call to something the factory also creates, you have a duplicate.
- **Don't auto-abort in-progress merges**: the user may have hand-resolved conflicts in a prior session. Always ask.
