# Template Source Governance

## Purpose

Defines canonical ownership, documentation, and validation expectations for
reusable and schema-owned SpecOps templates. Ensures contributors know which
source path is authoritative for each workflow artifact type.

## Requirements

### Requirement: Canonical template ownership is documented
The overlay SHALL document which source path is canonical for each workflow
artifact type and SHALL distinguish strict schema-owned templates from
lightweight reusable templates.

ID: `REQ-001`
Priority: `P0`

Acceptance criteria:

- `REQ-001-AC-001`: Documentation MUST name
  `openspec/schemas/evidence-first/templates/` as canonical for the
  `evidence-first` schema artifact lifecycle.
- `REQ-001-AC-002`: Documentation MUST name `templates/` as lightweight or
  transitional reusable material copied to `openspec/specops/templates/`.
- `REQ-001-AC-003`: Documentation MUST preserve `--schema evidence-first` as
  the OpenSpec-native selection mechanism and MUST NOT introduce `--workflow`
  as a competing lifecycle concept.

#### Scenario: Contributor finds the canonical strict template source
- **WHEN** a contributor reads the repository workflow documentation
- **THEN** the contributor can identify the canonical source path for
  `evidence-first` proposal, spec, design, proof, task, and evaluation
  templates
- **AND** the contributor can distinguish that path from lightweight reusable
  template material

### Requirement: Contribution guidance routes workflow edits
The overlay SHALL tell contributors where to edit schema templates, reusable
templates, validation checks, skills, flavors, adoption scripts, and workflow
documentation.

ID: `REQ-002`
Priority: `P0`

Acceptance criteria:

- `REQ-002-AC-001`: README MUST include a "Where to edit" or equivalent table
  mapping common workflow changes to source paths.
- `REQ-002-AC-002`: CONTRIBUTING MUST state when to edit
  `openspec/schemas/evidence-first/templates/` versus `templates/`.
- `REQ-002-AC-003`: CONTRIBUTING MUST require an OpenSpec change before
  changing documented workflow behavior or adoption contracts.

#### Scenario: Contributor routes a template change
- **WHEN** a contributor wants to change proof, evaluation, or task behavior
- **THEN** repository guidance identifies whether the change belongs in the
  `evidence-first` schema templates, lightweight reusable templates, validation
  checks, or a future OpenSpec change

### Requirement: Validation checks template source governance
The overlay validation SHALL verify that canonical template source expectations
remain present and that duplicated workflow template surfaces are classified
intentionally.

ID: `REQ-003`
Priority: `P0`

Acceptance criteria:

- `REQ-003-AC-001`: `scripts/validate.sh` MUST verify required
  `evidence-first` schema templates exist for proposal, spec, design, proof,
  tasks, and evaluation.
- `REQ-003-AC-002`: `scripts/validate.sh` MUST verify README or CONTRIBUTING
  contains canonical source ownership guidance for schema templates and
  reusable templates.
- `REQ-003-AC-003`: Validation MUST report failures with actionable file or
  source-path evidence.

#### Scenario: Governance validation catches missing ownership guidance
- **WHEN** canonical template ownership guidance is removed from repository
  documentation
- **THEN** local validation fails with an actionable message naming the missing
  ownership guidance

### Requirement: Adoption contract remains stable
The overlay SHALL preserve existing adoption destinations while documenting
template ownership.

ID: `REQ-004`
Priority: `P1`

Acceptance criteria:

- `REQ-004-AC-001`: Generic adoption MUST continue copying `templates/` to
  `openspec/specops/templates/`.
- `REQ-004-AC-002`: Evidence-first adoption MUST continue installing
  `openspec/schemas/evidence-first/` only when `--schema evidence-first` is
  selected.
- `REQ-004-AC-003`: Changes to template ownership documentation MUST NOT
  convert `docs/project/*` into overlay-source facts while those files are
  copied directly into adopting repositories.

#### Scenario: Existing adoption paths stay valid
- **WHEN** a consuming repository runs generic adoption or evidence-first
  adoption
- **THEN** the adopted file layout remains compatible with the documented
  source-to-adoption mapping
