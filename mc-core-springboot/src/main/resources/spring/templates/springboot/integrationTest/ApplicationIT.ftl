<#include "/common/Copyright.ftl">
package ${Application.packageName()};

import ${AbstractIntegrationTest.fqcn()};
import org.junit.jupiter.api.Test;

class ${Application.integrationTestClass()} extends ${AbstractIntegrationTest.className()} {

    @Test
    @SuppressWarnings("java:S2699") // there's nothing to assert
    void contextLoads() {
        // If this test runs without throwing an exception, then SpringBoot started successfully
    }
}
