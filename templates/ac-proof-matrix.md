# AC Proof Matrix: <change title>

Use this file before implementation to make each acceptance criterion
verifiable. During planning, evidence cells can stay empty. After
implementation, fill them with file/line evidence or the searches performed.

Status values:

- `planned`: proof is defined but not yet executed.
- `MET`: evidence fully proves the check.
- `UNMET`: evidence is absent, ambiguous, or incomplete.
- `blocked`: proof cannot be planned safely without clarification.
- `excluded`: out of scope for this change.

| Story ID | Req ID | Priority | AC ID | Check ID | Task ID | Expected file(s) | Scope status | Weight | I-check | Unit T-check | Integration/e2e T-check | Real outcome T-check | Evidence | Status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| S1 | REQ-001 | P0 | REQ-001-AC-001 | I-001 | T-010 | `<source files>` | in scope | 3 | `<atomic implementation behavior to prove>` | n/a | n/a | n/a | `<file:line after implementation>` | planned |
| S1 | REQ-001 | P0 | REQ-001-AC-001 | T-001 | T-010 | `<test files>` | in scope | 3 | n/a | `<service/domain assertion or n/a>` | `<boundary, persistence, security, config, or external assertion or n/a>` | `<persisted state, durable event, returned payload, or n/a>` | `<file:line after implementation>` | planned |
| S1 | REQ-001 | P0 | REQ-001-AC-002 | I-002 | T-011 | `<source files>` | unknown | 3 | `<needs clarification>` | `<test needed if in scope>` | `<test needed if in scope>` | `<test needed if in scope>` | `<empty until resolved>` | blocked |
| S2 | REQ-002 | P2 | REQ-002-AC-001 | X-001 | n/a | n/a | out of scope | 0 | n/a | n/a | n/a | n/a | `<rationale>` | excluded |

## Required Fields

- `Story ID`: stable story label, such as `S1`.
- `Req ID`: stable requirement ID, such as `REQ-001`.
- `Priority`: `P0`, `P1`, `P2`, or a project-defined priority.
- `AC ID`: stable acceptance criterion ID, such as `REQ-001-AC-001`.
- `Check ID`: stable atomic check ID. One AC can have multiple I-check and
  T-check rows.
- `Task ID`: task expected to create or prove the check.
- `Expected file(s)`: planned implementation, test, or documentation files.
- `Scope status`: `in scope`, `out of scope`, or `unknown`.
- `Weight`: scoring weight. Use `0` for out-of-scope ACs.
- `I-check`: production behavior that proves implementation.
- `Unit T-check`: unit-level assertion for service, domain, or pure logic.
- `Integration/e2e T-check`: boundary-level assertion for observable behavior.
- `Real outcome T-check`: final persisted state, durable event, returned
  payload, or equivalent observable outcome when relevant.
- `Evidence`: file/line evidence after implementation, or searched paths when
  evidence is missing.
- `Status`: `planned`, `MET`, `UNMET`, `blocked`, or `excluded`.

## AC Interpretation Freeze

| AC ID | Frozen interpretation | Status | Rationale |
| --- | --- | --- | --- |
| REQ-001-AC-001 | `<resolved assumption or exact reading>` | frozen/resolved/unknown | `<source or reason>` |

## Scope Decisions

| Item | Decision | Rationale |
| --- | --- | --- |
| `<implicit requirement or future behavior>` | `in scope/out of scope/unknown` | `<why>` |

## Notes

- Tests that only execute a path without assertions do not prove an AC.
- Mock-only proof is not enough for final persisted state, durable events, or
  user-visible outcomes unless the requirement is specifically the call itself.
- Extra defensive tests are useful, but they do not compensate for missing AC
  proof.
- In strict mode, each atomic check resolves to `MET` or `UNMET`. Borderline,
  indirect, or ambiguous evidence is `UNMET`; partial AC scores come from the
  fraction of met checks, not subjective per-check credit.
