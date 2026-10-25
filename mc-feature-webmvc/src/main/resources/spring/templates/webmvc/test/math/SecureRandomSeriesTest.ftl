<#include "/common/Copyright.ftl">
package ${SecureRandomSeries.packageName()};

import static org.assertj.core.api.Assertions.assertThat;
import static org.junit.jupiter.api.Assertions.assertThrows;

import org.junit.jupiter.api.Test;

class ${SecureRandomSeries.testClass()} {

    private final ${SecureRandomSeries.className()} generatorUnderTest = new ${SecureRandomSeries.className()}();

    @Test
    void nextString_returnsCorrectLength() {
        String result = generatorUnderTest.nextString();
        assertThat(result).hasSize(${SecureRandomSeries.className()}.ENTROPY_STRING_LENGTH);
    }

    @Test
    void nextString_returnsOnlyAlphanumericChars() {
        String result = generatorUnderTest.nextString();
        assertThat(result).matches("[0-9a-zA-Z]+");
    }

    @Test
    void nextResourceId_returnsCorrectLength() {
        String result = generatorUnderTest.nextResourceId();
        assertThat(result).hasSize(${SecureRandomSeries.className()}.ENTROPY_STRING_LENGTH);
    }

    @Test
    void nextLong_returnsValue() {
        Long result = generatorUnderTest.nextLong();
        assertThat(result).isNotNull();
    }

    @Test
    void nextNumericResourceId_returnsOnlyDigits() {
        String result = generatorUnderTest.nextNumericResourceId();
        assertThat(result).matches("[0-9]+");
    }

    @Test
    void nextNumericResourceId_returnsExpectedLength() {
        String result = generatorUnderTest.nextNumericResourceId();
        assertThat(result.length()).isBetween(${SecureRandomSeries.className()}.ENTROPY_MAX_NUMERIC_LENGTH - 1,
                ${SecureRandomSeries.className()}.ENTROPY_MAX_NUMERIC_LENGTH);
    }

    @Test
    void instance_returnsSingletonInstance() {
        ${SecureRandomSeries.className()} first = ${SecureRandomSeries.className()}.instance();
        ${SecureRandomSeries.className()} second = ${SecureRandomSeries.className()}.instance();
        assertThat(first).isSameAs(second);
    }

    @Test
    void constructorWithValidAlgorithm_createsInstance() {
        ${SecureRandomSeries.className()} generator = new ${SecureRandomSeries.className()}("SHA1PRNG");
        assertThat(generator.nextResourceId()).hasSize(${SecureRandomSeries.className()}.ENTROPY_STRING_LENGTH);
    }

    @Test
    void constructorWithInvalidAlgorithm_fallsBackToDefaultSecureRandom() {
        ${SecureRandomSeries.className()} generator = new ${SecureRandomSeries.className()}("BOGUS_ALGORITHM_XYZ");
        assertThat(generator.nextResourceId()).hasSize(${SecureRandomSeries.className()}.ENTROPY_STRING_LENGTH);
    }

    @Test
    void whenAlgorithmIsNull_shouldThrowNPE() {
        assertThrows(NullPointerException.class, () -> new ${SecureRandomSeries.className()}(null));
    }
}
