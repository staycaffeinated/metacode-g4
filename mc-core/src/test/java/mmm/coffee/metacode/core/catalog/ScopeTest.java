package mmm.coffee.metacode.core.catalog;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.NullAndEmptySource;
import org.junit.jupiter.params.provider.ValueSource;

class ScopeTest {

    // ── id() ──────────────────────────────────────────────────────────────────

    @Test
    void eachConstant_id_matchesExpected() {
        assertThat(Scope.PROJECT.id()).isEqualTo("project");
        assertThat(Scope.ENDPOINT.id()).isEqualTo("endpoint");
    }

    // ── fromId() — null/blank returns null ────────────────────────────────────

    @ParameterizedTest
    @NullAndEmptySource
    @ValueSource(strings = {"   ", "\t"})
    void fromId_nullOrBlank_returnsNull(String id) {
        assertThat(Scope.fromId(id)).isNull();
    }

    // ── fromId() — case-insensitive match ─────────────────────────────────────

    @ParameterizedTest
    @ValueSource(strings = {"project", "PROJECT", "Project"})
    void fromId_projectVariants(String id) {
        assertThat(Scope.fromId(id)).isEqualTo(Scope.PROJECT);
    }

    @ParameterizedTest
    @ValueSource(strings = {"endpoint", "ENDPOINT", "Endpoint"})
    void fromId_endpointVariants(String id) {
        assertThat(Scope.fromId(id)).isEqualTo(Scope.ENDPOINT);
    }

    // ── fromId() — unknown value throws ───────────────────────────────────────

    @Test
    void fromId_unknownValue_throwsIllegalArgument() {
        assertThatThrownBy(() -> Scope.fromId("module"))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("module");
    }
}
