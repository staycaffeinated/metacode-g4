# java-app Project Generator Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add `create project java-app` CLI command that generates a plain Java multi-module Gradle project with no Spring libraries.

**Architecture:** New self-contained module `mc-feature-javaapp` owns all its templates and catalog. `springboot-base.yaml` gains explicit `when: flavor:` guards on every entry so the new `javaapp` flavor inherits nothing from it. The `javaapp.yaml` catalog re-points common entries to the existing shared templates and provides new templates for Java-specific files.

**Tech Stack:** Java 21, Gradle, PicoCLI, FreeMarker, JUnit 5, AssertJ

---

## File Map

### New files
| File | Purpose |
|---|---|
| `mc-feature-javaapp/build.gradle` | Module build config |
| `mc-feature-javaapp/src/main/java/mmm/coffee/metacode/javaapp/JavaAppCatalogContributor.java` | Returns catalog resource path |
| `mc-feature-javaapp/src/test/java/mmm/coffee/metacode/javaapp/JavaAppCatalogContributorTest.java` | Unit test for contributor |
| `mc-feature-javaapp/src/test/java/mmm/coffee/metacode/javaapp/JavaAppCatalogTest.java` | Verifies catalog YAML loads and has correct flavor |
| `mc-feature-javaapp/src/main/resources/spring/catalogs/javaapp.yaml` | Self-contained catalog (24 entries, all guarded with `flavor: [javaapp]`) |
| `mc-feature-javaapp/src/main/resources/spring/templates/javaapp/main/Application.ftl` | Plain `main()` class |
| `mc-feature-javaapp/src/main/resources/spring/templates/javaapp/test/ApplicationTest.ftl` | JUnit 5 placeholder test |
| `mc-feature-javaapp/src/main/resources/spring/templates/javaapp/integrationTest/ApplicationIT.ftl` | Plain integration test |
| `mc-feature-javaapp/src/main/resources/spring/templates/javaapp/integrationTest/AbstractIntegrationTest.ftl` | Plain base IT class (no Spring annotations) |
| `mc-feature-javaapp/src/main/resources/spring/templates/javaapp/gradle/BuildDotGradle.ftl` | App-module `build.gradle` (no Spring) |
| `mc-feature-javaapp/src/main/resources/spring/templates/javaapp/gradle/VersionCatalog.ftl` | `libs.versions.toml` stripped of Spring |
| `mc-feature-javaapp/src/main/resources/spring/templates/javaapp/gradle/ApplicationConventions.ftl` | `buildlogic.application-conventions.gradle` (no Docker) |
| `mc-application/src/main/java/mmm/coffee/metacode/cli/SubcommandCreateJavaAppProject.java` | PicoCLI `java-app` subcommand |

### Modified files
| File | Change |
|---|---|
| `settings.gradle` | Add `include "mc-feature-javaapp"` |
| `mc-core-springboot/src/main/resources/spring/catalogs/springboot-base.yaml` | Add `when: flavor: [webmvc, webflux, springbatch, springboot]` to every entry |
| `mc-application/build.gradle` | Add `implementation project(':mc-feature-javaapp')` |
| `mc-application/src/main/java/mmm/coffee/metacode/cli/SubcommandCreateProject.java` | Register `SubcommandCreateJavaAppProject.class` |
| `mc-application/src/main/java/mmm/coffee/metacode/engine/AppConfiguration.java` | Register `javaAppCatalogContributor()` bean |

---

## Task 1: Scaffold the `mc-feature-javaapp` module

**Files:**
- Create: `settings.gradle` (modify)
- Create: `mc-feature-javaapp/build.gradle`
- Create: `mc-feature-javaapp/src/main/java/mmm/coffee/metacode/javaapp/JavaAppCatalogContributor.java`
- Create: `mc-feature-javaapp/src/test/java/mmm/coffee/metacode/javaapp/JavaAppCatalogContributorTest.java`

- [ ] **Step 1: Add module to root `settings.gradle`**

Open `settings.gradle` (root of project). After the existing `include "mc-feature-springbatch"` line, add:

```groovy
include "mc-feature-javaapp"
```

- [ ] **Step 2: Write the failing contributor test**

Create `mc-feature-javaapp/src/test/java/mmm/coffee/metacode/javaapp/JavaAppCatalogContributorTest.java`:

```java
package mmm.coffee.metacode.javaapp;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class JavaAppCatalogContributorTest {

    @Test
    void returnsExpectedCatalogResourcePath() {
        var contributor = new JavaAppCatalogContributor();
        assertThat(contributor.getCatalogResource()).isEqualTo("/spring/catalogs/javaapp.yaml");
    }

    @Test
    void catalogResourceExistsOnClasspath() {
        var contributor = new JavaAppCatalogContributor();
        var stream = getClass().getResourceAsStream(contributor.getCatalogResource());
        assertThat(stream).isNotNull();
    }
}
```

- [ ] **Step 3: Create the module `build.gradle`**

Create `mc-feature-javaapp/build.gradle`:

```groovy
plugins {
    id 'buildlogic.library-conventions'
    alias(libs.plugins.lombok.plugin)
}

dependencies {
    implementation project(':mc-core')
    testImplementation platform(libs.junit.bom)
    testImplementation libs.assertJ
    testImplementation libs.junit.jupiter
    testImplementation libs.mockito
    testRuntimeOnly libs.junit.platform.launcher
}

sonar {
    properties {
        property "sonar.tests", "src/test/java"
    }
}
```

- [ ] **Step 4: Create the `JavaAppCatalogContributor`**

Create `mc-feature-javaapp/src/main/java/mmm/coffee/metacode/javaapp/JavaAppCatalogContributor.java`:

```java
package mmm.coffee.metacode.javaapp;

import mmm.coffee.metacode.core.contributor.CatalogContributor;

public class JavaAppCatalogContributor implements CatalogContributor {

    static final String CATALOG_RESOURCE = "/spring/catalogs/javaapp.yaml";

    @Override
    public String getCatalogResource() {
        return CATALOG_RESOURCE;
    }
}
```

- [ ] **Step 5: Run test — expect failure because `javaapp.yaml` doesn't exist yet**

```
./gradlew :mc-feature-javaapp:test
```

Expected: `returnsExpectedCatalogResourcePath` passes; `catalogResourceExistsOnClasspath` FAILS (`stream is null` or `NullPointerException`) — this is correct. The test will pass after the catalog is created in Task 2.

- [ ] **Step 6: Commit**

```bash
git add settings.gradle mc-feature-javaapp/
git commit -m "feat: scaffold mc-feature-javaapp module with CatalogContributor"
```

---

## Task 2: Create `javaapp.yaml` catalog

**Files:**
- Create: `mc-feature-javaapp/src/main/resources/spring/catalogs/javaapp.yaml`
- Create: `mc-feature-javaapp/src/test/java/mmm/coffee/metacode/javaapp/JavaAppCatalogTest.java`

- [ ] **Step 1: Write the failing catalog test**

Create `mc-feature-javaapp/src/test/java/mmm/coffee/metacode/javaapp/JavaAppCatalogTest.java`:

```java
package mmm.coffee.metacode.javaapp;

import mmm.coffee.metacode.core.catalog.CatalogEntry;
import mmm.coffee.metacode.core.catalog.CatalogReader;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

class JavaAppCatalogTest {

    CatalogReader reader;

    @BeforeEach
    void setUp() {
        reader = new CatalogReader();
    }

    @Test
    void catalogLoadsWithEntries() {
        List<CatalogEntry> entries = reader.read("/spring/catalogs/javaapp.yaml");
        assertThat(entries).isNotEmpty();
    }

    @Test
    void allEntriesHaveJavaAppFlavorGuard() {
        List<CatalogEntry> entries = reader.read("/spring/catalogs/javaapp.yaml");
        assertThat(entries)
            .allMatch(e -> e.getWhen() != null
                && e.getWhen().getFlavor() != null
                && e.getWhen().getFlavor().contains("javaapp"),
                "every entry must have when.flavor containing 'javaapp'");
    }

    @Test
    void hasApplicationEntry() {
        List<CatalogEntry> entries = reader.read("/spring/catalogs/javaapp.yaml");
        assertThat(entries)
            .extracting(CatalogEntry::getArchetype)
            .contains("Application");
    }
}
```

- [ ] **Step 2: Run the test — expect CatalogNotFoundException**

```
./gradlew :mc-feature-javaapp:test
```

Expected: FAIL with `CatalogNotFoundException: javaapp.yaml`.

- [ ] **Step 3: Create `javaapp.yaml`**

Create `mc-feature-javaapp/src/main/resources/spring/catalogs/javaapp.yaml`:

```yaml
# Self-contained catalog for the 'javaapp' flavor.
# Every entry carries 'when: flavor: [javaapp]'.
# Common Gradle scaffold entries re-use templates from mc-core-springboot.
# Java-specific entries (Application, tests, build files) use new templates.

entries:

  # ─── Application class + tests ───────────────────────────────────────────────

  - scope: project
    archetype: Application
    when:
      flavor: [javaapp]
    facets:
      - facet: main
        sourceTemplate: /spring/templates/javaapp/main/Application.ftl
        destination: "{{basePackagePath}}/Application.java"
      - facet: test
        sourceTemplate: /spring/templates/javaapp/test/ApplicationTest.ftl
        destination: "{{testBasePackagePath}}/ApplicationTest.java"
      - facet: integrationTest
        sourceTemplate: /spring/templates/javaapp/integrationTest/ApplicationIT.ftl
        destination: "{{testBasePackagePath}}/ApplicationIT.java"

  - scope: project
    archetype: AbstractIntegrationTest
    when:
      flavor: [javaapp]
    facets:
      - facet: integrationTest
        sourceTemplate: /spring/templates/javaapp/integrationTest/AbstractIntegrationTest.ftl
        destination: "{{testBasePackagePath}}/common/AbstractIntegrationTest.java"

  # ─── Common project files ─────────────────────────────────────────────────────

  - scope: project
    archetype: Text
    when:
      flavor: [javaapp]
    facets:
      - facet: main
        sourceTemplate: /spring/templates/common/README.ftl
        destination: "README.adoc"

  - scope: project
    archetype: Text
    when:
      flavor: [javaapp]
    facets:
      - facet: main
        sourceTemplate: /spring/templates/common/DotGitIgnore.ftl
        destination: ".gitignore"

  - scope: project
    archetype: Text
    when:
      flavor: [javaapp]
    facets:
      - facet: main
        sourceTemplate: /spring/templates/common/LombokConfig.ftl
        destination: "lombok.config"

  # ─── Gradle root build files ──────────────────────────────────────────────────

  - scope: project
    archetype: Text
    when:
      flavor: [javaapp]
    facets:
      - facet: main
        sourceTemplate: /spring/templates/gradle/SettingsDotGradle.ftl
        destination: "settings.gradle"

  - scope: project
    archetype: Text
    when:
      flavor: [javaapp]
    facets:
      - facet: main
        sourceTemplate: /spring/templates/gradle/RootBuildDotGradle.ftl
        destination: "build.gradle"

  - scope: project
    archetype: Text
    when:
      flavor: [javaapp]
    facets:
      - facet: main
        sourceTemplate: /spring/templates/gradle/GradleDotProperties.ftl
        destination: "gradle.properties"

  - scope: project
    archetype: Text
    when:
      flavor: [javaapp]
    facets:
      - facet: main
        sourceTemplate: /spring/templates/gradle/DotJavaVersion.ftl
        destination: ".java-version"

  - scope: project
    archetype: Text
    when:
      flavor: [javaapp]
    facets:
      - facet: main
        sourceTemplate: /spring/templates/javaapp/gradle/VersionCatalog.ftl
        destination: "gradle/libs.versions.toml"

  # ─── App-module build.gradle (no Spring) ─────────────────────────────────────

  - scope: project
    archetype: Text
    when:
      flavor: [javaapp]
    facets:
      - facet: main
        sourceTemplate: /spring/templates/javaapp/gradle/BuildDotGradle.ftl
        destination: "{{appModule}}/build.gradle"

  # ─── Gradle convention plugins ────────────────────────────────────────────────

  - scope: project
    archetype: Text
    when:
      flavor: [javaapp]
    facets:
      - facet: main
        sourceTemplate: /spring/templates/gradle/plugins/PluginsSettingsDotGradle.ftl
        destination: "gradle/plugins/settings.gradle"

  - scope: project
    archetype: Text
    when:
      flavor: [javaapp]
    facets:
      - facet: main
        sourceTemplate: /spring/templates/gradle/plugins/java-conventions/BuildDotGradle.ftl
        destination: "gradle/plugins/java-conventions/build.gradle"

  - scope: project
    archetype: Text
    when:
      flavor: [javaapp]
    facets:
      - facet: main
        sourceTemplate: /spring/templates/gradle/plugins/java-conventions/groovy/JavaConventions.ftl
        destination: "gradle/plugins/java-conventions/src/main/groovy/buildlogic.java-conventions.gradle"

  - scope: project
    archetype: Text
    when:
      flavor: [javaapp]
    facets:
      - facet: main
        sourceTemplate: /spring/templates/javaapp/gradle/ApplicationConventions.ftl
        destination: "gradle/plugins/java-conventions/src/main/groovy/buildlogic.application-conventions.gradle"

  - scope: project
    archetype: Text
    when:
      flavor: [javaapp]
    facets:
      - facet: main
        sourceTemplate: /spring/templates/gradle/plugins/java-conventions/groovy/IntegrationTest.ftl
        destination: "gradle/plugins/java-conventions/src/main/groovy/buildlogic.integration-test.gradle"

  - scope: project
    archetype: Text
    when:
      flavor: [javaapp]
    facets:
      - facet: main
        sourceTemplate: /spring/templates/gradle/plugins/java-conventions/groovy/Testing.ftl
        destination: "gradle/plugins/java-conventions/src/main/groovy/buildlogic.testing.gradle"

  - scope: project
    archetype: Text
    when:
      flavor: [javaapp]
    facets:
      - facet: main
        sourceTemplate: /spring/templates/gradle/plugins/java-conventions/groovy/Jacoco.ftl
        destination: "gradle/plugins/java-conventions/src/main/groovy/buildlogic.jacoco.gradle"

  - scope: project
    archetype: Text
    when:
      flavor: [javaapp]
    facets:
      - facet: main
        sourceTemplate: /spring/templates/gradle/plugins/java-conventions/groovy/SonarJacoco.ftl
        destination: "gradle/plugins/java-conventions/src/main/groovy/buildlogic.sonar-jacoco.gradle"

  - scope: project
    archetype: Text
    when:
      flavor: [javaapp]
    facets:
      - facet: main
        sourceTemplate: /spring/templates/gradle/plugins/java-conventions/groovy/Spotless.ftl
        destination: "gradle/plugins/java-conventions/src/main/groovy/buildlogic.spotless.gradle"

  - scope: project
    archetype: Text
    when:
      flavor: [javaapp]
    facets:
      - facet: main
        sourceTemplate: /spring/templates/gradle/plugins/java-conventions/groovy/SubprojectConfigurations.ftl
        destination: "gradle/plugins/java-conventions/src/main/groovy/buildlogic.subproject-configurations.gradle"

  # ─── Gradle settings plugins ──────────────────────────────────────────────────

  - scope: project
    archetype: Text
    when:
      flavor: [javaapp]
    facets:
      - facet: main
        sourceTemplate: /spring/templates/gradle/settings/BuildDotGradle.ftl
        destination: "gradle/settings/build.gradle"

  - scope: project
    archetype: Text
    when:
      flavor: [javaapp]
    facets:
      - facet: main
        sourceTemplate: /spring/templates/gradle/settings/SettingsDotGradle.ftl
        destination: "gradle/settings/settings.gradle"

  - scope: project
    archetype: Text
    when:
      flavor: [javaapp]
    facets:
      - facet: main
        sourceTemplate: /spring/templates/gradle/settings/groovy/RepositoriesSettings.ftl
        destination: "gradle/settings/src/main/groovy/buildlogic.repositories.settings.gradle"
```

- [ ] **Step 4: Run tests — expect all 3 catalog tests to pass**

```
./gradlew :mc-feature-javaapp:test
```

Expected: all 4 tests in the module pass (2 contributor + 3 catalog).

- [ ] **Step 5: Commit**

```bash
git add mc-feature-javaapp/src/main/resources/ mc-feature-javaapp/src/test/
git commit -m "feat: add javaapp.yaml catalog with 24 self-contained entries"
```

---

## Task 3: Create Java-specific FTL templates

**Files:**
- Create: all 7 new FTL templates under `mc-feature-javaapp/src/main/resources/spring/templates/javaapp/`

No unit tests needed here — the catalog tests from Task 2 verify the paths resolve, and end-to-end testing in Task 6 validates rendered output.

- [ ] **Step 1: Create `Application.ftl`**

Create `mc-feature-javaapp/src/main/resources/spring/templates/javaapp/main/Application.ftl`:

```freemarker
<#include "/common/Copyright.ftl">
package ${Application.packageName()};

public class ${Application.className()} {
    public static void main(String[] args) {
    }
}
```

- [ ] **Step 2: Create `ApplicationTest.ftl`**

Create `mc-feature-javaapp/src/main/resources/spring/templates/javaapp/test/ApplicationTest.ftl`:

```freemarker
<#include "/common/Copyright.ftl">
package ${Application.packageName()};

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class ${Application.testClass()} {

    @Test
    void placeholderTest() {
        assertThat(true).isTrue();
    }
}
```

- [ ] **Step 3: Create `AbstractIntegrationTest.ftl`**

Create `mc-feature-javaapp/src/main/resources/spring/templates/javaapp/integrationTest/AbstractIntegrationTest.ftl`:

```freemarker
<#include "/common/Copyright.ftl">
package ${AbstractIntegrationTest.packageName()};

public abstract class ${AbstractIntegrationTest.className()} {
}
```

- [ ] **Step 4: Create `ApplicationIT.ftl`**

Create `mc-feature-javaapp/src/main/resources/spring/templates/javaapp/integrationTest/ApplicationIT.ftl`:

```freemarker
<#include "/common/Copyright.ftl">
package ${Application.packageName()};

import ${AbstractIntegrationTest.fqcn()};
import org.junit.jupiter.api.Test;

class ${Application.integrationTestClass()} extends ${AbstractIntegrationTest.className()} {

    @Test
    void applicationStarts() {
    }
}
```

- [ ] **Step 5: Create `ApplicationConventions.ftl`**

Create `mc-feature-javaapp/src/main/resources/spring/templates/javaapp/gradle/ApplicationConventions.ftl`:

```freemarker
plugins {
    id "buildlogic.java-conventions"
    id "application"
}
```

- [ ] **Step 6: Create `BuildDotGradle.ftl`** (app-module build.gradle)

Create `mc-feature-javaapp/src/main/resources/spring/templates/javaapp/gradle/BuildDotGradle.ftl`:

```freemarker
plugins {
    id 'buildlogic.application-conventions'
    id 'buildlogic.integration-test'
    id 'jacoco-report-aggregation'
    alias(libs.plugins.versions)
    alias(libs.plugins.lombok.plugin)
}

version = '0.0.1'

dependencies {
    <#noparse>mockitoAgent("org.mockito:mockito-core") { transitive = false }</#noparse>

    testImplementation platform(libs.junit.bom)
    testImplementation libs.assertJ
    testImplementation libs.junit.jupiter
    testImplementation libs.mockito
    testRuntimeOnly libs.junit.platform.launcher
}
```

- [ ] **Step 7: Create `VersionCatalog.ftl`**

Create `mc-feature-javaapp/src/main/resources/spring/templates/javaapp/gradle/VersionCatalog.ftl`:

```freemarker
[versions]
assertJ = '3.27.7'
junit = '6.1.3'
lombokPlugin = '9.2.0'
mockito = '5.23.0'
sonar = '7.5.0.8588'
spotless = '7.0.4'
benManesPlugin = '0.62.0'

[libraries]
assertJ = { module = "org.assertj:assertj-core", version.ref = "assertJ" }

junit-bom = { module = "org.junit:junit-bom", version.ref = "junit" }
junit-jupiter = { module = "org.junit.jupiter:junit-jupiter" }
junit-platform-launcher = { module = "org.junit.platform:junit-platform-launcher" }

mockito = { module = "org.mockito:mockito-core", version.ref = "mockito" }

[plugins]
lombok-plugin = { id = "io.freefair.lombok", version.ref = "lombokPlugin" }
sonar = { id = "org.sonarqube", version.ref = "sonar" }
versions = { id = "com.github.ben-manes.versions", version.ref = "benManesPlugin" }
```

- [ ] **Step 8: Run module tests to verify classpath resources resolve**

```
./gradlew :mc-feature-javaapp:test
```

Expected: all 4 tests pass, including `catalogResourceExistsOnClasspath`.

- [ ] **Step 9: Commit**

```bash
git add mc-feature-javaapp/src/main/resources/spring/templates/
git commit -m "feat: add FTL templates for java-app flavor"
```

---

## Task 4: Guard `springboot-base.yaml` entries with flavor conditions

**Files:**
- Modify: `mc-core-springboot/src/main/resources/spring/catalogs/springboot-base.yaml`

Add `when: flavor: [webmvc, webflux, springbatch, springboot]` to **every** entry. This prevents all 27 base entries from rendering for `javaapp`. Existing Spring flavors are explicitly listed and remain unaffected.

- [ ] **Step 1: Add flavor guards to `springboot-base.yaml`**

Open `mc-core-springboot/src/main/resources/spring/catalogs/springboot-base.yaml`.

For **every** entry that currently has no `when:` block, add one. For every entry that already has `when:`, add `webmvc, webflux, springbatch, springboot` to the flavor list. The file should look like:

```yaml
entries:

  - scope: project
    archetype: Application
    when:
      flavor: [webmvc, webflux, springbatch, springboot]
    facets:
      - facet: main
        sourceTemplate: /spring/templates/springboot/main/Application.ftl
        destination: "{{basePackagePath}}/Application.java"
      - facet: test
        sourceTemplate: /spring/templates/springboot/test/ApplicationTest.ftl
        destination: "{{testBasePackagePath}}/ApplicationTest.java"
      - facet: integrationTest
        sourceTemplate: /spring/templates/springboot/integrationTest/ApplicationIT.ftl
        destination: "{{testBasePackagePath}}/ApplicationIT.java"

  - scope: project
    archetype: SpringProfiles
    when:
      flavor: [webmvc, webflux, springbatch, springboot]
    facets:
      - facet: main
        sourceTemplate: /spring/templates/springboot/main/SpringProfiles.ftl

  - scope: project
    archetype: AbstractIntegrationTest
    when:
      flavor: [webmvc, webflux, springbatch, springboot]
    facets:
      - facet: integrationTest
        sourceTemplate: /spring/templates/springboot/integrationTest/AbstractIntegrationTest.ftl
        destination: "{{testBasePackagePath}}/common/AbstractIntegrationTest.java"

  - scope: project
    archetype: Text
    when:
      flavor: [webmvc, webflux, springbatch, springboot]
    facets:
      - facet: main
        sourceTemplate: /spring/templates/springboot/resources/ApplicationDotYml.ftl
        destination: "{{appModule}}/src/main/resources/application.yml"

  - scope: project
    archetype: Text
    when:
      flavor: [webmvc, webflux, springbatch, springboot]
    facets:
      - facet: main
        sourceTemplate: /spring/templates/common/README.ftl
        destination: "README.adoc"

  - scope: project
    archetype: Text
    when:
      flavor: [webmvc, webflux, springbatch, springboot]
    facets:
      - facet: main
        sourceTemplate: /spring/templates/common/DotGitIgnore.ftl
        destination: ".gitignore"

  - scope: project
    archetype: Text
    when:
      flavor: [webmvc, webflux, springbatch, springboot]
    facets:
      - facet: main
        sourceTemplate: /spring/templates/common/LombokConfig.ftl
        destination: "lombok.config"

  - scope: project
    archetype: Text
    when:
      flavor: [webmvc, webflux, springbatch, springboot]
    facets:
      - facet: main
        sourceTemplate: /spring/templates/gradle/SettingsDotGradle.ftl
        destination: "settings.gradle"

  - scope: project
    archetype: Text
    when:
      flavor: [webmvc, webflux, springbatch, springboot]
    facets:
      - facet: main
        sourceTemplate: /spring/templates/gradle/RootBuildDotGradle.ftl
        destination: "build.gradle"

  - scope: project
    archetype: Text
    when:
      flavor: [webmvc, webflux, springbatch, springboot]
    facets:
      - facet: main
        sourceTemplate: /spring/templates/gradle/GradleDotProperties.ftl
        destination: "gradle.properties"

  - scope: project
    archetype: Text
    when:
      flavor: [webmvc, webflux, springbatch, springboot]
    facets:
      - facet: main
        sourceTemplate: /spring/templates/gradle/DotJavaVersion.ftl
        destination: ".java-version"

  - scope: project
    archetype: Text
    when:
      flavor: [webmvc, webflux, springbatch, springboot]
    facets:
      - facet: main
        sourceTemplate: /spring/templates/gradle/VersionCatalog.ftl
        destination: "gradle/libs.versions.toml"

  - scope: project
    archetype: Text
    when:
      flavor: [webmvc, webflux, springbatch, springboot]
    facets:
      - facet: main
        sourceTemplate: /spring/templates/gradle/application/BuildDotGradle.ftl
        destination: "{{appModule}}/build.gradle"

  - scope: project
    archetype: Text
    when:
      flavor: [webmvc, webflux, springbatch, springboot]
    facets:
      - facet: main
        sourceTemplate: /spring/templates/gradle/plugins/PluginsSettingsDotGradle.ftl
        destination: "gradle/plugins/settings.gradle"

  - scope: project
    archetype: Text
    when:
      flavor: [webmvc, webflux, springbatch, springboot]
    facets:
      - facet: main
        sourceTemplate: /spring/templates/gradle/plugins/java-conventions/BuildDotGradle.ftl
        destination: "gradle/plugins/java-conventions/build.gradle"

  - scope: project
    archetype: Text
    when:
      flavor: [webmvc, webflux, springbatch, springboot]
    facets:
      - facet: main
        sourceTemplate: /spring/templates/gradle/plugins/java-conventions/groovy/JavaConventions.ftl
        destination: "gradle/plugins/java-conventions/src/main/groovy/buildlogic.java-conventions.gradle"

  - scope: project
    archetype: Text
    when:
      flavor: [webmvc, webflux, springbatch, springboot]
    facets:
      - facet: main
        sourceTemplate: /spring/templates/gradle/plugins/java-conventions/groovy/ApplicationConventions.ftl
        destination: "gradle/plugins/java-conventions/src/main/groovy/buildlogic.application-conventions.gradle"

  - scope: project
    archetype: Text
    when:
      flavor: [webmvc, webflux, springbatch, springboot]
    facets:
      - facet: main
        sourceTemplate: /spring/templates/gradle/plugins/java-conventions/groovy/IntegrationTest.ftl
        destination: "gradle/plugins/java-conventions/src/main/groovy/buildlogic.integration-test.gradle"

  - scope: project
    archetype: Text
    when:
      flavor: [webmvc, webflux, springbatch, springboot]
    facets:
      - facet: main
        sourceTemplate: /spring/templates/gradle/plugins/java-conventions/groovy/Testing.ftl
        destination: "gradle/plugins/java-conventions/src/main/groovy/buildlogic.testing.gradle"

  - scope: project
    archetype: Text
    when:
      flavor: [webmvc, webflux, springbatch, springboot]
    facets:
      - facet: main
        sourceTemplate: /spring/templates/gradle/plugins/java-conventions/groovy/Jacoco.ftl
        destination: "gradle/plugins/java-conventions/src/main/groovy/buildlogic.jacoco.gradle"

  - scope: project
    archetype: Text
    when:
      flavor: [webmvc, webflux, springbatch, springboot]
    facets:
      - facet: main
        sourceTemplate: /spring/templates/gradle/plugins/java-conventions/groovy/SonarJacoco.ftl
        destination: "gradle/plugins/java-conventions/src/main/groovy/buildlogic.sonar-jacoco.gradle"

  - scope: project
    archetype: Text
    when:
      flavor: [webmvc, webflux, springbatch, springboot]
    facets:
      - facet: main
        sourceTemplate: /spring/templates/gradle/plugins/java-conventions/groovy/Spotless.ftl
        destination: "gradle/plugins/java-conventions/src/main/groovy/buildlogic.spotless.gradle"

  - scope: project
    archetype: Text
    when:
      flavor: [webmvc, webflux, springbatch, springboot]
    facets:
      - facet: main
        sourceTemplate: /spring/templates/gradle/plugins/java-conventions/groovy/Docker.ftl
        destination: "gradle/plugins/java-conventions/src/main/groovy/buildlogic.docker.gradle"

  - scope: project
    archetype: Text
    when:
      flavor: [webmvc, webflux, springbatch, springboot]
    facets:
      - facet: main
        sourceTemplate: /spring/templates/gradle/plugins/java-conventions/groovy/SubprojectConfigurations.ftl
        destination: "gradle/plugins/java-conventions/src/main/groovy/buildlogic.subproject-configurations.gradle"

  - scope: project
    archetype: Text
    when:
      flavor: [webmvc, webflux, springbatch, springboot]
    facets:
      - facet: main
        sourceTemplate: /spring/templates/gradle/settings/BuildDotGradle.ftl
        destination: "gradle/settings/build.gradle"

  - scope: project
    archetype: Text
    when:
      flavor: [webmvc, webflux, springbatch, springboot]
    facets:
      - facet: main
        sourceTemplate: /spring/templates/gradle/settings/SettingsDotGradle.ftl
        destination: "gradle/settings/settings.gradle"

  - scope: project
    archetype: Text
    when:
      flavor: [webmvc, webflux, springbatch, springboot]
    facets:
      - facet: main
        sourceTemplate: /spring/templates/gradle/settings/groovy/RepositoriesSettings.ftl
        destination: "gradle/settings/src/main/groovy/buildlogic.repositories.settings.gradle"
```

- [ ] **Step 2: Run the full build to verify no regressions**

```
./gradlew build
```

Expected: BUILD SUCCESSFUL. All existing tests pass. The `when:` guards are purely additive for existing flavors.

- [ ] **Step 3: Commit**

```bash
git add mc-core-springboot/src/main/resources/spring/catalogs/springboot-base.yaml
git commit -m "feat: add flavor guards to springboot-base catalog entries"
```

---

## Task 5: Wire CLI and `AppConfiguration`

**Files:**
- Create: `mc-application/src/main/java/mmm/coffee/metacode/cli/SubcommandCreateJavaAppProject.java`
- Modify: `mc-application/src/main/java/mmm/coffee/metacode/cli/SubcommandCreateProject.java`
- Modify: `mc-application/src/main/java/mmm/coffee/metacode/engine/AppConfiguration.java`
- Modify: `mc-application/build.gradle`

- [ ] **Step 1: Create `SubcommandCreateJavaAppProject.java`**

Create `mc-application/src/main/java/mmm/coffee/metacode/cli/SubcommandCreateJavaAppProject.java`:

```java
package mmm.coffee.metacode.cli;

import mmm.coffee.metacode.core.descriptor.ProjectDescriptor;
import mmm.coffee.metacode.core.generator.ICodeGenerator;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import picocli.CommandLine;

@Component
@CommandLine.Command(
        name = "java-app",
        description = "Generate a plain Java application project",
        mixinStandardHelpOptions = true)
public class SubcommandCreateJavaAppProject extends AbstractCreateProject {

    @Autowired
    private ICodeGenerator<ProjectDescriptor> codeGenerator;

    @Override
    public void run() {
        ProjectDescriptor descriptor = ProjectDescriptor.builder()
                .applicationName(applicationName)
                .basePackage(basePackage)
                .baseDirectory(baseDirectory)
                .basePath(basePath)
                .flavor("javaapp")
                .features(activeFeatures())
                .javaVersion(javaVersion)
                .build();

        codeGenerator.doPreprocessing(descriptor).generateCode(descriptor);
    }
}
```

- [ ] **Step 2: Register the subcommand in `SubcommandCreateProject.java`**

Open `mc-application/src/main/java/mmm/coffee/metacode/cli/SubcommandCreateProject.java`.

Add `SubcommandCreateJavaAppProject.class` to the `subcommands` array:

```java
@Component
@CommandLine.Command(
        name = "project",
        subcommands = {
            SubcommandCreateWebMvcProject.class,
            SubcommandCreateWebFluxProject.class,
            SubcommandCreateSpringBootProject.class,
            SubcommandCreateSpringBatchProject.class,
            SubcommandCreateJavaAppProject.class,
            CommandLine.HelpCommand.class
        },
        mixinStandardHelpOptions = true,
        description = "Create a new project")
public class SubcommandCreateProject implements Runnable {

    @Override
    public void run() {
        CommandLine.usage(this, System.out);
    }
}
```

- [ ] **Step 3: Register contributor bean in `AppConfiguration.java`**

Open `mc-application/src/main/java/mmm/coffee/metacode/engine/AppConfiguration.java`.

Add the import and new `@Bean` method. The class should include:

```java
import mmm.coffee.metacode.javaapp.JavaAppCatalogContributor;
```

And inside the `@Configuration` class body, add:

```java
    @Bean
    CatalogContributor javaAppCatalogContributor() {
        return new JavaAppCatalogContributor();
    }
```

- [ ] **Step 4: Add dependency in `mc-application/build.gradle`**

Open `mc-application/build.gradle`. In the `dependencies` block, add alongside the other feature module dependencies:

```groovy
implementation project(':mc-feature-javaapp')
```

- [ ] **Step 5: Build the full project**

```
./gradlew build
```

Expected: BUILD SUCCESSFUL.

- [ ] **Step 6: Spot-check CLI help output**

```
./gradlew :mc-application:build
java -jar mc-application/build/libs/mc-application-*.jar create project --help
```

Expected: output includes `java-app` as a listed subcommand.

- [ ] **Step 7: Commit**

```bash
git add mc-application/
git commit -m "feat: wire java-app CLI subcommand and AppConfiguration bean"
```

---

## Task 6: End-to-end smoke test

**Files:** none — this task validates the generated project, not metacode itself.

- [ ] **Step 1: Build and stage the jar**

```
./gradlew stage
```

Expected: jar copied to `~/Scratch/Metacode/<version>/` directory.

- [ ] **Step 2: Generate a java-app project**

```bash
cd ~/Scratch/Metacode/<version>
java -jar metacode-*.jar create project java-app \
  --application-name MyApp \
  --package com.example.myapp \
  --directory /tmp/test-javaapp
```

Expected: files written to `/tmp/test-javaapp/`.

- [ ] **Step 3: Verify generated file structure**

```bash
find /tmp/test-javaapp -type f | sort
```

Expected output includes:
```
/tmp/test-javaapp/.gitignore
/tmp/test-javaapp/.java-version
/tmp/test-javaapp/README.adoc
/tmp/test-javaapp/build.gradle
/tmp/test-javaapp/gradle.properties
/tmp/test-javaapp/gradle/libs.versions.toml
/tmp/test-javaapp/gradle/plugins/...
/tmp/test-javaapp/settings.gradle
/tmp/test-javaapp/application/build.gradle
/tmp/test-javaapp/application/src/main/java/com/example/myapp/MyApp.java
/tmp/test-javaapp/application/src/test/java/com/example/myapp/MyAppTest.java
/tmp/test-javaapp/application/src/integrationTest/java/com/example/myapp/MyAppIT.java
```

**Not present** (verify these are absent):
```bash
grep -r "SpringApplication\|@SpringBootApplication\|spring.boot" /tmp/test-javaapp/
```
Expected: no matches.

- [ ] **Step 4: Build the generated project**

```bash
cd /tmp/test-javaapp
./gradlew build
```

Expected: BUILD SUCCESSFUL. All generated tests pass.

- [ ] **Step 5: Commit**

No source changes — if everything passed, the feature is complete.
