---
name: spec-quality-gate
description: Audits OpenSpec specs and task plans before implementation when a change has explicit ACs, hidden requirement risk, external integrations, persistence, messaging, security, or async behavior.
license: CC-BY-4.0
adapted_from: tech-leads-club/agent-skills
metadata:
  version: 1.0.0
---

# Spec Quality Gate

Use this skill before implementation when an OpenSpec change has explicit
acceptance criteria or materially touches persistence, messaging, external
integrations, security, configuration, async workflows, scheduled work, or
webhook behavior.

Do not use it for trivial documentation-only changes, pure refactors with no
behavioral ACs, or PR review.

For risky surfaces, the gate is default-on. Skipping it requires a recorded
opt-out rationale in the proposal, design, or task notes that names why no AC
proof, hidden-requirement review, or test strategy decision is needed.
Change size cannot be used as the opt-out rationale for persistence, messaging,
external integration, security, configuration, async, scheduled, webhook, or
explicit-AC changes.

## Load Only Relevant Context

Load the smallest useful set:

1. `AGENTS.md` and `openspec/config.yaml`.
2. The relevant OpenSpec change files under `openspec/changes/<change-name>/`.
3. Only the `docs/project/*` files needed for the behavior under review.
4. Reference files in this skill that match the risk:
   - `references/implicit-requirements.md`
   - `references/ac-proof-matrix.md`
   - `references/test-strategy.md`
   - `references/scope-discipline.md`
5. Domain guidance from the selected flavor, such as
   `flavors/java-quarkus/docs/CODING-PATTERNS.md` or
   `flavors/java-quarkus/docs/INTEGRATION-PATTERNS.md`, only when the planned
   change uses it.

Do not load every skill or every project document by default.

## Process

1. Inventory all stories, requirements, and ACs with stable IDs and priorities.
2. Freeze AC interpretation before task execution: resolve ambiguity, record a
   scoped assumption, or mark the AC `unknown`/blocked.
3. Run the implicit requirements checklist for relevant risks.
4. Build or review the AC proof matrix.
5. Confirm the planned test levels match the behavior to prove.
6. Check scope discipline: every planned file, endpoint, job, event, config,
   and test must map to an AC, sanctioned implicit risk, or documented
   engineering gate.
7. Decide the gate result.

## Gate Result

Return one of:

- `pass`: implementation may proceed; ACs, implicit risks, scope decisions, and
  proof tasks are clear enough.
- `partial`: implementation may proceed only for explicitly scoped items; list
  unknowns, assumptions, and deferred proof.
- `fail`: stop or clarify before implementation because a reasonable scoped
  assumption would be risky.

## Output Format

```markdown
## Spec Quality Gate

Result: pass | partial | fail

### Requirement Inventory
| Story | Priority | AC ID | Scope | Notes |
| --- | --- | --- | --- | --- |

### AC Interpretation Freeze
| AC ID | Frozen interpretation | Status | Rationale |
| --- | --- | --- | --- |

### Implicit Requirement Decisions
| Concern | Outcome | Rationale | Follow-up |
| --- | --- | --- | --- |

### AC Proof Matrix
Use `references/ac-proof-matrix.md`.

### Test Strategy
| AC ID | Required levels | Real outcome needed? | Rationale |
| --- | --- | --- | --- |

### Scope Check
| Planned item | Mapped to | Status |
| --- | --- | --- |

### Blocking Questions
- `<only questions that cannot be safely scoped>`
```

## Rules

- Never authorize scope expansion. Mark new product ideas as `out of scope`.
- Hidden requirements can be sanctioned only when tied to an AC, documented
  project risk, or a necessary engineering gate.
- Ambiguous AC wording must not drift during implementation. Freeze the
  interpretation before execution or mark the AC `unknown`/blocked.
- Ask for clarification only when a reasonable scoped assumption would be
  risky.
- Preserve OpenSpec's low ceremony: compact tables beat long narrative.
