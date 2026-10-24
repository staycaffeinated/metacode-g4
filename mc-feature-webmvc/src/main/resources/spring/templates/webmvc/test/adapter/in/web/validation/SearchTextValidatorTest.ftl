<#include "/common/Copyright.ftl">
package ${SearchTextValidator.packageName()};

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.NullSource;
import org.junit.jupiter.params.provider.ValueSource;

class ${SearchTextValidator.testClass()} {

    private ${SearchTextValidator.className()} validator;

    @BeforeEach
    void setUp() {
        validator = new ${SearchTextValidator.className()}();
    }

    @Test
    void shouldAcceptNullValue() {
        assertThat(validator.isValid(null, null)).isTrue();
    }

    @Test
    void shouldAcceptEmptyString() {
        assertThat(validator.isValid("", null)).isTrue();
    }

    @Test
    void shouldAcceptValueWithinMaxLength() {
        assertThat(validator.isValid("valid", null)).isTrue();
    }

    @Test
    void shouldAcceptValueAtMaxLength() {
        assertThat(validator.isValid("a".repeat(24), null)).isTrue();
    }

    @Test
    void shouldRejectValueExceedingMaxLength() {
        assertThat(validator.isValid("a".repeat(25), null)).isFalse();
    }
}
