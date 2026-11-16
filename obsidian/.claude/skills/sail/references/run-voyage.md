# Run the voyage

The local Captain coordinates agents and maintains knowledge-base artifacts.
Workers perform product edits in Ona; reviewers inspect those remote changes.
Load [setup](setup.md), resolve required access for the next step, and reuse
existing session authorization.

## Start or resume

1. Read the plan (`executor: sail`), its source Markdown, and any existing ship
   log. Verify task fields, dependencies, and unresolved decisions before work.
2. Record autonomous execution, the per-task environments/worktrees,
   actual reviewer availability, and concurrency limit. Account for runtime
   agent slots and Ona resources; start small rather than launching unlimited
   builds. The Captain must retain capacity to run reviewers.
3. Create/resume the local [dashboard](dashboard.md) and [Mermaid graph](diagram.md).
   Reconcile recorded branches, commit SHAs, worktrees, PR state, and CI against
   reality on resume. Logs are checkpoints, not proof that a process survived.
   Replace legacy human-approval waits with autonomous draft publication.
   Compare source Markdown with the recorded snapshot; if requirements changed,
   reconcile affected tasks and refresh their packets/review before advancing.
4. Establish the [PR sequence](#pr-sequence-and-dependencies). For each task
   whose base is available, [allocate an isolated workspace](worker.md#allocate-isolated-workspaces)
   in a shared or separate Ona instance and record its owner before delegating.
   Reuse a matching task worktree only after verifying ownership, identity,
   changes, and that no earlier writer/process is still active. Queue tasks
   when allocations or shared runtime resources conflict. Do not create
   duplicate PRs on resume.

## Per-task loop

1. **Working:** the worker implements, validates, and commits in Ona. Record its
   immutable base and head SHAs plus command results. Compare the remote main
   checkout in that task's instance with its initial snapshot. If isolation was
   violated, stop that task and inspect the changes; never automatically
   restore/delete files that might belong to the user or another task.
2. **PR created:** use the [worker's publication procedure](worker.md#publish)
   as soon as the implementation commit can be pushed. Open or update the draft
   without waiting for human approval, independent review, or green CI. Record
   outstanding validation and findings honestly in the draft.
3. **Evaluating:** delegate [independent review](evaluator.md) of the pinned
   remote diff. Wait for all assigned reviewers; account for an unavailable or
   failed reviewer explicitly instead of recording it as passed.
4. **Fixing:** resume the original worker with [findings](fix-round.md). Require
   a disposition for each finding and appropriate revalidation. Have reviewers
   verify blocking fixes and material new changes on the new head. Push fixes
   to the existing draft automatically. After two cycles without progress,
   change the diagnosis or approach; do not turn the retry limit into a human
   approval gate. Escalate only a concrete blocker that cannot be resolved
   within the authorized scope, and continue unaffected work.
5. **CI:** track every draft from the local session. Diagnose Buildkite locally
   and send failure evidence to Ona for fixes and validation. Retry transient
   failures when evidence supports it; investigate repeated failures instead
   of blindly rerunning them. Keep working through pending or failing checks.
   Never bypass hooks, disable checks, or weaken tests to obtain green CI.
6. **PR green:** record the exact published head and observed CI results. All
   required checks must pass and no applicable CI check may remain pending or
   failing. Verify that expected checks actually ran; missing checks are not
   passing evidence. A new commit or base update invalidates earlier CI evidence
   and requires checking the resulting diff for review changes. Keep the PR in
   draft; human review can happen asynchronously. No merge or auto-merge occurs.

Update the ship log and its Mermaid diagram after each transition. Use agent
notifications and supported waits for ongoing work. Use bounded CI polls while
continuing task/review/fix work, and keep the session working until the completion
criteria are met. Pending CI or a user who has not reviewed drafts is not a
reason to end the voyage. Do not promise monitoring after the session ends
unless an actual persistent mechanism has been established.

## PR sequence and dependencies

Use ordinary Git branches and draft PRs. Do not create or enroll PRs in GitHub
native stacks. Choose a linear task order that respects all code dependencies;
use plan order to break ties and record the sequence in the ship log.

- The first task branches from and targets the intended project base, normally
  the repository's default branch unless the project specifies another base.
- Every later task branches from the preceding task PR's verified published
  head and sets its PR base to that feature branch, including tasks with no
  direct code dependency. Record the base branch, pinned base SHA, and preceding
  PR URL. For example: `task-1 → main`, `task-2 → task-1`, `task-3 → task-2`.
- Continue to later tasks once their implementation base is available; do not
  wait for human review, an upstream merge, or upstream CI to finish before
  creating their drafts. The linear history must contain every prerequisite;
  inspect actual ancestry rather than assuming the sequence guarantees it.
- When an upstream head changes, update affected descendants in sequence,
  preserve each task's focused diff, resolve conflicts in Ona, and rerun the
  affected validation, review, and CI. Inspect history and diff after an external
  merge before retargeting; use the intended project base once the predecessor
  has merged there. Never treat green CI as a merge.

Retain worktrees/branches while CI fixes, review, or dependent work needs them.
Only remove a voyage-owned worktree once it is clean, its commits are preserved,
and no active agent is using it. Never force-remove dirty worktrees or delete
someone else's branches to finish a voyage. Rejecting a task records its state
and preserves evidence; it is not permission to discard changes.

Finish successfully only when every task has its draft PR, blocking findings
are resolved, and every PR is green at its current published head and base.
Report all PR URLs, their base branches, verified validation, and the local plan
and ship-log paths. If an external blocker makes completion impossible, report
the exact blocker and remaining work separately; do not label the voyage done.
