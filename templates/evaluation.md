# Spec-Driven Evaluation: <change title>

Use this template after implementation when acceptance criteria are clear
enough to score. Every non-zero score must cite file/line evidence.

The canonical evaluator instructions and detailed rubric live in
`skills/spec-driven-eval/references/reference.md`. This file is the reusable
project template and should stay structurally aligned with that reference.

## 1. Metadata

| Field | Value |
| --- | --- |
| Requirement source | `<path, PRD, OpenSpec change, ticket, or source>` |
| Implementation scope | `<files/modules>` |
| Test scope | `<files/modules>` |
| Diff surface | `<changed files or n/a>` |
| Mode | `normal` or `strict benchmark` |
| AC proof matrix / frozen checklist | `<path or n/a>` |
| OpenSpec verification | `pass/fail/unavailable/not-run/n/a: <command or rationale>` |
| Evaluator | `AI-assisted` |
| Date | `<YYYY-MM-DD>` |

## 2. Requirement Inventory

| Story | Priority | AC ID | Acceptance criterion | In scope? |
| --- | --- | --- | --- | --- |
| S1 | P0 | REQ-001-AC-001 | `<criterion>` | yes |
| S1 | P0 | REQ-001-AC-002 | `<criterion>` | yes |
| S2 | P2 | REQ-002-AC-001 | `<out-of-scope criterion>` | no |

Out-of-scope notes:

- `<item>` excluded from final grade because `<reason>`.

Assumptions:

- `<priority, scope, or wording assumption if any>`.

## 3. Implementation Scoring

Use scores `0`, `0.25`, `0.50`, `0.75`, or `1.00`.

| AC ID | Evidence | I | Rationale |
| --- | --- | --- | --- |
| REQ-001-AC-001 | `<source-root>/...:42` | 1.00 | Fully implements required behavior. |
| REQ-001-AC-002 | `<source-root>/...:95` | 0.50 | Core behavior present, but missing `<clause>`. |
| REQ-002-AC-001 | searched `<paths/terms>`; none found | 0.00 | No implementation evidence found. |

Strict benchmark check table, when used:

| AC ID | Check ID | I-check | Task ID | Expected file(s) | Status | Evidence or search |
| --- | --- | --- | --- | --- | --- | --- |
| REQ-001-AC-001 | I-001 | `<frozen implementation check>` | T-010 | `<source files>` | `MET` or `UNMET` | `<file:line or searched paths>` |

## 4. Test Scoring

Use scores `0`, `0.25`, `0.50`, `0.75`, or `1.00`.

| AC ID | Unit evidence | Unit score | Integration/e2e evidence | Integration/e2e score | T |
| --- | --- | --- | --- | --- | --- |
| REQ-001-AC-001 | `<test-root>/...:30` | 1.00 | `<test-root>/...:55` | 1.00 | 1.00 |
| REQ-001-AC-002 | `<test-root>/...:80` | 0.75 | searched `<paths/terms>`; none found | 0.00 | 0.375 |
| REQ-002-AC-001 | searched `<paths/terms>`; none found | 0.00 | searched `<paths/terms>`; none found | 0.00 | 0.00 |

Explain required test levels when not obvious:

- `<AC ID>` requires `<unit/integration/e2e/outcome>` proof because `<reason>`.

Strict benchmark T-check table, when used:

| AC ID | Check ID | T-check | Level | Task ID | Expected file(s) | Status | Evidence or search |
| --- | --- | --- | --- | --- | --- | --- | --- |
| REQ-001-AC-001 | T-001 | `<frozen test check>` | unit/integration/e2e/outcome | T-010 | `<test files>` | `MET` or `UNMET` | `<file:line or searched paths>` |

Real outcome note:

- Webhook, async, scheduled, or message-driven behavior receives full test
  credit only when tests assert real persisted state, a durable event, returned
  payload, or equivalent observable final outcome.

## 5. Score Calculation

Formula:

```text
AC_score = 0.6 * I + 0.4 * T
```

| AC ID | I | T | AC score | Calculation |
| --- | --- | --- | --- | --- |
| REQ-001-AC-001 | 1.00 | 1.00 | 1.00 | `0.6*1.00 + 0.4*1.00` |
| REQ-001-AC-002 | 0.50 | 0.375 | 0.45 | `0.6*0.50 + 0.4*0.375` |

Story score:

```text
S1 = mean(<AC scores>) = <value>
```

Final:

```text
Final = weighted mean by priority = <value>
Band = <Spec-complete | Strong | Partial | Weak | Inadequate>
```

For strict benchmark mode, paste the script command and output used to compute
the roll-up. Partial AC scores come from binary atomic checks: borderline,
indirect, or ambiguous checks are `UNMET`.

Docs/template-only mode:

- Mark runtime test scoring `n/a` when no executable behavior exists.
- Label the result unadjusted for runtime test proof.

## 6. Test Distribution

| Class | Count | Percent | Interpretation |
| --- | --- | --- | --- |
| Necessary | `<count>` | `<%>` | Primary tests that prove in-scope P0/P1 ACs. |
| Secondary | `<count>` | `<%>` | Edge/error tests tied to ACs or documented risks. |
| Nice-to-have | `<count>` | `<%>` | Useful tests not mapped to scored ACs. |

Nice-to-have tests are reported but do not raise the final grade. Missing
necessary tests rank above extra robustness tests.

## 7. Extra Tests Inventory

| ID | Scenario | Level | Evidence | Weight |
| --- | --- | --- | --- | --- |
| E1 | `<scenario>` | unit/integration/e2e | `<test-root>/...:70` | High/Medium/Low |

Robustness index:

```text
R = High*1.0 + Medium*0.5 + Low*0.25 = <value>
```

## 8. Side Signals

These signals are adjacent to, not part of, the Final score.

| Signal | Value | Evidence | Notes |
| --- | --- | --- | --- |
| Scope adherence | `pass`, `partial`, or `fail` | `<evidence>` | Same result as section 9. |
| Robustness | `<R value>` | `<extra test evidence>` | Defensive tests outside scored ACs. |
| Test distribution | `<Necessary/Secondary/Nice-to-have>` | `<counts>` | Distribution of feature tests. |
| Engineering gates | `<summary>` | `<commands/results>` | Build, static, unit, integration/e2e. |
| Planning-artifact quality | `<n/a or summary>` | `<spec/tasks evidence>` | Required when specs/tasks exist; not folded into Final. |

## 9. Scope Adherence

| Item | Status | Evidence |
| --- | --- | --- |
| Avoided explicit out-of-scope behavior | pass/partial/fail | `<evidence>` |
| No rogue behavior unrelated to requirements | pass/partial/fail | `<evidence>` |
| No inconsistent half-built feature | pass/partial/fail | `<evidence>` |

Scope adherence: `<pass, partial, or fail>`

## 10. Planned Versus Created

| Planned item | Expected evidence | Created evidence | Status |
| --- | --- | --- | --- |
| `<task/test/file from tasks or proof matrix>` | `<expected path/check>` | `<actual path/check or none>` | `created/missing/unmapped` |

Created files, tests, endpoints, jobs, events, config, or docs that do not map
to an AC, sanctioned implicit risk, or engineering gate are scope-drift gaps.
Planned tests/tasks that were never created are proof gaps.

## 11. Engineering Gates

| Gate | Status | Evidence |
| --- | --- | --- |
| OpenSpec verify | pass/fail/unavailable/not-run/n/a | `<command/output summary or fallback>` |
| Build | pass/fail/unavailable/not-run/n/a | `<command/output summary>` |
| Static checks | pass/fail/unavailable/not-run/n/a | `<command/output summary>` |
| Unit tests | pass/fail/unavailable/not-run/n/a | `<command/output summary>` |
| Integration/e2e tests | pass/fail/unavailable/not-run/n/a | `<command/output summary>` |

`unavailable` and `not-run` gates are unadjusted and blind to runtime failure;
do not treat them as passing.

If any hard gate fails:

```text
Adjusted Final = Final * 0.5 = <value>
```

Archive readiness must distinguish deferred ideas from unresolved gaps.

## 12. Ranked Gaps

1. `<highest-impact gap>`
   - AC: `<AC ID>`
   - Impact: `<why it matters>`
   - Fix: `<specific production or test change>`

2. `<next gap>`
   - AC: `<AC ID>`
   - Impact: `<why it matters>`
   - Fix: `<specific production or test change>`

## 13. Path To 1.00

- `<production fix>`
- `<unit test fix>`
- `<integration/e2e test fix>`
- `<documentation or spec clarification if needed>`
