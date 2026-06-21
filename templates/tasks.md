# Tasks: <change title>

Use task IDs `T-001`, `T-002`, and so on. Every implementation, proof, and
validation task must map to a requirement ID, AC ID, sanctioned implicit risk,
or engineering gate.

Implementation tasks carry their own proof fields. Do not create a separate
deferred "tests later" block for work that can be verified with the task that
changes behavior. Use a cross-cutting proof task only when the validation
cannot reasonably belong to one implementation task, such as a full regression
run, migration verification, or final evaluation.

## Task Format

```text
- [ ] T-000 Task title.
  Priority: P0|P1|P2
  Maps to: REQ-000-AC-000 or engineering gate
  Files: <expected files>
  Tests: <unit|integration|e2e|documentation proof|none with rationale>
  Gate: <quick|full|build|docs|security|OpenSpec verify|evaluation>
  Done when: <observable completion condition>
  Commit: <suggested Conventional Commit subject>
```

## Validation Tiers

| Gate | Use When | Expected Proof |
| --- | --- | --- |
| `quick` | Small, local edits or planning proof | Targeted command, structural review, or documented search. |
| `full` | Multi-file behavior or high-risk planning | All relevant project checks from `docs/project/TESTING.md`. |
| `build` | Runtime code, generated artifacts, or packaging changes | Documented build command. |
| `docs` | Markdown, templates, guidance, or examples | Link/reference check, markdown lint, or documented structural review. |
| `security` | Secrets, auth, privacy, dependency, or config-sensitive changes | Secret scan, security review, or documented operational proof. |
| `OpenSpec verify` | Proposal, spec, design, task, sync, or archive changes | `/opsx:verify` when available, otherwise equivalent OpenSpec structural review. |
| `evaluation` | Post-implementation scoring against ACs | `skills/spec-driven-eval/SKILL.md` when acceptance criteria are scoreable. |

## RED/GREEN Execution Rules

- For code-changing tasks, write or update the smallest appropriate failing
  test first, confirm the failure when feasible, then implement the smallest
  passing change.
- If a failing-test run is impractical, record the reason in the task evidence
  or implementation summary before making the production change.
- Do not delete tests, skip tests, weaken assertions, lower test scope, or mark
  failures as acceptable merely to pass validation. Exceptions require explicit
  rationale and mapping to an AC, sanctioned implicit risk, or engineering
  gate.
- Use the documented commands in `docs/project/TESTING.md`; if a command is
  unknown or unavailable, record that status rather than inventing one.
- Before implementation, every planned file, endpoint, job, event, config
  entry, and test must map to an AC, sanctioned implicit risk, or documented
  engineering gate.
- Prefer one focused Conventional Commit per non-trivial implementation task
  when the repository workflow allows it. Examples: `feat(api): add invite
  endpoint`, `fix(auth): preserve tenant boundary`, `docs(tasks): add proof
  mapping`.
- Before archive or merge, run `/opsx:verify` when available, then run
  `skills/spec-driven-eval/SKILL.md` when ACs are clear enough to score. If
  `/opsx:verify` is unavailable, record that status and run `openspec validate
  <change-id>` or equivalent generated structural review.
- Do not archive until specs are synced or explicitly archive-ready, evaluation
  evidence is recorded, and unresolved gaps are named.
- Record "while here" ideas as out of scope or deferred unless they map to an
  AC, sanctioned implicit risk, or engineering gate.

## Pre-Implementation

- [ ] T-001 Load relevant project context from `docs/project/*`.
  Priority: P0
  Maps to: planning
  Files: `AGENTS.md`, `openspec/config.yaml`, relevant `docs/project/*`
  Tests: documentation proof
  Gate: quick
  Done when: relevant context and skipped context are named.
  Commit: n/a

- [ ] T-002 Confirm selected flavor guidance is required or not required.
  Priority: P0
  Maps to: planning
  Files: `flavors/<id>/` or n/a
  Tests: documentation proof
  Gate: quick
  Done when: selected flavor use is recorded with rationale.
  Commit: n/a

- [ ] T-003 Run `skills/spec-quality-gate/SKILL.md` when ACs or hidden-risk
  proof are required.
  Priority: P0
  Maps to: planning gate
  Files: `openspec/changes/<change-id>/*`, relevant quality-gate references
  Tests: quality-gate proof
  Gate: full
  Done when: result is `pass` or explicitly scoped `partial`, with no unknown
  P0 blocker.
  Commit: n/a

## Implementation

- [ ] T-010 Implement `<behavior or component>`.
  Priority: P0
  Maps to: `REQ-001-AC-001`
  Files: `<production files>`, `<test files>`
  Tests: `<unit/integration/e2e/documentation proof>`
  Gate: `<quick/full/build/docs/security/OpenSpec verify/evaluation>`
  Done when: behavior and task-local proof satisfy the mapped AC.
  Commit: `<type(scope): subject>`

- [ ] T-011 Update `<contract, adapter, state transition, or doc>`.
  Priority: P0
  Maps to: `REQ-001-AC-002`
  Files: `<production files>`, `<test files>`, `<docs/spec files>`
  Tests: `<unit/integration/e2e/documentation proof>`
  Gate: `<quick/full/build/docs/security/OpenSpec verify/evaluation>`
  Done when: changed contract and proof are both recorded.
  Commit: `<type(scope): subject>`

## Cross-Cutting Proof

- [ ] T-020 Run the documented build command when runtime or package behavior
  changes.
  Priority: P0
  Maps to: engineering gate
  Files: `docs/project/TESTING.md`
  Tests: build proof
  Gate: build
  Done when: command result or unavailable rationale is recorded.
  Commit: n/a

- [ ] T-021 Run final OpenSpec verification before archive or sync.
  Priority: P0
  Maps to: OpenSpec verify gate
  Files: `openspec/changes/<change-id>/*`
  Tests: OpenSpec structural proof
  Gate: OpenSpec verify
  Done when: `/opsx:verify` passes, or unavailable status and equivalent
  structural review are recorded.
  Commit: n/a

- [ ] T-022 Run `skills/spec-driven-eval/SKILL.md` when acceptance criteria are
  clear enough to score.
  Priority: P0
  Maps to: evaluation gate
  Files: `openspec/changes/<change-id>/*`, changed implementation and tests
  Tests: evaluation proof
  Gate: evaluation
  Done when: implementation evidence, test evidence, remaining gaps, and
  unrun gates are recorded.
  Commit: n/a

- [ ] T-023 Archive or sync OpenSpec artifacts only after validation is
  sufficient for the repository workflow.
  Priority: P0
  Maps to: archive gate
  Files: `openspec/changes/<change-id>/*`, `openspec/specs/*`
  Tests: archive readiness proof
  Gate: OpenSpec verify
  Done when: specs are synced or explicitly archive-ready and unresolved gaps
  are named.
  Commit: n/a

## Deferred Ideas

| Idea | Reason Deferred | Follow-up Trigger |
| --- | --- | --- |
| `<idea>` | `<why not part of this change>` | `<future AC, risk, or owner>` |

## Handoff Notes

Use this section for long-running changes only. Keep it compact resume context
inside the OpenSpec change: decisions, blockers, validation results, deferred
ideas, and archive readiness. Do not use it as a parallel source of truth for
requirements or project facts.

| Topic | Current State | Next Action |
| --- | --- | --- |
| Decisions | `<summary>` | `<none or follow-up>` |
| Blockers | `<summary>` | `<owner or unblock condition>` |
| Validation | `<commands run or pending>` | `<next check>` |
| Archive readiness | `<ready/not ready>` | `<sync/eval/archive step>` |
