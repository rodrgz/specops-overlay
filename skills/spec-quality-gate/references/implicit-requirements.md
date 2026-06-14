# Implicit Requirements Checklist

Use this checklist to improve recall without gold-plating. Each row must be
classified as `in scope`, `out of scope`, or `unknown`, with rationale.

| Concern | Review question | Allowed outcome |
| --- | --- | --- |
| Validation | Are request shape, business invariants, and invalid states specified? | `in scope` when required to make an AC safe; `out of scope` for unrelated validation; `unknown` when invalid behavior changes product semantics. |
| Idempotency | Can the same command, webhook, message, or retry run twice? | `in scope` for repeatable external mutations or at-least-once delivery; `out of scope` for pure reads; `unknown` when duplicate behavior changes billing, access, or ownership. When the surface applies, this row cannot be skipped; record the idempotency key, uniqueness rule, or duplicate-outcome proof. |
| Authorization | Does the actor have permission for the resource or action? | `in scope` for protected user or admin behavior; `out of scope` only when the slice is explicitly unauthenticated; `unknown` when roles are not documented. |
| Identity boundaries | Could a user read or mutate another user's resource? | `in scope` for user-owned data; `out of scope` for system-only jobs; `unknown` when ownership is ambiguous. |
| Transient dependency failures | What happens when a required dependency times out or is unavailable? | `in scope` when an AC depends on an external system; `out of scope` for local-only logic; `unknown` when retry/fallback semantics affect product outcome. When in scope, identify the typed transient error exposed to callers or operators. |
| Typed errors | Are client-actionable errors represented with stable codes or shapes? | `in scope` for API contracts and external failures; `out of scope` for internal-only operations; `unknown` when public error compatibility matters. When the surface applies, this row cannot be skipped; record the expected stable error code, status, envelope, or domain error. |
| Concurrency | Can two requests create the same business outcome or race on status? | `in scope` when duplicate writes, uniqueness, or state transitions matter; `out of scope` for immutable reads; `unknown` when locking or uniqueness is not documented. When the surface applies, this row cannot be skipped; record the race, guard, and proof strategy. |
| Observability | Are important failures and outcomes visible without leaking secrets? | `in scope` for external dependencies, async jobs, and critical state changes; `out of scope` for trivial pure functions; `unknown` when audit or compliance requirements are unclear. |
| Privacy | Could logs, errors, fixtures, or responses expose PII or secrets? | `in scope` for user data, credentials, payments, identity, and external payloads; `out of scope` only when no sensitive data is handled; `unknown` when data classification is missing. |
| Data consistency | Must local state and emitted events change atomically or recoverably? | `in scope` for persistence plus messaging or multi-write workflows; `out of scope` for stateless behavior; `unknown` when partial failure semantics are undefined. |
| Async completion | How does the system know a webhook, job, or message completed? | `in scope` for async state transitions; `out of scope` for synchronous-only behavior; `unknown` when final state is not specified. When the surface applies, this row cannot be skipped; record the terminal state and real-outcome proof such as persisted state, durable event, or externally visible status. |
| Rollback | What must happen when migration, deployment, or multi-step work fails? | `in scope` for persistence or rollout-sensitive changes; `out of scope` for docs-only work; `unknown` when recovery policy affects production readiness. |

## Clarification Rule

Ask the user or product owner only when a reasonable scoped assumption would be
risky. Otherwise, make the smallest defensible assumption, record the rationale,
and keep unrelated enhancements out of scope.

## Anti-Gold-Plating Rule

Do not add endpoints, jobs, configuration, integrations, or tests merely because
they are generally useful. The item must map to an AC, one of the concerns above
with an `in scope` rationale, or a documented engineering gate.
