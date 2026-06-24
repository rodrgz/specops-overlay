# SpecOps Overlay

SpecOps Overlay is a technology-agnostic delivery overlay for OpenSpec. It
adds project context, scope discipline, task-time proof, and post-implementation
evaluation around OpenSpec's proposal/spec/task/apply/sync/archive lifecycle.

It is not a runnable application or service. An adopting repository must fill
in its own runtime facts, commands, architecture, tests, integrations, and
operational constraints before relying on agents for code changes.

Tool-specific OpenSpec command files are not versioned in this overlay.
Generate them in each adopting repository with `openspec init` so the selected
tools, workflow profile, and installed OpenSpec version decide the final files.

## Contents

- [What It Adds](#what-it-adds)
- [Workflow](#workflow)
- [Adoption](#adoption)
- [Repository Contents](#repository-contents)
- [Core And Flavors](#core-and-flavors)
- [Path Convention](#path-convention)
- [OpenSpec Setup](#openspec-setup)
- [Validation](#validation)
- [Licensing](#licensing)
- [Contributing](#contributing)

## What It Adds

OpenSpec owns the lifecycle and artifact structure. SpecOps Overlay adds the
working contract around that lifecycle:

- `AGENTS.md` as the local agent contract;
- `docs/project/*` as the stable source for architecture, stack, testing,
  integrations, conventions, and concerns;
- task-local proof fields for `Maps to`, `Tests`, `Gate`, and `Done when`;
- AC-to-proof matrices that map requirements to implementation and validation;
- `skills/spec-quality-gate/` for pre-implementation risk and test planning;
- `skills/spec-driven-eval/` for post-implementation scoring with evidence;
- optional stack flavors under `flavors/<id>/`.

The source repository stays flat for maintenance. During adoption,
`scripts/adopt.sh` installs each source directory to a conventional destination
in the adopting repository (see [Path Convention](#path-convention) below).

The overlay does not guarantee implementation quality by itself. It gives
agents and reviewers a clearer contract for finding risks, proving acceptance
criteria, and recording what was actually validated.

## Workflow

After a repository has adopted the overlay, the day-to-day change path is:

```text
propose -> specs/design/tasks as needed -> spec-quality-gate -> apply -> verify/validate -> spec-driven-eval -> sync/archive
```

`propose` opens or updates the OpenSpec change and turns the intent into
proposal, delta spec, design, and task artifacts as needed. Run
`spec-quality-gate` before implementation when the change has explicit
acceptance criteria or risk around persistence, messaging, integrations,
security, config, async work, scheduled work, or webhooks.

### OpenSpec Actions And Overlay Skills

Names in the workflow are either OpenSpec lifecycle actions or SpecOps Overlay
agent skills:

| Name | Owner | Kind | Day-to-day use |
| --- | --- | --- | --- |
| `propose` | OpenSpec | Lifecycle action / generated tool command | Start or update `openspec/changes/<change-id>/` from intent, PRD, issue, or prompt. |
| `specs`, `design`, `tasks` | OpenSpec | Change artifacts | Record behavior deltas, design decisions, and implementation tasks. |
| `spec-quality-gate` | SpecOps Overlay | Agent skill | Before implementation, audit ACs, hidden requirements, scope, and test strategy. |
| `apply` | OpenSpec | Lifecycle action / generated tool command | Implement the planned change with the chosen agent/tool. |
| `verify` / `validate` | OpenSpec | Structural validation | Check OpenSpec proposal/spec/design/task structure before merge or archive. |
| `spec-driven-eval` | SpecOps Overlay | Agent skill | After implementation, score behavior and tests against ACs/specs before archive or merge. |
| `sync` / `archive` | OpenSpec | Lifecycle action / generated tool command | Sync accepted behavior into current specs, then archive the completed change. |

In this source repository, overlay skills live under `skills/<name>/SKILL.md`.
After adoption, they are installed in the consuming repository under
`.agents/skills/<name>/SKILL.md`. They are not native OpenSpec commands; they
are agent workflows that read and strengthen OpenSpec artifacts.

Adoption and brownfield mapping are setup work before this daily path:

```text
adopt overlay -> brownfield-mapping if existing -> openspec init/update -> first change
```

Then use the parts that match the risk of the change:

- New repository: adopt overlay, fill `AGENTS.md`, fill `docs/project/*`, run
  `openspec init`, then start the first change.
- Existing repository: adopt overlay, run `.agents/skills/brownfield-mapping/SKILL.md`,
  fill project docs from evidence, then plan changes.
- Small docs/template update: use a short change under `openspec/changes/`, map
  tasks to a docs gate, and run targeted validation.
- Clear medium feature: create proposal/spec/task artifacts, run the quality
  gate when ACs or risks apply, then implement.
- Risky or AC-heavy behavior: use full proposal/spec/design/tasks, run
  `spec-quality-gate`, implement task-local proof, then verify and evaluate.
- Unclear requirement: use `/opsx:explore`, then create or update a change once
  the smallest defensible scope is clear.

OpenSpec commands remain actions, not rigid phases. SpecOps Overlay adds proof
gates for teams that want stronger AI-assisted delivery controls. If a
default-on gate is skipped, record the opt-out rationale in the change.

### Change Sizing

`AGENTS.md` is the canonical source for sizing rules copied into adopting
repositories. The short version:

- Small changes may use shorter artifacts, but keep traceability under
  `openspec/changes/` when behavior or proof matters.
- Medium changes need proposal/spec/task artifacts when behavior changes.
- Large and complex changes need full proposal, specs, design, tasks, proof
  planning, OpenSpec verification, and evaluation.
- Risky surfaces trigger quality gates regardless of size: explicit ACs,
  persistence, messaging, external integrations, security, config, async,
  scheduled, or webhook behavior.

## Adoption

Use this flow once per adopting repository:

```text
copy overlay -> fill AGENTS.md -> fill docs/project/* -> choose flavor -> openspec init/update -> first change
```

1. Copy the overlay files into the adopting repository root.
2. Fill `AGENTS.md` under `Template Defaults / Fill After Adoption` with real
   project facts.
3. Fill every file under `docs/project/` with project-specific information.
4. For existing repositories, use `.agents/skills/brownfield-mapping/SKILL.md` to fill
   `docs/project/*` from observed code, manifests, scripts, and CI before
   relying on agents for implementation work.
5. Confirm `openspec/config.yaml` matches the repository's desired OpenSpec
   workflow and context rules.
6. Load flavor guidance only when the adopting repository actually uses that
   stack.
7. Run `openspec init` and select the AI tools that should receive generated
   OpenSpec command files.
8. Run `openspec config profile` and `openspec update` only when the project
   needs the expanded workflow commands.

For guided setup, run the adoption script from the adopting repository root by
using the overlay path:

```bash
/path/to/specops-overlay/scripts/adopt.sh
# or, when a stack flavor applies:
/path/to/specops-overlay/scripts/adopt.sh --flavor node-typescript
```

For manual copy from the adopting repository root:

```bash
OVERLAY=/path/to/specops-overlay
cp -a "$OVERLAY"/AGENTS.md .
mkdir -p docs openspec .agents
cp -a "$OVERLAY"/docs/project docs/
cp -a "$OVERLAY"/openspec/config.yaml openspec/
mkdir -p openspec/specs openspec/changes/archive
touch openspec/specs/.gitkeep openspec/changes/.gitkeep \
  openspec/changes/archive/.gitkeep
mkdir -p openspec/specops
cp -a "$OVERLAY"/templates openspec/specops/
cp -a "$OVERLAY"/flavors openspec/specops/
cp -a "$OVERLAY"/skills .agents/
```

For an existing repository, work on a branch and keep backups while merging:

```bash
git checkout -b adopt-specops-overlay
/path/to/specops-overlay/scripts/adopt.sh --force
```

Do not copy `.git/`. In brownfield repositories, do not overwrite the existing
application `README.md`; keep this overlay README as source guidance and merge
only the adoption instructions the project wants to keep.

Long-form AI prompts for new repositories, brownfield mapping, existing agent
files, and the first feature after adoption live in
[`docs/adoption-prompts.md`](docs/adoption-prompts.md).

## Repository Contents

- `AGENTS.md`: local contract for agents working in an adopting repository.
- `docs/project/`: project facts that must be filled after adoption.
- `docs/adoption-prompts.md`: reusable prompts for applying the overlay.
- `skills/brownfield-mapping/`: evidence-based mapping for existing projects.
- `skills/spec-quality-gate/`: pre-implementation quality gate for ACs, hidden
  requirements, scope, and test strategy.
- `skills/spec-driven-eval/`: post-implementation scoring with evidence.
- `skills/pr-review/`: focused PR or diff review workflow.
- `templates/`: reusable proposal, spec, design, task, AC proof, and
  evaluation templates.
- `flavors/java-quarkus/`: optional Java/Quarkus guidance and stack defaults.
- `flavors/node-typescript/`: optional Node/TypeScript guidance and stack
  defaults.
- `openspec/config.yaml`: OpenSpec context bridge for proposal, specs, design,
  and task artifacts.
- `openspec/specs/` and `openspec/changes/`: placeholders for current behavior
  specs and proposed change artifacts.

## Core And Flavors

The repository root is the overlay core. Do not add or assume a nested `core/`
directory. Generic adoption must work without assuming any language, framework,
build tool, database, container runtime, or cloud provider.

Stack-specific guidance is maintained in optional source flavors under
`flavors/<id>/`. Java/Quarkus and Node/TypeScript are supported flavors, not
the identity of the overlay. When a flavor is selected, its `AGENTS.patch.md`
is injected between the flavor markers in `AGENTS.md`, and the flavor assets
are installed under `openspec/specops/flavors/<id>/` in the adopting
repository.

OpenSpec schema packaging remains a future distribution option; the current
strategy is copy-in adoption plus generated OpenSpec tool files.

## Path Convention

The source repository keeps a flat layout for maintainability. `scripts/adopt.sh`
maps each source directory to a conventional destination in the adopting
repository:

| Source (this repo) | Adopter destination | Purpose |
| --- | --- | --- |
| `skills/` | `.agents/skills/` | Agent quality-gate skills |
| `templates/` | `openspec/specops/templates/` | Reusable artifact templates |
| `flavors/` | `openspec/specops/flavors/` | Stack-specific guidance |
| `AGENTS.md` | `AGENTS.md` | Agent contract (unchanged) |
| `docs/project/` | `docs/project/` | Project reference docs (unchanged) |
| `openspec/config.yaml` | `openspec/config.yaml` | OpenSpec context bridge (unchanged) |

Cross-references inside documentation, skills, templates, and config use
**adopter-relative paths** — the paths as they will appear after adoption.
For example, a skill file in this repository at `skills/spec-quality-gate/SKILL.md`
references `.agents/skills/spec-driven-eval/SKILL.md`, not
`skills/spec-driven-eval/SKILL.md`. This is intentional: agents and developers
consume these files in the adopting repository, where adopter-relative paths
resolve correctly.

This is a deliberate trade-off inspired by GNU Stow's principle that package
contents should mirror the target layout. Unlike Stow, the overlay cannot use
symlinks (adopting repositories are separate git repositories) and the source
layout diverges from the target for maintainability. The mapping table above
and `scripts/adopt.sh` are the single canonical sources for how source paths
translate to adopter paths.

## OpenSpec Setup

Install OpenSpec, then initialize tool integrations from the root of the
adopting project:

```bash
npm install -g @fission-ai/openspec@latest
openspec init
```

The default `core` profile provides the shortest workflow:

```text
propose -> apply -> sync -> archive
```

The expanded profile adds explicit design, task, verification, onboarding, and
bulk archive commands:

```bash
openspec config profile
openspec update
```

For scripted setup, pass supported tool IDs explicitly:

```bash
openspec init --tools claude,github-copilot
```

Generated tool files such as `.claude/` and `.github/prompts/opsx-*` should
remain local to the adopting repository unless that team intentionally chooses
to version them.

## Validation

Run the overlay's self-validation before merging changes to templates, skills,
OpenSpec config, or adoption scripts:

```bash
scripts/validate.sh
```

The script checks required internal references, parses shell scripts, runs
`shellcheck` when installed, performs generic and selected-flavor adoption dry
runs in `/tmp`, checks task/proposal template traceability, scans tracked files
for obvious secret patterns, and validates active OpenSpec changes when
OpenSpec is installed.

CI runs the same script in `.github/workflows/validate.yml`.

## Licensing

- Repository source files, templates, scripts, and general documentation are
  distributed under the MIT License in `LICENSE`.
- Skill files declare their own license in front matter. Current workflow
  skills use `CC-BY-4.0`.
- These skills and the underlying workflow are adapted from
  [agent-skills](https://github.com/tech-leads-club/agent-skills) by Tech Leads
  Club.
- Keep license metadata current when adding or changing reusable skills.

## Contributing

Use the contribution flow in `CONTRIBUTING.md`. User-visible workflow changes
should use OpenSpec when proposal/spec traceability is useful; routine overlay
maintenance may use a direct diff. Update affected specs/templates/skills, run
`scripts/validate.sh`, and record notable changes in `CHANGELOG.md`.

The authoritative bootstrap checklist lives in `AGENTS.md`. Stable engineering
facts should remain in `docs/project/`; observable behavior belongs in
`openspec/specs/`; proposed behavior changes belong under
`openspec/changes/<change-id>/`.
