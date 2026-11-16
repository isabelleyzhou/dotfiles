# Testing principles

Pass these principles to workers, reviewers, and fix rounds along with the
actual remote repository rules. Repository instructions determine required
checks and test conventions; the source team's preferences are not new
Obsidian-wide prohibitions.

- Test observable behavior: inputs, outputs, persisted effects, and failure
  handling at the appropriate boundary. Avoid tests that merely mirror code.
- Use stubs to control inputs. Prefer contract assertions to internal call
  counts/order; outbound adapter payloads or pure sinks may legitimately be
  the observable contract. Explain non-obvious choices rather than banning
  all mock assertions regardless of repository conventions.
- Cover meaningful regressions and relevant edge cases. Do not add tests only
  to satisfy a quota or for reversible documentation-only edits.
- Run product setup, codegen, lint, typecheck, builds, tests, and hooks in the
  assigned Ona worktree. Check current commands in Obsidian's instructions.
- Report exact commands, completed results, relevant log locations, and the
  checked commit. Missing access, timeouts, interrupted connections, or a
  check that never ran are limitations, not passing evidence.
- Inspect Buildkite locally. Send the failure evidence to the Ona worker for
  fixes; never transfer local tokens to the environment or logs.
