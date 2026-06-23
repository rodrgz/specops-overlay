## Stack Flavor: Java / Quarkus

Load this flavor only when the adopting repository is a Java/Quarkus service
or intentionally follows Java/Quarkus backend conventions.

### Stack Defaults

- Language/runtime: Java
- Framework: Quarkus
- Build tools: Maven or Gradle

### Stack-Specific Context

- Use `openspec/specops/flavors/java-quarkus/docs/CODING-PATTERNS.md` for resources, services,
  repositories, DTOs, validation, transactions, and tests.
- Use `openspec/specops/flavors/java-quarkus/docs/INTEGRATION-PATTERNS.md` for CDI,
  MicroProfile REST Client, SmallRye Fault Tolerance, messaging, observability,
  and security.
- Use `openspec/specops/flavors/java-quarkus/docs/HARDENING-PATTERNS.md` for Maven, Gradle,
  Spotless, SpotBugs, ArchUnit, dependency scanning, and CI gates.
- Use `openspec/specops/flavors/java-quarkus/skills/modular-architecture/SKILL.md` before
  designing or changing modules, boundaries, facades, repositories, persistence
  ownership, or subdomains in Java/Quarkus code.
