## Why

SpecOps Overlay currently ships strong evidence and gate conventions as a
parallel overlay around OpenSpec, but OpenSpec already supports custom schemas
as a native extension point. Moving the evidence-first workflow into an
OpenSpec schema makes the project closer to OpenSpec's philosophy: optional,
iterative, schema-driven, and easy to adopt without making the default workflow
heavy.

## What Changes

- Add an `evidence-first` OpenSpec schema under `openspec/schemas/` with
  templates for proposal, specs, design, proof, tasks, and evaluation.
- Keep the default overlay workflow lightweight by making `evidence-first`
  opt-in rather than mandatory for every adopting repository.
- Update adoption guidance so teams can choose the native schema when they want
  stricter AC-to-task-to-test traceability.
- Update validation to prove the schema is discoverable and its templates can
  be resolved by the OpenSpec CLI.
- Keep agent skills as accelerators for gates and evaluation, not as the only
  representation of the workflow.

## Capabilities

### New Capabilities

- `evidence-first-workflow`: Defines a native OpenSpec schema/profile for
  evidence-oriented planning, proof, task mapping, validation, and
  post-implementation evaluation.

### Modified Capabilities

- None. There are no existing canonical capability specs in `openspec/specs/`
  for this overlay source repository.

## Impact

- Affected areas:
  - `openspec/schemas/` for the new native schema and templates.
  - `scripts/adopt.sh` for optional schema installation or configuration.
  - `scripts/validate.sh` for OpenSpec schema/template validation.
  - `README.md`, `CONTRIBUTING.md`, and `docs/adoption-prompts.md` for updated
    adoption and contribution guidance.
  - Existing `templates/` and `.agents/skills/` references where they need to
    point at the schema-backed workflow.
- Stack-specific flavor guidance is not directly affected; the schema must
  remain stack-agnostic.
- Observable behavior is limited to repository workflow behavior: how the
  overlay is adopted, validated, and used to generate planning artifacts.
- Risk level: medium. The change touches workflow structure, adoption behavior,
  templates, validation, and documentation, but not runtime service code.
- Spec quality gate: not required before implementation because this change is
  documentation/template/script workflow work with no persistence, security,
  integration, messaging, async, scheduled, or webhook runtime behavior. The
  change still uses explicit ACs in specs and task-local proof.
- Out of scope:
  - Adding new commands to OpenSpec core such as `openspec quality-gate` or
    `openspec evaluate`.
  - Upstreaming the schema to OpenSpec in this same change.
  - Requiring all adopting repositories to use `evidence-first`.
  - Changing stack flavor architecture rules.
