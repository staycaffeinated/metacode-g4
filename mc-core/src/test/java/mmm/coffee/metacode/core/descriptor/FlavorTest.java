package mmm.coffee.metacode.core.descriptor;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.NullAndEmptySource;
import org.junit.jupiter.params.provider.ValueSource;

class FlavorTest {

    // ── id() ──────────────────────────────────────────────────────────────────

    @Test
    void eachConstant_id_matchesExpected() {
        assertThat(Flavor.WEBMVC.id()).isEqualTo("webmvc");
        assertThat(Flavor.WEBFLUX.id()).isEqualTo("webflux");
        assertThat(Flavor.SPRING_BATCH.id()).isEqualTo("springbatch");
        assertThat(Flavor.SPRING_BOOT.id()).isEqualTo("springboot");
        assertThat(Flavor.JAVA_APP.id()).isEqualTo("javaapp");
    }

    // ── fromId() — null/blank returns null ────────────────────────────────────

    @ParameterizedTest
    @NullAndEmptySource
    @ValueSource(strings = {"   ", "\t"})
    void fromId_nullOrBlank_returnsNull(String id) {
        assertThat(Flavor.fromId(id)).isNull();
    }

    // ── fromId() — case-insensitive match for every constant ──────────────────

    @ParameterizedTest
    @ValueSource(strings = {"webmvc", "WEBMVC", "WebMvc"})
    void fromId_webmvcVariants(String id) {
        assertThat(Flavor.fromId(id)).isEqualTo(Flavor.WEBMVC);
    }

    @ParameterizedTest
    @ValueSource(strings = {"webflux", "WEBFLUX", "WebFlux"})
    void fromId_webfluxVariants(String id) {
        assertThat(Flavor.fromId(id)).isEqualTo(Flavor.WEBFLUX);
    }

    @ParameterizedTest
    @ValueSource(strings = {"springbatch", "SPRINGBATCH", "SpringBatch"})
    void fromId_springBatchVariants(String id) {
        assertThat(Flavor.fromId(id)).isEqualTo(Flavor.SPRING_BATCH);
    }

    @ParameterizedTest
    @ValueSource(strings = {"springboot", "SPRINGBOOT", "SpringBoot"})
    void fromId_springBootVariants(String id) {
        assertThat(Flavor.fromId(id)).isEqualTo(Flavor.SPRING_BOOT);
    }

    @ParameterizedTest
    @ValueSource(strings = {"javaapp", "JAVAAPP", "JavaApp"})
    void fromId_javaAppVariants(String id) {
        assertThat(Flavor.fromId(id)).isEqualTo(Flavor.JAVA_APP);
    }

    // ── fromId() — unknown value throws ───────────────────────────────────────

    @Test
    void fromId_unknownValue_throwsIllegalArgument() {
        assertThatThrownBy(() -> Flavor.fromId("grpc"))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("grpc");
    }
}
