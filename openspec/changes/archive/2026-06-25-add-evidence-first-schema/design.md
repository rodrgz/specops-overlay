## Context

SpecOps Overlay currently distributes evidence-oriented templates and agent
skills as reusable overlay assets. That works, but it leaves the strongest
workflow outside OpenSpec's native schema mechanism.

OpenSpec `1.4.1` resolves schemas in this order:

1. project-local `openspec/schemas/<name>/schema.yaml`;
2. user-local schema overrides;
3. package built-in schemas.

This change uses that native project-local schema path so the overlay can stay
aligned with OpenSpec while preserving its evidence-first quality gates.

Relevant context:

- `README.md`: current adoption and overlay positioning.
- `AGENTS.md`: current agent contract and gate decisions.
- `openspec/config.yaml`: OpenSpec context bridge and artifact rules.
- `templates/*`: current enhanced SpecOps templates.
- `skills/spec-quality-gate/*`: pre-implementation proof workflow.
- `skills/spec-driven-eval/*`: post-implementation evaluation workflow.
- `scripts/adopt.sh`: adoption copy mapping.
- `scripts/validate.sh`: local overlay validation.
- `docs/openspec-evidence-workflow-design.md`: analysis of the upstream
  OpenSpec alignment opportunity.

No stack-specific flavor architecture skill is required because this change
does not affect application module boundaries, persistence ownership, or a
language runtime.

## Goals / Non-Goals

**Goals:**

- Add a native project-local OpenSpec schema named `evidence-first`.
- Model proof and evaluation as schema artifacts, not only as agent skills.
- Keep generic adoption lightweight unless `evidence-first` is explicitly
  selected.
- Keep the schema stack-agnostic.
- Validate schema structure and template resolution through OpenSpec when the
  CLI is available.
- Update documentation so contributors understand the lightweight and
  evidence-first paths.

**Non-Goals:**

- Add commands to OpenSpec core.
- Change OpenSpec's built-in `spec-driven` schema.
- Require every adopting repository to use `evidence-first`.
- Remove the existing `templates/` or `skills/` sources in the same change.
- Change Java/Quarkus or Node/TypeScript flavor architecture behavior.

## Decisions

### Decision: Use `openspec/schemas/evidence-first/` as schema source

Chosen approach:

- Create `openspec/schemas/evidence-first/schema.yaml`.
- Create templates under `openspec/schemas/evidence-first/templates/`.
- Keep the schema project-local so `openspec schemas`, `openspec templates`,
  `openspec instructions`, and `openspec status` can resolve it natively.

Alternatives considered:

- Keep only `openspec/specops/templates/`: lower implementation effort, but it
  keeps the workflow outside the OpenSpec schema system.
- Store schema source under top-level `schemas/`: cleaner source layout, but it
  would require extra copying before the local OpenSpec CLI can validate the
  schema in this repository.

Reason:

- Project-local schema source is the closest match to OpenSpec's existing
  extension model and gives immediate CLI validation.

### Decision: Keep adoption opt-in

Chosen approach:

- Generic adoption keeps the current lightweight OpenSpec default.
- Add an explicit adoption option for the evidence-first workflow.
- Do not require a stack flavor when evidence-first is selected.

Alternatives considered:

- Make `evidence-first` the default schema for all adoption.
- Split adoption into multiple scripts.

Reason:

- OpenSpec's default experience must remain low ceremony. Evidence-first is for
  teams or changes that need stronger traceability.

### Decision: Keep skills as accelerators, not canonical artifacts

Chosen approach:

- `proof.md` becomes the planning artifact for quality-gate output.
- `evaluation.md` becomes the post-implementation artifact for evidence and
  archive readiness.
- Existing skills continue to guide agents in producing those artifacts.

Alternatives considered:

- Move all skill guidance into schema instructions.
- Leave proof and evaluation entirely in `.agents/skills/`.

Reason:

- Artifacts are reviewable by humans and OpenSpec-aware tools. Skills remain
  useful, but the workflow contract becomes visible in the change folder.

### Decision: Validate schema capability separately from runtime checks

Chosen approach:

- `scripts/validate.sh` validates schema structure and template resolution when
  `openspec` is available.
- Existing shell, adoption dry run, traceability, path, secret, and OpenSpec
  change checks remain.
- If `openspec` is unavailable, validation reports the schema gate as
  unavailable rather than passing.

Alternatives considered:

- Make `openspec` a hard dependency of every validation run.
- Skip schema validation in local checks.

Reason:

- The overlay is not a runnable application and needs lightweight local
  validation, but schema correctness is central to this change.

### Decision: Preserve current templates during the first schema migration

Chosen approach:

- Add schema-backed templates first.
- Keep existing `templates/` source paths for current adoption behavior.
- Document any duplicated template intent.
- Defer consolidation until the schema path is validated in real use.

Alternatives considered:

- Replace `templates/` immediately.
- Generate `templates/` from the schema templates.

Reason:

- Immediate replacement would increase migration risk and obscure the primary
  goal: proving the OpenSpec-native workflow.

## Risks / Trade-offs

- [Risk] Template duplication between `templates/` and
  `openspec/schemas/evidence-first/templates/` creates drift.
  -> Mitigation: document the canonical intent and add validation checks for
  required evidence-first fields.
- [Risk] Adoption options become confusing.
  -> Mitigation: keep generic adoption as the default and document
  evidence-first as an explicit workflow choice.
- [Risk] The schema becomes too strict for normal OpenSpec users.
  -> Mitigation: keep the schema opt-in and risk-triggered.
- [Risk] OpenSpec CLI support for schemas is experimental.
  -> Mitigation: use only documented/current CLI behaviors verified locally:
  `openspec schemas`, `openspec schema validate`, `openspec templates`,
  `openspec instructions`, and `openspec status`.
- [Risk] Evaluation scores create false confidence.
  -> Mitigation: require file/line evidence and report unavailable or not-run
  validation gates separately.

## Migration Plan

1. Add `openspec/schemas/evidence-first/schema.yaml` and templates.
2. Validate the schema with OpenSpec CLI commands.
3. Update `scripts/adopt.sh` to preserve generic adoption and support explicit
   evidence-first adoption.
4. Update `scripts/validate.sh` to cover generic, flavor, and evidence-first
   adoption cases.
5. Update README, contribution guidance, and adoption prompts.
6. Run `scripts/validate.sh`.
7. Leave existing `templates/` and skills in place until the schema-backed
   workflow is proven.

Rollback:

- Remove the schema directory and adoption option.
- Keep existing templates, skills, flavors, and generic adoption behavior.

## Open Questions

- None blocking.

Resolved decisions:

- Use `--schema evidence-first` as the adoption option because it matches
  OpenSpec terminology.
- Keep this repository's default `openspec/config.yaml` schema as
  `spec-driven` while shipping `evidence-first` as an available project-local
  schema.
- Defer consolidation of legacy `templates/` with schema templates to a later
  change after the schema-backed workflow is validated.
