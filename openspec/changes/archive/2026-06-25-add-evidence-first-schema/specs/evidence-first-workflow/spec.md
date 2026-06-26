## ADDED Requirements

### Requirement: Evidence-first schema is available
The overlay SHALL provide a project-local OpenSpec schema named
`evidence-first` that is discoverable by the OpenSpec CLI from
`openspec/schemas/evidence-first/schema.yaml`.

ID: `REQ-001`
Priority: `P0`

Acceptance criteria:

- `REQ-001-AC-001`: The schema file MUST exist at
  `openspec/schemas/evidence-first/schema.yaml`.
- `REQ-001-AC-002`: `openspec schemas --json` MUST report
  `evidence-first` as a project-local schema.
- `REQ-001-AC-003`: `openspec schema validate evidence-first` MUST pass.

#### Scenario: Schema discovery
- **WHEN** a contributor runs `openspec schemas --json` from the repository root
- **THEN** the output includes a schema named `evidence-first`
- **AND** the schema resolves from the project-local `openspec/schemas/`
  directory

### Requirement: Evidence-first schema defines proof artifacts
The `evidence-first` schema SHALL preserve the OpenSpec proposal, specs,
design, tasks, apply, and archive lifecycle while adding explicit proof and
evaluation artifacts for evidence-oriented changes.

ID: `REQ-002`
Priority: `P0`

Acceptance criteria:

- `REQ-002-AC-001`: The schema MUST define proposal, specs, design, proof,
  tasks, and evaluation artifacts.
- `REQ-002-AC-002`: The schema MUST require tasks before apply.
- `REQ-002-AC-003`: The proof artifact MUST capture AC interpretation, scope
  decisions, planned implementation proof, planned test proof, and gate result.
- `REQ-002-AC-004`: The evaluation artifact MUST capture implementation
  evidence, test evidence, validation gates, unresolved gaps, and archive
  readiness.

#### Scenario: Artifact order
- **WHEN** a contributor creates a change using the `evidence-first` schema
- **THEN** OpenSpec reports proposal as the first ready artifact
- **AND** tasks remain blocked until required planning and proof artifacts are
  present
- **AND** apply remains blocked until tasks are complete

### Requirement: Evidence-first adoption is opt-in
The overlay SHALL allow adopting repositories to keep the existing lightweight
OpenSpec workflow unless they explicitly select the `evidence-first` schema.

ID: `REQ-003`
Priority: `P0`

Acceptance criteria:

- `REQ-003-AC-001`: Generic adoption MUST continue to work without changing the
  default schema to `evidence-first`.
- `REQ-003-AC-002`: Adoption guidance MUST document how to select the
  `evidence-first` schema.
- `REQ-003-AC-003`: Selecting `evidence-first` MUST NOT require a stack flavor.
- `REQ-003-AC-004`: Existing Java/Quarkus and Node/TypeScript flavor adoption
  MUST remain compatible with generic adoption.

#### Scenario: Generic adoption remains lightweight
- **WHEN** a repository runs `scripts/adopt.sh` without selecting
  `evidence-first`
- **THEN** the adopted OpenSpec configuration keeps the lightweight default
  workflow
- **AND** the repository still receives SpecOps templates, skills, and flavor
  assets as before

#### Scenario: Evidence-first adoption is selected
- **WHEN** a repository selects the `evidence-first` workflow during adoption
- **THEN** the adopted repository receives the project-local schema
- **AND** OpenSpec commands can resolve evidence-first templates in that
  repository

### Requirement: Validation proves schema integrity
The overlay validation SHALL verify that the `evidence-first` schema and
adoption paths are structurally valid before changes are merged.

ID: `REQ-004`
Priority: `P0`

Acceptance criteria:

- `REQ-004-AC-001`: `scripts/validate.sh` MUST validate the `evidence-first`
  schema when the OpenSpec CLI is available.
- `REQ-004-AC-002`: `scripts/validate.sh` MUST verify that OpenSpec can resolve
  `evidence-first` templates.
- `REQ-004-AC-003`: Adoption dry runs MUST prove generic adoption still works.
- `REQ-004-AC-004`: Adoption dry runs MUST prove evidence-first adoption works
  when selected.

#### Scenario: Overlay validation includes schema checks
- **WHEN** a contributor runs `scripts/validate.sh`
- **THEN** the script validates required overlay paths
- **AND** the script validates the `evidence-first` schema when OpenSpec is
  available
- **AND** the script reports unavailable OpenSpec tooling as unavailable rather
  than as a passing schema check

### Requirement: Documentation explains the OpenSpec-aligned workflow
The overlay documentation SHALL explain that `evidence-first` is an optional
OpenSpec schema for teams that need stronger proof, not a replacement for the
default OpenSpec workflow.

ID: `REQ-005`
Priority: `P1`

Acceptance criteria:

- `REQ-005-AC-001`: README guidance MUST describe when to use the lightweight
  workflow and when to use `evidence-first`.
- `REQ-005-AC-002`: Contribution guidance MUST describe where schema source,
  templates, skills, and flavor assets belong.
- `REQ-005-AC-003`: Adoption prompts MUST tell agents to choose
  `evidence-first` only when the repository needs stricter AC-to-proof
  traceability.
- `REQ-005-AC-004`: Documentation MUST state that upstream OpenSpec CLI command
  changes are out of scope for this overlay change.

#### Scenario: Contributor chooses the appropriate workflow
- **WHEN** a contributor reads the adoption documentation
- **THEN** the contributor can distinguish lightweight OpenSpec adoption from
  evidence-first adoption
- **AND** the contributor can identify which workflow to use for low-risk and
  high-risk changes
