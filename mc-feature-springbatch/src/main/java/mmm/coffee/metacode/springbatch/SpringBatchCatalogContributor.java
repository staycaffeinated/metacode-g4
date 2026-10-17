package mmm.coffee.metacode.springbatch;

import mmm.coffee.metacode.core.contributor.CatalogContributor;

public class SpringBatchCatalogContributor implements CatalogContributor {

    static final String CATALOG_RESOURCE = "/spring/catalogs/springbatch.yaml";

    @Override
    public String getCatalogResource() {
        return CATALOG_RESOURCE;
    }
}
