<#include "/common/Copyright.ftl">
package ${ContainerConfiguration.packageName()};

import java.time.Duration;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Bean;
<#if ((project.isWithPostgres()) && (project.isWithTestContainers()))>
import org.springframework.boot.devtools.restart.RestartScope;
import org.springframework.boot.testcontainers.service.connection.ServiceConnection;
import org.testcontainers.postgresql.PostgreSQLContainer;
import org.testcontainers.containers.wait.strategy.Wait;
</#if>

@TestConfiguration(proxyBeanMethods=false)
public class ContainerConfiguration {

<#if ((project.isWithPostgres()) && (project.isWithTestContainers()))>
    @Bean
    @ServiceConnection
    @RestartScope
    public PostgreSQLContainer postgreSQLContainer() {
        return new PostgreSQLContainer("postgres")
            .withReuse(true)
            .withStartupTimeout(Duration.ofMinutes(1))
    <#if (project.schema?has_content)>
            .withInitScript("create-schema.sql")
    </#if>
            .waitingFor(Wait.forListeningPort());
    }
</#if>
}