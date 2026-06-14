# AC Proof Matrix

Use this matrix before implementation to ensure every acceptance criterion has
implementation proof and test proof. In normal planning mode, evidence cells may
remain empty until implementation. In strict benchmark mode, each frozen check
must resolve to `MET` or `UNMET` with file/line evidence.

## Template

| Story ID | Priority | AC ID | Check ID | Task ID | Expected file(s) | Scope status | Weight | I-check | Unit T-check | Integration/e2e T-check | Real outcome T-check | Evidence placeholder | Status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| S1 | P0 | AC1 | I-001 | T-010 | `<source files>` | in scope | 3 | `<atomic implementation behavior to prove>` | n/a | n/a | n/a | `<file:line after implementation>` | planned |
| S1 | P0 | AC1 | T-001 | T-010 | `<test files>` | in scope | 3 | n/a | `<service/domain assertion or n/a>` | `<HTTP/persistence/security/etc. assertion or n/a>` | `<persisted state, durable event, or n/a>` | `<file:line after implementation>` | planned |
| S1 | P0 | AC2 | I-002 | T-011 | `<source files>` | unknown | 3 | `<needs clarification>` | `<test needed if in scope>` | `<test needed if in scope>` | `<test needed if in scope>` | empty until resolved | blocked |
| S2 | P2 | AC3 | X-001 | n/a | n/a | out of scope | 0 | n/a | n/a | n/a | n/a | rationale only | excluded |

## Required Columns

- `Story ID`: stable story or requirement label.
- `Priority`: `P0`, `P1`, `P2`, or project-specific priority.
- `AC ID`: stable acceptance criterion ID.
- `Check ID`: stable atomic check ID; one AC can have multiple rows.
- `Task ID`: task expected to create or prove the check.
- `Expected file(s)`: planned implementation, test, or documentation paths.
- `Scope status`: `in scope`, `out of scope`, or `unknown`.
- `Weight`: priority weight for scoring. Out-of-scope ACs use weight `0`.
- `I-check`: implementation behavior that proves the AC.
- `Unit T-check`: unit test proof for service/domain rules.
- `Integration/e2e T-check`: proof for HTTP, persistence, transactions,
  messaging, security, config, or external boundaries.
- `Real outcome T-check`: persisted state, durable emitted event, or equivalent
  observable result for async/webhook/message-driven behavior.
- `Evidence placeholder`: file/line evidence after implementation.
- `Status`: `planned`, `MET`, `UNMET`, `blocked`, or `excluded`.

## Benchmark Mode

Strict benchmark mode uses binary wording:

- `MET`: evidence exists and the check is fully satisfied.
- `UNMET`: evidence is absent, ambiguous, only indirectly exercised, or
  borderline.

Partial AC scores are derived from the fraction of `MET` checks. Do not assign
subjective partial credit to an individual check. Borderline, indirect, or
ambiguous evidence is `UNMET`.

## Planning Notes

- Tests without assertions do not prove a check.
- Mock-only proof can verify mapping or error translation, not final business
  outcome.
- Nice-to-have tests may be recorded separately, but they do not compensate for
  missing AC checks.
- Ambiguous AC interpretation must be resolved, frozen as an assumption, or
  marked `unknown` before implementation tasks start.
