# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Test Commands

```shell
# Compile and run all tests (unit + integration)
./gradlew build

# Run unit tests only
./gradlew test

# Run integration tests only
./gradlew integrationTest

# Run tests in a single subproject
./gradlew :mc-core:test
./gradlew :mc-application:test

# Run a single test class
./gradlew :mc-core:test --tests "mmm.coffee.metacode.core.catalog.CatalogReaderTest"

# Apply code formatting (Spotless / Palantir Java Format)
./gradlew spotlessApply

# Check formatting without modifying files
./gradlew spotlessCheck

# Build Docker image
./gradlew jibDockerBuild

# Check for dependency updates
./gradlew dependencyUpdates

# Build with SonarQube code coverage (requires sonar config in gradle.properties)
./gradlew clean build sonar
```

`spotlessApply` runs automatically as part of `build` and `check` — formatting failures will break the build.

## Architecture Overview

MetaCode is a **code-generation CLI** built on Spring Boot + PicoCLI. It reads a user's choices from the command line, selects matching catalog entries, renders Freemarker templates, and writes the generated files to disk.

### Module Structure

| Module | Role |
|---|---|
| `mc-core` | Domain model: `CatalogEntry`, `CatalogReader`, `ICodeGenerator`, `ProjectDescriptor`, `EndpointDescriptor`, `ArchetypeModel` |
| `mc-core-springboot` | Base Spring Boot catalog contributor (`springboot-base.yaml`) — scaffold common to all flavors |
| `mc-feature-webmvc` | WebMVC-specific Freemarker templates + catalog YAML |
| `mc-feature-webflux` | WebFlux-specific Freemarker templates + catalog YAML |
| `mc-application` | CLI entrypoint, Spring Boot wiring, generation engine (`CodeGenerationEngine`, `CatalogRegistry`, `TemplateModelConverter`) |

### Code Generation Pipeline

1. **CLI** (`mc-application/src/main/java/.../cli/`) — PicoCLI subcommands (`SubcommandCreateWebMvcProject`, `SubcommandCreateWebFluxProject`, `SubcommandCreateEndpoint`) collect user options and build a `ProjectDescriptor` or `EndpointDescriptor`.
2. **CatalogRegistry** — collects all `CatalogContributor` beans (one per feature module), loads their YAML catalogs via `CatalogReader`, and filters entries by `flavor` + `features`.
3. **CodeGenerationEngine** — iterates filtered `CatalogEntry` objects, renders each `TemplateFacet` with `FreemarkerTemplateRenderer`, resolves `{{token}}` destinations with `MustacheExpressionResolver`, and writes files to disk.
4. **TemplateModelConverter** — converts a descriptor into (a) a Freemarker model `Map<String, Object>` (populated with `ArchetypeModel` instances from `PackageLayout`) and (b) a Mustache token map used to expand `{{...}}` destination paths.

### Catalog YAML Structure

Each feature module ships a catalog YAML (e.g. `webflux.yaml`) in `src/main/resources/spring/catalogs/`. Entries look like:

```yaml
- scope: project          # "project" or "endpoint"
  archetype: Controller   # logical class name used as FTL model key
  when:
    flavor: [webflux]     # required flavor(s)
    features: [postgres]  # optional: also requires these active features
  facets:
    - facet: main
      sourceTemplate: /spring/templates/webflux/main/endpoint/...ftl
      destination: "{{basePackagePath}}/adapter/inbound/web/..."  # optional; derived from ArchetypeModel if absent
```

Catalogs support `includes:` for composing sub-catalogs. `CatalogReader` resolves includes recursively with cycle detection.

### Convention Plugins

Build logic lives in `gradle/plugins/java-conventions/src/main/groovy/`. Key plugins:

- `buildlogic.library-conventions` — used by library modules; enables `buildlogic.java-conventions` (toolchain, Spotless, JaCoCo, Sonar, lint)
- `buildlogic.application-conventions` — used by `mc-application`; adds Spring Boot plugin and Jib
- `buildlogic.integration-test` — declares the `integrationTest` JVM test suite; wires it into `check`

Java version is read from `.java-version` (currently `21`).

### Test Layout

Each subproject has:
- `src/test/java/` — unit tests (JUnit 5 + Mockito)
- `src/integrationTest/java/` — integration tests; `AbstractIntegrationTest` bootstraps the full Spring context with `@SpringBootTest`

Integration tests in `mc-application` that need a Postgres container extend a Testcontainers base class (e.g. `PostgresDbContainerTests`), **not** `AbstractIntegrationTest` directly.

### Adding a New Feature Module

1. Create the directory and add to `settings.gradle`: `include "mc-feature-xyz"`
2. Create `mc-feature-xyz/build.gradle` using `buildlogic.library-conventions`
3. Implement `CatalogContributor` annotated `@Component` returning the classpath path to your catalog YAML
4. Add catalog YAML under `src/main/resources/spring/catalogs/`
5. Add Freemarker templates under `src/main/resources/spring/templates/`
6. Add the module as an `implementation` dependency in `mc-application/build.gradle`
