package mmm.coffee.metacode.core.archetype;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.dataformat.yaml.YAMLFactory;
import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Map;

/**
 * Loads the package-layout.yaml from the classpath and builds
 * ArchetypeModel instances for a given base package.
 */
public class PackageLayout {

    private static final String DEFAULT_RESOURCE = "/package-layout.yaml";

    private final Map<String, ArchetypeEntry> entries;

    private PackageLayout(Map<String, ArchetypeEntry> entries) {
        this.entries = entries;
    }

    public static PackageLayout loadDefault() {
        return load(DEFAULT_RESOURCE);
    }

    public static PackageLayout load(String classpathResource) {
        ObjectMapper mapper = new ObjectMapper(new YAMLFactory());
        try (InputStream is = PackageLayout.class.getResourceAsStream(classpathResource)) {
            if (is == null) {
                throw new IllegalStateException("Package layout not found on classpath: " + classpathResource);
            }
            LayoutFile file = mapper.readValue(is, LayoutFile.class);
            return new PackageLayout(file.archetypes != null ? file.archetypes : new HashMap<>());
        } catch (IOException e) {
            throw new IllegalStateException("Failed to load package layout from " + classpathResource, e);
        }
    }

    /**
     * Builds a map of archetype name → ArchetypeModel for the given base package.
     */
    public Map<String, ArchetypeModel> buildArchetypeModels(String basePackage) {
        Map<String, ArchetypeModel> models = new HashMap<>();
        for (Map.Entry<String, ArchetypeEntry> e : entries.entrySet()) {
            String archetypeName = e.getKey();
            ArchetypeEntry entry = e.getValue();
            String pkg = resolvePackage(basePackage, entry.subPackage);
            models.put(archetypeName, new ArchetypeModel(pkg, entry.className));
        }
        return models;
    }

    private String resolvePackage(String basePackage, String subPackage) {
        if (subPackage == null || subPackage.isEmpty()) {
            return basePackage;
        }
        return basePackage + "." + subPackage;
    }

    // Jackson deserialization types

    public static class LayoutFile {
        public Map<String, ArchetypeEntry> archetypes;
    }

    public static class ArchetypeEntry {
        public String subPackage = "";
        public String className;
    }
}
