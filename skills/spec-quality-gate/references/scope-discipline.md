# Scope Discipline Rules

Use these rules to preserve OpenSpec's scope adherence while improving implicit
requirement recall.

## Sanctioned Implicit Requirements

An implicit requirement is sanctioned when it is necessary to satisfy an AC or
to make an AC safe in the adopting project's documented architecture. Examples:

- idempotency for at-least-once webhook delivery;
- authorization for user-owned resources;
- typed error contracts for public API failures;
- concurrency protection for duplicate business outcomes;
- real-outcome tests for async persistence or durable events.

Every inferred requirement needs a rationale that points to the AC, risk, or
engineering gate that justifies it.

## AC Interpretation Freeze

Before implementation tasks start, each ambiguous AC must be handled in one of
three ways:

- resolve it with the product owner or source artifact;
- freeze the smallest defensible interpretation as an assumption in the design,
  task file, or AC proof matrix;
- mark it `unknown`/blocked and keep implementation for that AC out of scope.

Do not let the meaning of an AC change after implementation reveals a cheaper
or easier path.

## Out Of Scope

Mark an item `out of scope` when it is:

- roadmap or future-slice behavior;
- a new endpoint, job, event, or integration not required by the ACs;
- a broad platform improvement that would be useful but not necessary;
- a test that proves a nice-to-have scenario without mapping to an AC or risk.

Out-of-scope ACs use weight `0` in evaluation.

## Drift Rejection

Reject or remove planned files, endpoints, jobs, events, configuration, or
tests that do not map to one of:

- an in-scope AC;
- a sanctioned implicit requirement with rationale;
- a documented engineering gate.

If the item may be useful later, record it as out of scope instead of building
it.

Before implementation, tasks should list expected files and tests. After
implementation, evaluation should compare planned items to created artifacts:
planned tasks/tests that were never created are gaps, and created files/tests
without AC, risk, or gate mapping are scope drift.

## Benchmark Lesson

All OpenSpec benchmark runs passed scope adherence. The new gate must preserve
that strength: improve recall, but do not convert hidden-requirement review
into product expansion.
