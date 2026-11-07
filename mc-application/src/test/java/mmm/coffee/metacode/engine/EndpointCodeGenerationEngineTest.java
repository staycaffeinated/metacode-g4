package mmm.coffee.metacode.engine;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.Set;
import mmm.coffee.metacode.core.catalog.CatalogEntry;
import mmm.coffee.metacode.core.catalog.TemplateFacet;
import mmm.coffee.metacode.core.descriptor.Architecture;
import mmm.coffee.metacode.core.descriptor.EndpointDescriptor;
import mmm.coffee.metacode.core.descriptor.Feature;
import mmm.coffee.metacode.core.descriptor.Flavor;
import mmm.coffee.metacode.core.exceptions.MetacodeException;
import mmm.coffee.metacode.core.renderer.TemplateRenderer;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class EndpointCodeGenerationEngineTest {

    @Mock
    CatalogRegistry registry;

    @Mock
    TemplateRenderer renderer;

    @Mock
    EndpointTemplateModelConverter converter;

    @Mock
    ContentToFileWriter writer;

    @InjectMocks
    EndpointCodeGenerationEngine engine;

    private static final EndpointDescriptor DESCRIPTOR = EndpointDescriptor.builder()
            .entityName("Pet")
            .route("/pet")
            .basePackage("com.example.demo")
            .baseDirectory("/tmp/my-app")
            .appModule("application")
            .flavor(Flavor.WEBMVC)
            .javaVersion("21")
            .features(Set.of(Feature.POSTGRES))
            .architecture(Architecture.HEXAGONAL)
            .build();

    // ── doPreprocessing ───────────────────────────────────────────────────────

    @Test
    void doPreprocessing_returnsSameEngineInstance() {
        assertThat(engine.doPreprocessing(DESCRIPTOR)).isSameAs(engine);
    }

    // ── generateCode — empty catalog ──────────────────────────────────────────

    @Test
    void generateCode_returnsZero_whenNoCatalogEntries() {
        when(registry.endpointEntriesFor(DESCRIPTOR)).thenReturn(List.of());
        when(converter.toFtlModel(DESCRIPTOR)).thenReturn(Map.of());
        when(converter.toMustacheTokens(DESCRIPTOR)).thenReturn(Map.of());

        assertThat(engine.generateCode(DESCRIPTOR)).isZero();
        verifyNoInteractions(renderer, writer);
    }

    // ── generateCode — line 47: null destination → skip ──────────────────────

    @Test
    void generateCode_skipsWrite_whenFacetDestinationIsNull() {
        when(registry.endpointEntriesFor(DESCRIPTOR))
                .thenReturn(List.of(entry("Pet", facet("main", "/tpl/Pet.ftl", null))));
        when(converter.toFtlModel(DESCRIPTOR)).thenReturn(Map.of());
        when(converter.toMustacheTokens(DESCRIPTOR)).thenReturn(Map.of());

        engine.generateCode(DESCRIPTOR);

        verifyNoInteractions(renderer, writer);
    }

    // ── generateCode — line 47: empty destination → skip ─────────────────────

    @Test
    void generateCode_skipsWrite_whenFacetDestinationIsEmpty() {
        when(registry.endpointEntriesFor(DESCRIPTOR))
                .thenReturn(List.of(entry("Pet", facet("main", "/tpl/Pet.ftl", ""))));
        when(converter.toFtlModel(DESCRIPTOR)).thenReturn(Map.of());
        when(converter.toMustacheTokens(DESCRIPTOR)).thenReturn(Map.of());

        engine.generateCode(DESCRIPTOR);

        verifyNoInteractions(renderer, writer);
    }

    // ── generateCode — explicit destination → renders and writes ──────────────

    @Test
    void generateCode_rendersAndWrites_whenFacetHasExplicitDestination() throws IOException {
        when(registry.endpointEntriesFor(DESCRIPTOR))
                .thenReturn(List.of(
                        entry("Pet", facet("main", "/tpl/Pet.ftl", "{{basePackagePath}}/pet/PetController.java"))));
        when(converter.toFtlModel(DESCRIPTOR)).thenReturn(Map.of());
        when(converter.toMustacheTokens(DESCRIPTOR))
                .thenReturn(Map.of("basePackagePath", "application/src/main/java/com/example/demo"));
        when(renderer.render(eq("/tpl/Pet.ftl"), any())).thenReturn("// generated");

        engine.generateCode(DESCRIPTOR);

        verify(writer)
                .write(
                        "/tmp/my-app",
                        "application/src/main/java/com/example/demo/pet/PetController.java",
                        "// generated");
    }

    // ── generateCode — IOException → MetacodeException ────────────────────────

    @Test
    void generateCode_throwsMetacodeException_whenWriterThrowsIOException() throws IOException {
        doThrow(new IOException("disk full")).when(writer).write(any(), any(), any());

        when(registry.endpointEntriesFor(DESCRIPTOR))
                .thenReturn(List.of(entry("Pet", facet("main", "/tpl/Pet.ftl", "some/Pet.java"))));
        when(converter.toFtlModel(DESCRIPTOR)).thenReturn(Map.of());
        when(converter.toMustacheTokens(DESCRIPTOR)).thenReturn(Map.of());
        when(renderer.render(any(), any())).thenReturn("content");

        assertThatThrownBy(() -> engine.generateCode(DESCRIPTOR))
                .isInstanceOf(MetacodeException.class)
                .hasRootCauseInstanceOf(IOException.class)
                .hasRootCauseMessage("disk full");
    }

    // ── helpers ───────────────────────────────────────────────────────────────

    private static CatalogEntry entry(String archetype, TemplateFacet... facets) {
        CatalogEntry e = new CatalogEntry();
        e.setArchetype(archetype);
        e.setFacets(List.of(facets));
        return e;
    }

    private static TemplateFacet facet(String facetType, String sourceTemplate, String destination) {
        TemplateFacet f = new TemplateFacet();
        f.setFacet(facetType);
        f.setSourceTemplate(sourceTemplate);
        f.setDestination(destination);
        return f;
    }
}
