package mmm.coffee.metacode.engine;

import static org.assertj.core.api.Assertions.assertThat;

import java.time.Year;
import java.time.ZoneId;
import java.util.Map;
import java.util.Set;
import mmm.coffee.metacode.core.archetype.ArchetypeModel;
import mmm.coffee.metacode.core.descriptor.EndpointDescriptor;
import mmm.coffee.metacode.core.descriptor.Feature;
import mmm.coffee.metacode.core.descriptor.Flavor;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

@SuppressWarnings({"java:S8692" // System clock tests found here only verify the current year
})
class EndpointTemplateModelConverterTest {

    private static final String BASE_PACKAGE = "com.example.demo";
    private static final String APP_MODULE = "application";
    private static final String PACKAGE_PATH = "com/example/demo";

    private EndpointTemplateModelConverter converter;

    @BeforeEach
    void setUp() {
        converter = new EndpointTemplateModelConverter();
    }

    // -------------------------------------------------------------------------
    // toFtlModel
    // -------------------------------------------------------------------------

    @Test
    void toFtlModel_mapsBasePackage() {
        var model = converter.toFtlModel(endpointDescriptor("Pet"));
        assertThat(model).containsEntry("basePackage", BASE_PACKAGE);
    }

    @Test
    void toFtlModel_convertsDotsToSlashesInBasePackagePath() {
        var model = converter.toFtlModel(endpointDescriptor("Pet"));
        assertThat(model).containsEntry("basePackagePath", PACKAGE_PATH);
    }

    @Test
    void toFtlModel_mapsFlavorAndFeatures() {
        var model = converter.toFtlModel(endpointDescriptor("Pet"));
        assertThat(model).containsEntry("flavor", "webmvc").containsKey("features");
    }

    @Test
    void toFtlModel_includesCurrentYear() {
        int expectedYear = Year.now(ZoneId.systemDefault()).getValue();
        var model = converter.toFtlModel(endpointDescriptor("Pet"));
        assertThat(model).containsEntry("YEAR", expectedYear);
    }

    @Test
    void toFtlModel_includesEndpointModelInstance() {
        var model = converter.toFtlModel(endpointDescriptor("Pet"));
        assertThat(model).containsKey("endpoint");
        assertThat(model.get("endpoint")).isInstanceOf(EndpointModel.class);
    }

    @Test
    void toFtlModel_buildsControllerArchetypeWithEntityName() {
        var model = converter.toFtlModel(endpointDescriptor("Pet"));
        assertThat(model).containsKey("Controller");
        ArchetypeModel controller = (ArchetypeModel) model.get("Controller");
        assertThat(controller.className()).isEqualTo("PetController");
    }

    @Test
    void toFtlModel_buildsServiceImplArchetype() {
        var model = converter.toFtlModel(endpointDescriptor("Pet"));
        assertThat(model).containsKey("ServiceImpl");
        ArchetypeModel svc = (ArchetypeModel) model.get("ServiceImpl");
        assertThat(svc.className()).isEqualTo("PetService");
    }

    @Test
    void toFtlModel_buildsEntityArchetype() {
        var model = converter.toFtlModel(endpointDescriptor("Pet"));
        ArchetypeModel entity = (ArchetypeModel) model.get("Entity");
        assertThat(entity.className()).isEqualTo("PetEntity");
        assertThat(entity.packageName()).contains("persistence");
    }

    @Test
    void toFtlModel_buildsEntityResourceArchetype() {
        var model = converter.toFtlModel(endpointDescriptor("Pet"));
        ArchetypeModel entityResource = (ArchetypeModel) model.get("EntityResource");
        assertThat(entityResource.className()).isEqualTo("Pet");
        assertThat(entityResource.packageName()).contains("domain");
    }

    @Test
    void toFtlModel_buildsRepositoryArchetype() {
        var model = converter.toFtlModel(endpointDescriptor("Pet"));
        ArchetypeModel repo = (ArchetypeModel) model.get("Repository");
        assertThat(repo.className()).isEqualTo("PetRepository");
    }

    // -------------------------------------------------------------------------
    // toMustacheTokens
    // -------------------------------------------------------------------------

    @Test
    void toMustacheTokens_mapsBasePackage() {
        Map<String, String> tokens = converter.toMustacheTokens(endpointDescriptor("Pet"));
        assertThat(tokens).containsEntry("basePackage", BASE_PACKAGE);
    }

    @Test
    void toMustacheTokens_mapsEntityName() {
        Map<String, String> tokens = converter.toMustacheTokens(endpointDescriptor("Pet"));
        assertThat(tokens).containsEntry("entityName", "Pet");
    }

    @Test
    void toMustacheTokens_lowercasesEntityName() {
        Map<String, String> tokens = converter.toMustacheTokens(endpointDescriptor("Pet"));
        assertThat(tokens).containsEntry("lowerCaseEntityName", "pet");
    }

    @Test
    void toMustacheTokens_buildsBasePackagePath() {
        Map<String, String> tokens = converter.toMustacheTokens(endpointDescriptor("Pet"));
        assertThat(tokens).containsEntry("basePackagePath", APP_MODULE + "/src/main/java/" + PACKAGE_PATH);
    }

    @Test
    void toMustacheTokens_buildsCreateTableScriptName() {
        Map<String, String> tokens = converter.toMustacheTokens(endpointDescriptor("Pet"));
        assertThat(tokens).containsEntry("createTableScriptName", "V0002__create-pet-table.sql");
    }

    @Test
    void toMustacheTokens_buildsTestAndIntegrationTestPaths() {
        Map<String, String> tokens = converter.toMustacheTokens(endpointDescriptor("Pet"));
        assertThat(tokens)
                .containsKey("testBasePackagePath")
                .containsKey("integrationTestBasePackagePath")
                .containsKey("testFixturesBasePackagePath");
    }

    // -------------------------------------------------------------------------
    // helpers
    // -------------------------------------------------------------------------

    private static EndpointDescriptor endpointDescriptor(String entityName) {
        return EndpointDescriptor.builder()
                .entityName(entityName)
                .route("/" + entityName.toLowerCase())
                .basePackage(BASE_PACKAGE)
                .baseDirectory("/tmp/my-app")
                .flavor(Flavor.WEBMVC)
                .appModule(APP_MODULE)
                .javaVersion("21")
                .features(Set.of(Feature.POSTGRES))
                .build();
    }
}
