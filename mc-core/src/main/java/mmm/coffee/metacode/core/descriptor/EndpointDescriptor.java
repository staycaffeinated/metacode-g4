package mmm.coffee.metacode.core.descriptor;

import java.util.HashSet;
import java.util.Set;
import lombok.Builder;
import lombok.Data;

/**
 * Captures the user's choices for 'create endpoint': entity name, route,
 * and project settings read back from metacode.properties.
 */
@Data
@Builder
public class EndpointDescriptor {

    private String entityName;
    private String route;

    // Read from metacode.properties
    private String flavor;
    private String basePackage;
    private String basePath;
    private String baseDirectory;
    private String javaVersion;

    @Builder.Default
    private String appModule = "application";

    @Builder.Default
    private Set<String> features = new HashSet<>();
}
