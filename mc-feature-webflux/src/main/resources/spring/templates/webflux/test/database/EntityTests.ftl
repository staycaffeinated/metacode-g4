<#include "/common/Copyright.ftl">

package ${Entity.packageName()};

import ${EntityResource.fqcn()};
import ${ModelTestFixtures.fqcn()};
import ${EjbTestFixtures.fqcn()};
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;

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
            assertThat(underTest.equals(null)).isFalse();
        }

        @Test
        void whenMatchingResourceId_thenReturnsTrue() {
            ${endpoint.ejbName} sample = new ${Entity.className()}();
            sample.setResourceId(resourceId);
            assertThat(underTest.equals(sample)).isTrue();
        }

        @Test
        void whenSelf_thenReturnsTrue() {
            ${endpoint.ejbName} sample = underTest;
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
            ${endpoint.ejbName} sample = new ${Entity.className()}();
            sample.setResourceId(resourceId);

            assertThat(sample.hashCode()).isEqualTo(underTest.hashCode());
        }
    }
    


    @Nested
    class TestIsNew {
        @Test
        void whenNewObject_thenReturnsTrue() {
            ${endpoint.ejbName} sample = new ${endpoint.ejbName}();
            assertThat(sample.isNew()).isTrue();
        }

        @Test
        void whenIdAlreadySet_thenNotNewRow() {
            ${endpoint.ejbName} sample = new ${endpoint.ejbName}();
            sample.setId(2L);
            assertThat(sample.isNew()).isFalse();
        }
    }


    @Nested
    class TestCopyMutableFields {
        @Test
        void shouldCopyMutableFields() {
            var pojo = ${ModelTestFixtures.className()}.oneWithResourceId();
            var ejb = new ${Entity.className()}();
            var copy = ejb.copyMutableFieldsFrom(pojo);
            assertThat(copy.getText()).isEqualTo(pojo.getText());
        }
    }
}
