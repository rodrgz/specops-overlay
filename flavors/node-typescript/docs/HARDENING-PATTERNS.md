# Hardening Patterns

Guidance for formatting, static analysis, dependency safety, and validation
gates in Node.js and TypeScript repositories that adopt this overlay flavor.

SpecOps Overlay is not a runnable application, so do not add package scripts,
dependencies, or CI jobs here. Add concrete tooling in the adopting repository
and document the real commands in `docs/project/STACK.md` and
`docs/project/TESTING.md`.

## Default Harness

Use project-local package-manager scripts. A typical PR gate should include:

- Install with the documented package manager and lockfile.
- Typecheck.
- Lint.
- Formatting check.
- Unit tests.
- Integration/e2e tests for changed observable behavior.
- Dependency and secret scanning when the project risk justifies it.

Common command shape:

```bash
npm run typecheck
npm run lint
npm test
npm run test:e2e
```

Use the equivalent `pnpm`, `yarn`, or `bun` commands when the project uses that
package manager.

OpenSpec tasks for code changes should name the relevant build, static, unit,
integration/e2e, migration, and security gates from `docs/project/TESTING.md`.
If a gate is skipped, the implementation or evaluation summary should state
why.

## Package Manager Discipline

Rules:

- Use the repository's lockfile and documented package manager.
- Prefer `npm ci`, `pnpm install --frozen-lockfile`, `yarn install --frozen-lockfile`,
  or the project-standard frozen install in CI.
- Do not mix package managers in one change.
- Do not update lockfiles as a side effect unless dependency changes are in
  scope.
- In monorepos, use workspace-aware commands and affected-project commands when
  documented.

## TypeScript

Use `tsc --noEmit` or the project-standard equivalent as a hard gate.

Recommended compiler posture:

- `strict` enabled for new projects.
- `noImplicitAny`, `strictNullChecks`, and `noUncheckedIndexedAccess` when the
  project can support them.
- Source maps and declaration output configured intentionally for libraries.
- Path aliases documented and bounded to public module APIs.

Avoid weakening compiler settings to land a feature. If a brownfield project
cannot enable a strict option yet, document the gap and avoid expanding it.

## ESLint

Use ESLint for TypeScript, import boundaries, framework conventions, and common
bug patterns.

Recommended coverage:

- `@typescript-eslint` recommended type-checked rules where runtime is
  acceptable.
- Import ordering and unused import checks.
- Boundary rules for monorepos when the project has public module APIs.
- No floating promises.
- No unsafe `any` expansion in new code unless documented.
- No direct imports from another module's internal entity, repository, or
  service paths.

Auto-fix locally, not as a CI mutation:

```bash
npm run lint:fix
```

## Prettier

Use Prettier or the documented formatter as a formatting gate.

Rules:

- Keep formatting changes separate from behavior changes when adopting in a
  brownfield repository.
- Prefer ratcheted or changed-file checks when a full reformat would create
  noise.
- Do not debate formatting in feature changes; enforce it through the tool.

## Tests

Use Jest, Vitest, Node's built-in test runner, Playwright, Supertest, or the
project-standard tools.

Recommended split:

| Test type | Use |
| --- | --- |
| Unit | Business rules, mappers, validators, small adapters |
| Integration | DI wiring, repositories, transactions, clients with mocked edge systems |
| E2e | HTTP, GraphQL, queue, webhook, auth, and full observable workflows |
| Contract | Published APIs, events, clients, generated SDKs |

Rules:

- Keep external network calls out of default tests.
- Use Testcontainers or documented local infrastructure only when the project
  requires real dependencies.
- Make async tests deterministic with controlled clocks, fake timers, or
  explicit completion signals.
- Assert durable outcomes for queues, schedulers, and webhooks.

## Monorepos and Nx

When the project uses Nx or another task graph:

- Prefer documented affected-project commands for targeted checks.
- Use full workspace checks before merge when shared code, build config, or
  dependency graph behavior changes.
- Keep project boundaries in `project.json`, `package.json`, or workspace
  config aligned with the architecture docs.
- Do not add implicit dependency edges through deep imports.

Example command shapes:

```bash
npx nx affected --target=lint
npx nx affected --target=test
npx nx affected --target=build
```

## Stronger Harness Tools

Add these when project risk justifies the extra runtime and maintenance:

| Tool | Use | Gate |
| --- | --- | --- |
| npm audit, pnpm audit, OSV-Scanner, Trivy, or Snyk | Vulnerable dependency detection | Scheduled and release gate |
| Gitleaks or TruffleHog | Secret detection | PR gate |
| dependency-cruiser, Nx module boundaries, or ESLint import rules | Architecture boundaries | PR gate |
| Knip or ts-prune | Unused exports and dead code | Scheduled or changed-file gate |
| Playwright or Cypress | Browser or API e2e flows | PR or release gate |
| Pact or schema checks | Contract compatibility | Release gate |
| Semgrep | Security and framework anti-patterns | PR or scheduled gate |

## Adoption Checklist

- Document Node, package manager, and lockfile expectations in
  `docs/project/STACK.md`.
- Document exact build, typecheck, lint, format, unit, integration/e2e, and
  migration commands in `docs/project/TESTING.md`.
- Add or confirm package scripts for the documented gates.
- Run formatter adoption in a dedicated change or use ratcheting for brownfield
  repositories.
- Add boundary checks when the project has modules with public APIs.
- Publish machine-readable reports or CI annotations where the project expects
  them.
- Add OpenSpec task validation steps for hardening changes.
