package mmm.coffee.metacode.core.catalog;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.List;
import java.util.Set;
import mmm.coffee.metacode.core.descriptor.Flavor;
import org.junit.jupiter.api.Test;

class WhenConditionTest {

    // ── no conditions ─────────────────────────────────────────────────────────

    @Test
    void emptyCondition_matchesAnyFlavorAndFeatures() {
        var when = new WhenCondition();
        assertThat(when.matches(Flavor.WEBMVC, Set.of())).isTrue();
        assertThat(when.matches(Flavor.WEBFLUX, Set.of("postgres", "liquibase")))
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
        when.setFeatures(List.of("postgres"));

        assertThat(when.matches(Flavor.WEBMVC, Set.of("postgres"))).isTrue();
        assertThat(when.matches(Flavor.WEBMVC, Set.of("postgres", "liquibase"))).isTrue();
    }

    @Test
    void featuresList_noMatchWhenFeatureMissing() {
        var when = new WhenCondition();
        when.setFeatures(List.of("postgres"));

        assertThat(when.matches(Flavor.WEBMVC, Set.of())).isFalse();
        assertThat(when.matches(Flavor.WEBMVC, Set.of("mongodb"))).isFalse();
    }

    @Test
    void multipleFeatures_allMustBeActive() {
        var when = new WhenCondition();
        when.setFeatures(List.of("postgres", "liquibase"));

        assertThat(when.matches(Flavor.WEBMVC, Set.of("postgres", "liquibase"))).isTrue();
        assertThat(when.matches(Flavor.WEBMVC, Set.of("postgres"))).isFalse();
        assertThat(when.matches(Flavor.WEBMVC, Set.of("liquibase"))).isFalse();
        assertThat(when.matches(Flavor.WEBMVC, Set.of())).isFalse();
    }

    // ── flavor + features (AND logic) ─────────────────────────────────────────

    @Test
    void flavorAndFeatures_bothMustMatch() {
        var when = new WhenCondition();
        when.setFlavor(List.of("webmvc"));
        when.setFeatures(List.of("postgres"));

        assertThat(when.matches(Flavor.WEBMVC, Set.of("postgres"))).isTrue();
    }

    @Test
    void flavorMatches_butFeaturesMissing_noMatch() {
        var when = new WhenCondition();
        when.setFlavor(List.of("webmvc"));
        when.setFeatures(List.of("postgres"));

        assertThat(when.matches(Flavor.WEBMVC, Set.of())).isFalse();
    }

    @Test
    void featuresMatch_butFlavorWrong_noMatch() {
        var when = new WhenCondition();
        when.setFlavor(List.of("webmvc"));
        when.setFeatures(List.of("postgres"));

        assertThat(when.matches(Flavor.WEBFLUX, Set.of("postgres"))).isFalse();
    }
}
