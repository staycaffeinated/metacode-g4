package mmm.coffee.metacode.javaapp;

import mmm.coffee.metacode.core.contributor.CatalogContributor;
import org.springframework.stereotype.Component;

@Component
public class JavaAppCatalogContributor implements CatalogContributor {

    static final String CATALOG_RESOURCE = "/spring/catalogs/javaapp.yaml";

    @Override
    public String getCatalogResource() {
        return CATALOG_RESOURCE;
    }
}
