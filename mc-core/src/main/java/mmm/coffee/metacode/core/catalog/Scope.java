package mmm.coffee.metacode.core.catalog;

import com.fasterxml.jackson.annotation.JsonCreator;

/**
 * Discriminates whether a catalog entry applies to the whole project scaffold
 * or to a single endpoint. Matches the {@code scope} field in catalog YAML.
 */
public enum Scope {
    PROJECT("project"),
    ENDPOINT("endpoint");

    private final String id;

    Scope(String id) {
        this.id = id;
    }

    public String id() {
        return id;
    }

    @JsonCreator
    public static Scope fromId(String id) {
        if (id == null || id.isBlank()) return null;
        for (Scope s : values()) {
            if (s.id.equalsIgnoreCase(id)) return s;
        }
        throw new IllegalArgumentException("Unknown scope: " + id);
    }
}
