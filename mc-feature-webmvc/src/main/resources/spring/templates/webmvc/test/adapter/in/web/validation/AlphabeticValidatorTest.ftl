<#include "/common/Copyright.ftl">
package ${AlphabeticValidator.packageName()};

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.NullSource;
import org.junit.jupiter.params.provider.ValueSource;

class ${AlphabeticValidator.testClass()} {

    private ${AlphabeticValidator.className()} validator;

    @BeforeEach
    void setUp() {
        validator = new ${AlphabeticValidator.className()}();
    }

    @Test
    void shouldAcceptAllAlphabeticString() {
        assertThat(validator.isValid("HelloWorld", null)).isTrue();
    }

    @ParameterizedTest
    @ValueSource(strings = {"hello123", "has space", "has-dash", "has_underscore"})
    void shouldRejectNonAlphabeticString(String value) {
        assertThat(validator.isValid(value, null)).isFalse();
    }

    @ParameterizedTest
    @NullSource
    void shouldRejectNull(String value) {
        assertThat(validator.isValid(value, null)).isFalse();
    }
}
