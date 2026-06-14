# Spec-Driven Evaluation Report Template

This reference is the canonical report shape used by
`skills/spec-driven-eval/SKILL.md`. `templates/evaluation.md` is the reusable
project template for teams that want a checked-in starting point; keep both in
sync when the report shape changes. Keep scores tied to evidence. In strict
benchmark mode, fill the optional binary check tables.

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
| Date | `<date>` |

## 2. Requirement Inventory

| Story | Priority | AC ID | Acceptance criterion | In scope? |
| --- | --- | --- | --- | --- |
| S1 | P0 | AC1 | `<criterion>` | yes |
| S1 | P0 | AC2 | `<criterion>` | yes |
| S2 | P2 | AC1 | `<out-of-scope criterion>` | no |

Out-of-scope notes:

- `<item>` excluded from final grade because `<reason>`.

Assumptions:

- `<priority, scope, or wording assumption if any>`.

## 3. Implementation Scoring

| AC ID | Evidence | I | Rationale |
| --- | --- | --- | --- |
| AC1 | `<source-root>/.../Component:42-80` | 1.00 | Fully implements required behavior |
| AC2 | `<source-root>/.../Component:95-110` | 0.50 | Core behavior present, but missing `<clause>` |
| AC3 | searched `<paths/terms>`; none found | 0.00 | No implementation evidence found |

Strict benchmark check table, when used:

| AC ID | Check ID | I-check | Task ID | Expected file(s) | Status | Evidence or search |
| --- | --- | --- | --- | --- | --- | --- |
| AC1 | I-001 | `<frozen implementation check>` | T-010 | `<source files>` | `MET` or `UNMET` | `<file:line or searched paths>` |

## 4. Test Scoring

| AC ID | Unit evidence | Unit score | Integration/e2e evidence | Integration/e2e score | T |
| --- | --- | --- | --- | --- | --- |
| AC1 | `<test-root>/.../ServiceTest:30-65` | 1.00 | `<test-root>/.../HandlerTest:20-55` | 1.00 | 1.00 |
| AC2 | `<test-root>/.../ServiceTest:80-96` | 0.75 | searched `<paths/terms>`; none found | 0.00 | 0.375 |
| AC3 | searched `<paths/terms>`; none found | 0.00 | searched `<paths/terms>`; none found | 0.00 | 0.00 |

Explain required test levels when not obvious:

- AC1 requires unit and integration/e2e because it includes business rules and
  observable HTTP behavior.
- AC2 requires integration/e2e because persistence side effects are part of the
  requirement.

Strict benchmark T-check table, when used:

| AC ID | Check ID | T-check | Level | Task ID | Expected file(s) | Status | Evidence or search |
| --- | --- | --- | --- | --- | --- | --- | --- |
| AC1 | T-001 | `<frozen test check>` | unit/integration/e2e/outcome | T-010 | `<test files>` | `MET` or `UNMET` | `<file:line or searched paths>` |

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
| AC1 | 1.00 | 1.00 | 1.00 | `0.6*1.00 + 0.4*1.00` |
| AC2 | 0.50 | 0.375 | 0.45 | `0.6*0.50 + 0.4*0.375` |
| AC3 | 0.00 | 0.00 | 0.00 | `0.6*0.00 + 0.4*0.00` |

Story score:

```text
S1 = mean(AC1, AC2, AC3) = <value>
```

Final:

```text
Final = weighted mean by priority = <value>
Band = <Spec-complete | Strong | Partial | Weak | Inadequate>
```

For strict benchmark mode, paste the script command and output used to compute
the roll-up. Partial AC scores come from binary atomic checks: borderline,
indirect, or ambiguous checks are `UNMET`.

## 6. Test Distribution

Classify tests by contribution to scored requirements.

| Class | Count | Percent | Interpretation |
| --- | --- | --- | --- |
| Necessary | `<count>` | `<%>` | Primary tests that prove in-scope P0/P1 ACs. |
| Secondary | `<count>` | `<%>` | Edge/error tests tied to ACs or documented risks. |
| Nice-to-have | `<count>` | `<%>` | Useful tests not mapped to scored ACs. |

Nice-to-have tests are reported but do not raise the final grade. Missing
necessary tests rank above extra robustness tests.

## 7. Extra Tests Inventory

Extra tests do not increase the final grade, but they indicate robustness.

| ID | Scenario | Level | Evidence | Weight |
| --- | --- | --- | --- | --- |
| E1 | Invalid request returns 400 | integration/e2e | `<test-root>/...:70-88` | High |
| E2 | Repository handles empty result | unit | `<test-root>/...:20-28` | Medium |

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

## 12. Ranked Gaps

1. `<Highest-impact gap>`
   - AC: `<AC ID>`
   - Impact: `<why it matters>`
   - Fix: `<specific production/test change>`

2. `<Next gap>`
   - AC: `<AC ID>`
   - Impact: `<why it matters>`
   - Fix: `<specific production/test change>`

## 13. Path To 1.00

- `<production fix>`
- `<unit test fix>`
- `<integration/e2e test fix>`
- `<documentation or spec clarification if needed>`

## Minimal Worked Example

Spec:

- AC1: Creating an order with valid items returns `201` and persists the order.
- AC2: Creating an order with no items returns `400`.

Evidence:

- Implementation for AC1: `OrderHandler:28-40`,
  `OrderService:50-82`, `OrderRepository:15-22`.
- Test for AC1: `OrderHandlerTest:31-70`.
- Implementation for AC2: `CreateOrderRequest:10-18`.
- Test for AC2: searched `OrderHandlerTest`, `OrderServiceTest`, `rg "no items|empty items|400"`; none found.

Scores:

| AC | I | T | AC score | Notes |
| --- | --- | --- | --- | --- |
| AC1 | 1.00 | 1.00 | 1.00 | Fully implemented and tested through HTTP/persistence |
| AC2 | 0.75 | 0.00 | 0.45 | Validation exists, but no test evidence |

Final:

```text
Story = mean(1.00, 0.45) = 0.725
Final = 0.725
Band = Partial
```
