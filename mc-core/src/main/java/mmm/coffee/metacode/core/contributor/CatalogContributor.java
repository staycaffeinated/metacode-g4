package mmm.coffee.metacode.core.contributor;

/**
 * Implemented by each feature module to register its catalog YAML.
 * The engine calls {@link #getCatalogResource()} to load and merge entries.
 *
 * Example implementation in mc-feature-webmvc:
 * <pre>
 * {@code @Component}
 * public class WebMvcCatalogContributor implements CatalogContributor {
 *     public String getCatalogResource() {
 *         return "/spring/catalogs/webmvc.yaml";
 *     }
 * }
 * </pre>
 */
public interface CatalogContributor {

    /**
     * @return classpath resource path to this feature's root catalog YAML
     */
    String getCatalogResource();
}
