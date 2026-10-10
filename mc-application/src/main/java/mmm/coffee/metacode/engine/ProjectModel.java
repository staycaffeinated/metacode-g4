package mmm.coffee.metacode.engine;

import java.util.Set;
import mmm.coffee.metacode.core.descriptor.ProjectDescriptor;

/**
 * Exposes feature-presence checks to FreeMarker templates via the "project" variable.
 * Templates call ${project.isWithOpenApi()}, ${project.isWithPostgres()}, etc.
 */
public class ProjectModel {

    private final Set<String> features;
    private final String applicationName;
    private final String basePackage;
    private final String basePath;
    private final String schema;
    private final String flavor;

    public ProjectModel(ProjectDescriptor d) {
        this.features = d.getFeatures();
        this.applicationName = d.getApplicationName();
        this.basePackage = d.getBasePackage();
        this.basePath = d.getBasePath() != null ? d.getBasePath() : "/";
        this.schema = "public";
        this.flavor = d.getFlavor() != null ? d.getFlavor() : "";
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
        return features.contains("postgres");
    }

    public boolean isWithTestContainers() {
        return features.contains("testcontainers");
    }

    public boolean isWithLiquibase() {
        return features.contains("liquibase");
    }

    public boolean isWithFlyway() {
        return features.contains("flyway");
    }

    public boolean isWithOpenApi() {
        return features.contains("openapi");
    }

    public boolean isWithMongoDb() {
        return features.contains("mongodb");
    }

    public boolean isWithKafka() {
        return features.contains("kafka");
    }

    public boolean isWebMvc() {
        return "webmvc".equalsIgnoreCase(flavor);
    }

    public boolean isWebFlux() {
        return "webflux".equalsIgnoreCase(flavor);
    }

    public boolean isSpringBoot() {
        return "springboot".equalsIgnoreCase(flavor);
    }

    public boolean isSpringBatch() {
        return "springbatch".equalsIgnoreCase(flavor);
    }
}
