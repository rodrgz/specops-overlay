## Context

The overlay currently exposes two template surfaces:

- `openspec/schemas/evidence-first/templates/` for the optional strict
  OpenSpec schema.
- `templates/` for reusable templates installed into adopting repositories
  under `openspec/specops/templates/`.

Both surfaces contain overlapping concepts for proposal, spec, design, tasks,
proof, and evaluation. That overlap is intentional during transition, but the
repository does not yet state which source owns which artifact contract. The
result is maintenance ambiguity: contributors can update proof, evaluation, or
task guidance in one place while the other surface silently drifts.

This is a core overlay workflow change. It does not affect stack flavors,
runtime application behavior, persistence, external integrations, or adoption
destinations.

## Goals / Non-Goals

**Goals:**

- Define canonical template ownership for strict `evidence-first` artifacts.
- Preserve lightweight/default adoption behavior for repositories that do not
  select `evidence-first`.
- Make README and CONTRIBUTING tell contributors where to edit each workflow
  artifact source.
- Extend validation so drift between canonical and transitional template
  surfaces is reported intentionally.
- Keep the implementation OpenSpec-native by using schema terminology and the
  existing `--schema evidence-first` selection path.

**Non-Goals:**

- Removing top-level `templates/`.
- Moving adopter-facing destination paths.
- Adding or requiring a `--workflow` CLI flag.
- Changing OpenSpec upstream commands or built-in schemas.
- Replacing `docs/project/*` adopter templates with overlay-source facts.
- Introducing stack-specific flavor behavior.

## Decisions

### Decision: Schema templates own strict evidence-first artifacts

For `evidence-first`, the canonical lifecycle source is
`openspec/schemas/evidence-first/schema.yaml` plus
`openspec/schemas/evidence-first/templates/`.

Rationale: OpenSpec schemas already define artifact order, requirements, and
template resolution. Making the schema path canonical keeps the overlay aligned
with OpenSpec instead of inventing a parallel workflow abstraction.

Alternative considered: make top-level `templates/` canonical and copy or
mirror content into the schema. That preserves legacy paths, but it makes the
OpenSpec schema a secondary output even though OpenSpec is the lifecycle owner.

### Decision: Top-level templates remain lightweight/adopter reusable material

The `templates/` directory remains the source copied to
`openspec/specops/templates/` during generic adoption. Its role is lightweight
workflow guidance and transitional reusable material, not ownership of strict
`evidence-first` schema behavior.

Rationale: generic adoption currently installs those templates, and removing
or moving them would change the adoption contract. That should be a later
OpenSpec change if still desired.

Alternative considered: remove duplicated top-level templates now. That would
reduce drift but create a larger migration and make this planning change carry
adoption compatibility risk.

### Decision: Documentation must include a "where to edit" map

README should name canonical and adopted paths. CONTRIBUTING should explain
which path to edit for schema-owned artifacts, reusable templates, skills,
flavors, adoption scripts, and validation.

Rationale: contributors need a short routing rule before editing workflow
behavior. The map also gives validation a documented target.

Alternative considered: leave the guidance in backlog only. Backlog guidance is
not durable enough because contributors normally read README and CONTRIBUTING.

### Decision: Validation reports drift, not automatic synchronization

Validation should check that canonical expectations are present and that known
duplicate surfaces are intentionally classified. It should not silently copy or
rewrite templates.

Rationale: the repository does not yet have a generator. A read-only checker is
lower risk and keeps manual edits visible in review.

Alternative considered: generate lightweight templates from schema templates.
That may be useful later, but it requires a stronger format contract than this
change needs.

## Risks / Trade-offs

- Template duplication remains after this change -> Mitigation: document
  ownership and add validation that makes drift visible.
- Validation can become too brittle if it compares full markdown files ->
  Mitigation: check structural markers and ownership declarations first; defer
  full generation or byte-level comparison.
- Contributors may still treat `docs/project/*` as overlay-source docs ->
  Mitigation: explicitly document those files as adopter templates and keep
  overlay-source facts in README, CONTRIBUTING, design docs, or a future
  source-only docs path.
- Strict and lightweight templates can intentionally differ -> Mitigation:
  require documentation to classify differences as schema-owned, lightweight,
  or transitional.

## Migration Plan

1. Update README with a "Where to edit" table that names canonical source paths
   and adopted destination paths.
2. Update CONTRIBUTING with edit-routing rules for schema templates, reusable
   templates, validation, skills, flavors, and adoption scripts.
3. Add validation checks for canonical ownership markers and expected
   `evidence-first` schema templates.
4. Run `scripts/validate.sh`.
5. Run `openspec validate consolidate-template-sources`.

Rollback is straightforward: revert documentation and validation changes. No
adopted destination paths or runtime behavior are changed by this proposal.

## Open Questions

- None blocking. A future change can decide whether to generate lightweight
  templates from schema templates or remove the transitional reusable template
  surface.
