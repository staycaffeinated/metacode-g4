package mmm.coffee.metacode.webflux;

import mmm.coffee.metacode.core.contributor.CatalogContributor;
import org.springframework.stereotype.Component;

/**
 * Registers the webflux catalog.
 * All entries carry {@code when: flavor: [webflux]} so they only render
 * when the user selected the webflux flavor.
 * Feature-gated entries (postgres, liquibase, etc.) add {@code features:} conditions.
 */
@Component
public class WebFluxCatalogContributor implements CatalogContributor {

    static final String CATALOG_RESOURCE = "/spring/catalogs/webflux.yaml";

    @Override
    public String getCatalogResource() {
        return CATALOG_RESOURCE;
    }
}
