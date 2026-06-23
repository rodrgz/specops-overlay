# Coding Patterns

Implementation guidance for Node.js and TypeScript backends. Use this document
when creating or changing handlers, controllers, resolvers, services,
repositories, models, DTOs, validation, transactions, and tests.

For module layout and boundary decisions, load
`openspec/specops/flavors/node-typescript/skills/modular-architecture/SKILL.md`.

## Handler, Controller, and Resolver Pattern

HTTP handlers, NestJS controllers, GraphQL resolvers, and queue processors are
boundary adapters. They should stay thin.

Rules:

- Put routing, request parsing, validation, auth context extraction, response
  mapping, and status mapping in boundary adapters.
- Put business decisions, orchestration, persistence calls, and external calls
  in services or use-case objects.
- Inject services, facades, or use-case objects. Do not inject repositories
  into controllers, resolvers, or HTTP route handlers.
- Keep methods short enough to read at a glance. Move business branching to a
  service.
- Use DTOs, schemas, or validators at the boundary. Enforce business invariants
  again in services.

Good:

```typescript
@Controller('orders')
export class OrderController {
  constructor(private readonly orderService: OrderService) {}

  @Post()
  async create(@Body() request: CreateOrderDto): Promise<OrderResponseDto> {
    const order = await this.orderService.createOrder(request);
    return OrderResponseDto.from(order);
  }
}
```

Avoid:

```typescript
@Post()
async create(@Body() request: CreateOrderDto) {
  const account = await this.accountRepository.findOneBy({ id: request.accountId });
  if (!account?.active) throw new NotFoundException();
  const order = await this.orderRepository.save(new Order(request));
  return order;
}
```

## Service Pattern

Services own business behavior for an aggregate or workflow.

Rules:

- Name service methods after business actions, not CRUD mechanics.
- Use repositories through business-meaningful methods.
- Keep ORM query syntax, SQL, GraphQL transport objects, HTTP details, and
  vendor SDK payloads out of services unless the service is explicitly an
  adapter.
- Put write transactions around complete business operations when the project
  uses transactional decorators, units of work, or request-scoped managers.
- Prefer domain-specific errors over `null`, `undefined`, or raw dependency
  errors for business failures.

Good service method names:

```typescript
createOrder(...)
approveAccount(...)
recordShipment(...)
findOpenOrdersForAccount(...)
```

Avoid names that leak implementation:

```typescript
queryWithFilter(...)
updateEntity(...)
findOneWithRelations(...)
```

## Repository and Persistence Pattern

Repositories and persistence adapters encapsulate database details. They may
use TypeORM, Prisma, Knex, Drizzle, Mongoose, raw SQL, or another persistence
tool internally, but callers should see business-meaningful methods.

Rules:

- Keep query builders, ORM operators, raw SQL, relation loading, and transaction
  manager details inside repositories or persistence adapters.
- Do not expose ORM repository instances, query builders, clients, cursors, or
  raw result sets to services.
- Return domain-relevant types: model/entity, optional model/entity, list,
  page, projection, or count.
- Name query methods by business intent.
- Add indexes or migration changes when new request-path queries need them.
- Avoid unbounded `findAll`, `listAll`, or full-table scans from request paths.

Example:

```typescript
@Injectable()
export class OrderRepository {
  constructor(private readonly dataSource: DataSource) {}

  async findOpenByAccountId(accountId: string): Promise<Order[]> {
    return this.dataSource.getRepository(Order).find({
      where: { accountId, status: OrderStatus.Open },
      order: { createdAt: 'DESC' },
      take: 100,
    });
  }

  async findReadyToShip(limit: number): Promise<Order[]> {
    return this.dataSource.getRepository(Order).find({
      where: { status: OrderStatus.ReadyToShip },
      order: { updatedAt: 'ASC' },
      take: limit,
    });
  }
}
```

Avoid:

```typescript
async query(where: FindOptionsWhere<Order>, relations: string[]) {
  return this.repository.find({ where, relations });
}
```

## ORM Leakage Prevention

Services should not contain persistence-library syntax.

Rules:

- Keep TypeORM operators, Prisma include/select trees, SQL fragments, Mongo
  filters, and relation names in repositories or adapters.
- Add repository methods when a service needs a new business query.
- Keep dependency-specific imports out of services unless the service is the
  adapter.

Good:

```typescript
const order = await this.orderRepository.findOpenByIdForAccount(orderId, accountId);
```

Avoid:

```typescript
const order = await this.orderRepository.findOne({
  where: { id: orderId, accountId, status: OrderStatus.Open },
  relations: ['lines', 'shipment'],
});
```

## Transactions

Write operations should use the project's documented transaction mechanism.

Rules:

- Apply one outer transaction to a complete business operation that writes
  state.
- Use explicit connection, datasource, tenant, or unit-of-work names in
  multi-database projects.
- Do not add transactions to pure reads unless consistency requirements demand
  it.
- Avoid slow remote calls inside an open database transaction when the operation
  can be split safely.
- Do not nest transaction decorators unless the project has a documented
  propagation policy.

Example:

```typescript
@Transactional({ connectionName: 'orders' })
async markShipped(orderId: string, shipmentId: string): Promise<Order> {
  const order = await this.orderRepository.requireReadyToShip(orderId);
  order.markShipped(shipmentId);
  return this.orderRepository.save(order);
}
```

## Models, Entities, and State Ownership

Durable state belongs to one module. A module owns its tables, collections,
migrations, repositories, and write paths.

Rules:

- Make table, collection, topic, and migration names reveal ownership when a
  shared database or broker is used.
- Do not let one module write another module's durable state directly.
- Avoid shared mutable tables or collections across modules.
- Keep persistence-only fields out of public response DTOs unless they are part
  of the contract.
- Model lifecycle states explicitly with enums or literal-union types.
- Use optimistic locking, unique keys, or idempotency records when concurrent
  writes can create duplicate outcomes.
- Generate migrations with the adopting project's documented workflow. Do not
  handwrite migrations when the project uses generated migrations.

## DTOs and Validation

Rules:

- Use request and response DTOs, schema objects, or contract types for external
  APIs. Do not expose persistence entities from handlers.
- Use `class-validator`, Zod, Valibot, TypeBox, or the project-standard
  validator at boundaries.
- Keep internal command/result types separate from public DTOs when the shapes
  diverge.
- Validate inbound data at the boundary, then enforce business invariants in
  services.
- Treat all parsed external data as untrusted.

Example:

```typescript
export class CreateOrderDto {
  @IsUUID()
  accountId!: string;

  @ArrayMinSize(1)
  @ValidateNested({ each: true })
  lines!: CreateOrderLineDto[];
}
```

## File Naming

Prefer aggregate-oriented folders and role suffixes over technical subfolders.

| Role | Suffix | Example |
| --- | --- | --- |
| Persistence model | `.entity.ts`, `.model.ts`, `.schema.ts` | `order.entity.ts` |
| Repository or adapter | `.repository.ts`, `.adapter.ts` | `order.repository.ts` |
| Business service | `.service.ts` | `order.service.ts` |
| Boundary adapter | `.controller.ts`, `.resolver.ts`, `.handler.ts`, `.processor.ts` | `order.controller.ts` |
| DTO or contract | `.dto.ts`, `.contract.ts`, `.types.ts` | `order.dto.ts` |
| Module facade | `.facade.ts` | `orders.facade.ts` |
| External client | `.client.ts` | `shipping.client.ts` |
| Tests | `.spec.ts`, `.test.ts`, `.e2e-spec.ts` | `order.service.spec.ts` |

Rules:

- Use kebab-case file and folder names unless the project documents another
  convention.
- Use PascalCase for classes, interfaces, enums, and decorators.
- Export only stable public contracts from module root indexes.
- Do not export repositories, entities, or internal services across module
  boundaries unless the project explicitly treats them as public API.

## Enum and Literal-Union Usage

Use named enum members or literal-union constants for finite state.

Rules:

- Prefer `OrderStatus.Open` or a typed constant over raw strings in production
  code and tests.
- Do not cast raw strings to enum types to silence TypeScript.
- Keep API wire values stable when changing internal enum names.

## Testing

Rules:

- Unit-test service/domain rules and repository mapping behavior.
- Integration-test persistence, transaction behavior, dependency injection, and
  module wiring when they are part of the contract.
- E2e-test important HTTP, GraphQL, queue, webhook, and auth paths.
- Mock external systems at the edge. Do not mock the service method whose
  behavior is under test.
- Use builders or factories that express business defaults clearly.
- Keep tests deterministic: no real network calls, no wall-clock assumptions
  without a controllable clock, and no order-dependent shared state.

## Common Anti-Patterns

| Anti-pattern | Fix |
| --- | --- |
| Controller/resolver injects a repository | Inject a service or facade |
| Service imports ORM operators or query-builder APIs | Add repository methods |
| Public API returns persistence entities | Map to response DTOs |
| Transaction decorator without explicit datasource in multi-database code | Name the datasource or unit of work |
| Shared package owns business workflows | Move workflow to the owning module |
| Module imports another module's entity or repository | Use facade, client, event, command, or read model |
| Raw string state values where enum/constants exist | Use the named enum or constant |
