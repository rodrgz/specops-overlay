# Test Strategy Rules

Choose the smallest sufficient test set for each AC. Do not plan tests by
volume; plan them by the behavior that must be proved.

## Required Test Levels

| Behavior | Required proof |
| --- | --- |
| Pure service/domain rules | Unit tests for rule branches and edge cases. |
| HTTP contracts | Integration/e2e tests through the resource boundary. |
| Persistence and transactions | Integration/e2e tests that assert stored state and transaction effects. |
| Security and authorization | Integration/e2e tests for allowed and denied actors. |
| Configuration behavior | Integration/e2e or startup tests using documented profiles/config. |
| Messaging or events | Integration/e2e tests for consumed/emitted durable messages when the project supports it. |
| External client boundaries | Unit tests for mapping/error translation plus integration tests with WireMock, MockServer, Dev Services, or project-standard equivalents. |
| Async, scheduled, or webhook flows | Assertions against real persisted state, durable event records, or an equivalent observable outcome. |

## Mock-Only Limits

Mock-only tests are allowed for:

- request/response mapping;
- vendor error translation;
- retry/fallback branch selection;
- local adapter behavior when the real boundary is separately covered.

Mock-only tests are not sufficient for final business outcomes such as access
grants, cancellation, pause, status update, notification trigger emission, or
persistence consistency.

## Avoid Nice-To-Have Drift

- Prefer one focused unit test per meaningful service/domain rule branch.
- Prefer one integration/e2e success path and one meaningful failure path per
  new endpoint or external behavior, unless ACs require more.
- Add extra robustness tests only when they map to a documented risk.
- Record nice-to-have tests separately; they do not raise AC proof scores.
