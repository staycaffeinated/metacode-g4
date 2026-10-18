package mmm.coffee.metacode.javaapp;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.List;
import mmm.coffee.metacode.core.catalog.CatalogEntry;
import mmm.coffee.metacode.core.catalog.CatalogReader;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

class JavaAppCatalogTest {

    CatalogReader reader;

    @BeforeEach
    void setUp() {
        reader = new CatalogReader();
    }

    @Test
    void catalogLoadsWithEntries() {
        List<CatalogEntry> entries = reader.read("/spring/catalogs/javaapp.yaml");
        assertThat(entries).isNotEmpty();
    }

    @Test
    void allEntriesHaveJavaAppFlavorGuard() {
        List<CatalogEntry> entries = reader.read("/spring/catalogs/javaapp.yaml");
        assertThat(entries)
                .isNotEmpty()
                .allMatch(
                        e -> e.getWhen() != null
                                && e.getWhen().getFlavor() != null
                                && e.getWhen().getFlavor().contains("javaapp"),
                        "every entry must have when.flavor containing 'javaapp'");
    }

    @Test
    void hasApplicationEntry() {
        List<CatalogEntry> entries = reader.read("/spring/catalogs/javaapp.yaml");
        assertThat(entries).extracting(CatalogEntry::getArchetype).contains("Application");
    }
}
