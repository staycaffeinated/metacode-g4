<#include "/common/Copyright.ftl">
package ${AbstractIntegrationTest.packageName()};

import static ${SpringProfiles.packageName()}.SpringProfiles.INTEGRATION_TEST;
import static ${SpringProfiles.packageName()}.SpringProfiles.TEST;
import static org.springframework.boot.test.context.SpringBootTest.WebEnvironment.RANDOM_PORT;

import tools.jackson.databind.json.JsonMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.jdbc.autoconfigure.DataSourceAutoConfiguration;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.boot.jdbc.test.autoconfigure.AutoConfigureTestDatabase;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
<#if (project.testcontainers)??>
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;
</#if>
<#if (project.testcontainers)?? &&  (project.postgres)??>
import org.testcontainers.postgresql.PostgreSQLContainer;
</#if>

@ActiveProfiles({TEST, INTEGRATION_TEST})
@SpringBootTest(webEnvironment = RANDOM_PORT)
@AutoConfigureMockMvc
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
<#if (project.testcontainers)??>
    @Testcontainers
    @SuppressWarnings({"rawtypes"})
</#if>
<#if (project.postgres)??>
    @TestPropertySource(properties = {
    "spring.datasource.url=jdbc:tc:postgresql:13.2-alpine:///public",
    "spring.datasource.driver-class-name=org.testcontainers.jdbc.ContainerDatabaseDriver",
    "spring.jpa.hibernate.ddl-auto=create-drop"})
</#if>
public abstract class AbstractIntegrationTest {
    @Autowired
    protected MockMvc mockMvc;

    @Autowired
    protected JsonMapper jsonMapper;
<#if (project.testcontainers)??>

    // if possible, initialize these from bootstrap-test.properties
    private static final String databaseName = "testdb";
    private static final String username = "postgres";
    private static final String password = "root";
</#if>
<#if (project.testcontainers)?? &&  (project.postgres)??>

    @Container
    final static PostgreSQLContainer postgresqlContainer = new PostgreSQLContainer("postgres:latest")
        .withDatabaseName( databaseName )
        .withUsername( username )
        .withPassword( password );
</#if>
}
