package mmm.coffee.metacode.engine;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.Set;
import mmm.coffee.metacode.core.descriptor.Feature;
import mmm.coffee.metacode.core.descriptor.Flavor;
import mmm.coffee.metacode.core.descriptor.ProjectDescriptor;
import org.junit.jupiter.api.Test;

class ProjectModelTest {

    // -----------------------------------------------------------------------
    // Flavor detection
    // -----------------------------------------------------------------------

    @Test
    void shouldRecognizeWebMvcFlavor() {
        var model = new ProjectModel(aWebMvcProjectWithH2AndOpenApi());

        assertThat(model.isWebMvc()).isTrue();
        assertThat(model.isWebFlux()).isFalse();
        assertThat(model.isSpringBoot()).isFalse();
        assertThat(model.isSpringBatch()).isFalse();
    }

    @Test
    void shouldRecognizeWebFluxFlavor() {
        var model = new ProjectModel(aBasicWebFluxProject());

        assertThat(model.isWebFlux()).isTrue();
        assertThat(model.isWebMvc()).isFalse();
        assertThat(model.isSpringBoot()).isFalse();
        assertThat(model.isSpringBatch()).isFalse();
    }

    @Test
    void shouldRecognizeSpringBootFlavor() {
        var descriptor = ProjectDescriptor.builder()
                .flavor(Flavor.SPRING_BOOT)
                .applicationName("boot-app")
                .basePackage("com.example")
                .basePath("/api/v1")
                .features(Set.of())
                .build();

        var model = new ProjectModel(descriptor);

        assertThat(model.isSpringBoot()).isTrue();
        assertThat(model.isWebMvc()).isFalse();
        assertThat(model.isWebFlux()).isFalse();
        assertThat(model.isSpringBatch()).isFalse();
    }

    @Test
    void shouldRecognizeSpringBatchFlavor() {
        var descriptor = ProjectDescriptor.builder()
                .flavor(Flavor.SPRING_BATCH)
                .applicationName("batch-app")
                .basePackage("com.example")
                .basePath("/api/v1")
                .features(Set.of())
                .build();

        var model = new ProjectModel(descriptor);

        assertThat(model.isSpringBatch()).isTrue();
        assertThat(model.isWebMvc()).isFalse();
        assertThat(model.isWebFlux()).isFalse();
        assertThat(model.isSpringBoot()).isFalse();
    }

    // -----------------------------------------------------------------------
    // Feature detection
    // -----------------------------------------------------------------------

    @Test
    void shouldDetectOpenApiFeature() {
        var model = new ProjectModel(aWebMvcProjectWithH2AndOpenApi());

        assertThat(model.isWithOpenApi()).isTrue();
        assertThat(model.isWithPostgres()).isFalse();
        assertThat(model.isWithFlyway()).isFalse();
        assertThat(model.isWithLiquibase()).isFalse();
        assertThat(model.isWithTestContainers()).isFalse();
        assertThat(model.isWithKafka()).isFalse();
        assertThat(model.isWithMongoDb()).isFalse();
    }

    @Test
    void shouldDetectPostgresAndTestContainersFeatures() {
        var model = new ProjectModel(aWebMvcWithPostgresAndTestContainers());

        assertThat(model.isWithPostgres()).isTrue();
        assertThat(model.isWithTestContainers()).isTrue();
        assertThat(model.isWithFlyway()).isFalse();
        assertThat(model.isWithLiquibase()).isFalse();
    }

    @Test
    void shouldDetectFlywayFeature() {
        var model = new ProjectModel(aWebMvcWithPostgresTestContainersFlyway());

        assertThat(model.isWithPostgres()).isTrue();
        assertThat(model.isWithFlyway()).isTrue();
        assertThat(model.isWithTestContainers()).isTrue();
        assertThat(model.isWithLiquibase()).isFalse();
    }

    @Test
    void shouldDetectLiquibaseFeature() {
        var model = new ProjectModel(aWebMvcWithPostgresTestContainersLiquibase());

        assertThat(model.isWithPostgres()).isTrue();
        assertThat(model.isWithLiquibase()).isTrue();
        assertThat(model.isWithTestContainers()).isTrue();
        assertThat(model.isWithFlyway()).isFalse();
    }

    @Test
    void shouldDetectKafkaFeature() {
        var model = new ProjectModel(aWebMvcWithPostgresAndKafka());

        assertThat(model.isWithKafka()).isTrue();
        assertThat(model.isWithPostgres()).isTrue();
    }

    @Test
    void shouldDetectMongoDbFeature() {
        var model = new ProjectModel(aWebMvcWithMongoDb());

        assertThat(model.isWithMongoDb()).isTrue();
        assertThat(model.isWithTestContainers()).isTrue();
        assertThat(model.isWithPostgres()).isFalse();
    }

    @Test
    void shouldDetectMultipleFeaturesOnWebFlux() {
        var model = new ProjectModel(aBasicWebFluxProjectWithPostgresAndTestContainers());

        assertThat(model.isWebFlux()).isTrue();
        assertThat(model.isWithPostgres()).isTrue();
        assertThat(model.isWithTestContainers()).isTrue();
        assertThat(model.isWithFlyway()).isTrue();
        assertThat(model.isWithOpenApi()).isTrue();
    }

    @Test
    void shouldDetectKafkaOnWebFlux() {
        var model = new ProjectModel(aBasicWebFluxWithPostgresAndTestContainersAndKafka());

        assertThat(model.isWebFlux()).isTrue();
        assertThat(model.isWithKafka()).isTrue();
        assertThat(model.isWithPostgres()).isTrue();
    }

    // -----------------------------------------------------------------------
    // Property accessors
    // -----------------------------------------------------------------------

    @Test
    void shouldExposeApplicationName() {
        var model = new ProjectModel(aWebMvcProjectWithH2AndOpenApi());
        assertThat(model.getApplicationName()).isEqualTo("my-web-mvc-app");
    }

    @Test
    void shouldExposeBasePackage() {
        var model = new ProjectModel(aWebMvcProjectWithH2AndOpenApi());
        assertThat(model.getBasePackage()).isEqualTo("com.example");
    }

    @Test
    void shouldExposeBasePath() {
        var model = new ProjectModel(aWebMvcProjectWithH2AndOpenApi());
        assertThat(model.getBasePath()).isEqualTo("/api/v1");
    }

    @Test
    void shouldExposeDefaultSchema() {
        var model = new ProjectModel(aWebMvcProjectWithH2AndOpenApi());
        assertThat(model.getSchema()).isEqualTo("public");
    }

    @Test
    void shouldExposeCustomSchema() {
        var descriptor = ProjectDescriptor.builder()
                .flavor(Flavor.WEBMVC)
                .applicationName("app")
                .basePackage("com.example")
                .basePath("/api/v1")
                .schema("myschema")
                .features(Set.of())
                .build();
        var model = new ProjectModel(descriptor);
        assertThat(model.getSchema()).isEqualTo("myschema");
    }

    // -----------------------------------------------------------------------
    // Edge cases
    // -----------------------------------------------------------------------

    @Test
    void shouldDefaultBasePathToSlash_whenDescriptorBasePathIsNull() {
        var descriptor = ProjectDescriptor.builder()
                .flavor(Flavor.WEBMVC)
                .applicationName("app")
                .basePackage("com.example")
                .basePath(null)
                .features(Set.of())
                .build();

        var model = new ProjectModel(descriptor);

        assertThat(model.getBasePath()).isEqualTo("/");
    }

    @Test
    void shouldTreatNullFeaturesAsEmpty() {
        var descriptor = ProjectDescriptor.builder()
                .flavor(Flavor.WEBMVC)
                .applicationName("app")
                .basePackage("com.example")
                .basePath("/api/v1")
                .features(null)
                .build();

        var model = new ProjectModel(descriptor);

        assertThat(model.isWithPostgres()).isFalse();
        assertThat(model.isWithOpenApi()).isFalse();
        assertThat(model.isWithKafka()).isFalse();
    }

    @Test
    void shouldNotMatchAnyFlavor_whenFlavorIsNull() {
        var descriptor = ProjectDescriptor.builder()
                .flavor(null)
                .applicationName("app")
                .basePackage("com.example")
                .basePath("/api/v1")
                .features(Set.of())
                .build();

        var model = new ProjectModel(descriptor);

        assertThat(model.isWebMvc()).isFalse();
        assertThat(model.isWebFlux()).isFalse();
        assertThat(model.isSpringBoot()).isFalse();
        assertThat(model.isSpringBatch()).isFalse();
    }

    // -----------------------------------------------------------------------
    // Descriptor factory methods
    // -----------------------------------------------------------------------

    ProjectDescriptor aWebMvcProjectWithH2AndOpenApi() {
        return ProjectDescriptor.builder()
                .flavor(Flavor.WEBMVC)
                .applicationName("my-web-mvc-app")
                .basePackage("com.example")
                .basePath("/api/v1")
                .features(Set.of(Feature.OPENAPI))
                .build();
    }

    ProjectDescriptor aWebMvcWithPostgresAndTestContainers() {
        return ProjectDescriptor.builder()
                .flavor(Flavor.WEBMVC)
                .applicationName("my-web-mvc-app")
                .basePackage("com.example")
                .basePath("/api/v1")
                .features(Set.of(Feature.POSTGRES, Feature.TESTCONTAINERS))
                .build();
    }

    ProjectDescriptor aWebMvcWithPostgresTestContainersFlyway() {
        return ProjectDescriptor.builder()
                .flavor(Flavor.WEBMVC)
                .applicationName("my-web-mvc-app")
                .basePackage("com.example")
                .basePath("/api/v1")
                .features(Set.of(Feature.POSTGRES, Feature.FLYWAY, Feature.TESTCONTAINERS))
                .build();
    }

    ProjectDescriptor aWebMvcWithPostgresTestContainersLiquibase() {
        return ProjectDescriptor.builder()
                .flavor(Flavor.WEBMVC)
                .applicationName("webmvc-postgres-tc-liquibase")
                .basePath("/api/v1")
                .basePackage("com.example")
                .features(Set.of(Feature.POSTGRES, Feature.LIQUIBASE, Feature.TESTCONTAINERS))
                .build();
    }

    ProjectDescriptor aWebMvcWithPostgresAndKafka() {
        return ProjectDescriptor.builder()
                .flavor(Flavor.WEBMVC)
                .applicationName("webmvc-postgres-kafka")
                .basePath("/api/v1")
                .basePackage("com.example")
                .features(Set.of(Feature.POSTGRES, Feature.KAFKA, Feature.TESTCONTAINERS))
                .build();
    }

    ProjectDescriptor aWebMvcWithMongoDb() {
        return ProjectDescriptor.builder()
                .flavor(Flavor.WEBMVC)
                .applicationName("webmvc-mongodb")
                .basePath("/api/v1")
                .basePackage("com.example")
                .features(Set.of(Feature.MONGODB, Feature.TESTCONTAINERS))
                .build();
    }

    ProjectDescriptor aBasicWebFluxProject() {
        return ProjectDescriptor.builder()
                .flavor(Flavor.WEBFLUX)
                .applicationName("webflux-h2-openapi")
                .basePath("/api/v1")
                .basePackage("com.example")
                .features(Set.of(Feature.OPENAPI))
                .build();
    }

    ProjectDescriptor aBasicWebFluxProjectWithPostgresAndTestContainers() {
        return ProjectDescriptor.builder()
                .flavor(Flavor.WEBFLUX)
                .applicationName("webflux-postgres-testcontainers")
                .basePath("/api/v1")
                .basePackage("com.example")
                .features(Set.of(Feature.POSTGRES, Feature.TESTCONTAINERS, Feature.FLYWAY, Feature.OPENAPI))
                .build();
    }

    ProjectDescriptor aBasicWebFluxWithPostgresAndTestContainersAndKafka() {
        return ProjectDescriptor.builder()
                .flavor(Flavor.WEBFLUX)
                .applicationName("webflux-postgres-tc-kafka")
                .basePath("/api/v1")
                .basePackage("com.example")
                .features(Set.of(
                        Feature.POSTGRES, Feature.TESTCONTAINERS, Feature.FLYWAY, Feature.OPENAPI, Feature.KAFKA))
                .build();
    }
}
