package mmm.coffee.metacode.javaapp;

import mmm.coffee.metacode.core.contributor.CatalogContributor;

public class JavaAppCatalogContributor implements CatalogContributor {

    static final String CATALOG_RESOURCE = "/spring/catalogs/javaapp.yaml";

    @Override
    public String getCatalogResource() {
        return CATALOG_RESOURCE;
    }
}
