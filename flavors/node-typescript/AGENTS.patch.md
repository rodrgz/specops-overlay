## Stack Flavor: Node / TypeScript

Load this flavor only when the adopting repository is a Node.js or TypeScript
project, or intentionally follows Node/TypeScript backend conventions.

### Stack Defaults

- Language/runtime: TypeScript on Node.js
- Framework: Node.js, with optional NestJS, Express, Fastify, GraphQL, or worker
  frameworks when the project documents them
- Build tools: npm, pnpm, yarn, or bun using project-local scripts

### Stack-Specific Context

- Use `openspec/specops/flavors/node-typescript/docs/CODING-PATTERNS.md` for handlers,
  controllers, resolvers, services, repositories, DTOs, validation,
  transactions, entities/models, and tests.
- Use `openspec/specops/flavors/node-typescript/docs/INTEGRATION-PATTERNS.md` for dependency
  injection, external clients, configuration, events, queues, observability,
  resilience, webhooks, and security.
- Use `openspec/specops/flavors/node-typescript/docs/HARDENING-PATTERNS.md` for package-manager
  scripts, typecheck, ESLint, Prettier, Jest or Vitest, e2e tests, dependency
  scanning, secret scanning, and CI gates.
- Use `openspec/specops/flavors/node-typescript/skills/modular-architecture/SKILL.md` before
  designing or changing modules, boundaries, facades, repositories, persistence
  ownership, or subdomains in Node/TypeScript code.
