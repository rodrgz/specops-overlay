# Evidence Proof: <change title>

Use this file before implementation to make each acceptance criterion
verifiable. During planning, evidence cells can stay empty. After
implementation, fill them with file/line evidence or the searches performed.

Status values:

- `planned`: proof is defined but not yet executed.
- `MET`: evidence fully proves the check.
- `UNMET`: evidence is absent, ambiguous, or incomplete.
- `blocked`: proof cannot be planned safely without clarification.
- `excluded`: out of scope for this change.

## AC Interpretation Freeze

| AC ID | Frozen interpretation | Status | Rationale |
| --- | --- | --- | --- |
| REQ-001-AC-001 | `<resolved assumption or exact reading>` | frozen/resolved/unknown | `<source or reason>` |

## Scope Decisions

| Item | Decision | Rationale |
| --- | --- | --- |
| `<implicit requirement or future behavior>` | `in scope/out of scope/unknown` | `<why>` |

## Proof Matrix

| Story ID | Req ID | Priority | AC ID | Check ID | Task ID | Expected file(s) | Scope status | Weight | I-check | Unit T-check | Integration/e2e T-check | Real outcome T-check | Evidence | Status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| S1 | REQ-001 | P0 | REQ-001-AC-001 | I-001 | T-010 | `<source files>` | in scope | 3 | `<atomic implementation behavior to prove>` | n/a | n/a | n/a | `<file:line after implementation>` | planned |
| S1 | REQ-001 | P0 | REQ-001-AC-001 | T-001 | T-010 | `<test files>` | in scope | 3 | n/a | `<service/domain assertion or n/a>` | `<boundary, persistence, security, config, or external assertion or n/a>` | `<persisted state, durable event, returned payload, or n/a>` | `<file:line after implementation>` | planned |

## Gate Result

| Field | Value |
| --- | --- |
| Result | `pass/partial/fail/skipped/blocked` |
| Reason | `<why this gate result is justified>` |
| Required validation | `<commands or review steps>` |
| Blockers | `<none or unresolved AC/scope issues>` |

## Notes

- Tests that only execute a path without assertions do not prove an AC.
- Mock-only proof is not enough for final persisted state, durable events, or
  user-visible outcomes unless the requirement is specifically the call itself.
- Borderline, indirect, or ambiguous evidence is `UNMET`.
