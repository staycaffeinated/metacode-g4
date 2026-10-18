<#include "/common/Copyright.ftl">
package ${Application.packageName()};

import ${AbstractIntegrationTest.fqcn()};
import org.junit.jupiter.api.Test;

class ${Application.integrationTestClass()} extends ${AbstractIntegrationTest.className()} {

    @Test
    void applicationStarts() {
    }
}
