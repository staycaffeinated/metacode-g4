<#include "/common/Copyright.ftl">
package ${Application.packageName()};

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class ${Application.testClass()} {

    @Test
    void placeholderTest() {
        assertThat(true).isTrue();
    }
}
