# Testing

Template note: fill this file in the repository that adopts SpecOps Overlay.
Until then, the fields below are placeholders, not project facts.

Use this file to document how the adopting repository validates changes.

## Fill After Adoption

- Build command:
- Unit test command:
- Integration test command:
- End-to-end test command:
- Static analysis command:
- Formatting command:
- Migration validation command:
- Commands that require local services:
- CI-only checks:
- Local services required for integration/e2e tests:
- Test data reset or isolation command:
- Known checks that cannot run locally:

## Expected Test Levels

Fill these with the adopting repository's conventions:

- Service/domain business rules:
- HTTP contracts:
- Persistence and transaction behavior:
- Messaging, jobs, and event consumers:
- Security and authorization:
- Configuration/startup behavior:
- External integrations and REST clients:
- Async or webhook outcomes:
- Migration validation and rollback/repair checks:

## OpenSpec Use

OpenSpec tasks for code changes should include the relevant checks from this
file. When acceptance criteria exist, tasks should map ACs to unit,
integration/e2e, and real-outcome proof. If a check cannot be run locally,
record the reason in the implementation summary or spec-driven evaluation.

## OpenSpec Validation Tiers

Use these gate names in `openspec/changes/<change-id>/tasks.md`:

| Gate | Use When | Proof To Record |
| --- | --- | --- |
| `quick` | Small local edits or planning checks | Targeted command, reviewed file, or search result. |
| `full` | Multi-file behavior or high-risk planning | All relevant commands from this file. |
| `build` | Runtime code, generated artifacts, packaging, or compiled docs | Documented build command result. |
| `docs` | Markdown, templates, examples, or guidance | Markdown/link/reference check or structural review. |
| `security` | Secrets, auth, privacy, dependency, or config-sensitive changes | Secret scan, security review, or documented operational proof. |
| `OpenSpec verify` | Proposal, spec, design, task, sync, or archive changes | `/opsx:verify` when available, otherwise equivalent structural review. |
| `evaluation` | Post-implementation AC scoring | `skills/spec-driven-eval/SKILL.md` report when applicable. |
