package mmm.coffee.metacode.core.catalog;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import java.util.List;
import java.util.Set;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

class CatalogReaderTest {

    CatalogReader reader;

    @BeforeEach
    void setUp() {
        reader = new CatalogReader();
    }

    // ── basic reading ─────────────────────────────────────────────────────────

    @Test
    void readsSimpleCatalog_returnsAllEntries() {
        List<CatalogEntry> entries = reader.read("/catalogs/simple.yaml");

        assertThat(entries).hasSize(4);
    }

    @Test
    void entriesHaveCorrectScope() {
        List<CatalogEntry> entries = reader.read("/catalogs/simple.yaml");

        assertThat(entries)
                .extracting(CatalogEntry::getScope)
                .containsExactly("project", "project", "project", "endpoint");
    }

    @Test
    void entriesHaveCorrectArchetypes() {
        List<CatalogEntry> entries = reader.read("/catalogs/simple.yaml");

        assertThat(entries)
                .extracting(CatalogEntry::getArchetype)
                .containsExactly("Application", "WebMvcConfiguration", "DatabaseConfig", "Controller");
    }

    // ── when: condition parsing ───────────────────────────────────────────────

    @Test
    void entryWithNoWhen_hasNullWhenCondition() {
        List<CatalogEntry> entries = reader.read("/catalogs/simple.yaml");

        CatalogEntry application = entries.get(0);
        assertThat(application.getWhen()).isNull();
    }

    @Test
    void entryWithNoWhen_matchesAlwaysViaMatches() {
        List<CatalogEntry> entries = reader.read("/catalogs/simple.yaml");

        CatalogEntry application = entries.get(0);
        assertThat(application.matches("webmvc", Set.of())).isTrue();
        assertThat(application.matches("webflux", Set.of("postgres"))).isTrue();
    }

    @Test
    void entryWithFlavorCondition_whenParsedCorrectly() {
        List<CatalogEntry> entries = reader.read("/catalogs/simple.yaml");

        CatalogEntry webMvcConfig = entries.get(1);
        assertThat(webMvcConfig.getWhen()).isNotNull();
        assertThat(webMvcConfig.getWhen().getFlavor()).containsExactly("webmvc");
        assertThat(webMvcConfig.getWhen().getFeatures()).isEmpty();
    }

    @Test
    void entryWithFlavorCondition_matchesCorrectFlavor() {
        List<CatalogEntry> entries = reader.read("/catalogs/simple.yaml");

        CatalogEntry webMvcConfig = entries.get(1);
        assertThat(webMvcConfig.matches("webmvc", Set.of())).isTrue();
        assertThat(webMvcConfig.matches("webflux", Set.of())).isFalse();
    }

    @Test
    void entryWithFlavorAndFeatures_whenParsedCorrectly() {
        List<CatalogEntry> entries = reader.read("/catalogs/simple.yaml");

        CatalogEntry dbConfig = entries.get(2);
        assertThat(dbConfig.getWhen()).isNotNull();
        assertThat(dbConfig.getWhen().getFlavor()).containsExactly("webmvc");
        assertThat(dbConfig.getWhen().getFeatures()).containsExactly("postgres");
    }

    @Test
    void entryWithFlavorAndFeatures_matchesOnlyWhenBothSatisfied() {
        List<CatalogEntry> entries = reader.read("/catalogs/simple.yaml");

        CatalogEntry dbConfig = entries.get(2);
        assertThat(dbConfig.matches("webmvc", Set.of("postgres"))).isTrue();
        assertThat(dbConfig.matches("webmvc", Set.of())).isFalse();
        assertThat(dbConfig.matches("webflux", Set.of("postgres"))).isFalse();
    }

    // ── facets ────────────────────────────────────────────────────────────────

    @Test
    void facetsAreParsedCorrectly() {
        List<CatalogEntry> entries = reader.read("/catalogs/simple.yaml");

        CatalogEntry application = entries.get(0);
        assertThat(application.getFacets()).hasSize(1);

        TemplateFacet facet = application.getFacets().get(0);
        assertThat(facet.getFacet()).isEqualTo("main");
        assertThat(facet.getSourceTemplate()).isEqualTo("/templates/Application.ftl");
        assertThat(facet.getDestination()).isEqualTo("{{basePackagePath}}/Application.java");
    }

    // ── includes ──────────────────────────────────────────────────────────────

    @Test
    void includesResolution_mergesAllEntries() {
        List<CatalogEntry> entries = reader.read("/catalogs/with-includes.yaml");

        // base.yaml: 2 entries; with-includes.yaml: 1 entry → total 3
        assertThat(entries).hasSize(3);
    }

    @Test
    void includesResolution_includedEntriesAppearFirst() {
        List<CatalogEntry> entries = reader.read("/catalogs/with-includes.yaml");

        // base.yaml entries come first (Application, LombokConfig), then WebMvcConfiguration
        assertThat(entries)
                .extracting(CatalogEntry::getArchetype)
                .containsExactly("Application", "LombokConfig", "WebMvcConfiguration");
    }

    // ── circular include ──────────────────────────────────────────────────────

    @Test
    void circularInclude_doesNotLoopInfinitely() {
        // circular-a includes circular-b which includes circular-a
        // second visit of circular-a is skipped; entries from both are returned
        List<CatalogEntry> entries = reader.read("/catalogs/circular-a.yaml");

        assertThat(entries).extracting(CatalogEntry::getArchetype).containsExactlyInAnyOrder("Alpha", "Beta");
    }

    // ── error handling ────────────────────────────────────────────────────────

    @Test
    void missingResource_throwsCatalogNotFoundException() {
        assertThatThrownBy(() -> reader.read("/catalogs/does-not-exist.yaml"))
                .isInstanceOf(CatalogNotFoundException.class)
                .hasMessageContaining("does-not-exist.yaml");
    }
}
