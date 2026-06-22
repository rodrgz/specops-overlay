# Architecture Verification

Use this reference for modular compliance reviews and structural checks. Adapt
commands to the repository's source layout and package manager.

## Source Discovery

Find TypeScript source files:

```bash
find <source-root> -name "*.ts" -not -path "*/node_modules/*" -not -path "*/dist/*"
```

Find top-level module directories:

```bash
find <source-root> -mindepth 1 -maxdepth 3 -type d
```

## Structural Searches

Technical directory layout in domain code:

```bash
rg -n "/(controllers|services|repositories|dtos|entities|models|schemas)/" <source-root>
```

Controllers/resolvers/handlers importing repositories:

```bash
rg -n "Repository|\\.repository|from .*/repository" <source-root> -g "*.{controller,resolver,handler,processor}.ts"
```

Services importing persistence internals from another module:

```bash
rg -n "from ['\\\"].*(entity|model|schema|repository)['\\\"]|from ['\\\"].*\\.(entity|model|schema|repository)['\\\"]" <source-root>
```

Raw persistence calls outside repositories/adapters:

```bash
rg -n "createQueryBuilder|queryRaw|\\$queryRaw|SELECT |UPDATE |DELETE |INSERT " <source-root>
```

Then inspect whether hits are inside repositories/adapters or migrations.

Unbounded request-path queries:

```bash
rg -n "findAll|listAll|findMany\\(|find\\(\\)|toArray\\(\\)" <source-root>
```

Possible fat boundary adapters:

```bash
find <source-root> -name "*.controller.ts" -o -name "*.resolver.ts" -o -name "*.handler.ts" -o -name "*.processor.ts"
```

For each changed adapter, check method length and business branching manually.

Facade logic:

```bash
find <source-root> -name "*.facade.ts"
```

Facades should mostly delegate to services or compose simple DTOs.

Shared business logic:

```bash
find <source-root> -path "*/shared/*" -type f -name "*.ts"
rg -n "Repository|Service|Entity|Model|Schema" <source-root>
```

Inspect whether shared code is stable infrastructure or mutable business
workflow.

## Boundary Review

For each changed file:

1. Identify its module and aggregate from the path.
2. List imports or dependencies from sibling modules.
3. Classify each dependency:
   - OK: facade, public DTO/contract, event, command, port, client.
   - Suspicious: service from another module.
   - Violation: entity/model/schema or repository from another module.
4. Check whether the changed code writes state owned by another module.
5. Check whether a new shared abstraction has a stable, low-level reason to
   exist.

## Scoring

Use this scoring for architecture assessments:

| Score | Meaning |
| --- | --- |
| 5 | Clear modular boundary, tests verify important behavior |
| 4 | Good structure with minor naming or documentation issues |
| 3 | Mostly workable but has coupling that should be addressed |
| 2 | Boundary violations or shared-state pressure |
| 1 | Module ownership unclear; high regression risk |
| 0 | Direct cross-module persistence or severe structural break |

Report scores by principle:

- P1 Boundaries
- P2 Composability
- P3 Independence
- P4 Scale
- P5 Explicit communication
- P6 Replaceability
- P7 Deployment awareness
- P8 State isolation
- P9 Observability
- P10 Failure isolation
- P11-P19 Structural rules

## Severity Guidance

P0 critical:

- Cross-module repository/entity/model/schema imports used for writes.
- One module directly mutates another module's data store.
- Security-sensitive endpoint added without authorization or tests.
- Migration changes shared data stores without clear owner.

P1 high:

- Controller/resolver/handler contains business workflow or repository
  injection.
- New external integration lacks timeout/error handling.
- Public facade exposes persistence entities to other modules.
- Important endpoint, resolver, queue consumer, or webhook lacks integration/e2e
  coverage.

P2 medium:

- Technical directory layout used for new domain code.
- Facade contains non-trivial business branching.
- Service imports persistence query APIs directly.
- Shared package gains business logic.

P3 low:

- Naming drift from aggregate convention.
- Missing module documentation for a new boundary.
- Test directory does not mirror production convention.

## Verification Report Template

```markdown
## Architecture Verification

Scope: <files/modules reviewed>

### Summary
- Overall score: <0-5>
- Highest risk: <short statement>
- Commands run: <commands or "manual only">

### Findings
1. <Severity> <Title>
   - Evidence: <file:line>
   - Principle: <P#>
   - Impact: <why it matters>
   - Recommendation: <specific fix>

### Principle Scores
| Principle | Score | Notes |
| --- | --- | --- |
| P1 Boundaries |  |  |
| P8 State isolation |  |  |
| P11-P19 Structure |  |  |

### Test and Gate Coverage
- Build:
- Typecheck:
- Static checks:
- Unit tests:
- Integration/e2e tests:
- Migration validation:
```

## Pre-Merge Checklist

- [ ] No controller/resolver/handler injects a repository.
- [ ] No service imports another module's repository/entity/model/schema.
- [ ] No module writes another module's state directly.
- [ ] New aggregates are organized by business concept.
- [ ] Repositories hide persistence/query details.
- [ ] Public APIs/facades do not leak persistence internals.
- [ ] Root indexes export stable public APIs only.
- [ ] Shared code is stable infrastructure or primitive support.
- [ ] Important API/persistence/messaging paths have integration/e2e tests.
- [ ] Build, typecheck, static checks, unit tests, and integration/e2e tests
      were run or explicitly deferred with reason.
