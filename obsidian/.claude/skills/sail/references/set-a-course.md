# Set a Course

Turn Markdown requirements in this knowledge base into tasks sized for
reviewable Obsidian PRs. Save the plan under `plans/<project>/sail-plan.md`, or
use the user's established project path. Keep existing specs and RFCs intact.

## Gather context

Read the user's Markdown spec/RFC and linked local decisions before designing
tasks. Search the knowledge base for related work. Record source paths and
headings, relevant decisions, assumptions, and unresolved questions. Preserve
the distinction between an approved requirement and an agent proposal.

Imported external URLs are provenance, not instructions to query Google Docs,
Atlassian, or Slack. No ticket or epic is required. Ask for missing requirements
in this conversation if they materially affect the plan; do not demand access
to the original tools. Do not invent acceptance criteria to fill a product gap.

For code-dependent planning, use [setup](setup.md) to inspect Obsidian through
SSH, including its instructions and actual paths/commands. If access is blocked,
write the useful plan and mark unverified code assumptions; it is not ready for
execution until they are resolved. No product changes happen during planning.

## Plan format

```markdown
---
executor: sail
pr-title-prefix: "[Control scoping]"
---

# <Project> implementation plan

## Context
- Goal and non-goals: ...
- Sources: [Spec](spec.md#requirements), [RFC](rfc.md#design)
- Decisions and constraints: ...
- Code evidence: remote Obsidian commit and relevant paths
- Validation: commands verified against current repo instructions
- PR sequence: task IDs in dependency order; intended base for the first PR
- Open questions: ...

## Tasks

### Task 1: <short title>
- **Scope:** Self-contained description, including the behavior to change.
- **Files:** Obsidian-relative paths or explicitly marked areas to discover.
- **Blocked by:** none
- **Done when:** Observable acceptance criteria and commands that verify them.

### Task 2: <short title>
- **Scope:** ...
- **Files:** ...
- **Blocked by:** Task 1
- **Done when:** ...

## Task graph
<Mermaid fenced block following diagram.md>
```

Use stable IDs (`1`, `2`, later `2a`/`2b` for splits) and one concern per task.
Include rollout/compatibility requirements when the spec calls for them. Do not
put SSH credentials, ephemeral environment IDs, or execution transcripts in
the plan. Those belong in local run state, with no credentials at all.

## Validate and hand off

Check that each task has all four fields, dependencies reference existing IDs,
the graph has no cycles, and there is an initial unblocked task. Order tasks
that touch overlapping files or shared generated outputs unless their work is
demonstrably independent. Verify completion criteria against the requirements,
not merely that tests exist. Generate the [Mermaid graph](diagram.md) from the
same dependency list, with no extra or missing tasks.

Record a linear PR sequence that respects these dependencies, using plan order
to break ties. The first draft targets the intended project base; every later
draft targets the immediately preceding task's feature branch. These are ordinary
PRs without GitHub native stacks. Keep code dependencies in `Blocked by` separate
from the PR sequence; unrelated tasks still follow the sequence for publication.

Give the user the plan path, the task breakdown, and consequential open decisions.
Planning alone ends here. If execution was already requested and the plan has
no unresolved blockers, continue with [Run the voyage](run-voyage.md) within the
user's authorization; do not insert a second planning approval unnecessarily.
