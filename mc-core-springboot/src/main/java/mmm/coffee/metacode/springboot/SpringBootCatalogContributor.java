package mmm.coffee.metacode.springboot;

import mmm.coffee.metacode.core.contributor.CatalogContributor;

/**
 * Registers the springboot-base catalog, which contains entries for
 * the project scaffold common to all flavors: Application class,
 * application.yml, .gitignore, README, lombok.config.
 *
 * All other flavor modules include this catalog via their own catalog's
 * {@code includes:} list — so entries here render for every flavor.
 */
public class SpringBootCatalogContributor implements CatalogContributor {

    static final String CATALOG_RESOURCE = "/spring/catalogs/springboot-base.yaml";

    @Override
    public String getCatalogResource() {
        return CATALOG_RESOURCE;
    }
}
