<#include "/common/Copyright.ftl">
package ${AbstractIntegrationTest.packageName()};

import static ${SpringProfiles.packageName()}.SpringProfiles.INTEGRATION_TEST;
import static ${SpringProfiles.packageName()}.SpringProfiles.TEST;
import static org.springframework.boot.test.context.SpringBootTest.WebEnvironment.RANDOM_PORT;

import tools.jackson.databind.json.JsonMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.boot.jdbc.test.autoconfigure.AutoConfigureTestDatabase;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
<#if project.isWithTestContainers() && project.isWithPostgres()>
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;
import org.testcontainers.postgresql.PostgreSQLContainer;
</#if>

@ActiveProfiles({TEST, INTEGRATION_TEST})
@SpringBootTest(webEnvironment = RANDOM_PORT)
@AutoConfigureMockMvc
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
<#if project.isWithTestContainers() && project.isWithPostgres()>
@Testcontainers
@SuppressWarnings({"rawtypes"})
</#if>
public abstract class AbstractIntegrationTest {
    @Autowired
    protected MockMvc mockMvc;

    @Autowired
    protected JsonMapper jsonMapper;
<#if project.isWithTestContainers() && project.isWithPostgres()>

    @Container
    static final PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:17-alpine");

    @DynamicPropertySource
    static void configureProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", postgres::getJdbcUrl);
        registry.add("spring.datasource.username", postgres::getUsername);
        registry.add("spring.datasource.password", postgres::getPassword);
<#if project.isWithFlyway()>
        registry.add("spring.flyway.url", postgres::getJdbcUrl);
        registry.add("spring.flyway.username", postgres::getUsername);
        registry.add("spring.flyway.password", postgres::getPassword);
</#if>
    }
</#if>
}
