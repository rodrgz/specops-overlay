## 1. <Task Group Name>

- [ ] 1.1 <Task description>
  Maps to: `REQ-001-AC-001`
  Files: `<planned files>`
  Tests: `<test command or review check>`
  Gate: `<quick|full|build|docs|security|OpenSpec verify|evaluation>`
  Done when: <observable completion condition>

- [ ] 1.2 <Task description>
  Maps to: `REQ-001-AC-002`
  Files: `<planned files>`
  Tests: `<test command or review check>`
  Gate: `<quick|full|build|docs|security|OpenSpec verify|evaluation>`
  Done when: <observable completion condition>

## 2. Validation

- [ ] 2.1 Run mapped validation
  Maps to: engineering gate
  Files: `<changed files or n/a>`
  Tests: `<commands>`
  Gate: full
  Done when: validation passes or unavailable checks are explicitly recorded.

## Task Rules

- Keep every checkbox parseable as `- [ ]`.
- Keep RED/GREEN proof when code behavior changes and a failing test can be run.
- Do not delete, skip, weaken, or lower test scope merely to pass validation.
- Mark unavailable validation as unavailable, not passing.
