# Module Scaffolding

Use this reference when creating modules, aggregates, or subdomain-based
structures in modular Node/TypeScript services.

## Flat Module

Use flat-by-aggregate as the default. It is appropriate when a module has a
cohesive business vocabulary and the aggregates are owned by the same team or
deployment unit.

```text
<source-root>/<module>/
|-- <aggregate>/
|   |-- <aggregate>.entity.ts or <aggregate>.model.ts
|   |-- <aggregate>.repository.ts or <aggregate>.adapter.ts
|   |-- <aggregate>.service.ts
|   |-- <aggregate>.controller.ts, .resolver.ts, .handler.ts, or .processor.ts
|   |-- <aggregate>.dto.ts or <aggregate>.contract.ts
|   `-- <aggregate>.mapper.ts
|-- <module>.facade.ts
|-- <module>.module.ts
`-- index.ts

<test-root>/<module>/
|-- <aggregate>/
|   |-- <aggregate>.service.spec.ts
|   `-- <aggregate>.controller.spec.ts
`-- <module>.architecture.spec.ts       # optional architecture verification
```

Example:

```text
orders/
|-- order/
|   |-- order.entity.ts
|   |-- order.repository.ts
|   |-- order.service.ts
|   |-- order.controller.ts
|   `-- order.dto.ts
|-- shipment/
|   `-- ...
|-- orders.facade.ts
|-- orders.module.ts
`-- index.ts
```

## Implementation Order

1. Define the module name and bounded context.
2. List aggregates and their owning module.
3. Define public contracts: handlers, facade methods, events, commands, ports,
   or clients.
4. Create model/entity and repository pairs for owned persistence.
5. Create service methods with business names.
6. Create boundary adapters and DTOs for external contracts.
7. Add error mapping, validation, and security concerns.
8. Add unit tests for service/domain rules.
9. Add integration/e2e tests for APIs, persistence, messaging, and security
   behavior.
10. Run build, typecheck, lint, tests, and architecture verification.

## Flat Module Checklist

- [ ] Module name is business-oriented.
- [ ] Each aggregate has its own cohesive unit.
- [ ] No new `controllers/`, `services/`, `repositories/`, or `dtos/`
      technical directory for domain code.
- [ ] Controllers/resolvers/handlers inject services/facades, not repositories.
- [ ] Services do not import persistence query details.
- [ ] Repositories do not expose raw persistence APIs.
- [ ] Public facade/API exposes only stable module contracts.
- [ ] Root `index.ts` exports public contracts only.
- [ ] Tests mirror the production module layout.

## Subdomain-Based Module

Use subdomains when a single module has multiple cohesive internal areas with
different ownership, execution model, scale, security, or failure boundaries.

```text
<source-root>/<module>/
|-- <subdomain-a>/
|   |-- <aggregate>/
|   |   |-- <aggregate>.entity.ts
|   |   |-- <aggregate>.repository.ts
|   |   `-- <aggregate>.service.ts
|   `-- <subdomain-a>.facade.ts
|-- <subdomain-b>/
|   |-- <aggregate>/
|   `-- <subdomain-b>.facade.ts
`-- <module>.facade.ts
```

### Subdomain Rules

- Each subdomain owns its aggregate units and repositories.
- Shared persistence code may contain configuration and infrastructure helpers,
  but not repositories for all subdomains.
- Cross-subdomain reads go through facades, query ports, events, or denormalized
  read models.
- Do not inject sibling subdomain repositories directly.
- The top-level module facade composes subdomain facades; it should not contain
  deep business logic.

## When to Split

Prefer flat unless at least four of these six criteria are true:

| Criterion | Question |
| --- | --- |
| Different users | Are different personas or client types served? |
| Different authorization | Are permissions materially different? |
| Different execution model | Synchronous vs async worker vs scheduler vs stream? |
| Different scale | Does one area need independent throughput or resources? |
| Different ownership | Could different teams own or release the areas? |
| Failure isolation | Should one area's outage not affect another? |

Additional split signals:

- The module has more than roughly 8-10 aggregates.
- One aggregate unit grows beyond roughly 15-20 production files.
- Tests require large unrelated fixture graphs.
- Business vocabulary conflicts inside one unit.
- Changes repeatedly touch unrelated parts of the module.

Do not split only because a diagram looks cleaner. Splits add contracts,
coordination, and test overhead.

## Public API Options

Use the lightest explicit boundary that fits:

| Boundary | Use when |
| --- | --- |
| Facade | Same process, stable in-process use |
| Port/interface | Implementation replaceability matters |
| Client boundary | Boundary may become remote or already is remote |
| Event | A fact happened and consumers can react asynchronously |
| Command/message | Another owner should perform work asynchronously |
| Read model | High-volume cross-boundary reads need denormalized data |

## Stack-Specific Notes

Load `flavors/node-typescript/docs/CODING-PATTERNS.md` when creating
controllers, resolvers, services, repositories, DTOs, transactions, or tests.
Load `flavors/node-typescript/docs/INTEGRATION-PATTERNS.md` when the module
uses external clients, queues, events, webhooks, or observability hooks.
