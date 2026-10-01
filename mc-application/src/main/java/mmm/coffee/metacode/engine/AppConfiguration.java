package mmm.coffee.metacode.engine;

import mmm.coffee.metacode.core.catalog.CatalogReader;
import mmm.coffee.metacode.core.contributor.CatalogContributor;
import mmm.coffee.metacode.core.renderer.FreemarkerTemplateRenderer;
import mmm.coffee.metacode.core.renderer.TemplateRenderer;
import mmm.coffee.metacode.springboot.SpringBootCatalogContributor;
import mmm.coffee.metacode.webflux.WebFluxCatalogContributor;
import mmm.coffee.metacode.webmvc.WebMvcCatalogContributor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class AppConfiguration {

    @Bean
    CatalogReader catalogReader() {
        return new CatalogReader();
    }

    @Bean
    TemplateRenderer templateRenderer() {
        return new FreemarkerTemplateRenderer();
    }

    @Bean
    CatalogContributor springBootCatalogContributor() {
        return new SpringBootCatalogContributor();
    }

    @Bean
    CatalogContributor webMvcCatalogContributor() {
        return new WebMvcCatalogContributor();
    }

    @Bean
    CatalogContributor webFluxCatalogContributor() {
        return new WebFluxCatalogContributor();
    }
}
