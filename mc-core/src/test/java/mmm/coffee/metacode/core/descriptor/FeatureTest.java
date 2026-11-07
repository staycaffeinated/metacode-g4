package mmm.coffee.metacode.core.descriptor;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.NullAndEmptySource;
import org.junit.jupiter.params.provider.ValueSource;

class FeatureTest {

    // ── id() ──────────────────────────────────────────────────────────────────

    @Test
    void eachConstant_id_matchesExpected() {
        assertThat(Feature.POSTGRES.id()).isEqualTo("postgres");
        assertThat(Feature.TESTCONTAINERS.id()).isEqualTo("testcontainers");
        assertThat(Feature.LIQUIBASE.id()).isEqualTo("liquibase");
        assertThat(Feature.FLYWAY.id()).isEqualTo("flyway");
        assertThat(Feature.OPENAPI.id()).isEqualTo("openapi");
        assertThat(Feature.MONGODB.id()).isEqualTo("mongodb");
        assertThat(Feature.KAFKA.id()).isEqualTo("kafka");
    }

    // ── fromId() — null/blank returns null ────────────────────────────────────

    @ParameterizedTest
    @NullAndEmptySource
    @ValueSource(strings = {"   ", "\t"})
    void fromId_nullOrBlank_returnsNull(String id) {
        assertThat(Feature.fromId(id)).isNull();
    }

    // ── fromId() — case-insensitive match for every constant ──────────────────

    @ParameterizedTest
    @ValueSource(strings = {"postgres", "POSTGRES", "Postgres"})
    void fromId_postgresVariants(String id) {
        assertThat(Feature.fromId(id)).isEqualTo(Feature.POSTGRES);
    }

    @ParameterizedTest
    @ValueSource(strings = {"testcontainers", "TESTCONTAINERS", "TestContainers"})
    void fromId_testcontainersVariants(String id) {
        assertThat(Feature.fromId(id)).isEqualTo(Feature.TESTCONTAINERS);
    }

    @ParameterizedTest
    @ValueSource(strings = {"liquibase", "LIQUIBASE", "Liquibase"})
    void fromId_liquibaseVariants(String id) {
        assertThat(Feature.fromId(id)).isEqualTo(Feature.LIQUIBASE);
    }

    @ParameterizedTest
    @ValueSource(strings = {"flyway", "FLYWAY", "Flyway"})
    void fromId_flywayVariants(String id) {
        assertThat(Feature.fromId(id)).isEqualTo(Feature.FLYWAY);
    }

    @ParameterizedTest
    @ValueSource(strings = {"openapi", "OPENAPI", "OpenApi"})
    void fromId_openapiVariants(String id) {
        assertThat(Feature.fromId(id)).isEqualTo(Feature.OPENAPI);
    }

    @ParameterizedTest
    @ValueSource(strings = {"mongodb", "MONGODB", "MongoDB"})
    void fromId_mongodbVariants(String id) {
        assertThat(Feature.fromId(id)).isEqualTo(Feature.MONGODB);
    }

    @ParameterizedTest
    @ValueSource(strings = {"kafka", "KAFKA", "Kafka"})
    void fromId_kafkaVariants(String id) {
        assertThat(Feature.fromId(id)).isEqualTo(Feature.KAFKA);
    }

    // ── fromId() — unknown value throws ───────────────────────────────────────

    @Test
    void fromId_unknownValue_throwsIllegalArgument() {
        assertThatThrownBy(() -> Feature.fromId("redis"))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("redis")
                .hasMessageContaining("postgres")
                .hasMessageContaining("kafka");
    }
}
