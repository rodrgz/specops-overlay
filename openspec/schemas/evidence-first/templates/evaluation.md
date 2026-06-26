# Spec-Driven Evaluation: <change title>

Use this template after implementation when acceptance criteria are clear
enough to score. Every non-zero score must cite file/line evidence.

## 1. Metadata

| Field | Value |
| --- | --- |
| Requirement source | `<path, PRD, OpenSpec change, ticket, or source>` |
| Implementation scope | `<files/modules>` |
| Test scope | `<files/modules>` |
| Diff surface | `<changed files or n/a>` |
| AC proof matrix / frozen checklist | `<path or n/a>` |
| OpenSpec verification | `pass/fail/unavailable/not-run/n/a: <command or rationale>` |
| Evaluator | `AI-assisted` |
| Date | `<YYYY-MM-DD>` |

## 2. Requirement Inventory

| Story | Priority | AC ID | Acceptance criterion | In scope? |
| --- | --- | --- | --- | --- |
| S1 | P0 | REQ-001-AC-001 | `<criterion>` | yes |

## 3. Implementation Evidence

| AC ID | Evidence | I | Rationale |
| --- | --- | --- | --- |
| REQ-001-AC-001 | `<source-root>/...:42` | 1.00 | Fully implements required behavior. |

## 4. Test Evidence

| AC ID | Unit evidence | Unit score | Integration/e2e evidence | Integration/e2e score | T |
| --- | --- | --- | --- | --- | --- |
| REQ-001-AC-001 | `<test-root>/...:30` | 1.00 | `<test-root>/...:55` | 1.00 | 1.00 |

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
| --- | --- | --- | --- |
| REQ-001-AC-001 | 1.00 | 1.00 | 1.00 | `0.6*1.00 + 0.4*1.00` |

Final:

```text
Final = weighted mean by priority = <value>
Band = <Spec-complete | Strong | Partial | Weak | Inadequate>
```

Docs/template-only mode:

- Mark runtime test scoring `n/a` when no executable behavior exists.
- Label the result unadjusted for runtime test proof.

## 6. Validation Gates

| Gate | Status | Evidence |
| --- | --- | --- |
| OpenSpec verify | pass/fail/unavailable/not-run/n/a | `<command/output summary or fallback>` |
| Build | pass/fail/unavailable/not-run/n/a | `<command/output summary>` |
| Static checks | pass/fail/unavailable/not-run/n/a | `<command/output summary>` |
| Unit tests | pass/fail/unavailable/not-run/n/a | `<command/output summary>` |
| Integration/e2e tests | pass/fail/unavailable/not-run/n/a | `<command/output summary>` |

## 7. Scope Adherence

| Item | Status | Evidence |
| --- | --- | --- |
| Avoided explicit out-of-scope behavior | pass/partial/fail | `<evidence>` |
| No unrelated behavior | pass/partial/fail | `<evidence>` |
| No inconsistent half-built feature | pass/partial/fail | `<evidence>` |

Scope adherence: `<pass, partial, or fail>`

## 8. Ranked Gaps

1. `<highest-impact gap or none>`
   - AC: `<AC ID>`
   - Impact: `<why it matters>`
   - Fix: `<specific production or test change>`

## 9. Archive Readiness

| Item | Status | Evidence |
| --- | --- | --- |
| Specs ready to sync/archive | yes/no | `<evidence>` |
| Evaluation complete | yes/no | `<evidence>` |
| Unresolved gaps named | yes/no | `<evidence>` |
