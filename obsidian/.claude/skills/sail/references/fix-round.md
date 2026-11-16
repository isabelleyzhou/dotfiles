# Fix round

Resume the original worker in its assigned Ona worktree. If it cannot be
resumed, give a replacement the complete task packet, base/head, review
findings, and ship-log checkpoint. Verify remote path, branch, HEAD, and dirty
state before editing; don't assume a resumed agent's shell is still there.
Use the task's recorded environment and allocation. Before a replacement takes
ownership, confirm the previous writer and mutating processes have ended and
update the assignment; an unreachable worker may still be running in Ona.

Give the worker every review, labeled by author, and indicate independently
shared findings. Include the relevant [testing principles](testing-principles.md).

Ask it to:

1. Fix demonstrated defects in severity order. For every finding, record fixed,
   declined with evidence, or blocked pending a specific decision. A reviewer
   suggestion is not authority to expand the agreed scope.
2. Implement only in the assigned remote worktree and run appropriate lint,
   typecheck, tests, and any changed code-generation checks in Ona. Use the
   current repository instructions, not memorized commands.
3. Preserve commit hooks. Prefer a follow-up commit for a published task;
   do not rewrite published history merely to tidy a fix round.
4. Return the new head SHA, diff stat, fixes, declined findings with reasons,
   unresolved decisions, and validation results/log locations.

The Captain publishes fixes to the existing draft without human approval and
sends blocking fixes and material new changes back for independent verification
against the new head before task completion. Update affected downstream branches
and recheck CI following [Run the voyage](run-voyage.md). Resolve disagreements
with evidence and change approach when retries make no progress. Only a concrete
missing requirement or external blocker warrants interrupting affected work;
routine fix rounds do not require a user decision.

User-requested revisions from local review use this same remote path. Never
ask the user to copy files between checkouts or enter Ona to apply feedback.
