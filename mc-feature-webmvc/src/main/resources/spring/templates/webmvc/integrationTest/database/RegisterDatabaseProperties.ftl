<#include "/common/Copyright.ftl">
package ${RegisterDatabaseProperties.packageName()};

import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;


public interface RegisterDatabaseProperties {

<#if project.isWithTestContainers() && project.isWithPostgres()>
    @DynamicPropertySource
    static void registerDatabaseProperties(DynamicPropertyRegistry registry) {
        // Be aware that calling testContainer.getJdbcUrl returns a URL that starts
        // something like "jdbc:postgresql://localhost...etc...".
        // The URL needs to start with "jdbc:tc:postgresql", The 'tc' between 'jdbc' and
        // 'postgres' is the hint to the driver that the TestContainer handles the URL,
        // not the typical runtime JDCB driver.
        registry.add("spring.datasource.url", () -> "jdbc:tc:postgresql:15.1-alpine:///public");
        registry.add("spring.datasource.driver-class-name", () -> "org.testcontainers.jdbc.ContainerDatabaseDriver");
        registry.add("spring.jpa.database-platform", () -> "org.hibernate.dialect.PostgreSQLDialect");
        registry.add("spring.jpa.hibernate.ddl-auto", () -> "create-drop");
        registry.add("spring.jpa.show-sql", () -> "true");
        registry.add("spring.jpa.properties.hibernate.format_sql", () -> "true");
    }
<#elseif project.isWithPostgres()>
<#-- Using Postgres w/o Testcontainers -->
    /*
     * These properties need to be adjusted to match your environment
     */
    registry.add("spring.datasource.url", () -> "jdbc:postgresql://localhost:5432/postgres");
    registry.add("spring.datasource.driver-class-name", () -> "org.postgresql.Driver");
    registry.add("spring.jpa.properties.hibernate.dialect", () -> "rg.hibernate.dialect.PostgresPlusDialect");
    registry.add("spring.jpa.hibernate.ddl-auto", () -> "create-drop");
    registry.add("spring.jpa.show-sql", () -> "true");
    registry.add("spring.jpa.properties.hibernate.format_sql", () -> "true");
<#else>
<#-- Define H2 database properties -->
    @DynamicPropertySource
    static void registerDatabaseProperties(DynamicPropertyRegistry registry) {
<#if (project.schema?has_content)>
        registry.add("spring.datasource.url", () -> "jdbc:h2:mem:testdb;DATABASE_TO_UPPER=false;DB_CLOSE_DELAY=-1;INIT=CREATE SCHEMA IF NOT EXISTS ${project.schema}\\;");
<#else>
        registry.add("spring.datasource.url", () -> "jdbc:h2:mem:testdb;DATABASE_TO_UPPER=false;DB_CLOSE_DELAY=-1");
</#if>
        registry.add("spring.datasource.driver-class-name", () -> "org.h2.Driver");
        registry.add("spring.datasource.initialization-mode", () -> "embedded");
        registry.add("spring.jpa.database-platform", () -> "org.hibernate.dialect.H2Dialect");
        registry.add("spring.jpa.properties.hibernate.id.new_generator_mappings", () -> "false");

        // The username and password here must match the username and password in the
        // src/test/resources/application-test.yaml.  Otherwise, you will see
        // "org.h2.jdbc.JdbcSQLInvalidAuthorizationSpecException: Wrong user name or password"
        registry.add("spring.datasource.username", () -> "sa");
        registry.add("spring.datasource.password", () -> "password");
        registry.add("spring.jpa.hibernate.ddl-auto", () -> "create-drop");
        registry.add("spring.jpa.show-sql", () -> "true");
        registry.add("spring.jpa.properties.hibernate.format_sql", () -> "true");
    }
</#if>

}