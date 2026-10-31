package mmm.coffee.metacode.core.catalog;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import lombok.Data;
import mmm.coffee.metacode.core.descriptor.Flavor;

@Data
@JsonIgnoreProperties(ignoreUnknown = true)
@JsonPropertyOrder({"scope", "archetype", "when", "facets"})
public class CatalogEntry {

    /** "project" or "endpoint" */
    private String scope;

    /** Identifies the meta-class (Controller, Service, Repository, etc.) */
    private String archetype;

    /** Condition block — absent means "always render" */
    private WhenCondition when;

    private List<TemplateFacet> facets = new ArrayList<>();

    public boolean matches(Flavor selectedFlavor, Set<String> activeFeatures) {
        if (when == null) return true;
        return when.matches(selectedFlavor, activeFeatures);
    }
}
