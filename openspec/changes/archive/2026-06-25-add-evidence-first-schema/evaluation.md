# Spec-Driven Evaluation: add-evidence-first-schema

## 1. Metadata

| Field | Value |
| --- | --- |
| Requirement source | `openspec/changes/add-evidence-first-schema/specs/evidence-first-workflow/spec.md` |
| Implementation scope | `openspec/schemas/evidence-first/`, `scripts/adopt.sh`, `scripts/validate.sh`, `README.md`, `docs/adoption-prompts.md`, `CONTRIBUTING.md`, `CHANGELOG.md` |
| Test scope | `openspec schemas --json`, `openspec schema validate evidence-first`, `openspec templates --schema evidence-first --json`, `openspec validate add-evidence-first-schema`, `scripts/validate.sh` |
| Diff surface | Changed tracked files: `CHANGELOG.md`, `CONTRIBUTING.md`, `README.md`, `docs/adoption-prompts.md`, `scripts/adopt.sh`, `scripts/validate.sh`; new change/schema files under `openspec/changes/add-evidence-first-schema/` and `openspec/schemas/`. Unrelated untracked paths were not evaluated. |
| Mode | normal |
| AC proof matrix / frozen checklist | `openspec/changes/add-evidence-first-schema/tasks.md` |
| OpenSpec verification | pass: `openspec validate add-evidence-first-schema` -> `Change 'add-evidence-first-schema' is valid` |
| Evaluator | AI-assisted |
| Date | 2026-06-25 |

## 2. Requirement Inventory

| Story | Priority | AC ID | Acceptance criterion | In scope? |
| --- | --- | --- | --- | --- |
| S1 | P0 | REQ-001-AC-001 | Schema file exists at `openspec/schemas/evidence-first/schema.yaml`. | yes |
| S1 | P0 | REQ-001-AC-002 | `openspec schemas --json` reports `evidence-first` as project-local. | yes |
| S1 | P0 | REQ-001-AC-003 | `openspec schema validate evidence-first` passes. | yes |
| S2 | P0 | REQ-002-AC-001 | Schema defines proposal, specs, design, proof, tasks, and evaluation artifacts. | yes |
| S2 | P0 | REQ-002-AC-002 | Schema requires tasks before apply. | yes |
| S2 | P0 | REQ-002-AC-003 | Proof artifact captures AC interpretation, scope decisions, planned implementation proof, planned test proof, and gate result. | yes |
| S2 | P0 | REQ-002-AC-004 | Evaluation artifact captures implementation evidence, test evidence, validation gates, unresolved gaps, and archive readiness. | yes |
| S3 | P0 | REQ-003-AC-001 | Generic adoption keeps the lightweight default. | yes |
| S3 | P0 | REQ-003-AC-002 | Adoption guidance documents how to select `evidence-first`. | yes |
| S3 | P0 | REQ-003-AC-003 | Selecting `evidence-first` does not require a stack flavor. | yes |
| S3 | P0 | REQ-003-AC-004 | Java/Quarkus and Node/TypeScript flavor adoption remain compatible with generic adoption. | yes |
| S4 | P0 | REQ-004-AC-001 | `scripts/validate.sh` validates the schema when OpenSpec is available. | yes |
| S4 | P0 | REQ-004-AC-002 | `scripts/validate.sh` verifies template resolution. | yes |
| S4 | P0 | REQ-004-AC-003 | Adoption dry runs prove generic adoption still works. | yes |
| S4 | P0 | REQ-004-AC-004 | Adoption dry runs prove evidence-first adoption works when selected. | yes |
| S5 | P1 | REQ-005-AC-001 | README explains lightweight versus evidence-first workflows. | yes |
| S5 | P1 | REQ-005-AC-002 | Contribution guidance describes schema source, templates, skills, and flavors. | yes |
| S5 | P1 | REQ-005-AC-003 | Adoption prompts tell agents to choose evidence-first only for stricter traceability. | yes |
| S5 | P1 | REQ-005-AC-004 | Documentation states upstream OpenSpec CLI command changes are out of scope. | yes |

Out-of-scope notes:

- Upstream OpenSpec CLI command changes remain excluded; the implementation uses project-local schema support.
- Runtime unit/integration tests are n/a because this change has no application runtime behavior.

Assumptions:

- For this docs/script/schema change, shell syntax checks, OpenSpec schema commands, adoption dry runs, path convention checks, and OpenSpec structural validation are the appropriate test proof.

## 3. Implementation Scoring

| AC ID | Evidence | I | Rationale |
| --- | --- | --- | --- |
| REQ-001-AC-001 | `openspec/schemas/evidence-first/schema.yaml:1` | 1.00 | Schema file exists with `name: evidence-first`. |
| REQ-001-AC-002 | `scripts/validate.sh:182-190`; command output from `openspec schemas --json` reported `evidence-first` with `source: project`. | 1.00 | Validation asserts both discovery and project-local source. |
| REQ-001-AC-003 | `scripts/validate.sh:190`; command output from `openspec schema validate evidence-first` passed. | 1.00 | Validation runs the schema validator. |
| REQ-002-AC-001 | `openspec/schemas/evidence-first/schema.yaml:5`, `openspec/schemas/evidence-first/schema.yaml:22`, `openspec/schemas/evidence-first/schema.yaml:45`, `openspec/schemas/evidence-first/schema.yaml:62`, `openspec/schemas/evidence-first/schema.yaml:83`, `openspec/schemas/evidence-first/schema.yaml:103` | 1.00 | All required artifacts are defined. |
| REQ-002-AC-002 | `openspec/schemas/evidence-first/schema.yaml:117-119` | 1.00 | Apply requires `tasks` and tracks `tasks.md`. |
| REQ-002-AC-003 | `openspec/schemas/evidence-first/schema.yaml:67-78`; `openspec/schemas/evidence-first/templates/proof.md:15-41` | 1.00 | Proof artifact and template capture interpretation, scope, implementation/test proof, and gate result. |
| REQ-002-AC-004 | `openspec/schemas/evidence-first/schema.yaml:103-115`; `openspec/schemas/evidence-first/templates/evaluation.md:25-100` | 1.00 | Evaluation artifact and template capture implementation evidence, test evidence, gates, gaps, and archive readiness. |
| REQ-003-AC-001 | `openspec/config.yaml:1`; `scripts/adopt.sh:293-295`; `scripts/validate.sh:149-159` | 1.00 | Default config remains `spec-driven`; optional schema is copied only when selected; validation rejects accidental generic schema install. |
| REQ-003-AC-002 | `README.md:52-61`; `docs/adoption-prompts.md:63-64` | 1.00 | Adoption guidance documents `--schema evidence-first` and the default. |
| REQ-003-AC-003 | `scripts/adopt.sh:59-70`; `scripts/adopt.sh:264-272`; `scripts/adopt.sh:293-295`; `README.md:59-61` | 1.00 | Schema selection is parsed and installed independently of flavor selection. |
| REQ-003-AC-004 | `scripts/validate.sh:175-180` | 1.00 | Validation keeps generic, Java/Quarkus, Node/TypeScript, and evidence-first dry runs. |
| REQ-004-AC-001 | `scripts/validate.sh:182-199` | 1.00 | Validation checks schema discovery and validation when OpenSpec exists, otherwise reports unavailable. |
| REQ-004-AC-002 | `scripts/validate.sh:191-194` | 1.00 | Validation asserts proof and evaluation template resolution. |
| REQ-004-AC-003 | `scripts/validate.sh:149-159`; `scripts/validate.sh:175-180` | 1.00 | Validation runs and verifies generic adoption stays lightweight. |
| REQ-004-AC-004 | `scripts/validate.sh:138-148`; `scripts/validate.sh:175-180` | 1.00 | Validation runs evidence-first adoption and verifies schema files/config. |
| REQ-005-AC-001 | `README.md:52-61`; `README.md:114-126` | 1.00 | README explains when to use lightweight versus evidence-first. |
| REQ-005-AC-002 | `CONTRIBUTING.md:15-18`; `CONTRIBUTING.md:30-43` | 1.00 | Contribution guidance names schema, template, skill, flavor, and opt-in ownership. |
| REQ-005-AC-003 | `docs/adoption-prompts.md:9-13`; `docs/adoption-prompts.md:192-194` | 1.00 | Prompts restrict evidence-first to stricter traceability and avoid inventing artifacts for lightweight repos. |
| REQ-005-AC-004 | `README.md:125-126`; `docs/adoption-prompts.md:11-13` | 1.00 | Docs state upstream CLI command changes are out of scope. |

## 4. Test Scoring

For this schema/docs/script workflow change, runtime unit and integration/e2e
test levels are n/a. The scored test proof is structural OpenSpec validation,
schema/template CLI checks, adoption dry runs, shell syntax checks, path
convention checks, and secret scan.

| AC ID | Structural/test evidence | T | Rationale |
| --- | --- | --- | --- |
| REQ-001-AC-001 | `scripts/validate.sh:21-42`; `scripts/validate.sh` passed. | 1.00 | Required schema file and templates are checked as required paths. |
| REQ-001-AC-002 | `scripts/validate.sh:185-189`; `openspec schemas --json` manually confirmed project source. | 1.00 | Discovery is automated and was manually verified. |
| REQ-001-AC-003 | `scripts/validate.sh:190`; `openspec schema validate evidence-first` passed. | 1.00 | Schema validation is automated and was manually verified. |
| REQ-002-AC-001 | `openspec templates --schema evidence-first --json` resolved all six artifact templates. | 1.00 | Template resolution proves artifact/template wiring. |
| REQ-002-AC-002 | `openspec schema validate evidence-first` passed with apply requires tasks. | 1.00 | Schema structure validates. |
| REQ-002-AC-003 | `scripts/validate.sh:223-225`; `openspec/schemas/evidence-first/templates/proof.md:15-41` | 1.00 | Validation scans stable AC examples; template contains required proof fields. |
| REQ-002-AC-004 | `scripts/validate.sh:191-194`; `openspec/schemas/evidence-first/templates/evaluation.md:25-100` | 1.00 | Validation resolves evaluation template; template contains required fields. |
| REQ-003-AC-001 | `scripts/validate.sh:149-159`; `scripts/validate.sh` generic dry run passed. | 1.00 | Generic adoption is validated to keep `spec-driven` and omit schema install. |
| REQ-003-AC-002 | `scripts/validate.sh` path convention and docs checks passed. | 1.00 | Docs were included in the final validation run. |
| REQ-003-AC-003 | `scripts/validate.sh:138-148`; evidence-first generic dry run passed. | 1.00 | Evidence-first adoption was validated without any flavor. |
| REQ-003-AC-004 | `scripts/validate.sh:175-180`; Java/Quarkus and Node/TypeScript dry runs passed. | 1.00 | Flavor adoption compatibility is covered. |
| REQ-004-AC-001 | `scripts/validate.sh:182-199`; final `scripts/validate.sh` passed. | 1.00 | The validation script includes and executed the schema gate. |
| REQ-004-AC-002 | `scripts/validate.sh:191-194`; final `scripts/validate.sh` passed. | 1.00 | Template resolution checks executed. |
| REQ-004-AC-003 | `scripts/validate.sh:175-180`; final `scripts/validate.sh` passed. | 1.00 | Generic dry run executed. |
| REQ-004-AC-004 | `scripts/validate.sh:138-148`; final `scripts/validate.sh` passed. | 1.00 | Evidence-first dry run executed. |
| REQ-005-AC-001 | `scripts/validate.sh:278-332`; final `scripts/validate.sh` passed. | 1.00 | Documentation path convention validation passed. |
| REQ-005-AC-002 | `scripts/validate.sh:278-332`; final `scripts/validate.sh` passed. | 1.00 | Contribution docs are outside the path-convention scan by design, but final docs review found required guidance. |
| REQ-005-AC-003 | `scripts/validate.sh:290-294`; final `scripts/validate.sh` passed. | 1.00 | Adoption prompts are scanned for adopter-relative path conventions. |
| REQ-005-AC-004 | `scripts/validate.sh:278-332`; final `scripts/validate.sh` passed. | 1.00 | Docs review plus validation confirmed out-of-scope guidance. |

## 5. Score Calculation

Formula:

```text
AC_score = 0.6 * I + 0.4 * T
```

Every in-scope AC scored `I=1.00` and `T=1.00`, so every AC score is `1.00`.

Story scores:

```text
S1 = 1.00
S2 = 1.00
S3 = 1.00
S4 = 1.00
S5 = 1.00
```

Final:

```text
Final = 1.00
Band = Spec-complete
```

Docs/template-only mode:

- Runtime test scoring is n/a because there is no application runtime.
- Result is unadjusted for runtime test proof and based on schema/script/docs
  structure plus CLI validation.

## 6. Test Distribution

| Class | Count | Percent | Interpretation |
| --- | --- | --- | --- |
| Necessary | 5 | 100% | Schema discovery/validation, template resolution, adoption dry runs, OpenSpec validation, full overlay validation. |
| Secondary | 0 | 0% | No additional edge checks were required beyond invalid generic/evidence-first split checks in validation. |
| Nice-to-have | 0 | 0% | None. |

## 7. Extra Tests Inventory

| ID | Scenario | Level | Evidence | Weight |
| --- | --- | --- | --- | --- |
| n/a | None | n/a | n/a | n/a |

Robustness index:

```text
R = 0
```

## 8. Side Signals

| Signal | Value | Evidence | Notes |
| --- | --- | --- | --- |
| Scope adherence | pass | `README.md:125-126`; `docs/adoption-prompts.md:11-13` | Upstream CLI changes remain out of scope. |
| Robustness | 0 | n/a | No extra tests beyond necessary gates. |
| Test distribution | Necessary-only | `scripts/validate.sh:335-344` | Appropriate for workflow/schema change. |
| Engineering gates | pass with shellcheck unavailable | final `scripts/validate.sh` output | `shellcheck` unavailable; `bash -n` fallback passed. |
| Planning-artifact quality | pass | `openspec/changes/add-evidence-first-schema/tasks.md` | Tasks map to requirements, tests, gates, and done conditions. |

## 9. Scope Adherence

| Item | Status | Evidence |
| --- | --- | --- |
| Avoided explicit out-of-scope behavior | pass | `README.md:125-126`; `docs/adoption-prompts.md:11-13` |
| No unrelated behavior | pass | Implementation limited to schema, adoption, validation, docs, changelog, and OpenSpec task/evaluation artifacts. |
| No inconsistent half-built feature | pass | `scripts/validate.sh` passed; `openspec validate add-evidence-first-schema` passed. |

Scope adherence: pass

## 10. Planned Versus Created

| Planned item | Expected evidence | Created evidence | Status |
| --- | --- | --- | --- |
| Evidence-first schema | `openspec/schemas/evidence-first/schema.yaml` | `openspec/schemas/evidence-first/schema.yaml:1-124` | created |
| Evidence-first templates | `openspec/schemas/evidence-first/templates/*.md` | `openspec templates --schema evidence-first --json` resolved proposal, specs, design, proof, tasks, evaluation | created |
| Opt-in adoption | `scripts/adopt.sh` | `scripts/adopt.sh:59-70`, `scripts/adopt.sh:264-272`, `scripts/adopt.sh:293-317` | created |
| Overlay validation | `scripts/validate.sh` | `scripts/validate.sh:21-42`, `scripts/validate.sh:138-199`, `scripts/validate.sh:335-344` | created |
| Workflow docs | `README.md`, `docs/adoption-prompts.md` | `README.md:52-61`, `README.md:114-126`, `docs/adoption-prompts.md:9-13` | created |
| Contribution/changelog docs | `CONTRIBUTING.md`, `CHANGELOG.md` | `CONTRIBUTING.md:15-18`, `CONTRIBUTING.md:30-43`, `CHANGELOG.md:11-17` | created |
| Structural OpenSpec validation | `openspec validate add-evidence-first-schema` | command passed | created |
| Final overlay validation | `scripts/validate.sh` | command passed | created |

No unmapped created files were found in the evaluated change surface.

## 11. Engineering Gates

| Gate | Status | Evidence |
| --- | --- | --- |
| OpenSpec verify | pass | `openspec validate add-evidence-first-schema` -> `Change 'add-evidence-first-schema' is valid` |
| Build | n/a | This repository is not a runnable service. |
| Static checks | pass | `scripts/validate.sh` ran `bash -n`; `shellcheck` unavailable and reported as unavailable. |
| Unit tests | n/a | No application runtime code. |
| Integration/e2e tests | pass | `scripts/validate.sh` adoption dry runs and OpenSpec schema/template commands passed. |

## 12. Ranked Gaps

1. None.

## 13. Path To 1.00

- Already at 1.00 for the in-scope evidence-first workflow requirements.
