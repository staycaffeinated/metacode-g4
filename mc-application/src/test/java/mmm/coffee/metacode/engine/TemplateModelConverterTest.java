package mmm.coffee.metacode.engine;

import static org.assertj.core.api.Assertions.assertThat;

import java.time.Year;
import java.time.ZoneId;
import java.util.Map;
import java.util.Set;
import mmm.coffee.metacode.core.archetype.ArchetypeModel;
import mmm.coffee.metacode.core.archetype.PackageLayout;
import mmm.coffee.metacode.core.descriptor.EndpointDescriptor;
import mmm.coffee.metacode.core.descriptor.Flavor;
import mmm.coffee.metacode.core.descriptor.ProjectDescriptor;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

@SuppressWarnings({"java:S8692" // System clock tests found here only verify the current year
})
class TemplateModelConverterTest {

    private static final String BASE_PACKAGE = "com.example.demo";
    private static final String APP_MODULE = "application";
    private static final String PACKAGE_PATH = "com/example/demo";

    private TemplateModelConverter converter;

    @BeforeEach
    void setUp() {
        converter = new TemplateModelConverter(PackageLayout.loadDefault());
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
        Set<String> features = (Set<String>) model.get("features");
        assertThat(features).containsExactlyInAnyOrder("postgres", "openapi");
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
        // package-layout.yaml defines Application and many others; spot-check a few
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

    // -------------------------------------------------------------------------
    // toEndpointFtlModel
    // -------------------------------------------------------------------------

    @Test
    void toEndpointFtlModel_mapsBasePackage() {
        var model = converter.toEndpointFtlModel(endpointDescriptor("Pet"));
        assertThat(model).containsEntry("basePackage", BASE_PACKAGE);
    }

    @Test
    void toEndpointFtlModel_convertsDotsToSlashesInBasePackagePath() {
        var model = converter.toEndpointFtlModel(endpointDescriptor("Pet"));
        assertThat(model).containsEntry("basePackagePath", PACKAGE_PATH);
    }

    @Test
    void toEndpointFtlModel_mapsFlavorAndFeatures() {
        var model = converter.toEndpointFtlModel(endpointDescriptor("Pet"));
        assertThat(model).containsEntry("flavor", "webmvc").containsKey("features");
    }

    @Test
    void toEndpointFtlModel_includesCurrentYear() {
        int expectedYear = Year.now(ZoneId.systemDefault()).getValue();
        var model = converter.toEndpointFtlModel(endpointDescriptor("Pet"));
        assertThat(model).containsEntry("YEAR", expectedYear);
    }

    @Test
    void toEndpointFtlModel_includesEndpointModelInstance() {
        var model = converter.toEndpointFtlModel(endpointDescriptor("Pet"));
        assertThat(model).containsKey("endpoint");
        assertThat(model.get("endpoint")).isInstanceOf(EndpointModel.class);
    }

    @Test
    void toEndpointFtlModel_buildsControllerArchetypeWithEntityName() {
        var model = converter.toEndpointFtlModel(endpointDescriptor("Pet"));
        assertThat(model).containsKey("Controller");
        ArchetypeModel controller = (ArchetypeModel) model.get("Controller");
        assertThat(controller.className()).isEqualTo("PetController");
    }

    @Test
    void toEndpointFtlModel_buildsServiceImplArchetype() {
        var model = converter.toEndpointFtlModel(endpointDescriptor("Pet"));
        assertThat(model).containsKey("ServiceImpl");
        ArchetypeModel svc = (ArchetypeModel) model.get("ServiceImpl");
        assertThat(svc.className()).isEqualTo("PetService");
    }

    @Test
    void toEndpointFtlModel_buildsEntityArchetype() {
        var model = converter.toEndpointFtlModel(endpointDescriptor("Pet"));
        ArchetypeModel entity = (ArchetypeModel) model.get("Entity");
        assertThat(entity.className()).isEqualTo("PetEntity");
        assertThat(entity.packageName()).contains("persistence");
    }

    @Test
    void toEndpointFtlModel_buildsEntityResourceArchetype() {
        var model = converter.toEndpointFtlModel(endpointDescriptor("Pet"));
        ArchetypeModel entityResource = (ArchetypeModel) model.get("EntityResource");
        assertThat(entityResource.className()).isEqualTo("Pet");
        assertThat(entityResource.packageName()).contains("domain");
    }

    @Test
    void toEndpointFtlModel_buildsRepositoryArchetype() {
        var model = converter.toEndpointFtlModel(endpointDescriptor("Pet"));
        ArchetypeModel repo = (ArchetypeModel) model.get("Repository");
        assertThat(repo.className()).isEqualTo("PetRepository");
    }

    // -------------------------------------------------------------------------
    // toEndpointMustacheTokens
    // -------------------------------------------------------------------------

    @Test
    void toEndpointMustacheTokens_mapsBasePackage() {
        Map<String, String> tokens = converter.toEndpointMustacheTokens(endpointDescriptor("Pet"));
        assertThat(tokens).containsEntry("basePackage", BASE_PACKAGE);
    }

    @Test
    void toEndpointMustacheTokens_mapsEntityName() {
        Map<String, String> tokens = converter.toEndpointMustacheTokens(endpointDescriptor("Pet"));
        assertThat(tokens).containsEntry("entityName", "Pet");
    }

    @Test
    void toEndpointMustacheTokens_lowercasesEntityName() {
        Map<String, String> tokens = converter.toEndpointMustacheTokens(endpointDescriptor("Pet"));
        assertThat(tokens).containsEntry("lowerCaseEntityName", "pet");
    }

    @Test
    void toEndpointMustacheTokens_buildsBasePackagePath() {
        Map<String, String> tokens = converter.toEndpointMustacheTokens(endpointDescriptor("Pet"));
        assertThat(tokens).containsEntry("basePackagePath", APP_MODULE + "/src/main/java/" + PACKAGE_PATH);
    }

    @Test
    void toEndpointMustacheTokens_buildsCreateTableScriptName() {
        Map<String, String> tokens = converter.toEndpointMustacheTokens(endpointDescriptor("Pet"));
        assertThat(tokens).containsEntry("createTableScriptName", "V0002__create-pet-table.sql");
    }

    @Test
    void toEndpointMustacheTokens_buildsTestAndIntegrationTestPaths() {
        Map<String, String> tokens = converter.toEndpointMustacheTokens(endpointDescriptor("Pet"));
        assertThat(tokens)
                .containsKey("testBasePackagePath")
                .containsKey("integrationTestBasePackagePath")
                .containsKey("testFixturesBasePackagePath");
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
                .features(Set.of("postgres", "openapi"))
                .build();
    }

    private static EndpointDescriptor endpointDescriptor(String entityName) {
        return EndpointDescriptor.builder()
                .entityName(entityName)
                .route("/" + entityName.toLowerCase())
                .basePackage(BASE_PACKAGE)
                .baseDirectory("/tmp/my-app")
                .flavor(Flavor.WEBMVC)
                .appModule(APP_MODULE)
                .javaVersion("21")
                .features(Set.of("postgres"))
                .build();
    }
}
