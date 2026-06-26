# Changelog

All notable changes to SpecOps Overlay should be recorded here.

This project follows a lightweight changelog format. Group entries by date or
release tag, and call out changes to templates, skills, OpenSpec config,
adoption scripts, validation, and documented workflow behavior.

## Unreleased

- Added an optional project-local OpenSpec schema, `evidence-first`, with
  proposal, spec, design, proof, task, and evaluation templates for stricter
  AC-to-proof traceability.
- Added `scripts/adopt.sh --schema evidence-first` so adopting repositories can
  opt into the native evidence-first schema without selecting a stack flavor.
- Extended `scripts/validate.sh` to cover evidence-first schema validation,
  template resolution, and opt-in adoption dry runs when OpenSpec is available.
- Simplified adoption output mapping: the overlay source keeps flat
  `skills/`, `templates/`, and `flavors/` directories, while `scripts/adopt.sh`
  installs them into `.agents/skills/` and `openspec/specops/` in adopting
  repositories.
- Simplified `scripts/adopt.sh` into a non-interactive bootstrapper with
  optional `--flavor` injection and `--force` backups.
- Added local and CI validation entry points for overlay self-checks.
- Added OpenSpec capability mapping, task-local proof, quality-gate,
  evaluation, and archive-readiness guidance under the
  `improve-specops-overlay` change.
