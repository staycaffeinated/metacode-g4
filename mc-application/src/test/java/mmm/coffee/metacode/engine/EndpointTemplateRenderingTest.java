package mmm.coffee.metacode.engine;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatNoException;

import java.util.List;
import java.util.Set;
import mmm.coffee.metacode.core.archetype.PackageLayout;
import mmm.coffee.metacode.core.catalog.CatalogReader;
import mmm.coffee.metacode.core.contributor.CatalogContributor;
import mmm.coffee.metacode.core.descriptor.EndpointDescriptor;
import mmm.coffee.metacode.core.descriptor.Flavor;
import mmm.coffee.metacode.core.renderer.FreemarkerTemplateRenderer;
import mmm.coffee.metacode.springboot.SpringBootCatalogContributor;
import mmm.coffee.metacode.webflux.WebFluxCatalogContributor;
import mmm.coffee.metacode.webmvc.WebMvcCatalogContributor;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.EnumSource;

/**
 * Verifies that every endpoint template renders without FreeMarker errors,
 * meaning every variable the template references exists in the model.
 *
 * Uses a no-op writer so nothing is written to disk.
 */
class EndpointTemplateRenderingTest {

    EndpointCodeGenerationEngine engineUnderTest;

    @BeforeEach
    void setUp() {
        CatalogReader catalogReader = new CatalogReader();
        List<CatalogContributor> contributors = List.of(
                new SpringBootCatalogContributor(), new WebMvcCatalogContributor(), new WebFluxCatalogContributor());
        CatalogRegistry registry = new CatalogRegistry(contributors, catalogReader);
        FreemarkerTemplateRenderer renderer = new FreemarkerTemplateRenderer();
        PackageLayout packageLayout = PackageLayout.loadDefault();
        TemplateModelConverter converter = new TemplateModelConverter(packageLayout);

        // No-op writer: renders templates but discards output
        ContentToFileWriter nullWriter = new ContentToFileWriter() {
            @Override
            public void write(String baseDir, String path, String content) {
                /* discard */
            }
        };

        engineUnderTest = new EndpointCodeGenerationEngine(registry, renderer, converter, nullWriter);
    }

    @ParameterizedTest(name = "flavor={0}, all templates render")
    @EnumSource(
            value = Flavor.class,
            names = {"WEBMVC", "WEBFLUX"})
    void shouldRenderAllEndpointTemplatesWithoutError(Flavor flavor) {
        EndpointDescriptor descriptor = EndpointDescriptor.builder()
                .entityName("Pet")
                .route("/pets")
                .flavor(flavor)
                .basePackage("org.example.petstore")
                .basePath("/petstore")
                .baseDirectory("/tmp")
                .appModule("application")
                .javaVersion("21")
                .features(Set.of())
                .build();

        assertThatNoException().isThrownBy(() -> {
            int exitCode = engineUnderTest.doPreprocessing(descriptor).generateCode(descriptor);
            assertThat(exitCode).isZero();
        });
    }

    @ParameterizedTest(name = "flavor={0} with postgres+openapi+testcontainers, all templates render")
    @EnumSource(
            value = Flavor.class,
            names = {"WEBMVC", "WEBFLUX"})
    void shouldRenderAllEndpointTemplatesWithFeaturesEnabled(Flavor flavor) {
        EndpointDescriptor descriptor = EndpointDescriptor.builder()
                .entityName("Pet")
                .route("/pets")
                .flavor(flavor)
                .basePackage("org.example.petstore")
                .basePath("/petstore")
                .baseDirectory("/tmp")
                .appModule("application")
                .javaVersion("21")
                .features(Set.of("postgres", "openapi", "testcontainers"))
                .build();

        assertThatNoException().isThrownBy(() -> {
            int exitCode = engineUnderTest.doPreprocessing(descriptor).generateCode(descriptor);
            assertThat(exitCode).isZero();
        });
    }
}
