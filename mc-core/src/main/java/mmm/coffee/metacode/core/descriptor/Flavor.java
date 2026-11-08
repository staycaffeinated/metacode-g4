package mmm.coffee.metacode.core.descriptor;

import com.fasterxml.jackson.annotation.JsonCreator;

/**
 * The project flavor selected by the user on the CLI.
 * The {@link #id()} value is used in catalog YAML {@code when.flavor} lists
 * and written to {@code .metacode} as the {@code framework} key.
 */
public enum Flavor {
    WEBMVC("webmvc"),
    WEBFLUX("webflux"),
    SPRING_BATCH("springbatch"),
    SPRING_BOOT("springboot"),
    JAVA_APP("javaapp");

    private final String id;

    Flavor(String id) {
        this.id = id;
    }

    public String id() {
        return id;
    }

    @JsonCreator
    public static Flavor fromId(String id) {
        if (id == null || id.isBlank()) return null;
        for (Flavor f : values()) {
            if (f.id.equalsIgnoreCase(id)) return f;
        }
        throw new IllegalArgumentException("Unknown flavor: " + id);
    }
}
