package mmm.coffee.metacode.engine;

import java.util.Set;
import mmm.coffee.metacode.core.descriptor.Feature;
import mmm.coffee.metacode.core.descriptor.Flavor;
import mmm.coffee.metacode.core.descriptor.ProjectDescriptor;
import org.jspecify.annotations.NonNull;

/**
 * Exposes feature-presence checks to FreeMarker templates via the "project" variable.
 * Templates call ${project.isWithOpenApi()}, ${project.isWithPostgres()}, etc.
 */
public class ProjectModel {

    private final Set<Feature> features;
    private final String applicationName;
    private final String basePackage;
    private final String basePath;
    private final String schema;
    private final Flavor flavor;

    public ProjectModel(@NonNull ProjectDescriptor d) {
        this.features = d.getFeatures() == null ? Set.of() : d.getFeatures();
        this.applicationName = d.getApplicationName();
        this.basePackage = d.getBasePackage();
        this.basePath = d.getBasePath() != null ? d.getBasePath() : "/";
        this.schema = d.getSchema() != null ? d.getSchema() : "public";
        this.flavor = d.getFlavor();
    }

    public String getApplicationName() {
        return applicationName;
    }

    public String getBasePackage() {
        return basePackage;
    }

    public String getBasePath() {
        return basePath;
    }

    public String getSchema() {
        return schema;
    }

    public boolean isWithPostgres() {
        return features.contains(Feature.POSTGRES);
    }

    public boolean isWithTestContainers() {
        return features.contains(Feature.TESTCONTAINERS);
    }

    public boolean isWithLiquibase() {
        return features.contains(Feature.LIQUIBASE);
    }

    public boolean isWithFlyway() {
        return features.contains(Feature.FLYWAY);
    }

    public boolean isWithOpenApi() {
        return features.contains(Feature.OPENAPI);
    }

    public boolean isWithMongoDb() {
        return features.contains(Feature.MONGODB);
    }

    public boolean isWithKafka() {
        return features.contains(Feature.KAFKA);
    }

    public boolean isWebMvc() {
        return Flavor.WEBMVC == flavor;
    }

    public boolean isWebFlux() {
        return Flavor.WEBFLUX == flavor;
    }

    public boolean isSpringBoot() {
        return Flavor.SPRING_BOOT == flavor;
    }

    public boolean isSpringBatch() {
        return Flavor.SPRING_BATCH == flavor;
    }
}
