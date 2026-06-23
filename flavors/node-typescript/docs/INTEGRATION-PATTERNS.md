# Integration Patterns

Patterns for external services, messaging, observability, resilience, and
security in Node.js and TypeScript backends.

For package layout and module boundaries, load
`openspec/specops/flavors/node-typescript/skills/modular-architecture/SKILL.md`.

## External Client Encapsulation

External integration details belong in clients or adapters. Domain services
should call business operations, not assemble HTTP requests or SDK payloads.

Client owns:

- Base URLs, paths, headers, authentication, and timeouts.
- Vendor request and response mapping.
- Vendor error translation.
- Retry, timeout, and circuit-breaker policies.
- Logging and metrics for the external call.

Service owns:

- The business decision to call the dependency.
- Handling of domain-level success or failure.
- Persistence of local state.

Example:

```typescript
@Injectable()
export class ShippingClient {
  constructor(
    private readonly http: HttpService,
    private readonly config: ConfigService,
  ) {}

  async createShipment(request: ShipmentRequest): Promise<ShipmentResult> {
    const response = await firstValueFrom(
      this.http.post('/shipments', request, {
        baseURL: this.config.getOrThrow('shipping.baseUrl'),
        timeout: 2500,
      }),
    );

    return ShipmentResult.fromVendor(response.data);
  }
}
```

Avoid putting URLs, auth headers, vendor DTOs, or retry decisions in domain
services.

## Configuration

Rules:

- Use one project-standard configuration mechanism: NestJS ConfigService,
  environment schema validation, typed config modules, or equivalent.
- Validate required configuration at startup when missing values would break
  runtime behavior.
- Do not read arbitrary environment variables throughout business code.
- Keep secrets in deployment config, secret managers, or ignored local files.
- Keep feature flags, provider names, and timeout values typed and documented.

Example:

```typescript
const configSchema = z.object({
  SHIPPING_BASE_URL: z.string().url(),
  SHIPPING_TIMEOUT_MS: z.coerce.number().int().positive().default(2500),
});
```

## Dependency Injection

Default to direct injection when there is one concrete implementation.
Introduce interfaces or symbol tokens when replacement, testing, or boundary
clarity is a real requirement.

Rules:

- Use constructor injection for required dependencies.
- Avoid static access to config, clients, clocks, and loggers.
- Use provider tokens when multiple implementations are valid.
- Keep adapters at the edge; services should depend on ports only when the
  boundary matters.

Example:

```typescript
export interface TaxQuotePort {
  quote(request: TaxQuoteRequest): Promise<TaxQuote>;
}

export const TaxQuotePort = Symbol('TaxQuotePort');
```

## Events, Queues, and Jobs

Use events for facts that already happened. Use commands or jobs when another
owner should perform work.

Rules:

- Prefer durable brokers or queues for production workflows.
- Use in-memory events only for local coordination or tests unless the project
  explicitly accepts data-loss risk.
- Payloads must be typed, versionable, and stable enough for consumers.
- Consumers must be idempotent.
- Persist state changes and emitted messages consistently. Use an outbox
  pattern when message loss would be harmful.
- Use idempotency keys, unique constraints, or locks when duplicate delivery can
  create duplicate outcomes.

Example event contract:

```typescript
export interface OrderPlacedEvent {
  eventId: string;
  orderId: string;
  accountId: string;
  occurredAt: string;
  schemaVersion: 1;
}
```

## Resilience

Rules:

- Set explicit timeouts for all external calls.
- Retry only idempotent or safely repeatable operations.
- Use idempotency keys for repeatable external mutations.
- Use circuit breakers, bulkheads, queues, or degraded behavior for unstable
  dependencies where the project supports them.
- Define fallback behavior intentionally. Silent fallback can corrupt business
  decisions.
- Do not hold database transactions open while waiting on slow remote calls
  unless consistency requirements demand it.
- Translate transient dependency failures into stable typed errors when clients
  can act on them.

Example retry policy:

```typescript
const retryPolicy = {
  retries: 2,
  minTimeout: 100,
  maxTimeout: 1000,
  factor: 2,
};
```

## Observability

Logs, metrics, and traces should identify module, operation, outcome, and
correlation context.

Logging rules:

- Log important business events at `info`.
- Log expected validation failures at low severity or not at all, depending on
  project policy.
- Log external dependency failures with dependency name, operation, status, and
  latency.
- Keep labels and log fields bounded. Do not use user IDs, emails, UUIDs, raw
  paths, or arbitrary request values as metric labels.
- Never log secrets, tokens, passwords, payment data, or sensitive PII.
- Prefer structured logs when the project supports them.

Metrics rules:

- Add counters for important business outcomes.
- Add timers or histograms for request handlers and external calls.
- Expose health/readiness checks for required dependencies.

Tracing rules:

- Preserve correlation IDs across inbound requests, outbound calls, and
  messages.
- Add spans around meaningful external integrations and long-running internal
  operations.

## Webhooks

Rules:

- Validate signatures before parsing or routing webhook events.
- Use the raw request body when the provider signature algorithm requires it.
- Route by explicit event type.
- Ignore, reject, or dead-letter unsupported event types intentionally.
- Make event handling idempotent.
- Assert the durable final outcome in tests, not only the HTTP response.

## Security

Rules:

- Require authentication and authorization on protected handlers.
- Keep endpoint-specific authorization close to the boundary when the framework
  supports guards, middleware, decorators, or policies.
- Validate all inbound DTOs and schemas.
- Treat all external payloads as untrusted.
- Redact secrets and sensitive PII from logs, errors, metrics, traces, and test
  fixtures.
- Do not expose internal entity fields or vendor errors in API responses.
- Keep CORS restrictive and environment-specific.
- Use parameterized queries or repository APIs. Never concatenate untrusted
  input into SQL or query strings.

## External API Testing

Rules:

- Unit-test mapping logic and error translation.
- Integration-test clients with Nock, MSW, WireMock, Testcontainers, or the
  project-standard equivalent.
- Assert timeout, retry, and failure behavior when it is part of the contract.
- For webhook flows, test signature validation, event routing, idempotency, and
  the real durable outcome.
- Keep vendor sandbox calls out of default test suites unless the project has a
  dedicated profile for them.

## Anti-Patterns

- Service classes building raw URLs and headers.
- Vendor DTOs leaking into domain models or public API DTOs.
- Retrying non-idempotent mutations without idempotency keys.
- Catching all errors and returning success.
- In-memory events for durable workflows.
- Logging full request or response bodies that may contain sensitive data.
