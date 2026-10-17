<#include "/common/Copyright.ftl">
package ${AbstractIntegrationTest.packageName()};

import org.springframework.test.context.ActiveProfiles;

import static ${SpringProfiles.fqcn()}.INTEGRATION_TEST;

<#if project.isWithTestContainers()>
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;
</#if>
<#if project.isWithTestContainers() && project.isWithPostgres()>
import org.testcontainers.postgresql.PostgreSQLContainer;
</#if>

@ActiveProfiles({INTEGRATION_TEST})
<#if project.isWithTestContainers()>
@Testcontainers
</#if>
public abstract class ${AbstractIntegrationTest.className()} {
}
