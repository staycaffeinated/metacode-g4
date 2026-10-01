package mmm.coffee.metacode.webmvc;

import mmm.coffee.metacode.core.contributor.CatalogContributor;

/**
 * Registers the webmvc catalog.
 * All entries carry {@code when: flavor: [webmvc]} so they only render
 * when the user selected the webmvc flavor.
 * Feature-gated entries (postgres, liquibase, etc.) add {@code features:} conditions.
 */
public class WebMvcCatalogContributor implements CatalogContributor {

    static final String CATALOG_RESOURCE = "/spring/catalogs/webmvc.yaml";

    @Override
    public String getCatalogResource() {
        return CATALOG_RESOURCE;
    }
}
