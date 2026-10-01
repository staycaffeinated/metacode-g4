<#include "/common/Copyright.ftl">
package ${EntityResponse.packageName()};

import static org.assertj.core.api.Assertions.assertThat;

import ${EntityResource.fqcn()};
import org.junit.jupiter.api.Test;

class ${EntityResponse.testClass()} {

    @Test
    void shouldCreateResponse() {
        // when
        var response = new ${EntityResponse.className()}("12345", "something about this");

        // then
        assertThat(response.resourceId()).isEqualTo("12345");
        assertThat(response.text()).isEqualTo("something about this");
    }


    @Test
    void shouldConvertToDomainObject() {
        // given
        var pojo = ${EntityResource.className()}.builder().resourceId("12345").text("something about this").build();

        // when
        var response = ${EntityResponse.className()}.fromDomain(pojo);

        // then
        assertThat(response.resourceId()).isEqualTo("12345");
        assertThat(response.text()).isEqualTo("something about this");
    }
}

