# Architecture Verification

Use this reference for modular compliance reviews and structural checks. Adapt
commands to the repository's source layout and build tool.

## Source Discovery

Find source files (adapt patterns to the project stack):

```bash
find <source-root> -name "*.<ext>"
find <test-root> -name "*.<ext>"
```

Find top-level module directories:

```bash
find <source-root> -mindepth 2 -maxdepth 6 -type d
```

## Structural Searches

Technical directory layout in domain code:

```bash
rg -n "controller|controllers|service|services|repository|repositories|dto|dtos|entity|entities|model|models" <source-root> --type-list
```

Handler/controller files importing repositories:

```bash
rg -n "class.*Handler|class.*Controller|class.*Resource|Repository" <source-root>
```

Review hits manually. A handler file containing both `Handler`/`Controller` and
`Repository` is suspicious unless the repository appears only in comments.

Services importing persistence internals from another module:

```bash
rg -n "import.*entity|import.*repository|from.*repository|from.*model" <source-root>
```

Unbounded queries:

```bash
rg -n "listAll|findAll|find_all|\.all\(\)" <source-root>
```

Raw query strings outside repositories:

```bash
rg -n "createQuery|createNativeQuery|raw_query|execute_sql|SELECT |UPDATE |DELETE " <source-root>
```

Then inspect whether hits are inside repositories/adapters.

Possible fat handlers/controllers:

```bash
find <source-root> -name "*Resource*" -o -name "*Controller*" -o -name "*Handler*"
```

For each changed handler, check method length and business branching manually.

Facade logic:

```bash
find <source-root> -name "*Facade*"
```

Facades should mostly delegate to services or compose simple DTOs.

Shared business logic:

```bash
find <source-root> -path "*/shared/*"
rg -n "Repository|Service|Entity|Model" <source-root>/**/shared/**
```

If globstar is unavailable in the shell, use `find` and inspect manually.

## Boundary Review

For each changed file:

1. Identify its module and aggregate from the path.
2. List imports or dependencies from sibling modules.
3. Classify each dependency:
   - OK: facade, public DTO, event, command, port, client.
   - Suspicious: service from another module.
   - Violation: entity/model or repository from another module.
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

- Cross-module repository/entity imports used for writes.
- One module directly mutates another module's data store.
- Security-sensitive endpoint added without authorization or tests.
- Migration changes shared data stores without clear owner.

P1 high:

- Handler/controller contains business workflow or repository injection.
- New external integration lacks timeout/error handling.
- Public facade exposes persistence entities to other modules.
- Important endpoint lacks integration/e2e coverage.

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
- Static checks:
- Unit tests:
- Integration/e2e tests:
- Migration validation:
```

## Pre-Merge Checklist

- [ ] No handler/controller injects a repository.
- [ ] No service imports another module's repository/entity.
- [ ] No module writes another module's state directly.
- [ ] New aggregates are organized by business concept.
- [ ] Repositories hide persistence/query details.
- [ ] Public APIs/facades do not leak persistence internals.
- [ ] Shared code is stable infrastructure or primitive support.
- [ ] Important API/persistence/messaging paths have integration/e2e tests.
- [ ] Build, static checks, unit tests, and integration/e2e tests were run or
      explicitly deferred with reason.
