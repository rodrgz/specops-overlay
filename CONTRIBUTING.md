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
4. Run local validation:

   ```bash
   scripts/validate.sh
   ```

5. Update `CHANGELOG.md` for notable template, skill, adoption, or workflow
   changes.

## Quality Bar

- Map tasks and proof to ACs, sanctioned implicit risks, or engineering gates.
- Keep stack-specific source guidance in `flavors/<id>/`.
- Keep reusable agent skill source in `skills/`.
- Keep reusable artifact template source in `templates/`.
- Keep adoption output mapping in `scripts/adopt.sh`, not by moving source
  directories into generated destination paths.
- Use adopter-relative paths in all cross-references inside docs, skills,
  templates, and config (see [Path Convention](README.md#path-convention)).
- Do not commit secrets, local evidence dumps, or generated adoption outputs.
- Prefer small, focused changes with clear validation evidence.

## Licensing

The repository-level license is MIT unless a file declares a more specific
license. Skill files currently declare `CC-BY-4.0` in front matter; keep that
metadata accurate when adding or changing skills.
