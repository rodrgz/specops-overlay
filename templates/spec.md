# Spec: <capability>

This template is for behavior that belongs under
`openspec/changes/<change-id>/specs/<capability>/spec.md` or
`openspec/specs/<capability>/spec.md`.

Use stable IDs:

- Requirements: `REQ-001`
- Acceptance criteria: `REQ-001-AC-001`
- Scenarios: `SCN-001`

## ADDED Requirements

### Requirement: <REQ-001 Requirement Name>

ID: `REQ-001`
Priority: `P0`

The system SHALL `<observable behavior>`.

#### Acceptance Criteria

| AC ID | Criterion | Required proof |
| --- | --- | --- |
| REQ-001-AC-001 | `<observable criterion>` | `<implementation and test proof expected>` |
| REQ-001-AC-002 | `<observable criterion>` | `<implementation and test proof expected>` |

#### Scenario: <SCN-001 Scenario Name>

- Given `<initial state or actor>`
- When `<action or event>`
- Then `<observable result>`
- And `<additional observable result, if needed>`

## MODIFIED Requirements

### Requirement: <REQ-002 Existing Requirement Name>

ID: `REQ-002`
Priority: `P0`

The system SHALL `<updated observable behavior>`.

#### Acceptance Criteria

| AC ID | Criterion | Required proof |
| --- | --- | --- |
| REQ-002-AC-001 | `<changed criterion>` | `<implementation and test proof expected>` |

#### Scenario: <SCN-002 Scenario Name>

- Given `<initial state or actor>`
- When `<action or event>`
- Then `<observable result>`

## REMOVED Requirements

### Requirement: <REQ-003 Removed Requirement Name>

ID: `REQ-003`
Priority: `P2`

The system SHALL NOT `<removed behavior>`.

#### Rationale

Explain why the behavior is removed or moved out of scope.

## Out Of Scope

| Item | Reason |
| --- | --- |
| `<behavior>` | `<why it is excluded from this change>` |
