---
name: modular-architecture
description: Guides modular Node/TypeScript service architecture. Use before creating modules, changing boundaries, introducing facades, repositories, persistence ownership, subdomains, public package APIs, or reviewing modularity. Do not use for simple bug fixes that do not affect structure.
---

# Modular Architecture

Use this skill to design, scaffold, evaluate, or refactor modular
Node/TypeScript services. It favors pragmatic domain-oriented modularity over
generic layer-by-layer layouts.

## Core Philosophy

- Apps are bootstraps and composition roots.
- Modules are bounded contexts with their own vocabulary, model, persistence
  ownership, and public API.
- Aggregates are the default unit of code organization.
- Names should reveal business capability before technical mechanism.
- Cross-module communication must be explicit through facades, ports, clients,
  events, commands, or stable DTO/contracts.

## Default Structure

Prefer flat-by-aggregate within each module. The concrete source root depends
on the project, such as `src/`, `packages/`, `libs/`, or `app/`.

```text
<source-root>/<module>/
|-- <aggregate>/
|   |-- <aggregate>.entity.ts or <aggregate>.model.ts
|   |-- <aggregate>.repository.ts or <aggregate>.adapter.ts
|   |-- <aggregate>.service.ts
|   |-- <aggregate>.controller.ts, .resolver.ts, .handler.ts, or .processor.ts
|   |-- <aggregate>.dto.ts or <aggregate>.contract.ts
|   `-- <aggregate>.mapper.ts                    # optional
|-- <module>.facade.ts                           # public in-process API
|-- <module>.module.ts                           # framework metadata, if used
`-- index.ts                                     # public exports only
```

Tests should follow the project convention and mirror the production module
layout where practical.

Use subdomains only when the module has real internal boundaries:

```text
<source-root>/<module>/
|-- <subdomain>/
|   |-- <aggregate>/
|   `-- <subdomain>.facade.ts
`-- <module>.facade.ts
```

Flat is the default. Split only when independent ownership, security, scale,
execution model, deployment cadence, or failure isolation justifies it.

## Principles

| # | Principle | Key rule |
| --- | --- | --- |
| 1 | Boundaries | A module exposes public APIs/facades, not internals |
| 2 | Composability | Modules can be used together without hidden coupling |
| 3 | Independence | A module can be tested and reasoned about in isolation |
| 4 | Scale | Resource-heavy concerns can be tuned independently |
| 5 | Explicit communication | Cross-module contracts are visible and versionable |
| 6 | Replaceability | Adapters and ports are used where replacement matters |
| 7 | Deployment awareness | Code does not assume every module is always in-process |
| 8 | State isolation | Persistence stores and writes have one owning module |
| 9 | Observability | Logs, metrics, traces, and health identify module/operation |
| 10 | Failure isolation | One dependency failure should not cascade unnecessarily |

Structural principles for co-location, depth, naming, tests, and shared code
are in `references/principles.md`.

## Critical Violations

- A controller, resolver, handler, or processor injects a repository directly.
- A service imports another module's repository, entity, model, or schema.
- A module writes durable state owned by another module.
- Shared packages contain mutable business logic for multiple modules.
- Technical layout (`controllers/`, `services/`, `repositories/`, `dtos/`)
  hides the domain structure for new code.
- A facade contains business logic instead of delegating to module services.
- A new endpoint, resolver, queue consumer, or webhook lacks integration/e2e
  coverage for important paths.
- Persistence queries are exposed outside repositories/adapters.

## Reference Loading

Load only what the task needs:

| Task | Reference |
| --- | --- |
| Create a new module or aggregate | `references/module-scaffolding.md` |
| Decide whether to split into subdomains | `references/module-scaffolding.md` |
| Understand a principle or structural rule | `references/principles.md` |
| Manage persistence ownership across subdomains | `references/subdomain-persistence.md` |
| Review or score modular compliance | `references/verification.md` |
| Run architecture detection commands | `references/verification.md` |

## Workflows

### Creating a Module

1. Identify the module's bounded context, public API, aggregates, persistence
   ownership, external dependencies, and test surface.
2. Choose flat-by-aggregate unless subdomain criteria are met.
3. Load `references/module-scaffolding.md`.
4. Generate the module structure in the project style.
5. Add unit tests for business rules and integration/e2e tests for APIs,
   persistence, messaging, and cross-boundary behavior.
6. Run project build, typecheck, lint, tests, and architecture verification
   commands where available.

### Evaluating a Boundary

1. Identify the files touched and the modules they belong to.
2. Check whether dependencies point inward to public APIs or outward to
   internals.
3. Check persistence ownership: repositories and writes must stay in the owning
   module.
4. Check whether duplicated concepts indicate shared-kernel pressure or a
   missing public contract.
5. Produce prioritized findings with exact file references.

### Reviewing a Refactor

1. Load `references/verification.md`.
2. Run structural searches.
3. Compare before/after module shape.
4. Verify tests moved or stayed aligned with the production structure.
5. Confirm no public contract was widened unintentionally.

## Quick Checklist

- Module name describes a business capability.
- Aggregate unit contains related model/repository/service/handler/DTOs.
- Boundary adapter classes are API-only.
- Service classes own business rules.
- Repository/adapters own persistence/query details.
- Public cross-module calls use facades, ports, clients, events, or commands.
- Root indexes export stable public APIs only.
- Shared code is stable, small, and not business-process ownership.
- Tests cover business rules and externally observable behavior.
