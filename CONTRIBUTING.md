# Contributing

SpecOps Overlay changes should preserve OpenSpec ownership and keep the core
stack-agnostic.

## Workflow

1. Use an OpenSpec change under `openspec/changes/<change-id>/` only when the
   work changes the overlay's documented workflow or behavior enough to need
   proposal/spec traceability. Routine maintenance may use a direct diff.
2. When an OpenSpec change is used, update matching delta specs under
   `openspec/changes/<change-id>/specs/<capability>/spec.md`.
3. Keep generated tool files such as `.claude/` and
   `.github/prompts/opsx-*` out of overlay source.
4. For native OpenSpec workflow changes, keep project-local schema source under
   `openspec/schemas/<name>/`. Use `openspec/schemas/evidence-first/` for the
   optional evidence-first schema and keep its schema-owned templates under
   `openspec/schemas/evidence-first/templates/`.
5. Run local validation:

   ```bash
   scripts/validate.sh
   ```

6. Update `CHANGELOG.md` for notable template, skill, adoption, schema, or workflow
   changes.

## Quality Bar

- Map tasks and proof to ACs, sanctioned implicit risks, or engineering gates.
- Keep stack-specific source guidance in `flavors/<id>/`.
- Keep reusable agent skill source in `skills/`.
- Keep native OpenSpec schema definitions in `openspec/schemas/<name>/`.
- Keep adoption output mapping in `scripts/adopt.sh`, not by moving source
  directories into generated destination paths.
- Keep `evidence-first` opt-in. Generic adoption must continue to use the
  lightweight default unless `--schema evidence-first` is selected.
- Use adopter-relative paths in all cross-references inside docs, skills,
  templates, and config (see [Applied Project Map](README.md#applied-project-map)).
- Do not commit secrets, local evidence dumps, or generated adoption outputs.
- Prefer small, focused changes with clear validation evidence.

## Edit Routing

Use the [Where to Edit](README.md#where-to-edit) table in README to identify
the canonical source path for any workflow change.

**Schema templates** (`openspec/schemas/evidence-first/templates/`): Edit these
when changing the strict `evidence-first` artifact lifecycle — proposal, spec,
design, proof, tasks, or evaluation behavior that OpenSpec resolves through the
schema. These are the canonical source for `evidence-first` artifacts.

**Reusable templates** (`templates/`): Edit these when changing lightweight
default adoption material copied to `openspec/specops/templates/`. These
templates provide guidance for repositories that do not select
`evidence-first`. They do not own strict schema behavior.

**Both surfaces overlap** for some artifact types (e.g. evaluation, proposal).
When editing overlapping content, decide which surface is canonical for the
behavior you are changing and document the classification.

| Edit target | When to use |
| --- | --- |
| `openspec/schemas/evidence-first/templates/` | Strict schema-owned artifact behavior |
| `templates/` | Lightweight or transitional reusable adoption material |
| `scripts/validate.sh` | Validation checks for ownership, adoption, or structure |
| `skills/<name>/SKILL.md` | Agent skill workflows and quality gates |
| `flavors/<id>/` | Stack-specific guidance and skills |
| `scripts/adopt.sh` | Adoption script, source-to-destination mapping |
| `openspec/config.yaml` | OpenSpec context rules and project settings |
| `docs/project/*` | Adopter-facing project-reference templates (not overlay-source facts) |

**Require an OpenSpec change** before modifying documented workflow behavior or
adoption contracts. Routine maintenance, typo fixes, and non-behavioral docs
edits may use a direct diff.

## Licensing

The repository-level license is MIT unless a file declares a more specific
license. Skill files currently declare `CC-BY-4.0` in front matter; keep that
metadata accurate when adding or changing skills.
