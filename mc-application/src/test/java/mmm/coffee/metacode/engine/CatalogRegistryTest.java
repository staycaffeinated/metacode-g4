package mmm.coffee.metacode.engine;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.lenient;
import static org.mockito.Mockito.when;

import java.util.List;
import java.util.Set;
import mmm.coffee.metacode.core.catalog.CatalogEntry;
import mmm.coffee.metacode.core.catalog.CatalogReader;
import mmm.coffee.metacode.core.catalog.Scope;
import mmm.coffee.metacode.core.catalog.WhenCondition;
import mmm.coffee.metacode.core.contributor.CatalogContributor;
import mmm.coffee.metacode.core.descriptor.EndpointDescriptor;
import mmm.coffee.metacode.core.descriptor.Flavor;
import mmm.coffee.metacode.core.descriptor.ProjectDescriptor;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class CatalogRegistryTest {

    private static final String CATALOG_PATH = "/catalogs/test.yaml";

    @Mock
    private CatalogContributor contributor;

    @Mock
    private CatalogReader reader;

    private CatalogRegistry registry;

    @BeforeEach
    void setUp() {
        registry = new CatalogRegistry(List.of(contributor), reader);
        // lenient: the no-contributors test replaces the registry with an empty list, so this stub is intentionally
        // unused there
        lenient().when(contributor.getCatalogResource()).thenReturn(CATALOG_PATH);
    }

    // -----------------------------------------------------------------------
    // entriesFor
    // -----------------------------------------------------------------------

    @Test
    void entriesFor_shouldReturnMatchingEntries() {
        CatalogEntry entry = projectEntry(Flavor.WEBMVC);
        when(reader.read(CATALOG_PATH)).thenReturn(List.of(entry));

        List<CatalogEntry> result = registry.entriesFor(webMvcDescriptor());

        assertThat(result).containsExactly(entry);
    }

    @Test
    void entriesFor_shouldExcludeEntriesWithNonMatchingFlavor() {
        CatalogEntry webfluxEntry = projectEntry(Flavor.WEBFLUX);
        when(reader.read(CATALOG_PATH)).thenReturn(List.of(webfluxEntry));

        List<CatalogEntry> result = registry.entriesFor(webMvcDescriptor());

        assertThat(result).isEmpty();
    }

    @Test
    void entriesFor_shouldIncludeEntryWithNoWhenCondition() {
        CatalogEntry unconditional = unconditionalProjectEntry();
        when(reader.read(CATALOG_PATH)).thenReturn(List.of(unconditional));

        List<CatalogEntry> result = registry.entriesFor(webMvcDescriptor());

        assertThat(result).containsExactly(unconditional);
    }

    @Test
    void entriesFor_shouldMergeEntriesFromMultipleContributors() {
        CatalogContributor secondContributor = org.mockito.Mockito.mock(CatalogContributor.class);
        String secondPath = "/catalogs/second.yaml";
        when(secondContributor.getCatalogResource()).thenReturn(secondPath);

        CatalogEntry first = projectEntry(Flavor.WEBMVC);
        CatalogEntry second = projectEntry(Flavor.WEBMVC);
        when(reader.read(CATALOG_PATH)).thenReturn(List.of(first));
        when(reader.read(secondPath)).thenReturn(List.of(second));

        registry = new CatalogRegistry(List.of(contributor, secondContributor), reader);

        List<CatalogEntry> result = registry.entriesFor(webMvcDescriptor());

        assertThat(result).hasSize(2).containsExactly(first, second);
    }

    @Test
    void entriesFor_shouldReturnEmptyList_whenNoContributors() {
        registry = new CatalogRegistry(List.of(), reader);

        List<CatalogEntry> result = registry.entriesFor(webMvcDescriptor());

        assertThat(result).isEmpty();
    }

    // -----------------------------------------------------------------------
    // projectEntriesFor
    // -----------------------------------------------------------------------

    @Test
    void projectEntriesFor_shouldReturnOnlyProjectScopedEntries() {
        CatalogEntry project = projectEntry(Flavor.WEBMVC);
        CatalogEntry endpoint = endpointEntry(Flavor.WEBMVC);
        when(reader.read(CATALOG_PATH)).thenReturn(List.of(project, endpoint));

        List<CatalogEntry> result = registry.projectEntriesFor(webMvcDescriptor());

        assertThat(result).containsExactly(project);
    }

    @Test
    void projectEntriesFor_shouldExcludeEndpointScopedEntries() {
        CatalogEntry endpoint = endpointEntry(Flavor.WEBMVC);
        when(reader.read(CATALOG_PATH)).thenReturn(List.of(endpoint));

        List<CatalogEntry> result = registry.projectEntriesFor(webMvcDescriptor());

        assertThat(result).isEmpty();
    }

    // -----------------------------------------------------------------------
    // endpointEntriesFor
    // -----------------------------------------------------------------------

    @Test
    void endpointEntriesFor_shouldReturnOnlyEndpointScopedEntries() {
        CatalogEntry project = projectEntry(Flavor.WEBMVC);
        CatalogEntry endpoint = endpointEntry(Flavor.WEBMVC);
        when(reader.read(CATALOG_PATH)).thenReturn(List.of(project, endpoint));

        List<CatalogEntry> result = registry.endpointEntriesFor(webMvcEndpointDescriptor());

        assertThat(result).containsExactly(endpoint);
    }

    @Test
    void endpointEntriesFor_shouldExcludeNonMatchingFlavor() {
        CatalogEntry endpoint = endpointEntry(Flavor.WEBFLUX);
        when(reader.read(CATALOG_PATH)).thenReturn(List.of(endpoint));

        List<CatalogEntry> result = registry.endpointEntriesFor(webMvcEndpointDescriptor());

        assertThat(result).isEmpty();
    }

    // -----------------------------------------------------------------------
    // Factories
    // -----------------------------------------------------------------------

    private CatalogEntry projectEntry(Flavor flavor) {
        CatalogEntry e = new CatalogEntry();
        e.setScope(Scope.PROJECT);
        e.setArchetype("Controller");
        e.setWhen(whenFlavor(flavor));
        return e;
    }

    private CatalogEntry endpointEntry(Flavor flavor) {
        CatalogEntry e = new CatalogEntry();
        e.setScope(Scope.ENDPOINT);
        e.setArchetype("Controller");
        e.setWhen(whenFlavor(flavor));
        return e;
    }

    private CatalogEntry unconditionalProjectEntry() {
        CatalogEntry e = new CatalogEntry();
        e.setScope(Scope.PROJECT);
        e.setArchetype("Application");
        // when == null → always matches
        return e;
    }

    private WhenCondition whenFlavor(Flavor flavor) {
        WhenCondition when = new WhenCondition();
        when.setFlavor(List.of(flavor));
        return when;
    }

    private ProjectDescriptor webMvcDescriptor() {
        return ProjectDescriptor.builder()
                .flavor(Flavor.WEBMVC)
                .applicationName("test-app")
                .basePackage("com.example")
                .features(Set.of())
                .build();
    }

    private EndpointDescriptor webMvcEndpointDescriptor() {
        return EndpointDescriptor.builder()
                .flavor(Flavor.WEBMVC)
                .entityName("Widget")
                .route("/widgets")
                .features(Set.of())
                .build();
    }
}
