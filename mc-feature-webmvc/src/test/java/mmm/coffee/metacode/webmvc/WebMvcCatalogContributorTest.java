package mmm.coffee.metacode.webmvc;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

class WebMvcCatalogContributorTest {

    @Test
    void returnsExpectedCatalogResourcePath() {
        var contributor = new WebMvcCatalogContributor();
        assertThat(contributor.getCatalogResource()).isEqualTo("/spring/catalogs/webmvc.yaml");
    }

    @Test
    void catalogResourceExistsOnClasspath() {
        var contributor = new WebMvcCatalogContributor();
        var stream = getClass().getResourceAsStream(contributor.getCatalogResource());
        assertThat(stream).isNotNull();
    }
}
