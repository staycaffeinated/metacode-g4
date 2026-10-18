package mmm.coffee.metacode.webflux;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

class WebFluxCatalogContributorTest {

    @Test
    void returnsExpectedCatalogResourcePath() {
        var contributor = new WebFluxCatalogContributor();
        assertThat(contributor.getCatalogResource()).isEqualTo("/spring/catalogs/webflux.yaml");
    }

    @Test
    void catalogResourceExistsOnClasspath() {
        var contributor = new WebFluxCatalogContributor();
        var stream = getClass().getResourceAsStream(contributor.getCatalogResource());
        assertThat(stream).isNotNull();
    }
}
