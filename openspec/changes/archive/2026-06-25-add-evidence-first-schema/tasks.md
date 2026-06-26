## 1. Schema Source

- [x] 1.1 Add the `evidence-first` OpenSpec schema definition.
  Priority: P0
  Maps to: `REQ-001-AC-001`, `REQ-001-AC-002`, `REQ-001-AC-003`, `REQ-002-AC-001`, `REQ-002-AC-002`
  Files: `openspec/schemas/evidence-first/schema.yaml`
  Tests: `openspec schemas --json`, `openspec schema validate evidence-first`
  Gate: OpenSpec verify
  Done when: OpenSpec can discover and validate the `evidence-first` schema from the repository root.
  Commit: `feat(schema): add evidence-first workflow`

- [x] 1.2 Add schema templates for proposal, specs, design, proof, tasks, and evaluation.
  Priority: P0
  Maps to: `REQ-002-AC-001`, `REQ-002-AC-003`, `REQ-002-AC-004`
  Files: `openspec/schemas/evidence-first/templates/*.md`
  Tests: `openspec templates --schema evidence-first`
  Gate: OpenSpec verify
  Done when: OpenSpec resolves every evidence-first artifact template and the proof/evaluation templates contain the required evidence fields.
  Commit: `feat(schema): add evidence-first templates`

## 2. Adoption And Validation

- [x] 2.1 Add opt-in evidence-first adoption support.
  Priority: P0
  Maps to: `REQ-003-AC-001`, `REQ-003-AC-002`, `REQ-003-AC-003`, `REQ-003-AC-004`
  Files: `scripts/adopt.sh`, `openspec/config.yaml`
  Tests: generic adoption dry run, `--schema evidence-first` adoption dry run, flavor adoption dry runs
  Gate: full
  Done when: generic adoption keeps the lightweight default and `--schema evidence-first` installs/configures the project-local schema without requiring a stack flavor.
  Commit: `feat(adopt): support evidence-first schema`

- [x] 2.2 Extend overlay validation for the schema workflow.
  Priority: P0
  Maps to: `REQ-004-AC-001`, `REQ-004-AC-002`, `REQ-004-AC-003`, `REQ-004-AC-004`
  Files: `scripts/validate.sh`
  Tests: `scripts/validate.sh`
  Gate: full
  Done when: validation covers generic adoption, flavor adoption, evidence-first adoption, schema validation, and template resolution when OpenSpec is available.
  Commit: `test(validate): cover evidence-first schema`

## 3. Documentation

- [x] 3.1 Document lightweight versus evidence-first workflows.
  Priority: P1
  Maps to: `REQ-005-AC-001`, `REQ-005-AC-003`, `REQ-005-AC-004`
  Files: `README.md`, `docs/adoption-prompts.md`
  Tests: docs review plus `scripts/validate.sh`
  Gate: docs
  Done when: adoption docs explain when to keep the lightweight workflow and when to select `evidence-first`.
  Commit: `docs(workflow): explain evidence-first adoption`

- [x] 3.2 Update contribution guidance and changelog.
  Priority: P1
  Maps to: `REQ-005-AC-002`, engineering gate
  Files: `CONTRIBUTING.md`, `CHANGELOG.md`
  Tests: docs review plus `scripts/validate.sh`
  Gate: docs
  Done when: contributors can identify where schema source, templates, skills, flavors, and validation changes belong.
  Commit: `docs(contributing): add schema guidance`

## 4. Final Proof

- [x] 4.1 Run structural OpenSpec validation for the change.
  Priority: P0
  Maps to: OpenSpec verify gate
  Files: `openspec/changes/add-evidence-first-schema/*`
  Tests: `openspec validate add-evidence-first-schema`
  Gate: OpenSpec verify
  Done when: OpenSpec validation passes or any unavailable command is recorded with fallback rationale.
  Commit: n/a

- [x] 4.2 Run final overlay validation.
  Priority: P0
  Maps to: `REQ-001-AC-003`, `REQ-004-AC-001`, `REQ-004-AC-002`, `REQ-004-AC-003`, `REQ-004-AC-004`
  Files: `scripts/validate.sh`, `openspec/schemas/evidence-first/*`, adoption output in temporary dry-run directories
  Tests: `scripts/validate.sh`
  Gate: full
  Done when: all available overlay validation checks pass and unavailable checks are explicitly reported.
  Commit: n/a

- [x] 4.3 Evaluate implementation against the evidence-first workflow spec before archive.
  Priority: P0
  Maps to: evaluation gate
  Files: `openspec/changes/add-evidence-first-schema/*`, changed implementation and docs
  Tests: `.agents/skills/spec-driven-eval/SKILL.md` or equivalent evidence report
  Gate: evaluation
  Done when: implementation evidence, test evidence, remaining gaps, and unrun gates are recorded before sync/archive.
  Commit: n/a
