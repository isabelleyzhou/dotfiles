---
name: isabelle-review
description: Review PRs and code changes through Isabelle's correctness, design, and architecture lens. Orient her before presenting numbered findings and design questions. Supports self-review with source TODOs and a draft PR description when requested.
---

# Isabelle Review

Help Isabelle understand a change and evaluate both defects and design quality. Do not equate “no correctness bugs” with “nothing worth discussing.” Separate confirmed defects from architectural questions and tradeoffs.

## Scope and evidence

Review the PR, branch, commit, or working-tree changes Isabelle identifies. For a current-branch review, determine the actual target branch and compare against its merge base; do not assume `main`. Include uncommitted changes when requested and identify their scope separately.

Read applicable repository review guidance, the PR description when available, and enough surrounding code to understand the change. For ownership judgments, inspect package documentation and metadata, neighboring APIs, existing helpers, dependencies, and relevant call sites. Ground conclusions in the final implementation; distinguish the author's stated motivation from verified behavior.

Default to a review in chat without editing files. If Isabelle asks for inline TODOs or invokes this skill to annotate her code, use the source-annotation workflow below. Draft a PR description when requested or when she asks to prepare her PR for reviewers. Do not post comments to GitHub or update a PR unless requested.

## First-pass orientation

Assume Isabelle has not read the PR yet. Begin with concise **PR context** explaining:

- The user, product, or engineering problem being addressed.
- The high-level behavior and important request, data, or control flow.
- The packages or domains involved and each one's responsibility.
- Material rollout constraints, dependencies, follow-up work, and deliberately unchanged behavior, when relevant.

Explain unfamiliar terminology needed to follow the change. Build a useful mental model instead of restating filenames or commits. State uncertainty where the motivation or behavior cannot be established.

## Review lenses

### Correctness and integration

Examine changed behavior for incorrect conditions, edge cases, nullability, error handling, asynchronous behavior, races, authorization, state mutation, and integration failures. Trace callers and downstream assumptions where needed to establish impact.

### Ownership and responsibility boundaries

For significant new functions, classes, types, and service operations, identify their main responsibility in plain language and which domain, package, or architectural layer owns the underlying concept or policy.

- Separate domain behavior from package-specific adaptation. A local input type does not by itself establish ownership of the operation.
- Consider whether a domain-owning service should provide a reusable operation while the current package supplies a narrow adapter, extractor, or mapping.
- Search existing abstractions and plausible consumers before recommending a move. Do not extract code solely because it is small or hypothetically reusable.
- Evaluate dependency direction, authorization boundaries, cohesion, discoverability, ownership, and testing implications of the current and alternative placements.

Ask which package owns the central noun or policy, whether the code interprets domain semantics or adapts a record shape, and whether it duplicates knowledge a shared service already owns. Explain the tradeoff when recommending a different placement. When the evidence supports the current placement, say so briefly where it resolves a meaningful design question.

### Readability and encapsulation

Look for unclear contracts, leaked implementation details, excessive responsibilities, surprising mutation, and complexity that obscures behavior. Prefer specific improvements with concrete benefits. Avoid formatter or linter trivia and personal style preferences. For tests, flag incorrect or misleading behavior rather than style nits.

### Test and integration risks

Check whether tests exercise changed behavior, excluded cases, failure paths, and relevant interactions. Identify the concrete behavior at risk; absence of a test for every new function is not itself a finding. Distinguish tests inspected from checks actually executed, and report failures, skipped checks, and verification limits accurately.

## Feedback and output

Present:

1. **PR context** for a first-time reader.
2. **Actionable findings**, ordered by severity, with file/line references, the triggering condition, impact, and a recommended fix when supported.
3. **Design questions**, covering well-supported architectural concerns and tradeoffs separately from blocking defects. Include evidence, likely recommendation, and its costs where available.
4. **Test and integration risks**, including relevant verification results and limits.

Assign each observation a unique sequential ID across the review so Isabelle can say “fix #3” or “drop #7.” Use these feedback categories independently of severity:

- `[nit]`: a worthwhile small, non-blocking improvement.
- `[suggest]`: a concrete improvement with a supported recommendation, including a confirmed defect when applicable.
- `[disc]`: a decision or architectural question whose answer depends on requirements or a meaningful tradeoff.

State severity separately for confirmed defects using repository conventions. A `[suggest]` can be urgent; a `[disc]` is not a confirmed defect. Do not turn uncertainty into a finding or downgrade a defect into a question. Report no actionable findings when warranted, without inventing discussion points to fill sections.

## Source annotations when requested

Add comments immediately above the relevant code using the language's comment syntax. For TypeScript:

```ts
// TODO-ISABELLE-PR-REVIEW #3 [suggest]: <specific concern, impact, and proposed fix>
```

Preserve this marker so existing workflows and references keep working. Keep IDs consistent with the chat report and avoid collisions with existing markers in the reviewed scope. Mark confirmed defects with severity in the comment text as well.

Only add review comments; do not change implementation, tests, existing comments, or formatting. Use the chat report for concerns that cannot be safely annotated. Summarize the number of comments by category and the files annotated. Do not apply fixes unless Isabelle subsequently asks.

## PR description when requested

After the review, print a concise, copyable Markdown draft based on the cumulative diff, relevant commits, and available author intent. Follow the repository's current PR template and required sections. If there is no template, use Changes, Motivation, Testing, and Deployment.

Describe final behavior and meaningful changes rather than commit history. Include rollout steps, migrations, and feature flags only as established by evidence; do not infer a standard rollout from missing information. Report test results only when known. If AI disclosure is required, use the model identity actually available and substantive prompts from this conversation; do not invent model versions, context-window sizes, prompts, or prior work.
