# Proposal: <change title>

## Metadata

| Field | Value |
| --- | --- |
| Change ID | `<kebab-case-change-id>` |
| Status | `draft` |
| Owner | `<person or team>` |
| Date | `<YYYY-MM-DD>` |
| Source | `<ticket, PRD, incident, user request, or n/a>` |

## Why

Describe the problem, user need, operational issue, or product opportunity.
State why the current behavior is insufficient.

## Current Behavior

Summarize observable behavior today. Link to existing specs when available.

## Proposed Change

Summarize the intended behavior change. Keep this behavior-focused; defer
implementation details to `design.md`.

## Capability Deltas

Before naming capabilities, inspect `openspec/specs/` for existing canonical
capability names. Use `MODIFIED` when changing behavior already represented by
an existing spec, `ADDED` for a new behavior area, and `REMOVED` only when a
capability or requirement is intentionally retired.

Each capability listed below maps to a delta spec at:

```text
openspec/changes/<change-id>/specs/<capability>/spec.md
```

### New Capabilities

| Capability | Delta spec path | Summary |
| --- | --- | --- |
| `<new-capability>` | `openspec/changes/<change-id>/specs/<new-capability>/spec.md` | `<new observable behavior>` |

### Modified Capabilities

| Capability | Delta spec path | Summary |
| --- | --- | --- |
| `<existing-capability>` | `openspec/changes/<change-id>/specs/<existing-capability>/spec.md` | `<changed observable behavior>` |

### Removed Capabilities

| Capability | Delta spec path or source spec | Summary |
| --- | --- | --- |
| `<removed-capability>` | `openspec/changes/<change-id>/specs/<removed-capability>/spec.md` | `<removed behavior and rationale>` |

## Requirement Inventory

Use stable IDs from the start. Requirement IDs use `REQ-001`. Acceptance
criteria use `<requirement-id>-AC-001`, for example `REQ-001-AC-001`.

| Req ID | Priority | Summary | AC IDs | Spec path |
| --- | --- | --- | --- | --- |
| REQ-001 | P0 | `<requirement summary>` | REQ-001-AC-001 | `openspec/changes/<change-id>/specs/<capability>/spec.md` |

Priority meanings:

- `P0`: required for the change to be usable.
- `P1`: important but not release-blocking when explicitly deferred.
- `P2`: future slice or out of scope for this change.

## Scope

| Item | Status | Rationale |
| --- | --- | --- |
| `<behavior or artifact>` | `in scope` | `<why>` |
| `<future behavior>` | `out of scope` | `<why excluded now>` |
| `<unclear behavior>` | `unknown` | `<what must be clarified>` |

## Relevant Context

| Context | Required? | Notes |
| --- | --- | --- |
| `docs/project/ARCHITECTURE.md` | yes/no | `<why>` |
| `docs/project/STACK.md` | yes/no | `<why>` |
| `docs/project/STRUCTURE.md` | yes/no | `<why>` |
| `docs/project/CONVENTIONS.md` | yes/no | `<why>` |
| `docs/project/TESTING.md` | yes/no | `<why>` |
| `docs/project/INTEGRATIONS.md` | yes/no | `<why>` |
| `docs/project/CONCERNS.md` | yes/no | `<why>` |
| Selected flavor guidance | yes/no | `<flavor id and reason, or n/a>` |

## Risk And Gate Decision

| Concern | Present? | Notes |
| --- | --- | --- |
| Explicit acceptance criteria | yes/no | `<notes>` |
| External integration | yes/no | `<notes>` |
| Persistence or migration | yes/no | `<notes>` |
| Messaging, async, scheduled, or webhook behavior | yes/no | `<notes>` |
| Security, privacy, or authorization | yes/no | `<notes>` |
| Configuration or rollout risk | yes/no | `<notes>` |
| Hidden requirement risk | yes/no | `<notes>` |

Spec quality gate:

- Required before implementation: yes/no
- Reason: `<why the gate is or is not required>`

## Impact

| Area | Impact |
| --- | --- |
| Behavior | `<observable behavior impact>` |
| Data | `<data/state impact or n/a>` |
| Integrations | `<external or internal contract impact or n/a>` |
| Operations | `<deployment, config, monitoring, support impact or n/a>` |
| Documentation | `<docs/project or spec updates needed>` |

## Validation Plan

List the build, static checks, unit tests, integration/e2e tests, migration
validation, or manual checks expected for this change. Use documented commands
from `docs/project/TESTING.md`; do not invent commands here.

## Open Questions

- `<question that blocks safe scoping, or none>`
