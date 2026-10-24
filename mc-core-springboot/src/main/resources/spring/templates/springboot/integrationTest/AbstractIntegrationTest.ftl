<#include "/common/Copyright.ftl">

package ${AbstractIntegrationTest.packageName()};

import static ${SpringProfiles.fqcn()}.INTEGRATION_TEST;
import static ${SpringProfiles.fqcn()}.TEST;
import static org.springframework.boot.test.context.SpringBootTest.WebEnvironment.RANDOM_PORT;

import tools.jackson.databind.json.JsonMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
<#if project.isWithTestContainers() && project.isWithPostgres()>
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;
import org.testcontainers.postgresql.PostgreSQLContainer;
</#if>

@ActiveProfiles({TEST, INTEGRATION_TEST})
@SpringBootTest(webEnvironment = RANDOM_PORT)
<#if project.isWithTestContainers() && project.isWithPostgres()>
@Testcontainers
@SuppressWarnings({"rawtypes"})
</#if>
public abstract class ${AbstractIntegrationTest.className()} {

    @Autowired
    protected JsonMapper jsonMapper;
<#if project.isWithTestContainers() && project.isWithPostgres()>

    @Container
    static final PostgreSQLContainer postgres = new PostgreSQLContainer("postgres:17-alpine");

    @DynamicPropertySource
    static void configureProperties(DynamicPropertyRegistry registry) {
<#if project.isWebFlux()>
        registry.add("spring.r2dbc.url", () -> "r2dbc:postgresql://" + postgres.getHost() + ":" + postgres.getMappedPort(5432) + "/" + postgres.getDatabaseName());
        registry.add("spring.r2dbc.username", postgres::getUsername);
        registry.add("spring.r2dbc.password", postgres::getPassword);
<#else>
        registry.add("spring.datasource.url", postgres::getJdbcUrl);
        registry.add("spring.datasource.username", postgres::getUsername);
        registry.add("spring.datasource.password", postgres::getPassword);
</#if>
<#if project.isWithFlyway()>
        registry.add("spring.flyway.url", postgres::getJdbcUrl);
        registry.add("spring.flyway.user", postgres::getUsername);
        registry.add("spring.flyway.password", postgres::getPassword);
</#if>
    }
</#if>
}
