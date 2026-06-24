---
name: brownfield-mapping
description: Maps an existing repository before adopting SpecOps Overlay or planning work. Use when asked to map/analyze an existing codebase, fill docs/project/* from a real repository, document current architecture, or prepare brownfield OpenSpec context.
license: CC-BY-4.0
adapted_from: tech-leads-club/agent-skills
metadata:
  version: 1.1.0
---

# Brownfield Mapping

Use this skill to turn an existing repository into reliable project context for
agents. The output is an evidence-based update to `docs/project/*`, not a new
parallel documentation tree.

## Core Rules

- Document observed facts from files, manifests, scripts, CI, and representative
  code samples.
- Do not invent desired architecture, commands, conventions, environment
  variables, or dependencies.
- Cite concrete files when a fact is non-obvious or important.
- Sample enough code to find patterns, usually 5-10 representative files per
  category.
- Keep current behavior in `openspec/specs/` only when it is externally
  observable and stable enough to specify.
- Keep proposed changes in `openspec/changes/`; do not mix desired future
  behavior into brownfield docs.

## Workflow

1. Load `AGENTS.md` and the current `docs/project/*` placeholders or facts.
2. Inspect orientation sources: `README.md`, build manifests, wrapper scripts,
   Makefile, CI files, container files, and local dev scripts.
3. Inventory repository structure with fast file search. Identify source roots,
   test roots, resource roots, generated files, migrations, scripts, and files
   agents should avoid editing.
4. Detect stack from build and runtime configuration: language version, framework
   version, dependencies, build tool, plugins, test frameworks, static analysis,
   database, migration tool, messaging/cache/search, and deployment hints.
5. Map architecture from modules, packages, and representative source files:
   API handlers, services, repositories/adapters, entities/models, data transfer
   objects, facades, ports, clients, events, scheduled jobs, and module
   boundaries.
6. Extract conventions from actual code: naming patterns, module/package layout,
   API/handler/controller responsibilities, data transfer and validation style,
   persistence patterns, error handling, logging, comments, tests, commits, and
   branches.
7. Map testing from dependencies, test source layout, test annotations or
   conventions, fixtures, profiles, containers, scripts, and CI jobs.
8. Map integrations from configuration and code: databases, external APIs,
   auth providers, queues, caches, search, observability, credentials handling,
   webhooks, background jobs, and local startup dependencies.
9. Capture constraints and risks in `docs/project/CONCERNS.md`: security,
   privacy, performance, reliability, rollout, local development, production,
   migration, CI, and operational concerns.
10. Update `AGENTS.md` template defaults only with stable, project-wide facts
    that agents must see before loading detailed docs.
11. Update `openspec/config.yaml` context to reflect the actual repository and
    application stack instead of the generic overlay core.
12. Re-read all changed project docs and `openspec/config.yaml` for
    contradictions, missing commands, and accidental aspirational language.

## Knowledge Verification Chain

Use this order when facts conflict or are incomplete:

1. Local code, manifests, scripts, tests, runtime config, and CI.
2. Existing project docs and `docs/project/*`.
3. Selected flavor docs and skills when the repository actually uses that
   stack.
4. Official framework, tool, or vendor documentation when local evidence points
   to that dependency.
5. Web search only when current external facts are required.

Mark unresolved facts as unknown with the source needed to resolve them. Do not
fabricate commands, dependencies, environment variables, or architecture
decisions.

## Output Mapping

Write or update these files:

| File | Brownfield Content |
| --- | --- |
| `docs/project/STACK.md` | Runtime, framework, build tool, dependencies, database, migration tool, test frameworks, static analysis, deployment, required local tooling |
| `docs/project/ARCHITECTURE.md` | Runtime shape, bounded contexts, module boundaries, ownership, communication paths, data flows, key architecture decisions |
| `docs/project/STRUCTURE.md` | Source/test/resource roots, directory tree, module layout, migrations, scripts, generated files, ownership, avoid-edit paths |
| `docs/project/CONVENTIONS.md` | Naming, module/package layout, APIs, data transfer objects, validation, errors, persistence, logging, review and branch conventions |
| `docs/project/TESTING.md` | Build/test/static analysis commands, test layout, test naming, fixtures, profiles, local-service requirements, CI-only checks |
| `docs/project/INTEGRATIONS.md` | Databases, external APIs, auth, messaging, cache, search, observability, credentials, local dependency startup, contracts |
| `docs/project/CONCERNS.md` | Risks, constraints, tradeoffs, operational concerns, known local issues, rollout and migration concerns |
| `openspec/config.yaml` | Context block updated to reflect the actual repository and application stack instead of referencing the generic SpecOps overlay core |

## Evidence Checklist

- Stack facts come from dependency manifests, wrappers, runtime config, or CI.
- Commands come from wrappers, README, Makefile, package scripts, CI, or build
  files.
- Architecture facts reference actual modules, packages, classes, or directory
  structures.
- Conventions reference repeated examples, not isolated files.
- Integration facts reference config keys and client/adapter/handler locations.
- Testing facts reference test dependencies, test directories, conventions,
  fixtures, profiles, or CI jobs.
- Unknowns stay explicit as unknowns with the next file or person needed to
  resolve them.

## Verification

For documentation-only mapping, run lightweight checks when available:

- Markdown or formatting checks documented by the repository.
- `git diff --check` to catch whitespace problems.
- Any repository-specific documentation validation command.

Do not run full builds or integration tests solely for brownfield mapping unless
the repository documents that those commands are needed to verify project facts.
