# Module Scaffolding

Use this reference when creating modules, aggregates, or subdomain-based
structures in modular services.

## Part 1: Flat Module

Use flat-by-aggregate as the default. It is appropriate when a module has a
cohesive business vocabulary and the aggregates are owned by the same team or
deployment unit.

```text
<source-root>/<module>/
|-- <aggregate>/
|   |-- <Aggregate>Entity or Model
|   |-- <Aggregate>Repository or Adapter
|   |-- <Aggregate>Service
|   |-- <Aggregate>Handler or Controller
|   |-- <Aggregate>Request or Input
|   |-- <Aggregate>Response or Output
|   `-- <Aggregate>Mapper               # optional
|-- <Module>Facade                      # public in-process API, if needed
|-- <Module>ErrorMapper                 # optional error/exception mapping
`-- module metadata

<test-root>/<module>/
|-- <aggregate>/
|   |-- <Aggregate>ServiceTest
|   `-- <Aggregate>HandlerTest
`-- <Module>ArchitectureTest            # optional architecture verification
```

Example:

```text
orders/
|-- order/
|   |-- OrderEntity
|   |-- OrderRepository
|   |-- OrderService
|   |-- OrderHandler
|   |-- CreateOrderRequest
|   `-- OrderResponse
|-- shipment/
|   `-- ...
`-- OrdersFacade
```

### Implementation Order

1. Define the module name and bounded context.
2. List aggregates and their owning module.
3. Define public contracts: handler endpoints, facade methods, events, or
   ports.
4. Create entity/model and repository pairs for owned persistence.
5. Create service methods with business names.
6. Create handlers/controllers and data transfer objects for external contracts.
7. Add error mapping, validation, and security concerns.
8. Add unit tests for service/domain rules.
9. Add integration/e2e tests for APIs, persistence, messaging, and security
   behavior.
10. Run build, static checks, tests, and architecture verification.

### Flat Module Checklist

- [ ] Module name is business-oriented.
- [ ] Each aggregate has its own cohesive unit.
- [ ] No new `controller/`, `service/`, `repository/`, or `dto/` technical
      directory for domain code.
- [ ] Handlers/controllers inject services/facades, not repositories.
- [ ] Services do not import persistence query details.
- [ ] Repositories do not expose raw persistence APIs.
- [ ] Public facade/API exposes only stable module contracts.
- [ ] Tests mirror the production module layout.

## Part 2: Subdomain-Based Module

Use subdomains when a single module has multiple cohesive internal areas with
different ownership, execution model, scale, security, or failure boundaries.

```text
<source-root>/<module>/
|-- <subdomain-a>/
|   |-- <aggregate>/
|   |   |-- <Aggregate>Entity or Model
|   |   |-- <Aggregate>Repository
|   |   |-- <Aggregate>Service
|   |   `-- ...
|   `-- <SubdomainA>Facade
|-- <subdomain-b>/
|   |-- <aggregate>/
|   `-- <SubdomainB>Facade
`-- <Module>Facade
```

Example:

```text
operations/
|-- planning/
|   |-- schedule/
|   `-- PlanningFacade
|-- fulfillment/
|   |-- route/
|   `-- FulfillmentFacade
`-- OperationsFacade
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

## Part 3: When to Split

Prefer flat unless at least four of these six criteria are true:

| Criterion | Question |
| --- | --- |
| Different users | Are different personas or client types served? |
| Different authorization | Are permissions materially different? |
| Different execution model | Synchronous vs async worker vs scheduler vs stream? |
| Different scale | Does one area need independent throughput or resources? |
| Different ownership | Could different teams own/release the areas? |
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
| Facade | Same deployment/process, stable in-process use |
| Port/interface | Implementation replaceability matters |
| Client boundary | Boundary may become remote or already is remote |
| Event | A fact happened and consumers can react asynchronously |
| Command/message | Another owner should perform work asynchronously |
| Read model | High-volume cross-boundary reads need denormalized data |

## Stack-Specific Notes

Stack-specific scaffolding guidance (e.g., dependency injection scopes,
framework-specific handler conventions, persistence library patterns) belongs
in the applicable flavor. Load the flavor's coding patterns document when
creating modules in a specific stack.
