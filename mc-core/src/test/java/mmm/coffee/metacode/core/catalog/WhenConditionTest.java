package mmm.coffee.metacode.core.catalog;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.List;
import java.util.Set;
import mmm.coffee.metacode.core.descriptor.Feature;
import mmm.coffee.metacode.core.descriptor.Flavor;
import org.junit.jupiter.api.Test;

class WhenConditionTest {

    // ── no conditions ─────────────────────────────────────────────────────────

    @Test
    void emptyCondition_matchesAnyFlavorAndFeatures() {
        var when = new WhenCondition();
        assertThat(when.matches(Flavor.WEBMVC, Set.of())).isTrue();
        assertThat(when.matches(Flavor.WEBFLUX, Set.of(Feature.POSTGRES, Feature.LIQUIBASE)))
                .isTrue();
    }

    // ── flavor only ───────────────────────────────────────────────────────────

    @Test
    void flavorList_matchesWhenFlavorPresent() {
        var when = new WhenCondition();
        when.setFlavor(List.of("webmvc"));

        assertThat(when.matches(Flavor.WEBMVC, Set.of())).isTrue();
    }

    @Test
    void flavorList_noMatchWhenFlavorAbsent() {
        var when = new WhenCondition();
        when.setFlavor(List.of("webmvc"));

        assertThat(when.matches(Flavor.WEBFLUX, Set.of())).isFalse();
        assertThat(when.matches(Flavor.SPRING_BATCH, Set.of())).isFalse();
        assertThat(when.matches(Flavor.SPRING_BOOT, Set.of())).isFalse();
    }

    @Test
    void multipleFlavorList_matchesAnyListed() {
        var when = new WhenCondition();
        when.setFlavor(List.of("webmvc", "webflux"));

        assertThat(when.matches(Flavor.WEBMVC, Set.of())).isTrue();
        assertThat(when.matches(Flavor.WEBFLUX, Set.of())).isTrue();
        assertThat(when.matches(Flavor.SPRING_BATCH, Set.of())).isFalse();
    }

    // ── features only ─────────────────────────────────────────────────────────

    @Test
    void featuresList_matchesWhenAllFeaturesActive() {
        var when = new WhenCondition();
        when.setFeatures(List.of(Feature.POSTGRES));

        assertThat(when.matches(Flavor.WEBMVC, Set.of(Feature.POSTGRES))).isTrue();
        assertThat(when.matches(Flavor.WEBMVC, Set.of(Feature.POSTGRES, Feature.LIQUIBASE)))
                .isTrue();
    }

    @Test
    void featuresList_noMatchWhenFeatureMissing() {
        var when = new WhenCondition();
        when.setFeatures(List.of(Feature.POSTGRES));

        assertThat(when.matches(Flavor.WEBMVC, Set.of())).isFalse();
        assertThat(when.matches(Flavor.WEBMVC, Set.of(Feature.MONGODB))).isFalse();
    }

    @Test
    void multipleFeatures_allMustBeActive() {
        var when = new WhenCondition();
        when.setFeatures(List.of(Feature.POSTGRES, Feature.LIQUIBASE));

        assertThat(when.matches(Flavor.WEBMVC, Set.of(Feature.POSTGRES, Feature.LIQUIBASE)))
                .isTrue();
        assertThat(when.matches(Flavor.WEBMVC, Set.of(Feature.POSTGRES))).isFalse();
        assertThat(when.matches(Flavor.WEBMVC, Set.of(Feature.LIQUIBASE))).isFalse();
        assertThat(when.matches(Flavor.WEBMVC, Set.of())).isFalse();
    }

    // ── flavor + features (AND logic) ─────────────────────────────────────────

    @Test
    void flavorAndFeatures_bothMustMatch() {
        var when = new WhenCondition();
        when.setFlavor(List.of("webmvc"));
        when.setFeatures(List.of(Feature.POSTGRES));

        assertThat(when.matches(Flavor.WEBMVC, Set.of(Feature.POSTGRES))).isTrue();
    }

    @Test
    void flavorMatches_butFeaturesMissing_noMatch() {
        var when = new WhenCondition();
        when.setFlavor(List.of("webmvc"));
        when.setFeatures(List.of(Feature.POSTGRES));

        assertThat(when.matches(Flavor.WEBMVC, Set.of())).isFalse();
    }

    @Test
    void featuresMatch_butFlavorWrong_noMatch() {
        var when = new WhenCondition();
        when.setFlavor(List.of("webmvc"));
        when.setFeatures(List.of(Feature.POSTGRES));

        assertThat(when.matches(Flavor.WEBFLUX, Set.of(Feature.POSTGRES))).isFalse();
    }
}
