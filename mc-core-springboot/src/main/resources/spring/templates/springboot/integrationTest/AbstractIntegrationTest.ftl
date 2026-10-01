<#include "/common/Copyright.ftl">
package ${AbstractIntegrationTest.packageName()};

import static ${SpringProfiles.fqcn()}.INTEGRATION_TEST;
import static ${SpringProfiles.fqcn()}.TEST;
import static org.springframework.boot.test.context.SpringBootTest.WebEnvironment.RANDOM_PORT;

import tools.jackson.databind.json.JsonMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
<#if (project.testcontainers)??>
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;
</#if>
<#if (project.testcontainers)?? &&  (project.postgres)??>
import org.testcontainers.postgresql.PostgreSQLContainer;
</#if>

@ActiveProfiles({TEST,INTEGRATION_TEST})
@SpringBootTest(webEnvironment = RANDOM_PORT)
<#if (project.testcontainers)??>
@Testcontainers
@SuppressWarnings({"rawtypes"})
</#if>
public abstract class ${AbstractIntegrationTest.className()} {

    @Autowired
    protected JsonMapper jsonMapper;
<#if (project.testcontainers)??>

    // if possible, initialize these from bootstrap-test.properties
    private static final String databaseName = "testdb";
    private static final String username = "postgres";
    private static final String password = "root";
</#if>
<#if (project.testcontainers)?? &&  (project.postgres)??>

    // Task: Set the Postgres version to what your application will use
    @Container
    final static PostgreSQLContainer postgresqlContainer =
                new PostgreSQLContainer("postgres:latest")
                        .withDatabaseName( databaseName )
                        .withUsername( username )
                        .withPassword( password );
</#if>
}