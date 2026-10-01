<#include "/common/Copyright.ftl">

package ${Entity.packageName()};

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;

import java.util.Objects;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Unit tests of ${Entity.className()}
 */
@SuppressWarnings("java:S5838") // false positive from sonarqube
class ${Entity.testClass()} {

    ${Entity.className()} underTest;
    String resourceId = "12345";

    @BeforeEach
    void setUp() {
        underTest = new ${Entity.className()}();
        underTest.setResourceId(resourceId);
        underTest.setId(1L);
    }

    @Nested
    class TestEquals {
        @Test
        void whenNullObject_thenReturnsFalse() {
            assertThat(Objects.equals(underTest,null)).isFalse();
        }

        @Test
        void whenMatchingResourceId_thenReturnsTrue() {
            ${Entity.className()} sample = new ${Entity.className()}();
            sample.setResourceId(resourceId);
            assertThat(underTest.equals(sample)).isTrue();
        }

        @Test
        @SuppressWarnings("all")
        void whenSelf_thenReturnsTrue() {
            ${Entity.className()} sample = underTest;
            assertThat(underTest.equals(sample)).isTrue();
        }

        @Test
        @SuppressWarnings("all")
        void whenDifferentClasses_thenReturnsFalse() {
            assertThat(underTest.equals("hello,world")).isFalse();
        }
    }

    @Nested
    class TestHashCode {
        @Test
        void whenEqualObjects_thenReturnsSameHashCode() {
            ${Entity.className()} sample = new ${Entity.className()}();
            sample.setResourceId(resourceId);

            assertThat(sample.hashCode()).isEqualTo(underTest.hashCode());
        }
    }
}
