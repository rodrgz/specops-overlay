---
name: spec-driven-eval
description: Scores how completely an implementation fulfills a PRD/spec case by case, with separate implementation and test scores plus a final grade. Invoke when explicitly named or when the user asks to grade, audit, verify, or score an implemented feature against requirements, acceptance criteria, a PRD, an OpenSpec change, or a task checklist. Use after implementation or before archive/merge. Use strict benchmark mode only when the user asks for reproducible framework comparison.
license: CC-BY-4.0
adapted_from: tech-leads-club/agent-skills
metadata:
  version: 1.0.0
---

# Spec-Driven Evaluation

Evaluate an implementation against a PRD, OpenSpec change, task checklist, or
acceptance criteria. Score production behavior and tests separately, then roll
the results into a comparable final grade.

This skill is primarily a post-implementation verification gate. Benchmark
comparisons are supported, but they are an explicit mode, not the default.

## Inputs

Required:

1. PRD/spec, OpenSpec change, task checklist, or acceptance criteria.
2. Production implementation.
3. Tests.

Optional:

- Refined `spec.md` with requirement IDs.
- AC proof matrix from `.agents/skills/spec-quality-gate/references/ac-proof-matrix.md`.
- Linked issue/ticket content.
- PR diff, branch diff, or uncommitted working tree.
- Project docs and documented validation commands.
- OpenSpec verification output, such as `/opsx:verify` or
  `openspec validate <change-id>`.

The PRD/spec is the source of truth. Use derived specs only to clarify wording,
not to override product intent.

## Core Rules

1. **Evidence or zero.** Every non-zero score must cite evidence as `file:line`
   or `file:startLine-endLine`. Do not award credit from assumptions, comments,
   or restated intent.
2. **Search before zero.** Before scoring a requirement `0`, record what was
   searched. A missing requirement is `0` only after the relevant diff files,
   symbols, tests, and likely paths were inspected.
3. **Read the path end to end.** A matching method name is not enough. Trace the
   real code path and inspect the constructed DTO/entity/event/payload when the
   requirement names returned, persisted, or emitted fields.
4. **Tests must assert, not merely exercise.** A test that reaches a path but
   does not assert the required behavior receives reduced or zero test credit.
5. **Keep extra coverage separate.** Defensive tests are useful, but they do not
   compensate for missing requirement coverage.

## Scope the Evidence

When a diff is available, identify changed files before scoring. Use this diff
surface as the primary search scope, then expand only when needed to understand
called code, existing tests, shared helpers, or unchanged behavior.

```bash
git diff <base>..<head> --name-only   # branch or PR
git diff --name-only HEAD             # uncommitted changes
git status --short                    # include untracked files
```

Record the diff surface in the report. Evidence outside it is valid when it
explains the changed behavior, but note that it is outside the diff.

## Evaluation Modes

Use **normal mode** by default for day-to-day development, review gates, and
archive/merge checks.

Use **strict benchmark mode** only when the user asks for benchmark
comparability, framework comparison, or a reproducible audit:

- freeze acceptance criteria and binary I/T checks before scoring;
- mark each check `MET` or `UNMET`;
- treat absent, ambiguous, indirect, or borderline evidence as `UNMET`;
- derive AC-level `I` and `T` from the fraction of met checks;
- run three independent passes by default and majority-vote disputed checks;
- record why fewer than three passes were used, and record evaluator/model
  caveats when same-family self-evaluation is unavoidable.

## Scoring Model

Score each in-scope acceptance criterion on two axes:

- Implementation `I`: production code satisfies the requirement.
- Tests `T`: tests verify the requirement at the appropriate level.

Use the fixed scale `{0, 0.25, 0.50, 0.75, 1.00}` in normal mode.

Implementation:

| I | Meaning |
| --- | --- |
| 1.00 | Fully implemented as written |
| 0.75 | Core behavior present; minor clause missing or imperfect |
| 0.50 | Meaningful clause missing |
| 0.25 | Incidental support only; main behavior absent |
| 0.00 | Not implemented or no evidence found |

Tests:

| T | Meaning |
| --- | --- |
| 1.00 | Appropriate levels assert happy path and relevant negative/edge cases |
| 0.75 | Requirement is verified, but one assertion, clause, or edge case is missing |
| 0.50 | Key assertion or one required test level is missing |
| 0.25 | Tangential test only, or path is exercised without asserting the requirement |
| 0.00 | No located test evidence |

Choose test levels per AC:

- Pure business logic: unit tests may be sufficient.
- HTTP contracts, persistence, messaging, security, config, and cross-module
  behavior: integration/e2e tests are required.
- Most user-visible backend behavior needs both unit and integration/e2e
  confidence.
- Webhook, async, scheduled, or message-driven state transitions require tests
  that assert the real persisted state, durable event, returned payload, or
  equivalent observable outcome.

Formula:

```text
AC_score = 0.6 * I + 0.4 * T
Story_score = mean(AC_score for in-scope ACs)
Final = weighted mean of Story_score by priority
```

Documentation/template-only changes may mark runtime test scoring `n/a` when
there is no executable behavior to test. In that case, report the final as
implementation/structure fidelity only and label it unadjusted for runtime
test proof.

Priority weights:

| Priority | Weight |
| --- | --- |
| P0 | 3 |
| P1 | 2 |
| P2 / out of scope | 0 |

Grade bands:

| Final | Band |
| --- | --- |
| >= 0.90 | Spec-complete |
| 0.75-0.89 | Strong |
| 0.60-0.74 | Partial |
| 0.40-0.59 | Weak |
| < 0.40 | Inadequate |

## Scoring Guardrails

Apply these guardrails in normal and strict mode:

- Out-of-scope items get weight `0`. Do not penalize absence.
- If an AC names multiple returned, persisted, or emitted fields, score each
  meaningful field separately in strict mode, and mention missing fields in the
  normal-mode rationale.
- If an AC presents alternatives, freeze the interpretation before scoring. Do
  not let the interpretation vary by implementation.
- A call to `emit(...)`, `save(...)`, or `return ...` is not enough when the AC
  names the payload shape; inspect the object actually constructed.
- Mock-only assertions can prove calls to external clients when the requirement
  is the call itself. They do not fully prove persisted state, displayed status,
  or durable outcomes.
- A stronger-level test can satisfy a weaker-level requirement if it asserts the
  exact proposition.
- Extra tests contribute to the robustness summary, not to AC scores.
- In strict benchmark mode, partial AC scores are derived from binary atomic
  checks: `I = MET I-checks / total I-checks` and `T = MET T-checks / total
  T-checks`. Do not assign subjective partial credit to an individual check.

## Process

Track this checklist:

```markdown
- [ ] Locate requirement source, implementation, and tests
- [ ] Identify the diff surface when a diff exists
- [ ] Enumerate stories and acceptance criteria
- [ ] Mark priority and out-of-scope items
- [ ] For each AC, find implementation evidence and score I
- [ ] For each AC, find unit/integration/e2e evidence and score T
- [ ] Inventory extra defensive tests
- [ ] Assess scope adherence and engineering gates
- [ ] Compare planned tasks/tests/files with created artifacts
- [ ] Run OpenSpec structural verification before scored evaluation when
      `/opsx:verify` or an equivalent command is available
- [ ] Compute final score and band
- [ ] Produce report using references/reference.md
```

OpenSpec verification fallback:

- Expanded profile: run `/opsx:verify <change-id>` before evaluation when the
  generated command is available.
- Core profile or missing generated command: record `/opsx:verify` as
  `unavailable`, then run `openspec validate <change-id>` or the closest
  generated OpenSpec structural guidance.
- If no structural command can run, record the gate as `not-run` or
  `unavailable` with the reason; do not treat it as passing.

Side signals:

- `S` Scope adherence: `pass`, `partial`, or `fail`. Flag built behavior that
  contradicts the PRD, lands in explicit out-of-scope, or is half-built.
- `R` Robustness: extra defensive tests outside scored ACs.
- `D` Test distribution: classify feature tests as `Necessary`, `Secondary`,
  or `Nice-to-have`.
- `G` Engineering gates: OpenSpec verify, build, static checks, unit tests,
  and integration/e2e execution.
- `P` Planning-artifact quality: whether specs/tasks surfaced required
  implicit risks and whether planned proof was actually created.

Engineering gates must be actually executed to be marked passing. Use distinct
statuses:

- `pass`: command ran and passed.
- `fail`: command ran and failed.
- `unavailable`: command/profile/tool is not present; record fallback.
- `not-run`: command was available but not executed; record reason.
- `n/a`: gate does not apply to the change.

`unavailable` and `not-run` gates are unadjusted and blind to runtime failure;
do not present them as equivalent to passing gates. If a required hard gate
fails, report both the unadjusted `Final` and
`Adjusted Final = Final * 0.5`.

## Strict Benchmark Additions

When strict benchmark mode is active:

1. Build or load a frozen checklist of I-checks and T-checks per AC.
2. Score each check only as `MET` or `UNMET`.
3. Derive `I = met I-checks / total I-checks`.
4. Derive `T = met T-checks / total T-checks`.
5. Use a script for final arithmetic and paste the output in the report.
6. Run three passes by default.
7. If fewer than three passes are used, record the reason.
8. Note checks where verdicts disagreed and record evaluator/model caveats.

Strict mode may report planning-artifact quality beside the final grade when
`spec.md`/`tasks.md` exist, but do not fold that signal into `Final`. The final
grade means fidelity to the source requirements plus test proof.

## Output

Use the template in [reference.md](references/reference.md). The report must
include:

- Requirement sources.
- Diff surface, when available.
- Per-AC implementation scores with evidence.
- Per-AC test scores with evidence.
- Arithmetic for AC, story, and final grades.
- Test distribution: `Necessary`, `Secondary`, and `Nice-to-have`.
- Extra tests inventory.
- Scope adherence.
- Engineering gates.
- OpenSpec verification result or unavailable fallback.
- Planned-versus-created scope/proof comparison.
- Ranked gaps.
- Concrete fixes to reach 1.00.

Save the report under `<spec-folder>/evaluations/` when a spec folder exists.
Otherwise present it inline.
