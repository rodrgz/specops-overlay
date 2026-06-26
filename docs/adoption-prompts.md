# Adoption Prompts

Use these prompts when applying SpecOps Overlay to another repository. Keep the
discoverable contract at the repository root, not in a nested folder. In an
adopting project, the root should contain `AGENTS.md`, `docs/project/`,
`openspec/`, and `.agents/skills/`. SpecOps templates and flavors live under
`openspec/specops/`.

Use the default lightweight OpenSpec workflow unless the repository explicitly
needs stricter AC-to-proof-to-task-to-test traceability. Choose the
`evidence-first` schema only for teams or changes that need that stronger proof
contract. Upstream OpenSpec CLI command changes are out of scope for this
overlay; evidence-first uses project-local schema support.

Do not copy `.git/`. In brownfield repositories, do not overwrite the existing
application `README.md`; keep the overlay README as source guidance and merge
only the adoption instructions that the project wants to keep.

## New Repository

Use this when the application or service does not exist yet. Create the real
project first, then apply SpecOps Overlay at the project root.

```text
You are an AI engineering assistant operating under SpecOps Overlay. SpecOps is a
framework that adds quality gates, scope discipline, and strict requirement
traceability to the OpenSpec standard.

The overlay relies on these base paths. Always respect them:
- `AGENTS.md`: Your primary binding contract and rules.
- `docs/project/`: Stable project facts (Architecture, Stack, Conventions, etc).
- `.agents/skills/`: Reusable agent workflows and quality gates.
- `openspec/`: Observable behavior (`specs/`), proposed changes (`changes/`), and config.
- Optional schema: use `openspec/schemas/evidence-first/` only when stricter
  AC-to-proof traceability is selected.

You are in a new repository that has just adopted this workflow.

Goal: initialize the repository context for AI-assisted development before any
feature work begins.

Use AGENTS.md as the agent contract. Inspect only the files needed to identify
the real project facts: README.md, build manifests, package or module manifests,
wrapper scripts, source roots, test roots, resource/config roots, container or
compose files, CI configuration, and local scripts.

Fill AGENTS.md under "Template Defaults / Fill After Adoption" with stable
project-wide facts. Fill every docs/project/*.md file with facts from the
repository and from the explicit project description below. Mark unknowns as
unknown; do not invent services, commands, environment variables, databases, or
architecture decisions.

Project description:
- Project/service name:
- Business purpose:
- Language/runtime:
- Framework:
- Build tool:
- Database/migration tool:
- External integrations:
- Local dev command:
- Build/test/static analysis commands:
- Flavor guidance to load, if any:
- OpenSpec schema: `spec-driven` by default, or `evidence-first` only when stricter proof is required:

After the docs are coherent, update openspec/config.yaml context to describe
the adopted repository and application stack instead of referencing the generic
SpecOps overlay core. Do not implement product features yet. End with changed
files, unresolved unknowns, and the exact next commands to run, including
openspec init when OpenSpec tooling should be generated.
```

## Brownfield Repository

Use this when the application already exists. Apply SpecOps Overlay on a branch,
then map the current code before asking agents to change behavior.

```text
You are an AI engineering assistant operating under SpecOps Overlay. SpecOps is a
framework that adds quality gates, scope discipline, and strict requirement
traceability to the OpenSpec standard.

The overlay relies on these base paths. Always respect them:
- `AGENTS.md`: Your primary binding contract and rules.
- `docs/project/`: Stable project facts (Architecture, Stack, Conventions, etc).
- `.agents/skills/`: Reusable agent workflows and quality gates.
- `openspec/`: Observable behavior (`specs/`), proposed changes (`changes/`), and config.
- Optional schema: `openspec/schemas/evidence-first/` only when stricter
  AC-to-proof traceability was selected during adoption.

You are in an existing repository that has just adopted this workflow.

Goal: perform brownfield mapping so agents can work from observed facts instead
of assumptions or hallucinations. SpecOps requires strict adherence to project
realities. Do not invent details.

Use `.agents/skills/brownfield-mapping/SKILL.md`. Load AGENTS.md and the current
docs/project/*.md placeholders. Inspect README.md, build manifests, wrappers,
Makefile or task runner files, CI files, container files, runtime config,
source roots, test roots, migrations, scripts, and representative source files.

Update docs/project/STACK.md, ARCHITECTURE.md, STRUCTURE.md, CONVENTIONS.md,
TESTING.md, INTEGRATIONS.md, and CONCERNS.md from evidence in the repository.
Update AGENTS.md "Template Defaults / Fill After Adoption" only with stable,
project-wide facts that agents must see before loading detailed docs.
Update openspec/config.yaml context to describe the actual repository and
application stack instead of referencing the generic SpecOps overlay core.

Do not change application behavior. Do not add desired future architecture to
brownfield docs. Keep unknowns explicit with the file, command, or person needed
to resolve them. Preserve existing project documentation and local agent rules;
merge conflicts instead of replacing them silently.

When finished, run lightweight documentation verification such as git diff
--check and any documented markdown/docs check. End with changed files,
evidence highlights, unresolved unknowns, and whether openspec init or
openspec update should be run next.
```

## Existing Repository With Agent Or OpenSpec Files

Use this when a repository already has `AGENTS.md`, `.claude/`,
`.github/prompts/`, `openspec/`, or local AI instructions.

```text
You are an AI engineering assistant operating under SpecOps Overlay. SpecOps is a
framework that adds quality gates, scope discipline, and strict requirement
traceability to the OpenSpec standard.

You are in a repository that already had agent or OpenSpec files before
this overlay was introduced.

Goal: merge SpecOps Overlay without losing local rules.

Compare the existing AGENTS.md, docs/project/*, .agents/skills/*, openspec/*,
and openspec/config.yaml with the overlay structure. Preserve project-specific
instructions, generated tool files, and existing workflow decisions unless they
conflict with the overlay contract.
Update openspec/config.yaml context to describe the actual repository and
application stack instead of referencing the generic SpecOps overlay core,
while preserving existing workflow decisions that still apply.

Normalize the repository toward these root-level paths:
- AGENTS.md for the local agent contract.
- docs/project/* for stable project facts.
- .agents/skills/* for reusable agent quality gates.
- openspec/config.yaml as the OpenSpec context bridge.
- openspec/schemas/evidence-first/* only when the project has opted into the
  evidence-first schema.
- openspec/specs/* for current observable behavior.
- openspec/changes/* for proposed behavior changes.
- openspec/specops/flavors/<id>/* for optional stack-specific guidance when the repository uses
  a supported flavor.
- openspec/specops/templates/* for reusable SpecOps artifact templates.

Do not copy this overlay README over the application README. Do not maintain
generated .claude/ or .github/prompts/opsx-* files as overlay source unless
the adopting team intentionally versions generated tool files.

End with a merge summary, any conflicts or duplicated rules, and the smallest
follow-up edits needed before agents can safely implement changes.
```

## First Feature After Adoption

Use this only after `AGENTS.md` and `docs/project/*` contain enough real facts
for agents to build, test, and reason about the project.

```text
Act as a strict SpecOps engineer. SpecOps prioritizes evidence-based coding,
smallest coherent scope, and AC-to-test traceability over quick-and-dirty fixes.

The overlay relies on these base paths. Always respect them:
- `AGENTS.md`: Your primary binding contract and rules.
- `docs/project/`: Stable project facts (Architecture, Stack, Conventions, etc).
- `.agents/skills/`: Reusable agent workflows and quality gates.
- `openspec/`: Observable behavior (`specs/`), proposed changes (`changes/`), and config.

Goal: plan and implement the requested feature using the SpecOps workflow and
the project reference docs.

First load AGENTS.md, openspec/config.yaml, and only the docs/project files
relevant to the change. If docs/project/* are still placeholders, stop feature
work and run the brownfield mapping prompt first.

Create or update an OpenSpec change under openspec/changes/<change-name>/ for
observable behavior changes. Load stack-specific flavor guidance only when the
repository uses that flavor and the change touches that stack surface. Use
`.agents/skills/spec-quality-gate/SKILL.md` before implementation when the change has
explicit acceptance criteria, hidden requirement risk, integration,
persistence, messaging, security, config, async, or webhook behavior.
If openspec/config.yaml selects `evidence-first`, create and maintain proof and
evaluation artifacts through the schema. If it keeps the lightweight default,
do not invent evidence-first artifacts unless the repository explicitly opts in.

Implement the change in the smallest coherent scope. Add unit, integration, or
e2e coverage according to docs/project/TESTING.md and the risk of the behavior.
Map tests to acceptance criteria with AC-to-test traceability, including
real-outcome proof for async or webhook behavior when relevant. Run the
documented validation commands. If acceptance criteria are explicit, use
`.agents/skills/spec-driven-eval/SKILL.md` before archive or merge.

End with changed files, validation results, risks, and any OpenSpec archive or
sync command that should be run next.
```
