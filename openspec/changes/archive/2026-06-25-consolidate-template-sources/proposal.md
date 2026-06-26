## Why

SpecOps Overlay now has both reusable lightweight templates and
`evidence-first` schema-owned templates. Contributors need one documented rule
for which source path is canonical for each artifact type, otherwise proof,
evaluation, and task guidance can drift across parallel template systems.

This change makes template ownership explicit while preserving OpenSpec's
schema-first model: `evidence-first` schema templates own the strict lifecycle,
and top-level reusable templates remain only for lightweight/default adoption
or explicitly documented transition material.

## What Changes

- Document canonical ownership for proposal, spec, design, proof, task, and
  evaluation templates.
- Clarify when contributors edit `openspec/schemas/evidence-first/templates/`
  versus `templates/`.
- Add validation that checks canonical template expectations and reports drift
  intentionally.
- Update README and CONTRIBUTING with the source-to-adoption and "where to
  edit" guidance needed for future workflow changes.
- Keep `--schema evidence-first` as the OpenSpec-native selection mechanism;
  do not introduce a competing workflow lifecycle flag in this change.

## Capabilities

### New Capabilities

- `template-source-governance`: Defines canonical ownership, documentation, and
  validation expectations for reusable and schema-owned SpecOps templates.

### Modified Capabilities

- None.

## Impact

- Relevant project context: `docs/project/STRUCTURE.md`,
  `docs/project/CONVENTIONS.md`, `docs/project/TESTING.md`, and
  `docs/project/CONCERNS.md`; these files are adopter-facing templates today,
  so implementation should verify local source facts from README,
  CONTRIBUTING, scripts, templates, and schema files instead of treating
  `docs/project/*` as filled overlay-source documentation.
- Affected files are expected to include README, CONTRIBUTING,
  `scripts/validate.sh`, `templates/`, and
  `openspec/schemas/evidence-first/templates/`.
- Stack-specific flavor guidance is not relevant; this is core overlay
  workflow behavior.
- Observable repository behavior changes because validation and documented
  contribution rules will define canonical template ownership.
- Risk level: medium. The change touches workflow documentation and validation
  but no runtime application code, persistence, external integrations,
  security, config, async behavior, or webhooks.
- Quality gate: `.agents/skills/spec-quality-gate/SKILL.md` is not required
  before implementation because the change has clear OpenSpec acceptance
  criteria and no risky runtime surface. Use task-local proof plus
  `scripts/validate.sh`, `openspec validate consolidate-template-sources`, and
  post-implementation evaluation if acceptance criteria are scored before
  archive.
- Out of scope: removing top-level templates, changing OpenSpec upstream,
  adding a `--workflow` flag, changing adoption destinations, or converting
  `docs/project/*` into overlay-source facts.
