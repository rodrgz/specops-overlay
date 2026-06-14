# Contributing

SpecOps Overlay changes should preserve OpenSpec ownership and keep the core
stack-agnostic.

## Workflow

1. Create or update an OpenSpec change under `openspec/changes/<change-id>/`
   for user-visible workflow, template, skill, or documentation behavior.
2. Update matching delta specs under
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
- Keep stack-specific guidance in `flavors/<id>/`.
- Keep reusable workflow behavior in `skills/` and `templates/`.
- Do not commit secrets, local evidence dumps, or generated adoption outputs.
- Prefer small, focused changes with clear validation evidence.

## Licensing

The repository-level license is MIT unless a file declares a more specific
license. Skill files currently declare `CC-BY-4.0` in front matter; keep that
metadata accurate when adding or changing skills.
