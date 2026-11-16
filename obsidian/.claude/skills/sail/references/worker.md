# Worker

## Allocate isolated workspaces

Choose the isolation arrangement before dispatching parallel workers:

| Arrangement | Use when | Allocation |
|---|---|---|
| Separate worktrees in one Ona instance | Tasks can share the instance's runtime safely | A distinct remote worktree and branch for every writing worker |
| Separate Ona instances | Tasks need separate services, ports, databases, setup, or more resources | A distinct verified instance and task checkout/worktree for every writing worker |

Use available instances within the user's selected resources. If neither
arrangement is available, run tasks sequentially; do not share a writable
checkout to achieve concurrency or provision extra instances without scope to
do so. An agent's separate SSH session is not filesystem isolation.

The Captain allocates each `(environment ID, canonical worktree path)` to one
writer and records the task, branch, and owning agent in the ship log before
dispatch. Give branches and paths a unique run/task suffix so simultaneous
voyages do not collide. A task branch has one writer across all instances;
different machines must not independently commit/push the same branch.

Inspect each instance's existing worktrees and active assignments/processes
before allocation. A clean worktree is not evidence that it is unused. Create
a fresh task worktree unless resuming a verified assignment. If a branch/path
already exists unexpectedly, allocate another unique one rather than reset,
force checkout, or remove it. For a handoff, confirm the previous writer and
its mutating child processes have finished before assigning a replacement.

Worktrees isolate files, but can still share Git metadata, ports, databases,
containers, and mutable setup outputs. Coordinate checkout-wide setup/ref
maintenance; namespace supported test/service resources or serialize conflicting
commands. Use a separate instance when local runtime isolation is needed, and
verify it does not point at the same shared external test resources.

Reviewers may share a task worktree read-only while its writer is paused. Resume
writing only after those reviews finish; a reviewer that needs to generate
files or run mutating checks needs its own allocation.

## Prepare a remote worktree

The Captain owns task branch/base selection and worktree allocation. Use the
user's branch convention or infer it from existing task branches; resolve the
authenticated GitHub identity if a prefix is needed. Store the actual paths
and refs in the local ship log, not reusable skill files.

Inspect the remote repo's worktree/setup guidance. Use its supported `wt`
workflow if present and understood, otherwise remote `git worktree add`:

```bash
# Inside the agent-issued remote script, with verified, quoted actual values:
git -C '<remote-checkout>' worktree add -b '<task-branch>' '<remote-worktree>' '<base-sha>'
```

Fetch the intended remote base when necessary and pin its SHA. Follow the
Captain's linear PR sequence: the first task uses the project base; each later
task uses the immediately preceding task PR's verified published head and
feature branch as its base. Record the PR's base branch separately from its
pinned SHA. Use ordinary branches and PRs without GitHub native stacks.
If the dependency was built in another instance, fetch its published branch
into the assigned instance and verify the expected SHA; its filesystem path
and local Git refs do not exist here automatically.
Check that the target branch/path is unused before creation. A dirty main
checkout need not be cleaned or switched to create an independent worktree.
Run required setup in that remote worktree according to current Obsidian
instructions. Do not assume copied dependencies, a particular `just` recipe,
or a warm-worktree utility is available.

## Delegate from the local session

Use native delegation tools, without an automatic *local* worktree isolation
option. Assign at most one writer to each remote worktree. Include the filled
task packet below, the applicable remote instructions, and [testing
principles](testing-principles.md). Inline the relevant Markdown source content
and decisions; a local spec path alone is insufficient for a remote process.
For long context, an agent may transfer a bounded snapshot into a remote scratch
directory outside the product tree, recording its local sources and revision.
Never transfer credentials or the entire local configuration.

```text
Implement task <ID> in Obsidian through SSH from this session.

Connection: <verified explicit-ID SSH command, including CLI context if needed>
Environment: <environment ID>
Allocation owner: <run ID, task ID, and worker agent/session ID>
Remote checkout: <absolute path>
Remote task worktree: <absolute path>
Task branch: <branch>
Immutable base SHA: <SHA>
PR base branch: <branch>
Runtime isolation: <assigned service/test resources or commands to serialize>

First issue a remote identity check using git -C <remote-worktree>:
  rev-parse --show-toplevel
  branch --show-current
  status --short
Verify the recorded worktree and branch before edits. Report unexpected changes.
Use only this task's recorded environment and allocation; do not follow another
worker's environment/path or take over its branch. Report an ownership conflict.
Every product read/edit/build/test/commit command must run remotely in this
worktree. Local shell cwd does not select a remote worktree. Do not switch the
main checkout, use a local Obsidian clone for edits, or change another task.

Task: <title, scope, files, dependencies, done-when>
Requirements: <relevant Markdown excerpts, source paths/headings, decisions>
Instructions: <applicable remote AGENTS.md rules and testing principles>
Validation: <current repo commands and required checks for this change>

Implement within scope. Run required setup/codegen and appropriate validation
in Ona. Preserve hooks; do not use --no-verify. Commit on the assigned branch.
Return the first publishable implementation commit promptly so the Captain can
publish its draft without human approval or waiting for review/CI. The Captain
coordinates publication to avoid duplicate PRs. Return the head SHA,
changed-file summary, diff stat against the pinned base, validation
commands/results/log locations, and any blockers. Do not claim a check passed
without its completed result. Leave the worktree available for review/fixes.
```

If a remote agent CLI is deliberately used instead, ensure its prompt/context
actually exists remotely and its authentication is available there. Default to
local agents issuing SSH commands; remote model runtimes are not prerequisites.

## Publish

Once an implementation commit is available, resume the worker to verify the
worktree, branch, clean status, and intended head SHA. No human approval or
completed review/CI gate is required to open a draft. Unexpected dirty files are
not automatically "the reviewer's edits"; investigate their origin. Run any
required pre-push checks and push the task branch from Ona without bypassing hooks.

Read applicable Obsidian PR instructions, including `commit-and-pr` if available.
This workflow already authorizes draft publication without human approval and
requires ordinary PRs without GitHub native stacks. The Captain can open the
draft with local GitHub tools using the published head and correct base;
publication need not depend on remote `gh` credentials. Search for an existing
task PR before creating another.

Use the plan's title prefix. Describe the concrete behavior change, validation
and limitations, and link the preceding task's PR and any other dependencies.
Explicitly set draft status and the recorded base branch on creation. Verify
the resulting draft status, head, and base; do not rely on tool defaults.
Link the KB plan with a published URL when available; do not present a local
filesystem path as a link
reviewers can open. Return the PR URL and published head. Keep the draft open
while review and CI fixes continue, updating its description as needed. Do not
mark it ready for review or merge it; the user will review drafts asynchronously.
