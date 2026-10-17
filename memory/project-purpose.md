---
name: project-purpose
description: MetaCode is a Java code generator CLI that produces Spring Boot applications. Designed to be extensible to other app types via templates.
metadata:
  type: project
---

MetaCode generates Spring Boot application scaffolding from CLI commands. Currently supports WebMVC and WebFlux flavors with features like postgres, flyway, liquibase, testcontainers, openapi.

**Why:** Template-based generation — adding new app types means adding new templates + catalog YAML + CatalogContributor, no engine changes.

**How to apply:** When suggesting new capabilities, follow the template+catalog pattern. The engine is generic; don't modify it for new output types.

## E2E Test Strategy

Two levels of "generated code works" verification:

1. **Template rendering tests** (`EndpointTemplateRenderingTest`) — renders all templates in-process with a no-op writer; catches FreeMarker variable errors without touching disk.
2. **Integration test** (`ApplicationIntegrationTest`) — Spring context loads successfully.

There are also external e2e tests (not in this repo) that run the built jar, generate a project, and verify the generated project compiles. The `stage` Gradle task (`./gradlew :mc-application:stage`) copies the jar to `~/Scratch/Metacode/v{VERSION}` for that purpose.
