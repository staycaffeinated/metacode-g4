package mmm.coffee.metacode.core.catalog;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.dataformat.yaml.YAMLFactory;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import lombok.NonNull;
import lombok.extern.slf4j.Slf4j;

/**
 * Loads a catalog YAML from the classpath, resolves {@code includes} recursively,
 * and returns a flat list of all {@link CatalogEntry} instances.
 *
 * Circular includes are detected and skipped. Parsed YAML is cached per resource
 * path — classpath resources do not change at runtime.
 */
@Slf4j
public class CatalogReader {

    private static final ObjectMapper MAPPER = new ObjectMapper(new YAMLFactory());

    private final ConcurrentHashMap<String, TemplateCatalog> cache = new ConcurrentHashMap<>();

    public List<CatalogEntry> read(@NonNull String catalogResource) {
        return readRecursive(catalogResource, new HashSet<>());
    }

    private List<CatalogEntry> readRecursive(String resource, Set<String> visited) {
        if (!visited.add(resource)) {
            log.warn("Circular catalog include detected, skipping: {}", resource);
            return List.of();
        }

        TemplateCatalog catalog = cache.computeIfAbsent(resource, this::load);
        List<CatalogEntry> entries = new ArrayList<>();

        for (String include : catalog.getIncludes()) {
            entries.addAll(readRecursive(include, visited));
        }

        entries.addAll(catalog.getEntries());
        return entries;
    }

    private TemplateCatalog load(String resource) {
        try (InputStream is = getClass().getResourceAsStream(resource)) {
            if (is == null) {
                throw new CatalogNotFoundException("Catalog resource not found: " + resource);
            }
            return MAPPER.readValue(is, TemplateCatalog.class);
        } catch (IOException e) {
            throw new CatalogNotFoundException("Failed to read catalog: " + resource, e);
        }
    }
}
