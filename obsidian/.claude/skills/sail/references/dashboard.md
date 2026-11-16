# Dashboard

Keep durable specs, RFCs, decisions, and the reviewed plan in `plans/<project>/`.
Keep per-run state locally in `.sail/<plan-slug>/ship-log.md` and
`.sail/<plan-slug>/ship-log-dag.md`. `.sail/` is ignored by Git: it can contain
ephemeral environment paths, review patches, and logs. Never store credentials.
The Captain owns these files; concurrent workers return results instead of
racing to update them. No dashboard files belong in the product worktree.

```markdown
# Ship log: <plan name>

Updated: <ISO date/time and timezone>
Plan: <local plan path>
Requirements snapshot: <source Markdown paths and commit; content hashes for dirty files>
Execution: autonomous draft PRs; no human approval gates
PR sequence: <task IDs in dependency order; first PR base branch>
Reviewers: <actual runtime/model names; limitations>
Concurrency: <worker/reviewer limits>

## Workspace assignments

| Task | Ona environment | Remote worktree | Branch | Writer owner | Allocation state |
|---|---|---|---|---|---|
| 1 | <environment ID> | <canonical absolute path> | <unique branch> | <run/agent/session ID> | active / reviewing / released |

## Progress

| Task | Phase | PR | CI | Base | Head |
|---|---|---|---|---|---|
| 1 | Working | — | — | <branch + SHA> | <SHA or pending> |

## Task checkpoints
### Task 1
- Connection: <explicit environment ID, CLI context/verified SSH alias>
- Remote checkout: <path, initial branch/HEAD and dirty paths in this instance>
- Remote worktree/branch:
- Shared runtime resources and isolation/serialization arrangements:
- Worker/reviewer session IDs, if resumable:
- Requirement excerpts/snapshot used:
- Validation commands, results, logs, checked SHA:
- Findings, dispositions, reviewed SHA:
- Preceding task/PR and base branch:
- PR URL/base/published head and last observed checks:
- Remaining action or blocker:

## Drafts for asynchronous user review
- <task and draft PR URL; current CI state; outstanding findings>

## Events (newest first)
- <timestamp with timezone> — <task and event>
```

Use phases `Blocked by task N`, `Working`, `PR created`, `Evaluating`, `Fixing`,
`CI pending`, `PR green`, `Merged`, `Blocked`, `Failed`, or `Dropped`.
Record PR review state separately when useful. CI is `pending`, `green`,
`red (<check>)`, `unavailable`, or `—`, always tied to a published SHA.

Update the task row, checkpoint, and [diagram](diagram.md) together after each
transition. Prepend timestamped events; do not rewrite history to conceal an
earlier failure or changed decision. Date observations using the current clock.
On resume, verify live remote/GitHub state before trusting a checkpoint. Migrate
legacy `human` mode and `Awaiting review` checkpoints to the actual autonomous
phase; do not wait for user approval to publish or continue. Record the migration
as an event and retain earlier observations as history.
Keep each writer assignment until its agent and mutating processes have ended;
mark a handoff or release explicitly. A disconnected session is not a release.

Write significant resulting decisions/outcomes back into the project's tracked
Markdown as appropriate. If the user wants a shareable status artifact, save a
sanitized Markdown snapshot alongside the plan; omit local access details.
