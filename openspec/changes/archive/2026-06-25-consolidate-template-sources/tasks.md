## 1. Documentation Ownership Map

- [x] 1.1 Add README "Where to edit" guidance for template ownership.
  Priority: P0
  Maps to: `REQ-001-AC-001`, `REQ-001-AC-002`, `REQ-001-AC-003`, `REQ-002-AC-001`
  Files: `README.md`
  Tests: documentation proof by reviewing the table and path mappings.
  Gate: docs
  Done when: README names `openspec/schemas/evidence-first/templates/` as the
  canonical strict schema template source, names `templates/` as lightweight or
  transitional reusable material, preserves `--schema evidence-first`, and maps
  common workflow edits to source paths.
  Commit: `docs(readme): map template source ownership`

- [x] 1.2 Tighten CONTRIBUTING edit-routing rules.
  Priority: P0
  Maps to: `REQ-002-AC-002`, `REQ-002-AC-003`
  Files: `CONTRIBUTING.md`
  Tests: documentation proof by checking schema-template, reusable-template,
  validation, skill, flavor, script, and OpenSpec-change routing guidance.
  Gate: docs
  Done when: CONTRIBUTING clearly states when to edit
  `openspec/schemas/evidence-first/templates/` versus `templates/` and requires
  an OpenSpec change before documented workflow behavior or adoption contracts
  change.
  Commit: `docs(contributing): route workflow edits`

- [x] 1.3 Keep adopter-facing project docs out of overlay-source facts.
  Priority: P1
  Maps to: `REQ-004-AC-003`
  Files: `README.md`, `CONTRIBUTING.md`, `docs/project/*`
  Tests: documentation proof by confirming `docs/project/*` remain
  fill-after-adoption templates and overlay-source facts live elsewhere.
  Gate: docs
  Done when: implementation does not replace `docs/project/*` placeholder
  content with overlay-source facts and documents that boundary in durable
  contributor guidance.
  Commit: `docs: preserve project docs as adopter templates`

## 2. Validation Governance

- [x] 2.1 Add validation for required evidence-first schema templates.
  Priority: P0
  Maps to: `REQ-003-AC-001`
  Files: `scripts/validate.sh`, `openspec/schemas/evidence-first/templates/*`
  Tests: `scripts/validate.sh`
  Gate: docs
  Done when: validation verifies proposal, spec, design, proof, tasks, and
  evaluation templates exist under `openspec/schemas/evidence-first/templates/`.
  Commit: `test(validate): check schema template ownership`

- [x] 2.2 Add validation for canonical ownership guidance.
  Priority: P0
  Maps to: `REQ-003-AC-002`, `REQ-003-AC-003`
  Files: `scripts/validate.sh`, `README.md`, `CONTRIBUTING.md`
  Tests: `scripts/validate.sh`; targeted negative check if practical by running
  the checker against a temporary copy with the ownership marker removed.
  Gate: docs
  Done when: validation fails with an actionable message if README or
  CONTRIBUTING no longer contains canonical schema-template and reusable-template
  ownership guidance.
  Commit: `test(validate): check template ownership docs`

- [x] 2.3 Preserve adoption-path validation.
  Priority: P1
  Maps to: `REQ-004-AC-001`, `REQ-004-AC-002`
  Files: `scripts/validate.sh`, `scripts/adopt.sh`
  Tests: `scripts/validate.sh`
  Gate: docs
  Done when: generic adoption still copies `templates/` to
  `openspec/specops/templates/`, evidence-first adoption still installs
  `openspec/schemas/evidence-first/` only when selected, and validation covers
  both paths.
  Commit: `test(validate): preserve adoption template paths`

## 3. Template Classification

- [x] 3.1 Classify reusable templates as lightweight or transitional.
  Priority: P0
  Maps to: `REQ-001-AC-002`, `REQ-003-AC-002`
  Files: `templates/*`, `README.md`, `CONTRIBUTING.md`
  Tests: documentation proof plus `scripts/validate.sh`
  Gate: docs
  Done when: reusable templates are documented as lightweight/default adoption
  material or explicitly transitional source material, without claiming
  ownership of strict `evidence-first` schema behavior.
  Commit: `docs(templates): classify reusable templates`

- [x] 3.2 Confirm schema templates remain strict lifecycle artifacts.
  Priority: P0
  Maps to: `REQ-001-AC-001`, `REQ-003-AC-001`
  Files: `openspec/schemas/evidence-first/schema.yaml`,
  `openspec/schemas/evidence-first/templates/*`
  Tests: `openspec schema validate evidence-first`; `openspec templates --schema evidence-first --json`
  Gate: OpenSpec verify
  Done when: OpenSpec resolves every `evidence-first` artifact template and the
  schema template paths remain the documented canonical strict source.
  Commit: `docs(schema): affirm evidence-first template source`

## 4. Final Verification

- [x] 4.1 Run repository validation.
  Priority: P0
  Maps to: `REQ-003-AC-001`, `REQ-003-AC-002`, `REQ-003-AC-003`,
  `REQ-004-AC-001`, `REQ-004-AC-002`, engineering gate
  Files: changed documentation, templates, and validation files
  Tests: `scripts/validate.sh`
  Gate: full
  Done when: validation passes or unavailable tooling is explicitly recorded
  separately from passing checks.
  Commit: n/a

- [x] 4.2 Run OpenSpec structural validation.
  Priority: P0
  Maps to: OpenSpec verify gate
  Files: `openspec/changes/consolidate-template-sources/*`
  Tests: `openspec validate consolidate-template-sources`
  Gate: OpenSpec verify
  Done when: the OpenSpec change validates successfully.
  Commit: n/a

- [x] 4.3 Record post-implementation evaluation if AC scoring is needed before archive.
  Priority: P1
  Maps to: evaluation gate
  Files: `openspec/changes/consolidate-template-sources/*`
  Tests: `.agents/skills/spec-driven-eval/SKILL.md` or equivalent evaluation
  report if the change is being prepared for archive.
  Gate: evaluation
  Done when: implementation evidence, test evidence, unrun gates, and remaining
  gaps are recorded before archive or merge.
  Commit: n/a

## Deferred Ideas

| Idea | Reason Deferred | Follow-up Trigger |
| --- | --- | --- |
| Generate lightweight templates from schema templates | Requires a stronger generator and format contract than this change needs | Open a follow-up when manual drift remains costly |
| Remove top-level reusable templates | Would change the adoption contract and needs a separate migration plan | Open a follow-up after canonical ownership and validation are proven |
| Add a `--workflow` alias | Could be a convenience layer, but `--schema` is the OpenSpec-native term today | Consider only after schema/source ownership is stable |
