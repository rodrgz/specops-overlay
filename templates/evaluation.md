# Spec-Driven Evaluation: <change title>

Use this template after implementation when acceptance criteria are clear
enough to score. Every non-zero score must cite file/line evidence.
The canonical evaluator instructions live in
`skills/spec-driven-eval/references/reference.md`; this file is the reusable
project template and should stay structurally aligned with that reference.

## 1. Metadata

| Field | Value |
| --- | --- |
| Requirement source | `<path, PRD, ticket, or source>` |
| Implementation scope | `<files/modules>` |
| Test scope | `<files/modules>` |
| Diff surface | `<changed files or n/a>` |
| Mode | `normal` or `strict benchmark` |
| AC proof matrix | `<path or n/a>` |
| OpenSpec verification | `pass/fail/unavailable/not-run/n/a: <command or rationale>` |
| Evaluator | `AI-assisted` |
| Date | `<YYYY-MM-DD>` |

## 2. Requirement Inventory

| Story | Priority | AC ID | Acceptance criterion | In scope? |
| --- | --- | --- | --- | --- |
| S1 | P0 | REQ-001-AC-001 | `<criterion>` | yes |
| S1 | P0 | REQ-001-AC-002 | `<criterion>` | yes |
| S2 | P2 | REQ-002-AC-001 | `<out-of-scope criterion>` | no |

Assumptions:

- `<priority, scope, or wording assumption if any>`

Out-of-scope notes:

- `<item>` excluded from final grade because `<reason>`.

## 3. Implementation Scoring

Use scores `0`, `0.25`, `0.50`, `0.75`, or `1.00`.

| AC ID | Evidence or Search | I | Rationale |
| --- | --- | --- | --- |
| REQ-001-AC-001 | `<source-root>/...:42` | 1.00 | Fully implements required behavior |
| REQ-001-AC-002 | `<source-root>/...:95` | 0.50 | Core behavior present, but missing `<clause>` |
| REQ-002-AC-001 | searched `<paths/terms>`; none found | 0.00 | No implementation evidence found |

Strict benchmark table, when used:

| AC ID | Check ID | I-check | Task ID | Expected File(s) | Status | Evidence or Search |
| --- | --- | --- | --- | --- | --- | --- |
| REQ-001-AC-001 | I-001 | `<frozen implementation check>` | T-010 | `<source files>` | `MET` or `UNMET` | `<file:line or searched paths>` |

## 4. Test Scoring

Use scores `0`, `0.25`, `0.50`, `0.75`, or `1.00`.

| AC ID | Unit Evidence | Unit Score | Integration/e2e Evidence | Integration/e2e Score | Real Outcome Evidence | T |
| --- | --- | --- | --- | --- | --- | --- |
| REQ-001-AC-001 | `<test-root>/...:30` | 1.00 | `<test-root>/...:55` | 1.00 | `<test-root>/...:70` | 1.00 |
| REQ-001-AC-002 | `<test-root>/...:80` | 0.75 | searched `<paths/terms>`; none found | 0.00 | n/a | 0.375 |
| REQ-002-AC-001 | searched `<paths/terms>`; none found | 0.00 | searched `<paths/terms>`; none found | 0.00 | n/a | 0.00 |

Strict benchmark table, when used:

| AC ID | Check ID | T-check | Level | Task ID | Expected File(s) | Status | Evidence or Search |
| --- | --- | --- | --- | --- | --- | --- | --- |
| REQ-001-AC-001 | T-001 | `<frozen test check>` | unit/integration/e2e/outcome | T-010 | `<test files>` | `MET` or `UNMET` | `<file:line or searched paths>` |

## 5. Score Calculation

Formula:

```text
AC_score = 0.6 * I + 0.4 * T
Story_score = mean(AC_score for in-scope ACs)
Final = weighted mean of Story_score by priority
```

Priority weights:

| Priority | Weight |
| --- | --- |
| P0 | 3 |
| P1 | 2 |
| P2 / out of scope | 0 |

| AC ID | I | T | AC Score | Calculation |
| --- | --- | --- | --- | --- |
| REQ-001-AC-001 | 1.00 | 1.00 | 1.00 | `0.6*1.00 + 0.4*1.00` |
| REQ-001-AC-002 | 0.50 | 0.375 | 0.45 | `0.6*0.50 + 0.4*0.375` |

Final:

```text
S1 = mean(<AC scores>) = <value>
Final = weighted mean by priority = <value>
Band = <Spec-complete | Strong | Partial | Weak | Inadequate>
```

Strict benchmark mode:

- Derive `I` and `T` from binary atomic checks.
- Mark absent, indirect, ambiguous, or borderline checks `UNMET`.
- Use three passes by default; record why fewer passes were used.

Docs/template-only mode:

- Mark runtime test scoring `n/a` when no executable behavior exists.
- Label the result unadjusted for runtime test proof.

## 6. Test Distribution

| Class | Count | Percent | Interpretation |
| --- | --- | --- | --- |
| Necessary | `<count>` | `<%>` | Tests that prove in-scope P0/P1 ACs |
| Secondary | `<count>` | `<%>` | Edge/error tests tied to ACs or documented risks |
| Nice-to-have | `<count>` | `<%>` | Useful tests not mapped to scored ACs |

## 7. Extra Tests Inventory

| ID | Scenario | Level | Evidence | Weight |
| --- | --- | --- | --- | --- |
| E1 | `<scenario>` | unit/integration/e2e | `<test-root>/...:70` | High/Medium/Low |

Robustness index:

```text
R = High*1.0 + Medium*0.5 + Low*0.25 = <value>
```

## 8. Engineering Gates

| Gate | Status | Evidence |
| --- | --- | --- |
| OpenSpec verify | pass/fail/unavailable/not-run/n/a | `<command/output summary or fallback>` |
| Build | pass/fail/unavailable/not-run/n/a | `<command/output summary>` |
| Static checks | pass/fail/unavailable/not-run/n/a | `<command/output summary>` |
| Unit tests | pass/fail/unavailable/not-run/n/a | `<command/output summary>` |
| Integration/e2e tests | pass/fail/unavailable/not-run/n/a | `<command/output summary>` |
| Migration validation | pass/fail/unavailable/not-run/n/a | `<command/output summary>` |

`unavailable` and `not-run` gates are unadjusted and blind to runtime failure;
do not present them as passing.

If a required hard gate fails:

```text
Adjusted Final = Final * 0.5 = <value>
```

## 9. Scope Adherence

| Item | Status | Evidence |
| --- | --- | --- |
| Avoided explicit out-of-scope behavior | pass/partial/fail | `<evidence>` |
| No unrelated behavior added | pass/partial/fail | `<evidence>` |
| No inconsistent half-built feature | pass/partial/fail | `<evidence>` |

Scope adherence: `<pass, partial, or fail>`

## 10. Planned Versus Created

| Planned Item | Expected Evidence | Created Evidence | Status |
| --- | --- | --- | --- |
| `<task/test/file from tasks or proof matrix>` | `<expected path/check>` | `<actual path/check or none>` | `created/missing/unmapped` |

Planning-artifact quality is a side signal, not part of the final grade.

## 11. Scope Disposition

| Item | Disposition | Evidence | Notes |
| --- | --- | --- | --- |
| Completed scope | `<item>` | `<file:line or command>` | `<notes>` |
| Deferred idea | `<item>` | `<design/tasks reference>` | `<follow-up trigger>` |
| Unresolved gap | `<item>` | `<evidence or search>` | `<impact>` |
| Intentionally out of scope | `<item>` | `<source>` | `<rationale>` |

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
