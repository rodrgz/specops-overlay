# Subdomain Persistence

Use this reference when a module is split into subdomains and each subdomain
needs clear persistence ownership.

## Goal

Persistence ownership should match business ownership. A subdomain owns the
tables/collections, repositories, migrations, and write paths for its
aggregates.

## Anti-Pattern: Shared Persistence Hub

Avoid a central persistence directory that registers or exposes every repository
for every subdomain:

```text
operations/shared/persistence/
|-- ScheduleRepository
|-- RouteRepository
|-- AssignmentRepository
`-- CapacityRepository
```

This hides ownership and makes cross-subdomain database access too easy.

## Preferred Structure

```text
<source-root>/<module>/
|-- planning/
|   |-- schedule/
|   |   |-- ScheduleEntity
|   |   |-- ScheduleRepository
|   |   `-- ScheduleService
|   `-- PlanningFacade
|-- fulfillment/
|   |-- route/
|   |   |-- RouteEntity
|   |   |-- RouteRepository
|   |   `-- RouteService
|   `-- FulfillmentFacade
`-- OperationsFacade
```

Allowed shared persistence code:

- Datasource configuration.
- Migration infrastructure.
- Base repository helpers.
- Common converters.
- Test container or dev-service setup.

Not allowed in shared persistence:

- Repositories for multiple business subdomains.
- Business queries crossing ownership boundaries.
- Write methods for another subdomain's data stores.

## Ownership Rules

1. Entities/models live under the owning subdomain/aggregate directory.
2. Repositories live beside the entity or in the owning aggregate directory.
3. Services call their own repositories directly.
4. Sibling subdomain data is accessed through a facade, port, event-carried
   state, read model, or explicit query API.
5. Migrations should make ownership obvious through table/collection names,
   file names, or module documentation.

## Cross-Subdomain Read Options

Use the least coupled option that fits the need:

| Option | Use when |
| --- | --- |
| Facade call | Same process, low volume, strongly consistent enough |
| Query port | Caller should depend on an abstraction |
| Event-carried state | Consumer can use facts from past events |
| Read model | High-volume reads need denormalized local data |
| Client boundary | Subdomain may move out of process |

Example facade (pseudocode):

```
class PlanningFacade:
    scheduleService: ScheduleService

    function findPublishedSchedule(scheduleId):
        return scheduleService.findPublishedSummary(scheduleId)
```

Consumer (pseudocode):

```
class RouteService:
    planningFacade: PlanningFacade

    function describe(scheduleId):
        schedule = planningFacade.findPublishedSchedule(scheduleId)
        if schedule is empty:
            throw NotFound("schedule_not_found")
        return RouteResponse.from(schedule)
```

Avoid:

```
class RouteService:
    scheduleRepository: ScheduleRepository  // sibling internals - violation
```

## Cross-Subdomain Writes

Direct writes to a sibling subdomain's data stores are not allowed.

Use one of these:

- Call the owning facade/service command.
- Publish a command message handled by the owning subdomain.
- Emit an event and let the owning subdomain react.
- Use a saga/process manager when multiple owners must coordinate.

## Event-Carried State

Prefer event payloads that reduce immediate cross-boundary reads (pseudocode):

```
record SchedulePublishedEvent:
    eventId: UUID
    scheduleId: UUID
    routeCount: Int
    publishedAt: Timestamp
    schemaVersion: Int
```

Consumers can update their own read model without querying the planning
subdomain on every request.

## Migration Guidance

- Keep migrations reviewable by ownership. File names or comments should make
  the owning module/subdomain clear when the project uses one migration stream.
- Do not alter another subdomain's data store from a feature owned elsewhere
  without an explicit boundary decision.
- Add indexes for new repository query paths in the same change.
- Include migration validation in the verification plan.

## Review Checklist

- [ ] Each repository is under the owning subdomain/aggregate.
- [ ] Shared persistence contains infrastructure only.
- [ ] No sibling repository injection.
- [ ] Cross-subdomain reads use facade, port, event-carried state, read model,
      or client boundary.
- [ ] Cross-subdomain writes go through the owning subdomain.
- [ ] New queries have supporting indexes when needed.
- [ ] Integration/e2e tests cover important cross-boundary behavior.
