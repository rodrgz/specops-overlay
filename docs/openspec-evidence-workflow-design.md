# Design Doc: Evidence-Oriented OpenSpec Workflow

## Summary

SpecOps Overlay is a thin workflow layer around OpenSpec. It does not replace
OpenSpec's proposal, spec, design, task, apply, verify, and archive lifecycle.
It adds the operational guardrails that make agent-assisted implementation
safer in real repositories:

- project facts that agents can load progressively;
- stable requirement and acceptance-criteria IDs;
- task-to-AC and test-to-AC traceability;
- pre-implementation quality gates for risky changes;
- post-implementation evaluation with file/line evidence;
- optional stack-specific guidance without making the core stack-specific.

The upstream opportunity for OpenSpec is to make this evidence-oriented
workflow a first-class optional profile or documented community schema, while
preserving OpenSpec's current bias toward fluid, iterative, low-ceremony use.

## Problem Statement

OpenSpec already gives teams a change lifecycle and artifact structure. The
remaining failure mode this overlay targets is not lack of specs; it is loss of
proof between artifacts and implementation.

In agent-assisted work, the following problems are common:

- A proposal states intent, but tasks do not map to specific acceptance
  criteria.
- A task is checked off, but no one can tell which test proves it.
- Integration, persistence, security, async, and webhook risks are treated like
  ordinary code edits even when they require stronger proof.
- Brownfield repositories expose agents to incomplete docs, causing agents to
  invent commands, architecture, dependencies, or conventions.
- Completed changes are archived before implementation evidence and unresolved
  gaps are recorded.
- Extra tests can create confidence while the actual requirement remains
  untested.

SpecOps Overlay tries to solve those gaps by making traceability and evidence
cheap enough to use in normal OpenSpec work.

## Current OpenSpec Baseline

This analysis used the local OpenSpec CLI version `1.4.1` and the public
OpenSpec repository documentation available on 2026-06-25.

Observed baseline:

- OpenSpec exposes a default `spec-driven` schema with artifacts:
  `proposal -> specs -> design -> tasks`.
- The package templates are intentionally minimal:
  - `proposal.md` captures why, what changes, capabilities, and impact.
  - `spec.md` captures added requirements and scenarios.
  - `design.md` captures context, goals, decisions, and risks.
  - `tasks.md` captures task groups and checkbox items.
- `openspec/config.yaml` can inject project context and per-artifact rules.
- Custom schemas can live in `openspec/schemas/`.
- Community schemas are explicitly supported as separate repositories.
- The public README positions OpenSpec as fluid, iterative, easy, brownfield
  friendly, and scalable.

This means the right upstream shape is probably not to make every OpenSpec
change heavy by default. The better fit is an opt-in profile/schema for teams
that need stronger proof.

## What SpecOps Overlay Adds

### 1. Repository Contract For Agents

`AGENTS.md` is the root-level operating contract for AI-assisted development.
It tells agents where context lives, when to use gates, how to size changes,
how to avoid invented commands, and how to preserve OpenSpec ownership.

The important design choice is separation of concerns:

- `AGENTS.md` contains the binding rules for agents.
- `openspec/config.yaml` is only the OpenSpec context bridge.
- `docs/project/*` contains stable repository facts.
- `openspec/specs/*` contains observable behavior.
- `openspec/changes/*` contains proposed behavior changes.

This avoids turning OpenSpec config into a large, drifting instruction dump.

### 2. Progressive Project Context

The overlay adds these project-reference documents:

- `docs/project/ARCHITECTURE.md`
- `docs/project/STACK.md`
- `docs/project/STRUCTURE.md`
- `docs/project/CONVENTIONS.md`
- `docs/project/TESTING.md`
- `docs/project/INTEGRATIONS.md`
- `docs/project/CONCERNS.md`

Agents are instructed to load only the files relevant to the current task. This
keeps context smaller while still giving agents enough stable facts to avoid
guessing.

For brownfield repositories, the `brownfield-mapping` skill fills these docs
from observed files, manifests, scripts, tests, CI, and representative code.
Unknowns must stay explicit.

### 3. Stronger Artifact Templates

SpecOps templates add structure that the default OpenSpec templates do not
currently enforce:

- requirement inventory with stable IDs;
- acceptance criteria IDs such as `REQ-001-AC-001`;
- capability-to-delta-spec mapping;
- explicit scope tables;
- risk and gate decision tables;
- task-local `Tests`, `Gate`, `Done when`, and `Maps to` fields;
- AC proof matrix;
- evaluation report with implementation and test scoring.

The core principle is that every planned file, endpoint, job, event, config
entry, test, and validation command should map to one of:

- a requirement or acceptance criterion;
- a sanctioned implicit risk;
- a documented engineering gate.

Anything else is scope drift or a deferred idea.

### 4. Pre-Implementation Quality Gate

The `spec-quality-gate` skill is used before implementation when a change has
explicit ACs or touches risky surfaces:

- persistence or migrations;
- external integrations;
- messaging, async, scheduled, or webhook behavior;
- security, privacy, authorization, or configuration;
- hidden requirement risk.

The gate produces:

- requirement and AC inventory;
- frozen interpretation of ambiguous ACs;
- implicit requirement decisions;
- AC proof matrix;
- test strategy by AC;
- scope check;
- blocking questions.

The gate result is `pass`, `partial`, or `fail`. It is intentionally not a
generic approval ritual. Its job is to make risky work implementable without
allowing requirements to drift during coding.

### 5. Post-Implementation Evaluation

The `spec-driven-eval` skill scores implementation fidelity and test proof
separately:

```text
AC_score = 0.6 * implementation + 0.4 * tests
```

Every non-zero score must cite file/line evidence. Missing evidence is scored
as zero only after the relevant paths and symbols were searched.

This evaluation is meant for archive or merge readiness, not for planning. It
surfaces:

- implemented ACs;
- missing or partial implementation;
- missing tests;
- test distribution;
- extra defensive tests;
- scope adherence;
- engineering gate results;
- concrete path to full compliance.

### 6. Optional Stack Flavors

The overlay keeps the core stack-agnostic, but supports optional flavors under
`flavors/<id>/`. Current examples include Java/Quarkus and Node/TypeScript.

Each flavor can provide:

- defaults;
- relevant source/test/resource roots;
- documented commands;
- coding, integration, and hardening guidance;
- architecture skills for module or persistence-boundary changes.

This lets teams add stack specificity only when it matches the adopting
repository.

### 7. Adoption And Validation

`scripts/adopt.sh` copies overlay assets into an adopting repository:

- `AGENTS.md`
- `docs/project/`
- `.agents/skills/`
- `openspec/config.yaml`
- `openspec/specops/templates/`
- `openspec/specops/flavors/`

It supports generic adoption, optional flavor injection, brownfield detection,
and `--force` backups.

`scripts/validate.sh` protects the overlay itself by checking:

- required paths;
- shell syntax and optional shellcheck;
- adoption dry runs for generic and flavor installs;
- template traceability;
- adopter-relative path conventions;
- obvious tracked secrets;
- active OpenSpec changes when the CLI is available.

## Goals

- Preserve OpenSpec's lightweight default workflow.
- Offer an opt-in evidence-first workflow for teams that need stricter
  traceability.
- Make AC-to-task-to-test proof explicit before implementation.
- Make archive or merge readiness evidence-based after implementation.
- Improve brownfield safety by grounding project context in observed facts.
- Support stack-specific guidance without making OpenSpec core stack-specific.
- Keep the workflow usable by agents through compact tables and deterministic
  checklists.

## Non-Goals

- Do not make every OpenSpec project use heavyweight gates.
- Do not replace OpenSpec's artifact lifecycle.
- Do not turn OpenSpec into a test runner, CI system, or coverage tool.
- Do not require a specific AI agent, editor, framework, language, database, or
  container runtime.
- Do not vendor generated tool command files into reusable workflow source.
- Do not treat evaluation scores as a substitute for running project tests.

## Proposed Upstream Shape

There are three realistic contribution paths. They can be done independently.

### Option A: Community Schema Package

Create a standalone community schema or workflow package, for example
`openspec-evidence-workflow` or `openspec-specops-schema`.

It would include:

- schema definition;
- enhanced templates;
- optional proof matrix and evaluation templates;
- docs for when to use the workflow;
- migration guidance from the default `spec-driven` schema;
- examples for low-risk, medium-risk, and high-risk changes.

This aligns with current OpenSpec customization docs because community schemas
are already a supported extension path.

Best first PR:

- Add this workflow to the OpenSpec community schemas table.
- Add a short recipe showing how to install and when to choose it.

### Option B: Built-In Optional Profile

Add an official OpenSpec profile such as `evidence-first` or `strict-proof`.

The profile would keep the existing artifact lifecycle but swap in richer
templates and instructions:

```text
proposal -> specs -> design -> proof -> tasks -> apply -> verify -> evaluate -> archive
```

The `proof` and `evaluate` artifacts could be optional and triggered by risk
rules:

- explicit ACs;
- persistence or migration;
- security or privacy;
- external integrations;
- async, scheduled, message-driven, or webhook behavior;
- config or rollout risk.

Best first PR:

- Add optional richer templates for proposal, spec, design, and tasks.
- Defer new CLI commands until the template experience proves useful.

### Option C: First-Class Gate Commands

Add commands that operationalize the overlay's gates:

```text
openspec quality-gate <change-id>
openspec evaluate <change-id>
```

`quality-gate` would check whether the change has enough requirement inventory,
scope decisions, task mapping, and planned proof before implementation.

`evaluate` would help produce a post-implementation report, but it should not
claim correctness without evidence. It can scaffold the report and guide the
agent to cite files, tests, and command results.

Best first PR:

- Add machine-readable checks for artifact completeness and mapping fields.
- Keep subjective scoring in generated instructions at first.

## Recommended Path

Start with Option A, then upstream smaller pieces.

Reasoning:

- It fits OpenSpec's current extension model.
- It avoids making the default workflow feel rigid.
- It provides a real artifact that OpenSpec maintainers can evaluate.
- It lets teams test the workflow before OpenSpec adopts any part into core.

After the community schema has usage feedback, upstream improvements can be
split into smaller PRs:

1. Documentation PR: "Evidence-first workflows for high-risk changes."
2. Template PR: add stable AC ID and task mapping examples to default docs.
3. CLI PR: expose structural checks for missing task proof fields.
4. Schema PR: add official `evidence-first` profile if demand is clear.

## Suggested Workflow

### Low-Risk Change

Use default OpenSpec or a lightweight direct diff.

```text
idea -> proposal/tasks if needed -> implement -> validate -> archive
```

No proof matrix is required unless explicit ACs or risks exist.

### Medium-Risk Behavior Change

```text
idea
-> proposal with requirement inventory
-> delta specs with stable AC IDs
-> design with scope guard
-> tasks with Maps to / Tests / Gate / Done when
-> implement
-> OpenSpec verify
-> archive
```

### High-Risk Or Explicit-AC Change

```text
idea
-> proposal
-> specs
-> design
-> spec-quality-gate
-> AC proof matrix
-> tasks
-> implement with task-local proof
-> OpenSpec verify
-> spec-driven evaluation
-> sync/archive only after gaps are named
```

## Artifact Model

| Artifact | Purpose | Key Additions |
| --- | --- | --- |
| `proposal.md` | Explain problem and behavior change | Requirement inventory, capability deltas, scope table, gate decision |
| `spec.md` | Define observable behavior | Stable requirement IDs, AC IDs, proof expectations, out-of-scope behavior |
| `design.md` | Record implementation decisions | context sources, decision summary, scope guard, test strategy |
| `ac-proof-matrix.md` | Plan proof before coding | atomic implementation checks, test checks, real outcome checks |
| `tasks.md` | Execute implementation | task-local mapping, tests, gate, done condition, commit guidance |
| `evaluation.md` | Verify after coding | implementation score, test score, evidence, gaps, gates, path to full compliance |

## Validation Model

OpenSpec should distinguish four kinds of validation:

- Structural validation: artifacts exist and schema rules are satisfied.
- Traceability validation: requirements, ACs, tasks, and tests are mapped.
- Runtime validation: project build, tests, static checks, migrations, and
  integration checks actually ran.
- Evidence validation: implementation and test claims cite concrete files,
  lines, searches, and command results.

The overlay mainly targets traceability and evidence validation. It records
runtime validation results, but it does not replace the repository's actual
checks.

## UX Requirements

Any upstream version should preserve these user experience constraints:

- Default OpenSpec remains simple.
- Users can opt into stronger proof only when they need it.
- The workflow should be table-driven and skimmable.
- Agents should load only relevant context.
- Brownfield mapping must prefer observed facts over aspirational docs.
- Gates should produce actionable blockers, not vague warnings.
- The archive path must name unresolved gaps instead of hiding them.

## Risks And Tradeoffs

| Risk | Mitigation |
| --- | --- |
| Too much ceremony for small changes | Make the workflow opt-in and risk-triggered. |
| Agents generate large but low-signal tables | Keep required fields small and use examples with compact rows. |
| Evaluation scores create false confidence | Require file/line evidence and report unrun gates separately. |
| Teams confuse project docs with behavior specs | Keep `docs/project/*` for facts and `openspec/specs/*` for observable behavior. |
| Stack flavors fragment the workflow | Keep core generic; flavors add only optional stack guidance. |
| Upstream maintainers reject a broad PR | Start with docs/community schema, then split core changes. |

## Open Questions

- Should OpenSpec core include an official `evidence-first` schema, or should
  this remain a community schema?
- Should `quality-gate` and `evaluate` become CLI commands, generated slash
  commands, or only schema instructions?
- Should AC IDs be recommended in default templates, or only in stricter
  profiles?
- Should OpenSpec validate task-to-AC mappings structurally?
- How should evidence reports cite file ranges in a tool-agnostic way?
- Should stack flavors live in OpenSpec community schemas, separate packages,
  or project-local docs?

## Success Metrics

- Fewer archived changes with missing or ambiguous requirement proof.
- Higher percentage of tasks mapped to ACs or explicit engineering gates.
- Higher percentage of explicit ACs with at least one direct test assertion.
- Fewer agent-invented project commands after brownfield mapping.
- Faster review because implementation, tests, and remaining gaps are
  traceable from one change folder.
- Maintainers can adopt the workflow without changing the default OpenSpec
  experience.

## Evidence From This Repository

Local sources reviewed:

- `README.md`: states the overlay purpose, adoption model, and OpenSpec
  relationship.
- `AGENTS.md`: defines the project-local agent contract and conditional skill
  gates.
- `openspec/config.yaml`: injects OpenSpec context and artifact rules.
- `templates/proposal.md`: adds requirement inventory, scope, risk, and gate
  decisions.
- `templates/spec.md`: adds stable IDs and proof expectations.
- `templates/design.md`: adds decision tables, test strategy, and scope guard.
- `templates/tasks.md`: adds task-local mapping, tests, gates, and done
  conditions.
- `templates/ac-proof-matrix.md`: defines pre-implementation proof rows.
- `templates/evaluation.md`: defines post-implementation evidence scoring.
- `skills/brownfield-mapping/SKILL.md`: defines evidence-based project mapping.
- `skills/spec-quality-gate/SKILL.md`: defines pre-implementation gate logic.
- `skills/spec-driven-eval/SKILL.md`: defines post-implementation scoring.
- `scripts/adopt.sh`: installs the overlay into adopting repositories.
- `scripts/validate.sh`: validates source consistency and adoption behavior.

External sources checked:

- OpenSpec repository: https://github.com/Fission-AI/OpenSpec
- OpenSpec customization docs:
  https://github.com/Fission-AI/OpenSpec/blob/main/docs/customization.md
