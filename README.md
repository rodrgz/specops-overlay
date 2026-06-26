# SpecOps Overlay

SpecOps Overlay is a small delivery layer for teams using OpenSpec with AI
agents.

OpenSpec gives you the change lifecycle. SpecOps Overlay adds the working
contract around it: project context, scoped tasks, acceptance-criteria proof,
quality gates, and evidence before archive.

Use it when you want agent-assisted changes to stay understandable without
turning every task into heavyweight process.

This repository is not a runnable service. It is copied into an adopting
project and then filled with that project's real stack, commands, architecture,
tests, integrations, and constraints.

## What You Get

- `AGENTS.md`: the local contract agents follow in the adopting repository.
- `docs/project/*`: stable project facts for architecture, stack, structure,
  conventions, testing, integrations, and risks.
- `openspec/config.yaml`: OpenSpec context rules for proposals, specs, design,
  and tasks.
- `openspec/schemas/evidence-first/*`: an optional project-local OpenSpec
  schema for stricter proof, tasks, and evaluation artifacts.
- `.agents/skills/*`: focused agent workflows for brownfield mapping, quality
  gates, implementation evaluation, and PR review.
- `openspec/specops/templates/*`: reusable proposal, spec, design, task,
  proof, and evaluation templates.
- `openspec/specops/flavors/*`: optional stack guidance, currently including
  Java/Quarkus and Node/TypeScript.

The point is simple: requirements, tasks, tests, and evidence should point to
each other.

## Adopt It

Run the adoption script from the root of the project that will receive the
overlay:

```bash
/path/to/specops-overlay/scripts/adopt.sh
```

Use a stack flavor only when it matches the project:

```bash
/path/to/specops-overlay/scripts/adopt.sh --flavor node-typescript
/path/to/specops-overlay/scripts/adopt.sh --flavor java-quarkus
```

Keep the lightweight OpenSpec workflow unless the repository needs stricter
AC-to-proof traceability. To opt into the native evidence-first schema, use:

```bash
/path/to/specops-overlay/scripts/adopt.sh --schema evidence-first
```

The schema option does not require a stack flavor. It installs
`openspec/schemas/evidence-first/` and sets `openspec/config.yaml` to
`schema: evidence-first` in the adopting repository.

For an existing project, work on a branch and let the script back up paths it
needs to replace:

```bash
git checkout -b adopt-specops-overlay
/path/to/specops-overlay/scripts/adopt.sh --force
```

Then do the minimum setup that makes the overlay useful:

1. Fill `AGENTS.md` with the real project defaults.
2. Fill `docs/project/*` with observed project facts.
3. In brownfield projects, use `.agents/skills/brownfield-mapping/SKILL.md`
   before trusting the docs for implementation work.
4. Run `openspec init` in the adopting project to generate tool-specific
   OpenSpec commands.
5. Run `openspec config profile` and `openspec update` only if the project
   wants the expanded OPSX command set.

Generated tool files such as `.claude/` and `.github/prompts/opsx-*` belong to
the adopting project, not to this overlay source.

## OpenSpec Workflow

Use the lightest workflow that still preserves traceability.

```text
intent
  -> openspec change
  -> proposal / specs / design / tasks as needed
  -> spec-quality-gate when ACs or risk justify it
  -> apply the implementation
  -> verify or validate the OpenSpec change
  -> spec-driven-eval when behavior can be scored
  -> sync and archive
```

In practice:

- Small docs or template cleanup can stay small. Use a direct diff or a short
  change note when no behavior proof is needed.
- Behavior changes should live under `openspec/changes/<change-id>/`.
- Explicit acceptance criteria, persistence, messaging, integrations, security,
  config, async work, scheduled work, and webhooks should trigger
  `spec-quality-gate` before implementation.
- Completed behavior should be verified, evaluated when scoreable, synced into
  current specs, and archived with known gaps named.

OpenSpec owns the lifecycle. SpecOps Overlay keeps the work honest around that
lifecycle.

### Lightweight Versus Evidence-First

Use the default lightweight workflow for low-risk maintenance, early discovery,
small docs/template updates, and changes where proposal/spec/task traceability
is enough.

Use `evidence-first` when a repository or change needs stricter
AC-to-proof-to-task-to-test traceability. The schema keeps the OpenSpec
proposal, specs, design, tasks, apply, and archive lifecycle, and adds native
`proof.md` and `evaluation.md` artifacts.

OpenSpec CLI command changes are out of scope for this overlay. The schema uses
project-local OpenSpec schema support rather than adding new upstream commands.

## Applied Project Map

After adoption, a consuming repository should look roughly like this:

```text
your-project/
|-- AGENTS.md
|-- docs/
|   `-- project/
|       |-- ARCHITECTURE.md
|       |-- STACK.md
|       |-- STRUCTURE.md
|       |-- CONVENTIONS.md
|       |-- TESTING.md
|       |-- INTEGRATIONS.md
|       `-- CONCERNS.md
|-- openspec/
|   |-- config.yaml
|   |-- schemas/
|   |   `-- evidence-first/     # only when selected
|   |-- specs/
|   |   `-- <capability>/spec.md
|   |-- changes/
|   |   |-- <change-id>/
|   |   |   |-- proposal.md
|   |   |   |-- design.md
|   |   |   |-- tasks.md
|   |   |   `-- specs/<capability>/spec.md
|   |   `-- archive/
|   `-- specops/
|       |-- templates/
|       `-- flavors/
|           |-- java-quarkus/
|           `-- node-typescript/
`-- .agents/
    `-- skills/
        |-- brownfield-mapping/
        |-- spec-quality-gate/
        |-- spec-driven-eval/
        `-- pr-review/
```

This source repository stays flatter for maintenance:

```text
skills/     -> .agents/skills/
templates/  -> openspec/specops/templates/
flavors/    -> openspec/specops/flavors/
AGENTS.md   -> AGENTS.md
docs/project/ -> docs/project/
openspec/config.yaml -> openspec/config.yaml
```

## Source Repository

The overlay core is stack-agnostic. Do not add a nested `core/` directory and
do not make generic adoption depend on a language, framework, database,
container runtime, or cloud provider.

Reusable workflow guidance belongs here:

- `skills/`: source for agent quality gates.
- `templates/`: source for lightweight reusable OpenSpec artifacts and
  transitional material copied to `openspec/specops/templates/` during generic
  adoption. These templates do not own strict `evidence-first` schema behavior.
- `openspec/schemas/evidence-first/`: source for the optional native
  evidence-first schema and its schema-owned templates. This is the canonical
  strict lifecycle source for `evidence-first` proposal, spec, design, proof,
  task, and evaluation artifacts. Select it with `--schema evidence-first`.
- `flavors/<id>/`: optional stack-specific guidance.
- `docs/project/`: adopter-facing placeholders copied into adopting
  repositories. These are not overlay-source facts; they remain
  fill-after-adoption templates.
- `docs/adoption-prompts.md`: prompts for greenfield, brownfield, and first
  feature setup.
- `docs/openspec-evidence-workflow-design.md`: rationale and upstream-alignment
  notes for the evidence-oriented workflow.

Adopter-facing references should use the paths they will have after adoption,
such as `.agents/skills/spec-quality-gate/SKILL.md`, not the source-only
`skills/spec-quality-gate/SKILL.md` path.

### Where to Edit

Use this table to find the canonical source path for common workflow changes.

| What You Are Changing | Canonical Source Path | Role |
| --- | --- | --- |
| Evidence-first proposal template | `openspec/schemas/evidence-first/templates/proposal.md` | Strict schema-owned |
| Evidence-first spec template | `openspec/schemas/evidence-first/templates/spec.md` | Strict schema-owned |
| Evidence-first design template | `openspec/schemas/evidence-first/templates/design.md` | Strict schema-owned |
| Evidence-first proof template | `openspec/schemas/evidence-first/templates/proof.md` | Strict schema-owned |
| Evidence-first tasks template | `openspec/schemas/evidence-first/templates/tasks.md` | Strict schema-owned |
| Evidence-first evaluation template | `openspec/schemas/evidence-first/templates/evaluation.md` | Strict schema-owned |
| Evidence-first schema definition | `openspec/schemas/evidence-first/schema.yaml` | Strict schema-owned |
| Lightweight/default proposal template | `templates/proposal.md` | Lightweight reusable |
| Lightweight/default spec template | `templates/spec.md` | Lightweight reusable |
| Lightweight/default design template | `templates/design.md` | Lightweight reusable |
| Lightweight/default tasks template | `templates/tasks.md` | Lightweight reusable |
| Lightweight/default AC proof matrix | `templates/ac-proof-matrix.md` | Lightweight reusable |
| Lightweight/default evaluation template | `templates/evaluation.md` | Transitional reusable |
| Agent quality gate skills | `skills/<skill-name>/SKILL.md` | Skill source |
| Stack flavor guidance | `flavors/<id>/` | Optional flavor source |
| Adoption script and mapping | `scripts/adopt.sh` | Adoption tooling |
| Repository validation | `scripts/validate.sh` | Validation tooling |
| OpenSpec config and context rules | `openspec/config.yaml` | OpenSpec config |
| Adopter project-reference templates | `docs/project/*` | Adopter templates |

**Strict schema-owned** templates are the canonical lifecycle source for the
`evidence-first` schema. Select them with `--schema evidence-first`.

**Lightweight reusable** templates are default adoption material copied to
`openspec/specops/templates/`. They do not own strict `evidence-first` schema
behavior.

**Transitional reusable** templates exist in both surfaces. Their content may
overlap with schema-owned templates during transition; a future change can
consolidate or remove them.

## Validate Changes

Before merging changes to scripts, templates, skills, OpenSpec config, or
workflow docs, run:

```bash
scripts/validate.sh
```

The validation script checks required references, shell scripts, generic and
evidence-first adoption dry runs, template traceability, obvious secret
patterns, active OpenSpec changes, and evidence-first schema/template
resolution when OpenSpec is available.

## License

- Repository source, templates, scripts, and general documentation use the MIT
  License in `LICENSE`.
- Skill files declare their own license in front matter. Current workflow
  skills use `CC-BY-4.0`.
- The skills and workflow are adapted from
  [agent-skills](https://github.com/tech-leads-club/agent-skills) by Tech Leads
  Club.
