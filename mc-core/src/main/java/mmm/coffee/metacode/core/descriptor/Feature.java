package mmm.coffee.metacode.core.descriptor;

import com.fasterxml.jackson.annotation.JsonCreator;
import java.util.Arrays;
import java.util.stream.Collectors;

public enum Feature {
    POSTGRES("postgres"),
    TESTCONTAINERS("testcontainers"),
    LIQUIBASE("liquibase"),
    FLYWAY("flyway"),
    OPENAPI("openapi"),
    MONGODB("mongodb"),
    KAFKA("kafka");

    private final String id;

    Feature(String id) {
        this.id = id;
    }

    public String id() {
        return id;
    }

    @JsonCreator
    public static Feature fromId(String id) {
        if (id == null || id.isBlank()) return null;
        for (Feature f : values()) {
            if (f.id.equalsIgnoreCase(id)) return f;
        }
        String valid = Arrays.stream(values()).map(Feature::id).collect(Collectors.joining(", "));
        throw new IllegalArgumentException("Unknown feature: '" + id + "'. Valid values: " + valid);
    }
}
