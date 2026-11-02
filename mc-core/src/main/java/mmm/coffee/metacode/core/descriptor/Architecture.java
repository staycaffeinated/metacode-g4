package mmm.coffee.metacode.core.descriptor;

import com.fasterxml.jackson.annotation.JsonCreator;
import java.util.Arrays;
import java.util.stream.Collectors;

public enum Architecture {
    HEXAGONAL("hexagonal", "/package-layout.yaml"),
    CLEAN("clean", "/clean-arch-package-layout.yaml");

    private final String id;
    private final String layoutResource;

    Architecture(String id, String layoutResource) {
        this.id = id;
        this.layoutResource = layoutResource;
    }

    public String id() {
        return id;
    }

    public String layoutResource() {
        return layoutResource;
    }

    @JsonCreator
    public static Architecture fromId(String id) {
        if (id == null || id.isBlank()) return HEXAGONAL;
        for (Architecture a : values()) {
            if (a.id.equalsIgnoreCase(id)) return a;
        }
        String valid = Arrays.stream(values()).map(Architecture::id).collect(Collectors.joining(", "));
        throw new IllegalArgumentException("Unknown architecture: '" + id + "'. Valid values: " + valid);
    }
}
