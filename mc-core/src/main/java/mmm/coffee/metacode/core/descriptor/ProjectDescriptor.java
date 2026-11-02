package mmm.coffee.metacode.core.descriptor;

import java.util.HashSet;
import java.util.Set;
import lombok.Builder;
import lombok.Value;

/**
 * Captures the user's choices from the CLI: target flavor, active features,
 * and project coordinates. Passed through the generation pipeline.
 */
@Value
@Builder
public class ProjectDescriptor {

    private String applicationName;
    private String basePackage;
    private String baseDirectory;
    private String basePath;

    /**
     * The project flavor selected by the user.
     * Matched against {@code when.flavor} in catalog entries via {@link Flavor#id()}.
     */
    private Flavor flavor;

    /**
     * Active integrations matched against {@code when.features} in catalog entries.
     */
    @Builder.Default
    private Set<Feature> features = new HashSet<>();

    private String javaVersion;

    /**
     * The subproject directory containing application source code.
     * Defaults to "application" for multi-module builds.
     */
    @Builder.Default
    private String appModule = "application";

    /** PostgreSQL schema name. Defaults to "public". */
    @Builder.Default
    private String schema = "public";

    /** Package layout architecture. Defaults to hexagonal. */
    @Builder.Default
    private Architecture architecture = Architecture.HEXAGONAL;
}
