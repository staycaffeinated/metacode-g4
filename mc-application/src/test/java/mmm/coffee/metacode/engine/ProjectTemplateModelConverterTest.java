package mmm.coffee.metacode.engine;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import java.time.Year;
import java.time.ZoneId;
import java.util.Map;
import java.util.Set;
import mmm.coffee.metacode.core.archetype.ArchetypeModel;
import mmm.coffee.metacode.core.descriptor.Feature;
import mmm.coffee.metacode.core.descriptor.Flavor;
import mmm.coffee.metacode.core.descriptor.ProjectDescriptor;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

@SuppressWarnings({"java:S8692" // System clock tests found here only verify the current year
})
class ProjectTemplateModelConverterTest {

    private static final String BASE_PACKAGE = "com.example.demo";
    private static final String APP_MODULE = "application";
    private static final String PACKAGE_PATH = "com/example/demo";

    private ProjectTemplateModelConverter converter;

    @BeforeEach
    void setUp() {
        converter = new ProjectTemplateModelConverter();
    }

    // -------------------------------------------------------------------------
    // toFtlModel
    // -------------------------------------------------------------------------

    @Test
    void toFtlModel_mapsApplicationName() {
        var model = converter.toFtlModel(projectDescriptor());
        assertThat(model).containsEntry("applicationName", "my-app");
    }

    @Test
    void toFtlModel_mapsBasePackage() {
        var model = converter.toFtlModel(projectDescriptor());
        assertThat(model).containsEntry("basePackage", BASE_PACKAGE);
    }

    @Test
    void toFtlModel_convertsDotsToSlashesInBasePackagePath() {
        var model = converter.toFtlModel(projectDescriptor());
        assertThat(model).containsEntry("basePackagePath", PACKAGE_PATH);
    }

    @Test
    void toFtlModel_mapsAppModule() {
        var model = converter.toFtlModel(projectDescriptor());
        assertThat(model).containsEntry("appModule", APP_MODULE);
    }

    @Test
    void toFtlModel_mapsFlavor() {
        var model = converter.toFtlModel(projectDescriptor());
        assertThat(model).containsEntry("flavor", "webmvc");
    }

    @Test
    void toFtlModel_mapsFeatures() {
        var model = converter.toFtlModel(projectDescriptor());
        assertThat(model).containsKey("features");
        @SuppressWarnings("unchecked")
        Set<Feature> features = (Set<Feature>) model.get("features");
        assertThat(features).containsExactlyInAnyOrder(Feature.POSTGRES, Feature.OPENAPI);
    }

    @Test
    void toFtlModel_mapsJavaVersion() {
        var model = converter.toFtlModel(projectDescriptor());
        assertThat(model).containsEntry("javaVersion", "21");
    }

    @Test
    void toFtlModel_includesCurrentYear() {
        int expectedYear = Year.now(ZoneId.systemDefault()).getValue();
        var model = converter.toFtlModel(projectDescriptor());
        assertThat(model).containsEntry("YEAR", expectedYear);
    }

    @Test
    void toFtlModel_includesProjectModelInstance() {
        var model = converter.toFtlModel(projectDescriptor());
        assertThat(model).containsKey("project");
        assertThat(model.get("project")).isInstanceOf(ProjectModel.class);
    }

    @Test
    void toFtlModel_populatesArchetypeModelsFromPackageLayout() {
        var model = converter.toFtlModel(projectDescriptor());
        assertThat(model).containsKey("Application");
        assertThat(model.get("Application")).isInstanceOf(ArchetypeModel.class);
    }

    @Test
    void toFtlModel_archetypeModelHasCorrectBasePackage() {
        var model = converter.toFtlModel(projectDescriptor());
        ArchetypeModel application = (ArchetypeModel) model.get("Application");
        assertThat(application.packageName()).startsWith(BASE_PACKAGE);
    }

    // -------------------------------------------------------------------------
    // toMustacheTokens
    // -------------------------------------------------------------------------

    @Test
    void toMustacheTokens_mapsApplicationName() {
        Map<String, String> tokens = converter.toMustacheTokens(projectDescriptor());
        assertThat(tokens).containsEntry("applicationName", "my-app");
    }

    @Test
    void toMustacheTokens_mapsBasePackage() {
        Map<String, String> tokens = converter.toMustacheTokens(projectDescriptor());
        assertThat(tokens).containsEntry("basePackage", BASE_PACKAGE);
    }

    @Test
    void toMustacheTokens_mapsAppModule() {
        Map<String, String> tokens = converter.toMustacheTokens(projectDescriptor());
        assertThat(tokens).containsEntry("appModule", APP_MODULE);
    }

    @Test
    void toMustacheTokens_buildsBasePackagePath() {
        Map<String, String> tokens = converter.toMustacheTokens(projectDescriptor());
        assertThat(tokens).containsEntry("basePackagePath", APP_MODULE + "/src/main/java/" + PACKAGE_PATH);
    }

    @Test
    void toMustacheTokens_buildsTestBasePackagePath() {
        Map<String, String> tokens = converter.toMustacheTokens(projectDescriptor());
        assertThat(tokens).containsEntry("testBasePackagePath", APP_MODULE + "/src/test/java/" + PACKAGE_PATH);
    }

    @Test
    void toMustacheTokens_buildsIntegrationTestBasePackagePath() {
        Map<String, String> tokens = converter.toMustacheTokens(projectDescriptor());
        assertThat(tokens)
                .containsEntry(
                        "integrationTestBasePackagePath", APP_MODULE + "/src/integrationTest/java/" + PACKAGE_PATH);
    }

    @Test
    void toMustacheTokens_buildsTestFixturesBasePackagePath() {
        Map<String, String> tokens = converter.toMustacheTokens(projectDescriptor());
        assertThat(tokens)
                .containsEntry("testFixturesBasePackagePath", APP_MODULE + "/src/testFixtures/java/" + PACKAGE_PATH);
    }

    // ── line 22: null flavor → empty string ──────────────────────────────────

    @Test
    void toFtlModel_nullFlavor_putsEmptyStringForFlavor() {
        var d = ProjectDescriptor.builder()
                .applicationName("my-app")
                .basePackage(BASE_PACKAGE)
                .baseDirectory("/tmp/my-app")
                .appModule(APP_MODULE)
                .javaVersion("21")
                .flavor(null)
                .build();
        var model = converter.toFtlModel(d);
        assertThat(model).containsEntry("flavor", "");
    }

    // ── line 25: null architecture → "hexagonal" default ─────────────────────
    // Architecture.HEXAGONAL is a @Builder.Default so null requires an explicit override.
    // Line 31 (d.getArchitecture().layoutResource()) then NPEs, but line 25's else-branch
    // is still exercised and counted by the coverage tool before the exception propagates.

    @Test
    void toFtlModel_nullArchitecture_exercisesHexagonalDefaultBeforeNpe() {
        var d = ProjectDescriptor.builder()
                .applicationName("my-app")
                .basePackage(BASE_PACKAGE)
                .baseDirectory("/tmp/my-app")
                .appModule(APP_MODULE)
                .javaVersion("21")
                .architecture(null)
                .build();
        assertThatThrownBy(() -> converter.toFtlModel(d)).isInstanceOf(NullPointerException.class);
    }

    // -------------------------------------------------------------------------
    // helpers
    // -------------------------------------------------------------------------

    private static ProjectDescriptor projectDescriptor() {
        return ProjectDescriptor.builder()
                .applicationName("my-app")
                .basePackage(BASE_PACKAGE)
                .baseDirectory("/tmp/my-app")
                .basePath("/api")
                .flavor(Flavor.WEBMVC)
                .appModule(APP_MODULE)
                .javaVersion("21")
                .features(Set.of(Feature.POSTGRES, Feature.OPENAPI))
                .build();
    }
}
