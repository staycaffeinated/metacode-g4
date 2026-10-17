<#include "/common/Copyright.ftl">
package ${RootController.packageName()};

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.ApplicationContext;
import org.springframework.http.MediaType;
import org.springframework.test.web.reactive.server.WebTestClient;
<#if project.isWithKafka()>
import org.springframework.test.context.TestPropertySource;
</#if>
<#if project.isWithPostgres() && project.isWithTestContainers()>
import ${AbstractPostgresIntegrationTest.fqcn()};
import org.testcontainers.junit.jupiter.Testcontainers;
<#elseif project.isWithPostgres()>
import ${RegisterDatabaseProperties.fqcn()};
</#if>

import static org.springframework.boot.test.context.SpringBootTest.WebEnvironment.RANDOM_PORT;

@SpringBootTest(webEnvironment = RANDOM_PORT)
<#if project.isWithKafka()>
@TestPropertySource(properties = "spring.kafka.streams.auto-startup=false")
</#if>
<#if project.isWithPostgres() && project.isWithTestContainers()>
@Testcontainers
class ${RootController.integrationTestClass()} extends ${AbstractPostgresIntegrationTest.className()} {
<#elseif project.isWithPostgres()>
class ${RootController.integrationTestClass()} implements ${RegisterDatabaseProperties.className()} {
<#else>
class ${RootController.integrationTestClass()} {
</#if>

    private WebTestClient client;

    @Autowired
    public void setApplicationContext(ApplicationContext context) {
        this.client = WebTestClient.bindToApplicationContext(context).configureClient().build();
    }

    @Test
    void testGetHome() {
        client.get().uri("/").accept(MediaType.APPLICATION_JSON).exchange().expectStatus().isOk();
    }
}
