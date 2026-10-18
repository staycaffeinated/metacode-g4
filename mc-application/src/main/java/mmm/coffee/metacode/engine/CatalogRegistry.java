package mmm.coffee.metacode.engine;

import java.util.List;
import mmm.coffee.metacode.core.catalog.CatalogEntry;
import mmm.coffee.metacode.core.catalog.CatalogReader;
import mmm.coffee.metacode.core.contributor.CatalogContributor;
import mmm.coffee.metacode.core.descriptor.EndpointDescriptor;
import mmm.coffee.metacode.core.descriptor.ProjectDescriptor;
import org.springframework.stereotype.Component;

@Component
public class CatalogRegistry {

    private final List<CatalogContributor> contributors;
    private final CatalogReader reader;

    public CatalogRegistry(List<CatalogContributor> contributors, CatalogReader reader) {
        this.contributors = contributors;
        this.reader = reader;
    }

    public List<CatalogEntry> entriesFor(ProjectDescriptor descriptor) {
        return contributors.stream()
                .flatMap(c -> reader.read(c.getCatalogResource()).stream())
                .filter(e -> e.matches(descriptor.getFlavor(), descriptor.getFeatures()))
                .toList();
    }

    public List<CatalogEntry> projectEntriesFor(ProjectDescriptor descriptor) {
        return entriesFor(descriptor).stream()
                .filter(e -> "project".equals(e.getScope()))
                .toList();
    }

    public List<CatalogEntry> endpointEntriesFor(EndpointDescriptor descriptor) {
        return contributors.stream()
                .flatMap(c -> reader.read(c.getCatalogResource()).stream())
                .filter(e -> e.matches(descriptor.getFlavor(), descriptor.getFeatures()))
                .filter(e -> "endpoint".equals(e.getScope()))
                .toList();
    }
}
