package mmm.coffee.metacode.springbatch;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

class SpringBatchCatalogContributorTest {

    @Test
    void returnsExpectedCatalogResourcePath() {
        var contributor = new SpringBatchCatalogContributor();
        assertThat(contributor.getCatalogResource()).isEqualTo("/spring/catalogs/springbatch.yaml");
    }

    @Test
    void catalogResourceExistsOnClasspath() {
        var contributor = new SpringBatchCatalogContributor();
        var stream = getClass().getResourceAsStream(contributor.getCatalogResource());
        assertThat(stream).isNotNull();
    }
}
