package mmm.coffee.metacode.core.archetype;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import java.util.Map;
import org.junit.jupiter.api.Test;

class PackageLayoutTest {

    private static final String BASE_PACKAGE = "com.example.myapp";
    private static final String TEST_LAYOUT = "/test-package-layout.yaml";

    @Test
    void loadDefault_shouldSucceed() {
        PackageLayout layout = PackageLayout.loadDefault();
        assertThat(layout).isNotNull();
    }

    @Test
    void loadDefault_shouldContainKnownArchetypes() {
        PackageLayout layout = PackageLayout.loadDefault();
        Map<String, ArchetypeModel> models = layout.buildArchetypeModels(BASE_PACKAGE);
        assertThat(models).containsKey("Application").containsKey("RootController");
    }

    @Test
    void load_shouldSucceedWithValidResource() {
        PackageLayout layout = PackageLayout.load(TEST_LAYOUT);
        assertThat(layout).isNotNull();
    }

    @Test
    void load_shouldThrowWhenResourceNotFound() {
        assertThatThrownBy(() -> PackageLayout.load("/nonexistent-layout.yaml"))
                .isInstanceOf(IllegalStateException.class)
                .hasMessageContaining("nonexistent-layout.yaml");
    }

    @Test
    void buildArchetypeModels_emptySubPackage_usesBasePackage() {
        PackageLayout layout = PackageLayout.load(TEST_LAYOUT);
        Map<String, ArchetypeModel> models = layout.buildArchetypeModels(BASE_PACKAGE);

        ArchetypeModel application = models.get("Application");
        assertThat(application).isNotNull();
        assertThat(application.packageName()).isEqualTo(BASE_PACKAGE);
        assertThat(application.className()).isEqualTo("Application");
    }

    @Test
    void buildArchetypeModels_nonEmptySubPackage_appendsSubPackage() {
        PackageLayout layout = PackageLayout.load(TEST_LAYOUT);
        Map<String, ArchetypeModel> models = layout.buildArchetypeModels(BASE_PACKAGE);

        ArchetypeModel controller = models.get("Controller");
        assertThat(controller).isNotNull();
        assertThat(controller.packageName()).isEqualTo(BASE_PACKAGE + ".adapter.inbound.web");
        assertThat(controller.className()).isEqualTo("Controller");
    }

    @Test
    void buildArchetypeModels_containsAllDefinedArchetypes() {
        PackageLayout layout = PackageLayout.load(TEST_LAYOUT);
        Map<String, ArchetypeModel> models = layout.buildArchetypeModels(BASE_PACKAGE);

        assertThat(models).containsKeys("Application", "Controller", "Service").hasSize(3);
    }

    @Test
    void buildArchetypeModels_fqcnIsCorrect() {
        PackageLayout layout = PackageLayout.load(TEST_LAYOUT);
        Map<String, ArchetypeModel> models = layout.buildArchetypeModels(BASE_PACKAGE);

        ArchetypeModel service = models.get("Service");
        assertThat(service.fqcn()).isEqualTo(BASE_PACKAGE + ".application.service.Service");
    }

    @Test
    void buildArchetypeModels_differentBasePackage_reflectsInResult() {
        PackageLayout layout = PackageLayout.load(TEST_LAYOUT);

        Map<String, ArchetypeModel> models1 = layout.buildArchetypeModels("org.acme");
        Map<String, ArchetypeModel> models2 = layout.buildArchetypeModels("io.example");

        assertThat(models1.get("Controller").packageName()).isEqualTo("org.acme.adapter.inbound.web");
        assertThat(models2.get("Controller").packageName()).isEqualTo("io.example.adapter.inbound.web");
    }

    // ── line 35: file.archetypes == null → empty map ──────────────────────────

    @Test
    void load_noArchetypesKey_returnsLayoutWithEmptyModels() {
        PackageLayout layout = PackageLayout.load("/no-archetypes-layout.yaml");
        assertThat(layout).isNotNull();
        assertThat(layout.buildArchetypeModels(BASE_PACKAGE)).isEmpty();
    }

    // ── line 56: subPackage == null → returns basePackage ─────────────────────

    @Test
    void buildArchetypeModels_nullSubPackage_usesBasePackage() {
        PackageLayout layout = PackageLayout.load("/null-subpackage-layout.yaml");
        Map<String, ArchetypeModel> models = layout.buildArchetypeModels(BASE_PACKAGE);

        ArchetypeModel model = models.get("NoSubPackage");
        assertThat(model).isNotNull();
        assertThat(model.packageName()).isEqualTo(BASE_PACKAGE);
        assertThat(model.className()).isEqualTo("Foo");
    }
}
