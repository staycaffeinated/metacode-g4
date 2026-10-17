# java-app: Plain Java Project Generator

**Date:** 2026-10-17

## Goal

Add `create project java-app` CLI command that generates a Gradle multi-module project with the same scaffold structure as the Spring Boot flavors but without any Spring libraries or annotations.

---

## Approach

Self-contained new module (`mc-feature-javaapp`). The `javaapp` flavor owns all its entries — it does not inherit from `springboot-base.yaml`. To achieve this, every entry in `springboot-base.yaml` gains an explicit `when: flavor:` guard listing only the existing Spring flavors, so `javaapp` receives no base entries.

---

## Changes Required

### 1. `mc-core-springboot` — `springboot-base.yaml`

Add `when: flavor: [webmvc, webflux, springbatch, springboot]` to every entry.

- Purely additive: existing Spring flavors are explicitly listed and continue to receive all base entries unchanged.
- `javaapp` gets zero base entries, making the new module self-contained.

### 2. New module: `mc-feature-javaapp`

**`build.gradle`** — `buildlogic.library-conventions`, depends on `:mc-core`.

**`JavaAppCatalogContributor.java`** — implements `CatalogContributor`, returns `/spring/catalogs/javaapp.yaml`.

**`spring/catalogs/javaapp.yaml`** — fully self-contained; all entries tagged `when: flavor: [javaapp]`.

Catalog entries fall into two groups:

**Reused templates** — catalog entries point to existing paths in `mc-core-springboot`:

| Destination | Existing template |
|---|---|
| `.gitignore` | `/spring/templates/common/DotGitIgnore.ftl` |
| `README.adoc` | `/spring/templates/common/README.ftl` |
| `lombok.config` | `/spring/templates/common/LombokConfig.ftl` |
| `settings.gradle` | `/spring/templates/gradle/SettingsDotGradle.ftl` |
| `build.gradle` (root) | `/spring/templates/gradle/RootBuildDotGradle.ftl` |
| `gradle.properties` | `/spring/templates/gradle/GradleDotProperties.ftl` |
| `.java-version` | `/spring/templates/gradle/DotJavaVersion.ftl` |
| All convention plugins | `/spring/templates/gradle/plugins/java-conventions/groovy/*.ftl` |
| All settings plugins | `/spring/templates/gradle/settings/*.ftl` |

**New templates** — in `spring/templates/javaapp/`:

| Template | Destination | Notes |
|---|---|---|
| `main/Application.ftl` | `{{basePackagePath}}/Application.java` | Plain `public static void main()` |
| `test/ApplicationTest.ftl` | `{{testBasePackagePath}}/ApplicationTest.java` | JUnit 5 smoke test |
| `integrationTest/ApplicationIT.ftl` | `{{testBasePackagePath}}/ApplicationIT.java` | Plain IT, no Spring |
| `integrationTest/AbstractIntegrationTest.ftl` | `{{testBasePackagePath}}/common/AbstractIntegrationTest.java` | Base IT with no Spring annotations |
| `gradle/BuildDotGradle.ftl` | `{{appModule}}/build.gradle` | `application-conventions`, JUnit/AssertJ/Mockito deps only — no Spring plugins |
| `gradle/VersionCatalog.ftl` | `gradle/libs.versions.toml` | Stripped version catalog: JUnit, AssertJ, Mockito, Lombok, Spotless, Sonar — no Spring entries |

### 3. `mc-application`

**`SubcommandCreateJavaAppProject.java`** — new PicoCLI subcommand:
- `name = "java-app"`
- Sets `flavor("javaapp")` on `ProjectDescriptor`
- Extends `AbstractCreateProject`

**`SubcommandCreateProject.java`** — add `SubcommandCreateJavaAppProject.class` to `subcommands`.

**`build.gradle`** — add `implementation project(':mc-feature-javaapp')`.

**`AppConfiguration.java`** — register `JavaAppCatalogContributor` as a `@Bean` (same pattern as other contributors).

### 4. `settings.gradle` (root)

Add `include "mc-feature-javaapp"`.

---

## What the Generated Project Looks Like

```
<app-name>/
├── .gitignore
├── README.adoc
├── lombok.config
├── settings.gradle
├── build.gradle
├── gradle.properties
├── .java-version
├── gradle/
│   ├── libs.versions.toml          ← Java-only deps (no Spring)
│   ├── plugins/
│   │   ├── settings.gradle
│   │   └── java-conventions/
│   │       ├── build.gradle
│   │       └── src/main/groovy/    ← convention plugins (same as Spring)
│   └── settings/
│       └── ...
└── <app-name>/
    ├── build.gradle                ← no Spring plugins
    └── src/
        ├── main/java/<pkg>/
        │   └── Application.java
        ├── test/java/<pkg>/
        │   └── ApplicationTest.java
        └── integrationTest/java/<pkg>/
            ├── ApplicationIT.java
            └── common/
                └── AbstractIntegrationTest.java
```

---

## Out of Scope

- No `application.yml` (plain Java app needs none)
- No `--add` features (postgres, flyway, etc.) for this flavor — those are Spring-specific
- No Docker/Jib config in the app module `build.gradle`
