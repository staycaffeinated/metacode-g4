<#include "/common/Copyright.ftl">
package ${Repository.packageName()};


import ${ContainerConfiguration.fqcn()};
<#if endpoint.isWithPostgres() && endpoint.isWithTestContainers()>
import ${PostgresDbContainerTests.fqcn()};
</#if>
import ${RegisterDatabaseProperties.fqcn()};
import ${EjbTestFixtures.fqcn()};
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.data.r2dbc.core.R2dbcEntityTemplate;
import reactor.test.StepVerifier;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Repository integration help catch syntax errors in custom
 * queries that may get added to the Repository interface.
 * This class only needs to test those repository methods
 * that use custom queries; there's no value added by
 * testing the default repository query methods.
 */
@SpringBootTest
@ComponentScan(basePackageClasses = {${ContainerConfiguration.className()}.class})
<#if ((endpoint.isWithPostgres()))>
class ${Repository.integrationTestClass()} extends ${PostgresDbContainerTests.className()} {
<#else>
class ${Repository.integrationTestClass()} implements ${RegisterDatabaseProperties.className()} {
</#if>

    @Autowired
    ${Repository.className()} repositoryUnderTest;

    @Autowired
    R2dbcEntityTemplate template;

    @BeforeEach
    void insertTestRecordsIntoDatabase() {
        repositoryUnderTest.deleteAll().block();
        /*
         * repository.saveAll() turns out not be reliable in so much as the persisted resourceIds
         * sometimes end up null, despite being set in the Entity's `beforeInsert` method.
         * Explicitly inserting records doesn't suffer this problem.
         *
         */
        ${EjbTestFixtures.className()}.allItems().forEach(item -> {
            template.insert(${Entity.className()}.class)
                    .using(item)
                    .as(StepVerifier::create)
                    .expectNextCount(1)
                    .verifyComplete();
            });
    }

    @Test
    void shouldFindFirstRecord() {
        ${endpoint.ejbName} firstOne = repositoryUnderTest.findAll().blockFirst();
        assertThat(firstOne).isNotNull();
    }
}


