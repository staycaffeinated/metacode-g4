package mmm.coffee.metacode.core.descriptor;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.NullAndEmptySource;
import org.junit.jupiter.params.provider.ValueSource;

class ArchitectureTest {

    // ── id() ──────────────────────────────────────────────────────────────────

    @Test
    void hexagonal_id_isHexagonal() {
        assertThat(Architecture.HEXAGONAL.id()).isEqualTo("hexagonal");
    }

    @Test
    void clean_id_isClean() {
        assertThat(Architecture.CLEAN.id()).isEqualTo("clean");
    }

    // ── layoutResource() ──────────────────────────────────────────────────────

    @Test
    void hexagonal_layoutResource_pointsToPackageLayout() {
        assertThat(Architecture.HEXAGONAL.layoutResource()).isEqualTo("/package-layout.yaml");
    }

    @Test
    void clean_layoutResource_pointsToCleanArchLayout() {
        assertThat(Architecture.CLEAN.layoutResource()).isEqualTo("/clean-arch-package-layout.yaml");
    }

    // ── fromId() — null/blank defaults to HEXAGONAL ───────────────────────────

    @ParameterizedTest
    @NullAndEmptySource
    @ValueSource(strings = {"   ", "\t"})
    void fromId_nullOrBlank_returnsHexagonal(String id) {
        assertThat(Architecture.fromId(id)).isEqualTo(Architecture.HEXAGONAL);
    }

    // ── fromId() — case-insensitive match ─────────────────────────────────────

    @ParameterizedTest
    @ValueSource(strings = {"hexagonal", "HEXAGONAL", "Hexagonal", "hExAgOnAl"})
    void fromId_hexagonalVariants_returnsHexagonal(String id) {
        assertThat(Architecture.fromId(id)).isEqualTo(Architecture.HEXAGONAL);
    }

    @ParameterizedTest
    @ValueSource(strings = {"clean", "CLEAN", "Clean", "cLeAn"})
    void fromId_cleanVariants_returnsClean(String id) {
        assertThat(Architecture.fromId(id)).isEqualTo(Architecture.CLEAN);
    }

    // ── fromId() — unknown value throws ───────────────────────────────────────

    @Test
    void fromId_unknownValue_throwsIllegalArgument() {
        assertThatThrownBy(() -> Architecture.fromId("mvc"))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("mvc")
                .hasMessageContaining("hexagonal")
                .hasMessageContaining("clean");
    }
}
