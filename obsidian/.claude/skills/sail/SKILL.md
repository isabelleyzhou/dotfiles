---
name: sail
description: Plan or execute multi-task Obsidian work from Markdown specs in this knowledge base, with agents connecting to Ona over SSH, independent review, and draft PRs. Use when the user requests Sail or this plan-driven workflow.
---

# Sail

Adapted from [fprm-knowledge-base PR #9](https://github.com/VantaInc/fprm-knowledge-base/pull/9)
at `e3360c126b87ddc123f8edb2c2007d8f91658afd`. Use a local Captain and remote
code work: plan → implement → draft PR → independent review, fixes, and green CI.

The user starts the agent in `sco-seg-knowledge-base`. The agent handles SSH;
the user does not need to enter Ona, start an agent there, or open a remote IDE.
This is an opt-in workflow, not the default for ordinary edits or PR fixes.

## Choose a procedure

| Request | Read |
|---|---|
| Plan work from local specs/RFCs, or revise the task graph | [Set a Course](references/set-a-course.md) |
| Execute or resume a plan | [Run the voyage](references/run-voyage.md), starting with [setup](references/setup.md) |
| Check readiness without implementing | [Setup](references/setup.md) |

Load supporting references as their steps become relevant: [worker](references/worker.md),
[evaluator](references/evaluator.md), [fix round](references/fix-round.md),
[dashboard](references/dashboard.md), [diagram](references/diagram.md), and
[testing principles](references/testing-principles.md).

## Execution boundary

| Local knowledge-base session | Ona, reached by agent-issued SSH commands |
|---|---|
| Read Markdown specs, RFCs, plans, and decisions | Read applicable Obsidian `AGENTS.md` and skills |
| Plan, delegate, review results, and keep status | Create task branches/worktrees; implement and fix |
| Maintain Mermaid diagrams in Markdown | Run setup, codegen, lint, builds, hooks, and tests |
| Read GitHub and diagnose Buildkite with local access | Commit and push product code |

Local Markdown is the requirements source. No Google Docs, Atlassian, Slack,
or other requirements connector is required. Do not try to fetch a document's
original external link unless the user asks. Pass file contents to workers;
local absolute paths are not remote paths. No sibling Obsidian or KB checkout
inside Ona is required. Treat any local Obsidian checkout as read-only.

Parallel writers must have separate remote worktrees, or separate Ona instances
with their own checkouts. Assign one writer per environment/worktree and one
owner per task branch, even across instances. Follow [workspace allocation](references/worker.md#allocate-isolated-workspaces)
before spawning workers; if safe isolation is unavailable, queue the tasks.

## Autonomous execution

An execution or resume request authorizes implementing every task, committing,
pushing, opening draft PRs, and fixing review/CI failures without human approval.
Do not wait for the user to approve the plan, a diff, publication, or the next
task. Replace legacy `human` mode and approval checkpoints on resume with this
workflow unless the user explicitly requests a new pause or approval gate.

Create a draft PR for every task as soon as it has a publishable implementation
commit, even while review or CI is pending or failing. Keep all PRs as drafts
for the user to review on their own schedule. Use ordinary PRs, without GitHub
native stacks: the first targets the intended project base, and each later PR
targets the immediately preceding task's feature branch. Follow the branch
sequence in [Run the voyage](references/run-voyage.md#pr-sequence-and-dependencies).

Continue until every task has a draft PR, blocking review findings are resolved,
and every PR's latest published head has passing CI. Opening drafts or reporting
pending checks is not completion. Diagnose failures, fix them in Ona, update
dependent branches, and recheck CI without asking for permission. If a concrete
external blocker prevents further progress, preserve the drafts and checkpoint,
finish unaffected work, and report the blocker without claiming completion.

This authorizes draft publication, not merging, enabling auto-merge, production
changes, or messaging other people. A planning-only request does not authorize
execution.

## Agent runtime

Execution delegates implementation and independent review to agents available
in the current runtime. Workers can remain local and issue SSH commands; remote
Claude/Codex installations and remote model credentials are optional. Do not
assume Claude-specific tool names, a particular model, or fixed concurrency.
Give each agent the environment, remote paths, pinned refs, task context, and
relevant instruction text. If delegation is unavailable, the Captain can perform
the worker's steps in Ona and publish drafts. Continue CI work, record unavailable
independent review as a completion blocker, and never claim the review loop ran.
