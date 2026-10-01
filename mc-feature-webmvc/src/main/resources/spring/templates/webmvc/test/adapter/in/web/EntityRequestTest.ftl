<#include "/common/Copyright.ftl">
package ${EntityRequest.packageName()};

import static org.assertj.core.api.Assertions.assertThat;

import ${EntityResource.fqcn()};
import org.junit.jupiter.api.Test;


class ${EntityRequest.testClass()} {

    @Test
    void shouldCreateRequest() {
        var request = new ${EntityRequest.className()}(null, "something about this");

        assertThat(request.resourceId()).isNull();
        assertThat(request.text()).isEqualTo("something about this");
    }


    @Test
    void shouldYieldMatchingDomainObject() {
        var request = new ${EntityRequest.className()}(null, "something about this");
        var domainObject = request.toDomain();

        assertThat(domainObject.getResourceId()).isNull();
        assertThat(domainObject.getText()).isEqualTo("something about this");
    }
}
