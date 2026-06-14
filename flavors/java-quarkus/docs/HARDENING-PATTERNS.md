# Hardening Patterns

Guidance for adding formatting, static analysis, and validation harness gates to
Java/Quarkus repositories that adopt this overlay flavor.

SpecOps Overlay is not a runnable application, so do not add Maven or Gradle
plugins here. Add the build configuration in the adopting repository's root
build, parent POM, or convention plugin, then document the real commands in
`docs/project/STACK.md` and `docs/project/TESTING.md`.

## Default Harness

Use the project wrapper and make the PR gate boring:

```bash
./mvnw -q verify
```

or:

```bash
./gradlew check
```

The default harness should include:

- Compile and unit tests.
- Spotless formatting check.
- SpotBugs with max effort and CI failure on High-priority findings.
- Architecture tests when module boundaries matter.
- Machine-readable reports for CI annotations or artifacts.

OpenSpec tasks for code changes should name the relevant build, static, unit,
and integration/e2e gates from `docs/project/TESTING.md`. If a gate is skipped,
the implementation or evaluation summary should state why. Failed hard gates
should affect readiness and, for spec-driven evaluations, the adjusted score.

Run auto-fix commands locally, not as CI mutations:

```bash
./mvnw spotless:apply
./gradlew spotlessApply
```

## Spotless

Use Spotless as the formatting gate. In brownfield repositories, prefer
`ratchetFrom` during adoption to avoid one noisy reformatting change. CI must
fetch the ratchet base branch or use a non-shallow checkout.

Recommended Java steps:

- `googleJavaFormat` or the team's documented formatter.
- `removeUnusedImports`.
- `forbidWildcardImports`.
- `formatAnnotations`.
- UTF-8 encoding and deterministic line endings.

Maven sketch:

```xml
<plugin>
  <groupId>com.diffplug.spotless</groupId>
  <artifactId>spotless-maven-plugin</artifactId>
  <version>${spotless.maven.plugin.version}</version>
  <configuration>
    <ratchetFrom>origin/main</ratchetFrom>
    <java>
      <googleJavaFormat/>
      <removeUnusedImports/>
      <forbidWildcardImports/>
      <formatAnnotations/>
    </java>
  </configuration>
  <executions>
    <execution>
      <goals>
        <goal>check</goal>
      </goals>
    </execution>
  </executions>
</plugin>
```

Gradle sketch:

```kotlin
plugins {
    id("com.diffplug.spotless") version "<pin-version>"
}

spotless {
    ratchetFrom("origin/main")
    java {
        googleJavaFormat()
        removeUnusedImports()
        forbidWildcardImports()
        formatAnnotations()
    }
}
```

## SpotBugs High Gate

Use SpotBugs as a bytecode analysis gate after compilation. Prefer maximum
effort and a High failure threshold. For Maven, keep reporting broad enough to
see lower-priority debt while failing only on High.

Maven sketch:

```xml
<plugin>
  <groupId>com.github.spotbugs</groupId>
  <artifactId>spotbugs-maven-plugin</artifactId>
  <version>${spotbugs.maven.plugin.version}</version>
  <configuration>
    <effort>Max</effort>
    <threshold>Low</threshold>
    <failThreshold>High</failThreshold>
    <xmlOutput>true</xmlOutput>
    <sarifOutput>true</sarifOutput>
  </configuration>
  <executions>
    <execution>
      <goals>
        <goal>check</goal>
      </goals>
    </execution>
  </executions>
</plugin>
```

Gradle sketch:

```kotlin
import com.github.spotbugs.snom.Confidence
import com.github.spotbugs.snom.Effort

plugins {
    id("com.github.spotbugs") version "<pin-version>"
}

spotbugs {
    ignoreFailures = false
    effort = Effort.MAX
    reportLevel = Confidence.HIGH
}

tasks.withType<com.github.spotbugs.snom.SpotBugsTask>().configureEach {
    reports.create("xml") {
        required = true
    }
    reports.create("html") {
        required = true
    }
}
```

Use excludes sparingly. Every SpotBugs exclude should have a narrow pattern and
a comment that explains why the finding is false positive or intentionally
accepted.

## Stronger Harness Tools

Add these when the project risk justifies the extra runtime and maintenance:

| Tool | Use | Gate |
| --- | --- | --- |
| Maven Enforcer or Gradle toolchains/dependency locking | Pin JDK/build tool expectations and stop dependency drift | PR gate |
| ArchUnit | Enforce module boundaries, package ownership, and forbidden dependencies | PR gate |
| JaCoCo | Track coverage for domain and adapter code | PR gate for minimums, report for trends |
| OWASP Dependency-Check, OSV-Scanner, or Trivy | Detect vulnerable dependencies and images | Scheduled and release gate |
| Gitleaks or TruffleHog | Detect committed secrets | PR gate |
| Semgrep | Catch framework and security anti-patterns not covered by SpotBugs | PR or scheduled gate |
| PIT mutation testing | Measure test strength for critical domain logic | Scheduled gate |
| Revapi | Detect breaking API changes in published libraries or shared clients | Release gate |

For most Quarkus services, the best next additions after Spotless and SpotBugs
are Maven Enforcer or Gradle toolchains, ArchUnit, dependency vulnerability
scanning, and secret scanning. They catch environment drift, boundary erosion,
supply-chain risk, and credential mistakes without requiring a large redesign.

## Adoption Checklist

- Add Spotless and SpotBugs in the build root or shared convention plugin.
- Pin plugin versions in one place.
- Run the formatter once in a dedicated PR or use `ratchetFrom` for brownfield
  adoption.
- Fix existing High SpotBugs findings before making the gate mandatory, or add
  narrow temporary excludes with owners and removal criteria.
- Publish XML, HTML, or SARIF reports as CI artifacts.
- Document the exact commands in `docs/project/TESTING.md`.
- Document tool versions and local requirements in `docs/project/STACK.md`.
- Add OpenSpec task validation steps for the harness when a change touches
  build configuration, CI, module boundaries, security, or dependencies.
- For OpenSpec changes with code impact, document build, static, unit,
  integration/e2e, and migration validation expectations without adding concrete
  plugins to this overlay flavor.

## References

- Spotless Maven plugin: <https://github.com/diffplug/spotless/tree/main/plugin-maven>
- Spotless Gradle plugin: <https://github.com/diffplug/spotless/tree/main/plugin-gradle>
- SpotBugs Maven plugin: <https://spotbugs.github.io/spotbugs-maven-plugin/>
- SpotBugs Gradle plugin: <https://github.com/spotbugs/spotbugs-gradle-plugin>
