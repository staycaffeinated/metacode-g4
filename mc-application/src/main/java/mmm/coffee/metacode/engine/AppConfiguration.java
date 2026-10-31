package mmm.coffee.metacode.engine;

import mmm.coffee.metacode.core.archetype.PackageLayout;
import mmm.coffee.metacode.core.catalog.CatalogReader;
import mmm.coffee.metacode.core.renderer.TemplateRenderer;
import mmm.coffee.metacode.engine.renderer.FreemarkerTemplateRenderer;
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
    PackageLayout packageLayout() {
        return PackageLayout.loadDefault();
    }
}
