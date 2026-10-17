package mmm.coffee.metacode.javaapp;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

class JavaAppCatalogContributorTest {

    @Test
    void returnsExpectedCatalogResourcePath() {
        var contributor = new JavaAppCatalogContributor();
        assertThat(contributor.getCatalogResource()).isEqualTo("/spring/catalogs/javaapp.yaml");
    }

    @Test
    void catalogResourceExistsOnClasspath() {
        var contributor = new JavaAppCatalogContributor();
        var stream = getClass().getResourceAsStream(contributor.getCatalogResource());
        assertThat(stream).isNotNull();
    }
}
