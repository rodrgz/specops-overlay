---
name: pr-review
description: Multi-perspective PR review workflow for software projects. Use only when explicitly asked to review a pull request, code review a PR, or check PR changes. Do not use for implementation, debugging, planning, or general code questions.
license: CC-BY-4.0
adapted_from: tech-leads-club/agent-skills
metadata:
  version: 1.1.0
---

# PR Review

Review a pull request through specialized perspectives, then consolidate the
findings into a single actionable summary. The workflow is tool-agnostic: use
the available PR/diff tools in the environment.

## Inputs

Required:

- PR number, branch, or diff.
- Repository context.

Useful when available:

- PR title and description.
- Linked issue or ticket.
- Product spec, acceptance criteria, ADR, or task checklist.
- Project docs such as `AGENTS.md`, `docs/project/*`, architecture docs, and
  test docs. Stack-specific coding, integration, and hardening patterns from
  the applicable flavor when present.
- Existing review comments.

## Initialize

1. Identify the PR or diff to review.
2. Confirm the PR is open and has code changes.
3. Fetch the changed files and full diff.
4. Fetch existing inline comments when the platform supports it, so duplicates
   can be avoided.
5. Read PR title/body to infer intent.
6. Locate project docs:
   - Agent instructions: `AGENTS.md`
   - Project reference: `docs/project/*`
   - Stack-specific patterns: `openspec/specops/flavors/<id>/docs/*` when a flavor is active
   - Architecture docs: `docs/project/ARCHITECTURE.md` and selected flavor
     architecture skill, such as
     `openspec/specops/flavors/java-quarkus/skills/modular-architecture/SKILL.md`
   - Test docs: `docs/project/TESTING.md`, `CONTRIBUTING.md`
   - Specs: `.specs/`, `specs/`, `docs/specs/`, markdown links in the PR body
7. If the diff is very large, warn that confidence may be lower and review by
   module if practical.

Abort when:

- The PR/diff cannot be read.
- The PR is closed or merged and the user asked for active review only.
- The diff is empty.
- Required authentication for the requested PR platform is missing.

## Universal Review Rules

- Prioritize bugs, security issues, regressions, missing tests, and violations
  of documented project rules.
- Only comment on changed lines when posting inline comments.
- Skip duplicate comments within a few lines of an existing comment.
- Use at least 80 percent confidence before reporting a finding.
- Quote or reference exact evidence from the diff.
- Explain impact and give a specific recommendation.
- Do not approve, request changes, merge, push, or modify files unless the user
  separately asks for that action.
- If a dimension finds no issues, say so in the consolidation summary.

## Severity Labels

- Critical: likely bug, broken requirement, data corruption, failing path.
- Security: vulnerability, sensitive data exposure, auth/authz issue.
- Performance: significant latency, load, query, concurrency, or resource issue.
- Warning: maintainability, architecture, test, or operability risk.
- Suggestion: optional improvement.

## Review Dimensions

Run these perspectives in parallel when subagents are available. Otherwise,
review them sequentially.

### 1. Security

Focus:

- Missing authentication or authorization.
- Sensitive fields exposed in responses or logs.
- Hardcoded secrets or credentials.
- Injection vulnerabilities through string concatenation or unsafe input.
- Unsafe deserialization.
- Overly permissive CORS.
- Missing validation on inbound data.
- Internal errors or stack traces exposed to clients.

Use project security/integration docs when present.

Comment format:

```markdown
<!-- ai-review:security -->
Security - <short title>
<issue and impact>
Recommendation: <specific fix>
```

### 2. Requirements and Definition of Done

Find requirement sources in this order:

1. PR body checklists and acceptance criteria.
2. Linked spec files in the repo.
3. Linked issue/ticket content when the environment provides access.
4. Branch name or commit references that map to local spec files.

Compare each requirement with the diff.

Output a PR-level summary, not inline comments, unless a missing requirement has
an exact changed line as evidence.

Summary format:

```markdown
<!-- ai-review:requirements -->
## Requirements Review

Sources: <files, PR body, ticket, or "none found">

### Implemented
### Missing or Incomplete
### Definition of Done
- [ ] build/static checks considered
- [ ] unit tests considered
- [ ] integration/e2e tests considered

### Notes
```

If no requirements are found, state that requirements verification was skipped.

### 3. Integration/E2E Test Coverage

Focus:

- New or changed endpoints without integration/e2e tests.
- Persistence behavior not tested through integration tests.
- Missing negative/error tests for important paths.
- External client behavior not covered with mocks, stubs, test containers, or
  project-equivalent test infrastructure.
- Flaky sleeps instead of deterministic waits.
- Tests that only assert status code and not response/body/state.

Comment format:

```markdown
<!-- ai-review:e2e -->
<severity> - <short title>
<gap or risk>
Recommendation: <specific test to add>
```

### 4. Architecture and Coding Patterns

Load available project docs and extract explicit rules before reviewing.

Evaluate:

- Module/package boundary violations.
- Handler/controller classes with business logic.
- Persistence layer injected directly into handlers/controllers.
- Services importing persistence-specific internals.
- Cross-module internal imports.
- Shared business logic under generic shared/common packages.
- Facades or interfaces containing business logic or exposing persistence
  internals.
- Transaction/persistence boundaries for writes.
- Data transfer/entity separation.

Comment format:

```markdown
<!-- ai-review:architecture -->
<severity> - <short title>
Rule: <doc/rule if available>
<evidence and impact>
Recommendation: <specific fix>
```

### 5. Regression and Generated-Code Artifacts

Focus:

- Unrelated deletions or behavior changes.
- Phantom imports or calls to non-existent methods.
- Wrong method signatures.
- Duplicate logic that already exists.
- Weakened validation or error handling.
- Weakened test assertions.
- TODO/FIXME in production code without tracking context.
- Broad suppression annotations or unchecked casts without justification.
- Dead code introduced by the PR.

Comment format:

```markdown
<!-- ai-review:regression -->
<severity> - <short title>
Type: <unrelated-deletion | phantom-import | duplicate | regression | dead-code>
<evidence and impact>
Recommendation: <specific fix>
```

### 6. Performance and Reliability

Focus:

- N+1 queries or data fetching calls inside loops.
- Unbounded queries on request paths.
- Missing pagination.
- Slow external calls inside persistence transactions.
- Sequential independent remote calls that can be combined safely.
- Missing timeout, retry, circuit breaker, or idempotency for external calls.
- Blocking work on async/event-loop paths without justification.
- Inefficient batch operations.

Comment format:

```markdown
<!-- ai-review:performance -->
Performance - <short title>
<issue and likely impact>
Recommendation: <specific fix>
```

## Consolidation

After all dimensions finish:

1. Group findings by severity: Security, Critical, Performance, Warning,
   Suggestion.
2. Deduplicate findings on the same file/line.
3. Include requirement coverage status.
4. Include docs loaded and commands inspected/run.
5. List changed logic files that received no findings, so the user knows what
   was reviewed but clean.
6. Call out any review dimension that could not complete.

Summary format:

```markdown
## AI Review Summary

| Field | Value |
| --- | --- |
| Scope | <PR/diff> |
| Review dimensions | <completed/total> |
| Project docs loaded | <list or none> |
| Findings | <count> |

### Security
### Critical
### Performance
### Warnings
### Suggestions

### Requirements
<summary>

### Files Reviewed With No Findings
- <path>

### Residual Risk
- <tests not run, docs missing, diff too large, or access limitations>
```

If there are no findings, say: `No issues found across the reviewed
dimensions.` Then list residual risk and tests not run.

## Platform Commands

Use the platform available in the environment. Examples:

GitHub CLI:

```bash
gh pr view <number> --json title,body,state,headRefName
gh pr diff <number>
gh pr diff <number> --name-only
gh api repos/<owner>/<repo>/pulls/<number>/comments
```

Plain git:

```bash
git diff origin/main...HEAD
git diff --name-only origin/main...HEAD
git log --oneline origin/main..HEAD
```

Do not assume either tool is authenticated. If access fails, report the blocker
and continue with any local diff the user provides.
