package mmm.coffee.metacode.core.catalog;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import lombok.Data;

/**
 * Declarative condition block in a catalog entry.
 * An entry renders when ALL conditions are satisfied:
 *   - flavor is in the flavor list (if non-empty)
 *   - activeFeatures contains ALL listed features (if non-empty)
 * Absent lists mean "no restriction" (always matches).
 */
@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public class WhenCondition {

    private List<String> flavor = new ArrayList<>();
    private List<String> features = new ArrayList<>();

    public boolean matches(String selectedFlavor, Set<String> activeFeatures) {
        if (!flavor.isEmpty() && !flavor.contains(selectedFlavor)) {
            return false;
        }
        return features.isEmpty() || activeFeatures.containsAll(features);
    }
}
