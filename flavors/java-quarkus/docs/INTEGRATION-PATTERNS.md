# Integration Patterns

Patterns for external services, messaging, observability, resilience, and
security in Java/Quarkus services.

For package layout and module boundaries, load
`flavors/java-quarkus/skills/modular-architecture/SKILL.md`.

## External Client Encapsulation

External integration details belong in clients/adapters. Domain services should
call business operations, not assemble HTTP requests or vendor SDK payloads.

Client owns:

- Base URLs, paths, headers, authentication, and timeouts.
- Vendor request/response mapping.
- Vendor error translation.
- Retry, timeout, and circuit-breaker annotations or policies.
- Logging and metrics for the external call.

Service owns:

- Business decision to call the external dependency.
- Handling of domain-level success/failure.
- Persistence of local state.

Example with MicroProfile REST Client:

```java
@RegisterRestClient(configKey = "payment-gateway")
@RegisterProvider(PaymentGatewayExceptionMapper.class)
public interface PaymentGatewayApi {
    @POST
    @Path("/charges")
    ChargeResponse createCharge(ChargeRequest request);
}

@ApplicationScoped
public class PaymentGatewayClient {
    private final PaymentGatewayApi api;

    public PaymentGatewayClient(@RestClient PaymentGatewayApi api) {
        this.api = api;
    }

    @Timeout(3000)
    @Retry(maxRetries = 2, delay = 100)
    @CircuitBreaker(requestVolumeThreshold = 20, failureRatio = 0.5, delay = 10000)
    public PaymentResult charge(InvoiceEntity invoice) {
        ChargeResponse response = api.createCharge(ChargeRequest.from(invoice));
        return PaymentResult.from(response);
    }
}
```

Avoid:

```java
public class InvoiceService {
    public void pay(UUID invoiceId) {
        // Avoid URLs, auth headers, JSON mapping, and vendor errors in services.
        httpClient.post(baseUrl + "/charges", headers, body);
    }
}
```

## Configuration

Rules:

- Use Quarkus configuration mapping for structured configuration.
- Do not read arbitrary environment variables throughout business code.
- Keep secrets in secret managers, deployment config, or local ignored files.
- Validate required configuration at startup when missing values would break
  runtime behavior.

Example:

```java
@ConfigMapping(prefix = "payment-gateway")
public interface PaymentGatewayConfig {
    URI baseUrl();
    Optional<String> apiKey();
    Duration timeout();
}
```

## Dependency Injection

Default to direct CDI injection when there is one concrete implementation.
Introduce interfaces/ports when replacement, testing, or boundary clarity is a
real requirement.

Rules:

- Use constructor injection for required dependencies.
- Avoid static access to CDI beans, config, clocks, or clients.
- Use qualifiers when multiple implementations are valid.
- Keep adapters at the edge; services should depend on ports only when the
  boundary matters.

Example:

```java
public interface TaxCalculator {
    TaxQuote quote(TaxRequest request);
}

@ApplicationScoped
@Named("external-tax")
public class ExternalTaxCalculator implements TaxCalculator {
    ...
}
```

## Messaging and Events

Use events for cross-module or cross-service communication when synchronous
coupling is not required.

Rules:

- Events should describe facts that already happened.
- Commands should request work and need an owner.
- Event payloads must be versionable and contain enough data to avoid immediate
  cross-module reads.
- Consumers must be idempotent.
- Persist state changes and emitted events consistently. Use an outbox pattern
  when message loss would be harmful.
- Do not use in-memory events for durable business workflows.
- When two messages or requests can create the same business outcome, add a
  concurrency safeguard such as a unique key, optimistic lock, or idempotency
  record.

Example event contract:

```java
public record SubscriptionActivatedEvent(
        UUID eventId,
        UUID subscriptionId,
        UUID userId,
        Instant occurredAt,
        int schemaVersion
) {
}
```

## Resilience

Rules:

- Set explicit timeouts for all external calls.
- Retry only idempotent or safely repeatable operations.
- Use idempotency keys or equivalent request identity for repeatable external
  mutations.
- Use circuit breakers for unstable dependencies.
- Use bulkheads or worker pools for high-latency integrations when needed.
- Define fallback behavior intentionally. Silent fallback can corrupt business
  decisions.
- Do not hold database transactions open while waiting on slow remote calls
  unless consistency requirements demand it.
- Translate transient dependency failures into stable typed error contracts
  when clients can act on them.

Recommended annotations when the project uses SmallRye Fault Tolerance:

```java
@Timeout(2000)
@Retry(maxRetries = 2)
@CircuitBreaker(requestVolumeThreshold = 10, failureRatio = 0.5)
```

## Observability

Logs, metrics, and traces should identify module, operation, outcome, and
correlation context.

Logging rules:

- Log business events at `INFO`.
- Log expected validation failures at low severity or not at all, depending on
  project policy.
- Log external dependency failures with dependency name, operation, status, and
  latency.
- Keep observability for external failures bounded: record dependency,
  operation, outcome, correlation ID, and safe error code without high-cardinality
  labels.
- Never log secrets, tokens, full payment data, passwords, or sensitive PII.
- Prefer structured logs when the project supports them.

Metrics rules:

- Add counters for important business outcomes.
- Add timers/histograms for request handlers and external calls.
- Keep label cardinality bounded. Do not use user IDs, emails, UUIDs, or raw
  paths as metric labels.
- Expose module-specific health/readiness checks for required dependencies.

Tracing rules:

- Preserve correlation IDs across inbound requests, outbound calls, and
  messages.
- Add spans around meaningful external integrations and long-running internal
  operations.

## Security

Rules:

- Require authentication and authorization on protected resources.
- Prefer role/permission annotations near the endpoint when the rule is
  endpoint-specific.
- Validate all inbound DTOs.
- Treat all external payloads as untrusted.
- Redact PII and secrets from logs, errors, metrics, traces, and test fixtures.
- Do not expose internal entity fields or vendor errors in API responses.
- Keep CORS restrictive and environment-specific.
- Use parameterized queries or repository APIs. Never concatenate untrusted
  input into SQL/JPQL.
- Validate webhook signatures before parsing or routing event payloads.
- Route webhook events through explicit event-type handling and ignore or reject
  unsupported event types intentionally.

Example:

```java
@GET
@Path("/{id}")
@RolesAllowed("billing:read")
public InvoiceResponse get(@PathParam("id") UUID id) {
    return invoiceService.getInvoice(id);
}
```

## External API Testing

Rules:

- Unit-test mapping logic and error translation.
- Integration-test clients with WireMock, MockServer, Dev Services, or the
  project-standard equivalent.
- Assert timeout/retry/failure behavior when it is part of the contract.
- Assert typed error responses for transient failures when they are part of the
  public contract.
- For webhook flows, test signature validation, event routing, and the real
  persisted or durable outcome of the event.
- Keep vendor sandbox calls out of the default test suite unless the project has
  a dedicated profile for them.
- Mock external systems at the edge. Do not mock the service method whose
  behavior you are trying to verify.

## Anti-Patterns

- Service classes building raw URLs and headers.
- Vendor DTOs leaking into domain models or public API DTOs.
- Retrying non-idempotent payment or mutation calls without idempotency keys.
- Catching all exceptions and returning success.
- In-memory events for durable workflows.
- Logging full request/response payloads that may contain sensitive data.
- Unbounded metric labels.
- Cross-module reads through another module's repositories instead of a public
  API, facade, or event-carried state.
