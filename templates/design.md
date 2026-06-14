# Design: <change title>

## Context

Summarize the proposal, relevant specs, and project-reference docs loaded for
this design. Keep behavior requirements in `spec.md`; use this file for
implementation decisions and tradeoffs.

## Goals

- `<goal mapped to REQ/AC IDs>`

## Non-Goals

- `<explicitly out-of-scope behavior or implementation>`

## Deferred Ideas

Record "while here" ideas that do not map to an AC, sanctioned implicit risk,
or engineering gate. Deferred ideas are not implementation scope for this
change.

| Idea | Reason Deferred | Follow-up Trigger |
| --- | --- | --- |
| `<idea>` | `<why not part of this change>` | `<future AC, risk, or owner>` |

## Relevant Project Context

| Source | Decision Impact |
| --- | --- |
| `docs/project/ARCHITECTURE.md` | `<architecture constraint or n/a>` |
| `docs/project/STACK.md` | `<tool/runtime constraint or n/a>` |
| `docs/project/STRUCTURE.md` | `<layout or ownership constraint or n/a>` |
| `docs/project/CONVENTIONS.md` | `<coding/API/logging constraint or n/a>` |
| `docs/project/TESTING.md` | `<validation command or strategy impact>` |
| `docs/project/INTEGRATIONS.md` | `<dependency or contract impact or n/a>` |
| `docs/project/CONCERNS.md` | `<risk or operational concern or n/a>` |
| Selected flavor docs | `<flavor-specific constraint or n/a>` |

## Decision Summary

| Decision | Chosen Approach | Alternatives Considered | Reason |
| --- | --- | --- | --- |
| `<decision>` | `<approach>` | `<alternative>` | `<why>` |

## Architecture And Boundaries

Describe affected modules, services, interfaces, ownership boundaries, and
public contracts. If a selected flavor provides a boundary or architecture
skill, summarize the decisions from that skill here.

## Data And State

Document data model changes, state transitions, migrations, retention, privacy,
and consistency rules. Write `n/a` when no data or state changes are planned.

## Interfaces And Integrations

Document API contracts, client calls, events, jobs, webhooks, files, or other
integration boundaries. Include idempotency, retry, timeout, and failure
behavior when relevant.

## Security And Privacy

Document authorization, authentication, input validation, secrets handling,
audit logging, privacy, and data exposure decisions.

## Observability And Operations

Document logs, metrics, traces, alerts, feature flags, configuration, rollout,
rollback, and support considerations.

## Test Strategy

Map ACs to the smallest sufficient proof level.

| AC ID | Unit proof | Integration/e2e proof | Real outcome proof | Notes |
| --- | --- | --- | --- | --- |
| REQ-001-AC-001 | `<unit assertion or n/a>` | `<boundary assertion or n/a>` | `<persisted state, emitted durable event, or n/a>` | `<notes>` |

## Scope Guard

| Planned item | Maps to | Status |
| --- | --- | --- |
| `<file, endpoint, job, event, or doc>` | `<REQ/AC ID, risk, or gate>` | `in scope` |
| `<item>` | `<none>` | `remove or defer` |

## Open Questions

- `<question that blocks implementation, or none>`

## State And Handoff

Use this section only when the change is long-running or needs resume context.

| Item | Status | Notes |
| --- | --- | --- |
| Decision | `<active/final>` | `<decision and evidence>` |
| Blocker | `<open/resolved>` | `<owner or unblock condition>` |
| Validation | `<pending/pass/fail/unavailable>` | `<command and result>` |
| Deferred idea | `<deferred>` | `<where it is tracked>` |
