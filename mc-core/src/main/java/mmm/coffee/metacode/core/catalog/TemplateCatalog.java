package mmm.coffee.metacode.core.catalog;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import java.util.ArrayList;
import java.util.List;
import lombok.Data;

/**
 * Root object of a catalog YAML file.
 *
 * <pre>
 * includes:
 *   - /spring/catalogs/springboot-base.yaml
 * entries:
 *   - scope: project
 *     archetype: Controller
 *     when:
 *       flavor: [webmvc]
 *     facets:
 *       - facet: main
 *         sourceTemplate: /spring/webmvc/Controller.ftl
 *         destination: "{{basePackagePath}}/..."
 * </pre>
 */
@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public class TemplateCatalog {

    /** Classpath paths to other catalogs whose entries are merged in */
    private List<String> includes = new ArrayList<>();

    private List<CatalogEntry> entries = new ArrayList<>();
}
