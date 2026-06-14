# Coding Patterns

Implementation guidance for Java/Quarkus services. Use this document when
creating or changing resources, services, repositories, entities, DTOs,
validation, transactions, and tests.

For module layout and boundary decisions, load
`flavors/java-quarkus/skills/modular-architecture/SKILL.md`.

## Resource Pattern

JAX-RS resources expose HTTP contracts. They should stay thin.

Rules:

- Put routing, request validation, authentication context extraction, response
  status mapping, and DTO mapping in resources.
- Put business decisions, orchestration, persistence calls, and external calls
  in services.
- Inject services, facades, or use-case objects. Do not inject repositories into
  resources.
- Keep resource methods short enough to read at a glance. If a method starts
  branching on business rules, move that logic to a service.
- Use Bean Validation on request DTOs and method parameters.

Good:

```java
@Path("/subscriptions")
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
public class SubscriptionResource {
    private final SubscriptionService subscriptionService;

    public SubscriptionResource(SubscriptionService subscriptionService) {
        this.subscriptionService = subscriptionService;
    }

    @POST
    @Transactional
    public Response create(@Valid CreateSubscriptionRequest request) {
        SubscriptionResponse response = subscriptionService.create(request);
        return Response.status(Response.Status.CREATED).entity(response).build();
    }
}
```

Avoid:

```java
@POST
public Response create(CreateSubscriptionRequest request) {
    var plan = planRepository.findById(request.planId());
    if (plan == null || !plan.isActive()) {
        throw new WebApplicationException(404);
    }
    var entity = new SubscriptionEntity();
    entity.userId = request.userId();
    entity.plan = plan;
    subscriptionRepository.persist(entity);
    return Response.ok(entity).build();
}
```

## Service Pattern

Services own business behavior for an aggregate or workflow.

Rules:

- Name service methods after business actions, not CRUD mechanics.
- Use repositories through business-meaningful methods.
- Keep ORM-specific query syntax out of services.
- Keep HTTP, JSON, vendor SDK, and messaging details out of services unless the
  service is explicitly an adapter/client.
- Use transactions at the service boundary when a business operation writes
  state.
- Prefer clear domain exceptions over returning `null` for business failures.

Good service method names:

```java
activateTrial(...)
cancelAtPeriodEnd(...)
recordSuccessfulPayment(...)
findOpenInvoicesForCustomer(...)
```

Avoid names that leak implementation:

```java
queryWithFilter(...)
updateEntity(...)
findOneWithRelations(...)
```

## Repository Pattern

Repositories encapsulate persistence. They may use Hibernate ORM, Panache,
JPA Criteria, JPQL, native SQL, or another persistence tool internally, but
callers should see business-meaningful methods.

Rules:

- Keep `EntityManager`, Panache queries, JPQL, Criteria API, native SQL, and
  fetch strategy details inside repositories or persistence adapters.
- Do not expose `Query`, `EntityManager`, Panache `PanacheQuery`, or raw result
  sets to services.
- Return domain-relevant types: entity, optional entity, list/page, projection,
  or count.
- Name methods by business intent.
- Add indexes/migrations when new query methods need them.
- Avoid `listAll()` or unbounded `find()` from request paths.

Example:

```java
@ApplicationScoped
public class SubscriptionRepository implements PanacheRepositoryBase<SubscriptionEntity, UUID> {
    public Optional<SubscriptionEntity> findActiveByUserId(UUID userId) {
        return find("userId = ?1 and status = ?2", userId, SubscriptionStatus.ACTIVE)
                .firstResultOptional();
    }

    public List<SubscriptionEntity> findRenewingBefore(Instant cutoff, int limit) {
        return find("status = ?1 and renewsAt < ?2", Sort.by("renewsAt"), SubscriptionStatus.ACTIVE, cutoff)
                .page(0, limit)
                .list();
    }
}
```

Avoid:

```java
public PanacheQuery<SubscriptionEntity> query(String whereClause) {
    return find(whereClause);
}
```

## Transaction Management

Quarkus uses `@Transactional` for imperative transaction boundaries. Put write
transactions around complete business operations, usually on service methods or
short resource methods that delegate to a single service.

Rules:

- Apply `@Transactional` to methods that create, update, delete, or coordinate
  multiple writes.
- Prefer one outer transaction per business operation.
- Do not add transactions to pure reads unless consistency requirements justify
  it.
- Do not perform slow remote calls inside an open database transaction when the
  operation can be split safely.
- For reactive code, use the transaction mechanism that matches the reactive
  persistence stack instead of imperative `@Transactional`.

Example:

```java
@ApplicationScoped
public class InvoiceService {
    private final InvoiceRepository invoiceRepository;
    private final PaymentRepository paymentRepository;

    public InvoiceService(InvoiceRepository invoiceRepository, PaymentRepository paymentRepository) {
        this.invoiceRepository = invoiceRepository;
        this.paymentRepository = paymentRepository;
    }

    @Transactional
    public InvoiceResponse markPaid(UUID invoiceId, PaymentReceipt receipt) {
        InvoiceEntity invoice = invoiceRepository.requireOpen(invoiceId);
        PaymentEntity payment = PaymentEntity.from(receipt);
        paymentRepository.persist(payment);
        invoice.markPaid(payment.id);
        return InvoiceResponse.from(invoice);
    }
}
```

## Entities and Persistence Ownership

Entities belong to one module. A module owns its tables, migrations, and
repository access.

Rules:

- Use table names that include module/context ownership when ambiguity is
  likely, e.g. `billing_subscription`, `identity_user`.
- Do not let one module write another module's tables directly.
- Avoid shared mutable tables across modules.
- Keep persistence-only fields out of response DTOs unless they are part of the
  public contract.
- Model enums and lifecycle states explicitly.
- Use optimistic locking (`@Version`) when concurrent updates matter.
- Validate migration generation and rollback/repair procedures with the
  project's Flyway or Liquibase workflow.

Example:

```java
@Entity
@Table(name = "billing_subscription")
public class SubscriptionEntity {
    @Id
    public UUID id;

    @Column(nullable = false)
    public UUID userId;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    public SubscriptionStatus status;

    @Version
    public long version;
}
```

## DTOs and Validation

Rules:

- Use request/response DTOs for external contracts. Do not expose entities from
  resources.
- Prefer Java records for immutable DTOs when they fit the project style.
- Put Bean Validation annotations on request DTOs.
- Keep internal command/result types separate from public API DTOs when the
  shapes diverge.
- Validate at the boundary, then enforce business invariants in services.

Example:

```java
public record CreateSubscriptionRequest(
        @NotNull UUID userId,
        @NotNull UUID planId,
        @Min(1) @Max(90) int trialDays
) {
}
```

## Error Handling

Rules:

- Throw domain exceptions from services.
- Map domain exceptions to HTTP responses in exception mappers.
- Do not throw `WebApplicationException` from deep domain services.
- Include stable error codes for client-actionable errors.
- Do not leak stack traces, SQL, credentials, or vendor error payloads to
  clients.

Example:

```java
@Provider
public class DomainExceptionMapper implements ExceptionMapper<DomainException> {
    @Override
    public Response toResponse(DomainException exception) {
        return Response.status(exception.status())
                .entity(new ErrorResponse(exception.code(), exception.getMessage()))
                .build();
    }
}
```

## Testing

Use the smallest test type that gives confidence, then add integration coverage
for externally observable behavior.

Rules:

- Unit-test business rules in services and pure domain objects, including edge
  cases that drive important state decisions.
- Use `@QuarkusTest` for HTTP, CDI, persistence, transactions, security, and
  configuration behavior.
- Use Testcontainers, Dev Services, WireMock, MockServer, or project-standard
  equivalents for real integration boundaries.
- Cover happy paths and important edge/error cases.
- For new endpoints, include at least one integration/e2e test for the success
  path and at least one meaningful failure path.
- Assert observable behavior, not only status codes.
- For async, scheduled, message-driven, or webhook state changes, assert the
  real stored state, durable emitted event, or equivalent observable outcome.
- Mock-only tests may prove local mapping or error translation, but not final
  business outcomes.
- When OpenSpec artifacts exist, map tests to acceptance criteria and the
  planned proof matrix.
- Avoid sleeps in tests. Use Awaitility or deterministic synchronization for
  async flows.

Common commands to discover in a project:

```text
./mvnw -q test
./mvnw -q verify
./mvnw -q package
./gradlew test
./gradlew check
```

## Quick Review Checklist

- Resource injects service/facade, not repository.
- Business rules live outside HTTP resources.
- Services do not import or expose ORM query details.
- Repositories have business-meaningful method names.
- Writes have a clear transaction boundary.
- Entities/tables have clear module ownership.
- DTOs protect the public API from persistence internals.
- Validation covers request shape; services enforce invariants.
- Important behavior has unit and integration/e2e coverage.
