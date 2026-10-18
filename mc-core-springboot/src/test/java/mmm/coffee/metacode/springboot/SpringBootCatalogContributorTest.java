package mmm.coffee.metacode.springboot;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

class SpringBootCatalogContributorTest {

    @Test
    void returnsExpectedCatalogResourcePath() {
        var contributor = new SpringBootCatalogContributor();
        assertThat(contributor.getCatalogResource()).isEqualTo("/spring/catalogs/springboot-base.yaml");
    }

    @Test
    void catalogResourceExistsOnClasspath() {
        var contributor = new SpringBootCatalogContributor();
        var stream = getClass().getResourceAsStream(contributor.getCatalogResource());
        assertThat(stream).isNotNull();
    }
}
