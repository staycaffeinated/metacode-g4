package mmm.coffee.metacode.engine;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

import java.io.IOException;
import java.nio.file.Path;
import java.util.List;
import java.util.Map;
import mmm.coffee.metacode.core.archetype.ArchetypeModel;
import mmm.coffee.metacode.core.catalog.CatalogEntry;
import mmm.coffee.metacode.core.catalog.TemplateFacet;
import mmm.coffee.metacode.core.descriptor.ProjectDescriptor;
import mmm.coffee.metacode.core.exceptions.MetacodeException;
import mmm.coffee.metacode.core.renderer.TemplateRenderer;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.junit.jupiter.api.io.TempDir;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class CodeGenerationEngineTest {

    @Mock
    CatalogRegistry registry;

    @Mock
    TemplateRenderer renderer;

    @Mock
    TemplateModelConverter converter;

    @Mock
    ContentWriter writer;

    @InjectMocks
    CodeGenerationEngine engine;

    // -------------------------------------------------------------------------
    // doPreprocessing
    // -------------------------------------------------------------------------

    @Test
    void doPreprocessing_returnsEngineInstance(@TempDir Path tempDir) {
        var result = engine.doPreprocessing(descriptor(tempDir));
        assertThat(result).isSameAs(engine);
    }

    @Test
    void doPreprocessing_writesMetacodePropertiesFile(@TempDir Path tempDir) {
        engine.doPreprocessing(descriptor(tempDir));
        assertThat(tempDir.resolve("metacode.properties")).exists();
    }

    @Test
    void doPreprocessing_usesDefaults_whenDescriptorFieldsAreNull(@TempDir Path tempDir) {
        ProjectDescriptor sparse =
                ProjectDescriptor.builder().baseDirectory(tempDir.toString()).build();
        assertThatCode(() -> engine.doPreprocessing(sparse)).doesNotThrowAnyException();
        assertThat(tempDir.resolve("metacode.properties")).exists();
    }

    @Test
    void doPreprocessing_throwsMetacodeException_whenBaseDirectoryIsUnwritable() {
        ProjectDescriptor d =
                ProjectDescriptor.builder().baseDirectory("/no/such/path/xyz").build();
        assertThatThrownBy(() -> engine.doPreprocessing(d)).isInstanceOf(MetacodeException.class);
    }

    // -------------------------------------------------------------------------
    // generateCode — empty catalog
    // -------------------------------------------------------------------------

    @Test
    void generateCode_returnsZero_whenNoCatalogEntries(@TempDir Path tempDir) {
        ProjectDescriptor d = descriptor(tempDir);
        when(registry.projectEntriesFor(d)).thenReturn(List.of());
        when(converter.toFtlModel(d)).thenReturn(Map.of());
        when(converter.toMustacheTokens(d)).thenReturn(Map.of());

        assertThat(engine.generateCode(d)).isZero();
        verifyNoInteractions(renderer, writer);
    }

    // -------------------------------------------------------------------------
    // generateCode — explicit destination in catalog entry
    // -------------------------------------------------------------------------

    @Test
    void generateCode_rendersAndWrites_whenFacetHasExplicitDestination(@TempDir Path tempDir) throws IOException {
        ProjectDescriptor d = descriptor(tempDir);
        CatalogEntry entry = entry("MyType", facet("main", "/tpl/Foo.ftl", "{{basePackagePath}}/Foo.java"));

        when(registry.projectEntriesFor(d)).thenReturn(List.of(entry));
        when(converter.toFtlModel(d)).thenReturn(Map.of());
        when(converter.toMustacheTokens(d)).thenReturn(Map.of("basePackagePath", "app/src/main/java/com/example"));
        when(renderer.render(eq("/tpl/Foo.ftl"), any())).thenReturn("// generated");

        engine.generateCode(d);

        verify(writer).write(tempDir.toString(), "app/src/main/java/com/example/Foo.java", "// generated");
    }

    // -------------------------------------------------------------------------
    // generateCode — destination derived from ArchetypeModel
    // -------------------------------------------------------------------------

    @Test
    void generateCode_skipsEntry_whenArchetypeMissingFromFtlModel(@TempDir Path tempDir) {
        ProjectDescriptor d = descriptor(tempDir);
        CatalogEntry entry = entry("MissingType", facet("main", "/tpl/Foo.ftl", null));

        when(registry.projectEntriesFor(d)).thenReturn(List.of(entry));
        when(converter.toFtlModel(d)).thenReturn(Map.of("basePackagePath", "com/example"));
        when(converter.toMustacheTokens(d)).thenReturn(Map.of());

        engine.generateCode(d);

        verifyNoInteractions(renderer, writer);
    }

    @Test
    void generateCode_derivesMainSourceDestination_fromArchetypeModel(@TempDir Path tempDir) throws IOException {
        ProjectDescriptor d = descriptor(tempDir);
        ArchetypeModel archetype = new ArchetypeModel("com.example.service", "UserService");
        CatalogEntry entry = entry("Service", facet("main", "/tpl/Svc.ftl", null));

        when(registry.projectEntriesFor(d)).thenReturn(List.of(entry));
        when(converter.toFtlModel(d)).thenReturn(Map.of("Service", archetype, "basePackagePath", "com/example"));
        when(converter.toMustacheTokens(d)).thenReturn(Map.of("basePackagePath", "app/src/main/java/com/example"));
        when(renderer.render(any(), any())).thenReturn("svc-content");

        engine.generateCode(d);

        verify(writer)
                .write(tempDir.toString(), "app/src/main/java/com/example/service/UserService.java", "svc-content");
    }

    @Test
    void generateCode_derivesTestDestination_appendsTestSuffix(@TempDir Path tempDir) throws IOException {
        ProjectDescriptor d = descriptor(tempDir);
        ArchetypeModel archetype = new ArchetypeModel("com.example.service", "UserService");
        CatalogEntry entry = entry("Service", facet("test", "/tpl/SvcTest.ftl", null));

        when(registry.projectEntriesFor(d)).thenReturn(List.of(entry));
        when(converter.toFtlModel(d)).thenReturn(Map.of("Service", archetype, "basePackagePath", "com/example"));
        when(converter.toMustacheTokens(d)).thenReturn(Map.of("testBasePackagePath", "app/src/test/java/com/example"));
        when(renderer.render(any(), any())).thenReturn("test-content");

        engine.generateCode(d);

        verify(writer)
                .write(
                        tempDir.toString(),
                        "app/src/test/java/com/example/service/UserServiceTest.java",
                        "test-content");
    }

    @Test
    void generateCode_derivesIntegrationTestDestination_keepsOriginalClassName(@TempDir Path tempDir)
            throws IOException {
        ProjectDescriptor d = descriptor(tempDir);
        ArchetypeModel archetype = new ArchetypeModel("com.example.config", "AppConfig");
        CatalogEntry entry = entry("Config", facet("integrationTest", "/tpl/AppConfig.ftl", null));

        when(registry.projectEntriesFor(d)).thenReturn(List.of(entry));
        when(converter.toFtlModel(d)).thenReturn(Map.of("Config", archetype, "basePackagePath", "com/example"));
        when(converter.toMustacheTokens(d))
                .thenReturn(Map.of("integrationTestBasePackagePath", "app/src/integrationTest/java/com/example"));
        when(renderer.render(any(), any())).thenReturn("it-content");

        engine.generateCode(d);

        verify(writer)
                .write(
                        tempDir.toString(),
                        "app/src/integrationTest/java/com/example/config/AppConfig.java",
                        "it-content");
    }

    @Test
    void generateCode_derivesTestFixturesDestination(@TempDir Path tempDir) throws IOException {
        ProjectDescriptor d = descriptor(tempDir);
        ArchetypeModel archetype = new ArchetypeModel("com.example.persistence", "UserFixtures");
        CatalogEntry entry = entry("Fixtures", facet("testFixtures", "/tpl/Fixtures.ftl", null));

        when(registry.projectEntriesFor(d)).thenReturn(List.of(entry));
        when(converter.toFtlModel(d)).thenReturn(Map.of("Fixtures", archetype, "basePackagePath", "com/example"));
        when(converter.toMustacheTokens(d))
                .thenReturn(Map.of("testFixturesBasePackagePath", "app/src/testFixtures/java/com/example"));
        when(renderer.render(any(), any())).thenReturn("fixtures-content");

        engine.generateCode(d);

        verify(writer)
                .write(
                        tempDir.toString(),
                        "app/src/testFixtures/java/com/example/persistence/UserFixtures.java",
                        "fixtures-content");
    }

    @Test
    void generateCode_derivesDestinationAtBasePackageRoot(@TempDir Path tempDir) throws IOException {
        // When archetype package equals basePackage, sub-path is empty → file lands at root
        ProjectDescriptor d = descriptor(tempDir);
        ArchetypeModel archetype = new ArchetypeModel("com.example", "Application");
        CatalogEntry entry = entry("Application", facet("main", "/tpl/App.ftl", null));

        when(registry.projectEntriesFor(d)).thenReturn(List.of(entry));
        when(converter.toFtlModel(d)).thenReturn(Map.of("Application", archetype, "basePackagePath", "com/example"));
        when(converter.toMustacheTokens(d)).thenReturn(Map.of("basePackagePath", "app/src/main/java/com/example"));
        when(renderer.render(any(), any())).thenReturn("app-content");

        engine.generateCode(d);

        verify(writer).write(tempDir.toString(), "app/src/main/java/com/example/Application.java", "app-content");
    }

    // -------------------------------------------------------------------------
    // generateCode — error handling
    // -------------------------------------------------------------------------

    @Test
    void generateCode_throwsMetacodeException_whenWriterThrowsIOException(@TempDir Path tempDir) throws IOException {
        doThrow(new IOException("disk full")).when(writer).write(any(), any(), any());

        ProjectDescriptor d = descriptor(tempDir);
        CatalogEntry entry = entry("MyType", facet("main", "/tpl/Foo.ftl", "some/Foo.java"));

        when(registry.projectEntriesFor(d)).thenReturn(List.of(entry));
        when(converter.toFtlModel(d)).thenReturn(Map.of());
        when(converter.toMustacheTokens(d)).thenReturn(Map.of());
        when(renderer.render(any(), any())).thenReturn("content");

        assertThatThrownBy(() -> engine.generateCode(d))
                .isInstanceOf(MetacodeException.class)
                .hasRootCauseInstanceOf(IOException.class)
                .hasRootCauseMessage("disk full");
    }

    // -------------------------------------------------------------------------
    // helpers
    // -------------------------------------------------------------------------

    private static ProjectDescriptor descriptor(Path baseDir) {
        return ProjectDescriptor.builder()
                .applicationName("my-app")
                .basePackage("com.example")
                .baseDirectory(baseDir.toString())
                .basePath("/api")
                .flavor("webmvc")
                .appModule("application")
                .javaVersion("21")
                .build();
    }

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
