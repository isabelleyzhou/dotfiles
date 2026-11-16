# Evaluator

Delegate read-only review to agents independent of the implementing worker.
Use a second model family when available and a frontend specialist for UI work
when useful. Read relevant remote frontend guidance for UI tasks. Use actual
available models/tools, not hard-coded Claude names or speculative CLI flags.
Schedule within runtime/resource limits; concurrency is optional.

Reviewers can run locally and inspect Ona through SSH. Pass the same explicit
connection, environment, remote worktree, immutable base and head SHAs, task
packet, Markdown requirement excerpts, and applicable repository instructions.
Do not rely on local MCP sessions, external source access, or a path that only
exists on the Captain's machine. Include [testing principles](testing-principles.md).

## Review assignment

```text
Independently review task <ID> for concrete defects and unmet requirements.
Use <verified connection> to inspect <remote-worktree> on <branch> in Ona.
Expected head: <head SHA>. Immutable task base: <base SHA>.
Task and done-when: <full task>
Markdown requirements/decisions: <relevant contents and source paths>
Repo instructions and testing principles: <applicable text>

Verify the remote worktree identity, head, and clean status; report unexpected
dirty changes. Read git diff <base>...<head>,
callers, types, and relevant tests remotely. No file edits, commits, builds,
or branch/worktree mutations. If the head changes, report that review is stale.

Check behavior, edge cases, authorization/data isolation where relevant,
compatibility, completeness, and fit with existing domain interfaces. Examine
test quality and whether recorded validation supports the claimed behavior.
Consider impact and likelihood; do not invent findings to fill a quota.

Return file:line — [block|suggest|nit] finding, with a concrete failure or
missing requirement and supporting reasoning. Block means required before
task completion, not before draft publication; suggest is an improvement;
nit is optional. Include the reviewed head SHA, remaining uncertainty, and
counts by severity. If there are no
actionable defects, say so; do not imply this proves correctness.
```

Wait for every assigned reviewer or record the specific failure. Retry a
transient failure once if useful. A missing optional second model can fall back
to another independent available reviewer, with that limitation disclosed.
If no independent review can run, record that completion blocker and present
the limitation while continuing draft publication and CI work; never silently
replace it with a worker self-review or label it passed.

Pass all findings, labeled by reviewer, to the fix round. Identify independently
shared findings without dropping conflicting opinions. Record the actual
reviewers and head SHA in the ship log. Prioritize demonstrated defects over
votes or model prestige.
