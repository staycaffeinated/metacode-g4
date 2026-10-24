<#include "/common/Copyright.ftl">
package ${ResourceIdValidator.packageName()};

import static org.assertj.core.api.Assertions.assertThat;

import ${ResourceIdFormat.fqcn()};
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

class ${ResourceIdValidator.testClass()} {

    private ${ResourceIdValidator.className()} validator;

    @BeforeEach
    void setUp() {
        validator = new ${ResourceIdValidator.className()}();
    }

    @Test
    void shouldAcceptValidResourceId() {
        String validId = "a".repeat(${ResourceIdFormat.className()}.RESOURCE_ID_LENGTH);
        assertThat(validator.isValid(validId, null)).isTrue();
    }

    @Test
    void shouldRejectNull() {
        assertThat(validator.isValid(null, null)).isFalse();
    }

    @Test
    void shouldRejectTooShort() {
        String tooShort = "a".repeat(${ResourceIdFormat.className()}.RESOURCE_ID_LENGTH - 1);
        assertThat(validator.isValid(tooShort, null)).isFalse();
    }

    @Test
    void shouldRejectTooLong() {
        String tooLong = "a".repeat(${ResourceIdFormat.className()}.RESOURCE_ID_LENGTH + 1);
        assertThat(validator.isValid(tooLong, null)).isFalse();
    }

    @Test
    void shouldRejectNonAlphanumericChars() {
        String withSpecialChars = "a".repeat(${ResourceIdFormat.className()}.RESOURCE_ID_LENGTH - 1) + "-";
        assertThat(validator.isValid(withSpecialChars, null)).isFalse();
    }
}
