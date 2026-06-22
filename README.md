# SpecOps Overlay

SpecOps Overlay is a technology-agnostic delivery overlay for OpenSpec. It
adds project context, scope discipline, task-time proof, and post-implementation
evaluation around OpenSpec's proposal/spec/task/apply/sync/archive lifecycle.

It is not a runnable application or service. An adopting repository must fill
in its own runtime facts, commands, architecture, tests, integrations, and
operational constraints before relying on agents for code changes.

Tool-specific OpenSpec command and skill files are not versioned in this
overlay. Generate them in each adopting repository with `openspec init` so the
selected tools, workflow profile, and installed OpenSpec version decide the
final files.

## Contents

- [What It Adds](#what-it-adds)
- [Workflow](#workflow)
- [Adoption](#adoption)
- [Repository Contents](#repository-contents)
- [Core And Flavors](#core-and-flavors)
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

The overlay does not guarantee implementation quality by itself. It gives
agents and reviewers a clearer contract for finding risks, proving acceptance
criteria, and recording what was actually validated.

## Workflow

The full overlay path is:

```text
adopt -> map -> propose -> specs -> design -> quality-gate -> tasks -> apply -> verify -> eval -> sync/archive
```

Use the parts that match the risk of the change:

- New repository: adopt overlay, fill `AGENTS.md`, fill `docs/project/*`, run
  `openspec init`, then start the first change.
- Existing repository: adopt overlay, run `skills/brownfield-mapping/SKILL.md`,
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
4. For existing repositories, use `skills/brownfield-mapping/SKILL.md` to fill
   `docs/project/*` from observed code, manifests, scripts, and CI before
   relying on agents for implementation work.
5. Confirm `openspec/config.yaml` matches the repository's desired OpenSpec
   workflow and context rules.
6. Load flavor guidance only when the adopting repository actually uses that
   stack.
7. Run `openspec init` and select the AI tools that should receive generated
   OpenSpec commands and skills.
8. Run `openspec config profile` and `openspec update` only when the project
   needs the expanded workflow commands.

For guided setup, run the adoption script from the adopting repository root by
using the overlay path:

```bash
/path/to/specops-overlay/scripts/adopt.sh
```

For manual copy from the adopting repository root:

```bash
OVERLAY=/path/to/specops-overlay
rsync -a \
  "$OVERLAY"/AGENTS.md \
  "$OVERLAY"/docs \
  "$OVERLAY"/skills \
  "$OVERLAY"/openspec \
  "$OVERLAY"/templates \
  "$OVERLAY"/flavors \
  .
```

For an existing repository, work on a branch and keep backups while merging:

```bash
git checkout -b adopt-specops-overlay
OVERLAY=/path/to/specops-overlay
rsync -a --backup --suffix=.before-specops-overlay \
  "$OVERLAY"/AGENTS.md \
  "$OVERLAY"/docs \
  "$OVERLAY"/skills \
  "$OVERLAY"/openspec \
  "$OVERLAY"/templates \
  "$OVERLAY"/flavors \
  .
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
- `openspec/config.yaml`: OpenSpec context bridge for proposal, specs, design,
  and task artifacts.
- `openspec/specs/` and `openspec/changes/`: placeholders for current behavior
  specs and proposed change artifacts.

## Core And Flavors

The repository root is the overlay core. Do not add or assume a nested `core/`
directory. Generic adoption must work without assuming any language, framework,
build tool, database, container runtime, or cloud provider.

Stack-specific guidance belongs in optional flavors under `flavors/<id>/`.
Java/Quarkus is the first supported flavor, not the identity of the overlay.
When that flavor is selected, `flavors/java-quarkus/AGENTS.patch.md` is
injected between the flavor markers in `AGENTS.md`.

The next flavor validation target is Node/TypeScript. OpenSpec schema packaging
remains a future distribution option; the current strategy is copy-in adoption
plus generated OpenSpec tool files.

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

Use the contribution flow in `CONTRIBUTING.md`. User-visible changes should
include an OpenSpec change, update affected specs/templates/skills, run
`scripts/validate.sh`, and record notable changes in `CHANGELOG.md`.

The authoritative bootstrap checklist lives in `AGENTS.md`. Stable engineering
facts should remain in `docs/project/`; observable behavior belongs in
`openspec/specs/`; proposed behavior changes belong under
`openspec/changes/<change-id>/`.
