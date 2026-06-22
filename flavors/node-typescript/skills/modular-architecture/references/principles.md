# Modular Principles

Use this reference when explaining or applying architecture rules in
Node/TypeScript repositories. Each principle has rules that can be checked in a
repository.

## P1: Well-Defined Boundaries

A module owns its internals and exposes a small public contract.

Agent rules:

- Do not import another module's entity/model/schema, repository, or internal
  service.
- Use facades, ports, clients, events, commands, or DTO/contracts for
  cross-module communication.
- Do not widen public APIs just to make a local implementation easier.

## P2: Composability

Modules should work together through explicit contracts.

Agent rules:

- When adding a dependency, make it visible in constructor injection, module
  metadata, config, messaging subscription, or client interface.
- Do not introduce hidden static lookups or global mutable state.
- Keep module setup understandable from its directory and configuration.

## P3: Independence

A module should be testable and understandable in isolation.

Agent rules:

- Unit tests for a module should not require unrelated modules unless the test
  is explicitly integration/e2e.
- Fixtures should use public APIs or test builders, not sibling internals.
- Do not couple two modules through a shared mutable object.

## P4: Individual Scale

Hot paths and expensive integrations should be tunable separately.

Agent rules:

- Keep high-throughput consumers, schedulers, and long-running workers in
  modules or directories that reveal their execution model.
- Add bounded queries and pagination for request paths.
- Avoid putting unrelated heavy operations in the same transaction or handler
  method.

## P5: Explicit Communication

Communication across boundaries should be visible and versionable.

Agent rules:

- Name contracts after business intent.
- Version external events or APIs when compatibility matters.
- Prefer event payloads that carry enough state to avoid immediate cross-module
  data-store reads.

## P6: Replaceability

Use interfaces, symbol tokens, or ports when replacement is a real design need.

Agent rules:

- Do not introduce interfaces for every component by default.
- Introduce a port when there are multiple implementations, a remote boundary,
  a vendor dependency, or a testability/ownership reason.
- Keep adapters near infrastructure concerns; keep services near business
  concerns.

## P7: Deployment Awareness

Code should not unnecessarily assume that every module is in-process forever.

Agent rules:

- Do not rely on direct database access to another module's state.
- Prefer contracts that can survive extraction to another service when the
  boundary is important.
- Keep transport-specific code at the edge.

## P8: State Isolation

One module owns each table, collection, topic schema, queue payload, or durable
state model.

Agent rules:

- A module's repositories write only that module's owned data stores.
- Cross-module writes happen through commands, APIs, events, or the owning
  module's public API.
- Shared persistence utilities may exist; shared business repositories should
  not.
- Data-store names should make ownership clear when a database is shared.

## P9: Observability

Operational signals should identify module and operation.

Agent rules:

- Logs should include enough context to trace module behavior.
- Metrics labels must stay bounded and should include stable module/operation
  names where useful.
- Health checks should represent dependencies owned or required by the module.
- Do not log secrets or sensitive PII.

## P10: Failure Isolation

Failures should be contained where practical.

Agent rules:

- External calls should have timeouts.
- Use retries only when safe.
- Use circuit breakers, bulkheads, queues, or degraded behavior for unstable
  dependencies where the project supports them.
- Do not make a low-priority integration fail a critical business path unless
  the product requirement says so.

## P11: Aggregate Co-Location

One business concept should be easy to find in one cohesive unit.

Good:

```text
orders/order/
|-- order.entity.ts
|-- order.repository.ts
|-- order.service.ts
|-- order.controller.ts
`-- order.dto.ts
```

Avoid for new domain code:

```text
orders/controllers/order.controller.ts
orders/services/order.service.ts
orders/repositories/order.repository.ts
```

## P12: Suffixes Over Technical Directories

Use name suffixes to identify role inside an aggregate unit.

Common suffixes:

- `.entity.ts`, `.model.ts`, or `.schema.ts`
- `.repository.ts` or `.adapter.ts`
- `.service.ts`
- `.controller.ts`, `.resolver.ts`, `.handler.ts`, or `.processor.ts`
- `.dto.ts`, `.contract.ts`, or `.types.ts`
- `.mapper.ts`
- `.facade.ts`
- `.client.ts`
- `.event.ts`
- `.command.ts`
- `.module.ts`

## P13: Directory Depth

Keep domain code shallow enough to navigate.

Guidance:

- Flat module: `<module>/<aggregate>/<file>`
- Subdomain module: `<module>/<subdomain>/<aggregate>/<file>`
- Avoid deeper nesting unless the project has a strong local convention.

## P14: Avoid Single-File Technical Directories

A directory with one helper file is often a naming problem.

Prefer:

```text
order/order-price-calculator.service.ts
```

Avoid:

```text
order/calculator/price-calculator.ts
```

Allowed exceptions include generated code, framework-required directory shapes,
test utilities with multiple consumers, and project-established conventions.

## P15: Test Location Mirrors Production

Tests should mirror the production module layout under the project test root or
the local project convention.

Rules:

- Unit tests sit near the mirrored path of the component under test.
- Integration/e2e tests may use naming conventions such as `.int-spec.ts`,
  `.e2e-spec.ts`, `.test.ts`, or the project convention.
- Do not move tests merely for style in a small bug fix.

## P16: Facades Are Thin

A facade is a public module API, not a second service layer.

Rules:

- Facades delegate to services or compose simple results.
- Put business decisions in services.
- Avoid exposing entities/models directly from facades if callers outside the
  module do not own those entities.

## P17: Shared Code Is Conservative

Shared code must be stable and low-level.

Good shared candidates:

- ID/value primitives.
- Date/time abstractions.
- Error envelope types.
- Observability helpers.
- Test infrastructure.

Poor shared candidates:

- Business workflows.
- Repositories.
- Mutable state owned by a module.
- "Common" services with mixed domain behavior.

## P18: Brownfield Compatibility

Existing projects may already use layered layouts. Do not churn structure
without a reason.

Agent rules:

- For new code, prefer aggregate-oriented units when the project allows it.
- For small edits, follow the local style unless changing structure is part of
  the task.
- When migrating, move one module or aggregate at a time and keep tests green.

## P19: Documentation Placement

Docs belong at project, module, or architecture level.

Rules:

- Avoid README files inside every aggregate unit.
- Use `docs/`, ADRs, or module-level docs for architecture decisions.
- Let code structure carry routine navigation.
