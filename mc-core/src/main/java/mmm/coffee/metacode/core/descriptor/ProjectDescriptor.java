package mmm.coffee.metacode.core.descriptor;

import java.util.HashSet;
import java.util.Set;
import lombok.Builder;
import lombok.Data;

/**
 * Captures the user's choices from the CLI: target flavor, active features,
 * and project coordinates. Passed through the generation pipeline.
 */
@Data
@Builder
public class ProjectDescriptor {

    private String applicationName;
    private String basePackage;
    private String baseDirectory;
    private String basePath;

    /**
     * The project flavor: "webmvc", "webflux", "springbatch", or "springboot".
     * Matched against {@code when.flavor} in catalog entries.
     */
    private String flavor;

    /**
     * Active integrations: e.g. "postgres", "mongodb", "liquibase", "flyway",
     * "testcontainers", "openapi". Matched against {@code when.features} in catalog entries.
     */
    @Builder.Default
    private Set<String> features = new HashSet<>();

    private String javaVersion;

    /**
     * The subproject directory containing application source code.
     * Defaults to "application" for multi-module builds.
     */
    @Builder.Default
    private String appModule = "application";
}
