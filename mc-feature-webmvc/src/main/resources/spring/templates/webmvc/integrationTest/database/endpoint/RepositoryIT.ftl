<#include "/common/Copyright.ftl">

package ${Repository.packageName()};

<#if endpoint.isWithTestContainers()>
import org.testcontainers.junit.jupiter.Testcontainers;
</#if>
import ${Entity.fqcn()};
import ${EntitySpecification.fqcn()};
import ${EjbTestFixtures.fqcn()};
<#if endpoint.isWithPostgres() && endpoint.isWithTestContainers()>
import ${AbstractPostgresIntegrationTest.fqcn()};
<#else>
import ${RegisterDatabaseProperties.fqcn()};
</#if>

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import org.springframework.boot.jdbc.autoconfigure.DataSourceAutoConfiguration;
import org.springframework.boot.jdbc.test.autoconfigure.AutoConfigureTestDatabase;
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
<#if endpoint.isWithPostgres() && endpoint.isWithTestContainers()>
import static org.springframework.boot.test.context.SpringBootTest.WebEnvironment.RANDOM_PORT;
</#if>
/**
* These tests verify custom queries added to the repository.
* If the JPA queries are not modified, or not custom methods are added to the
* Repository class, these tests may be deleted.
*/
<#if endpoint.isWithPostgres() && endpoint.isWithTestContainers()>
@DataJpaTest
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
@Testcontainers
class ${Repository.integrationTestClass()} extends ${AbstractPostgresIntegrationTest.className()} {
<#else>
@DataJpaTest
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
class ${Repository.integrationTestClass()} implements RegisterDatabaseProperties {
</#if>
    @Autowired
    private ${Repository.className()} repositoryUnderTest;

    @BeforeEach
    void insertTestData() {
        repositoryUnderTest.saveAll(${EjbTestFixtures.className()}.allItems());
    }

    @AfterEach
    void tearDownEachTime() {
        repositoryUnderTest.deleteAll();
        repositoryUnderTest.flush();
    }

    @SuppressWarnings({"java:S125"}) // false positive: this comment block does not contain code
    /*
     * Test custom methods.
     *
     * Its worth testing custom queries to ensure the query semantics are correct;
     * simply having proper syntax does not ensure the records that _should_ be
     * returned are the one's being returned.
     *
     * The scope of these tests is to verify the semantics of custom JPA queries added
     * to the Repository interface. The repository methods that are available out-of-the-box,
     * such as findById, do not need to be tested. It's entirely possible that this test class
     * can be removed altogether.
     */
    @Nested
    class ValidateCustomMethod {
        /**
         * This is an example test. You do not actually need to verify the findAll method.
         * This test is only an example of how you might want to write such a test.
         */
        @Test
        void shouldFindAll() {
            Pageable pageable = PageRequest.of(0, 10);
            Page<${Entity.className()}> page = repositoryUnderTest.findAll(pageable);

            assertThat(page).isNotNull();
            assertThat(page.hasContent()).isTrue();
        }
    }

    @Nested
    class ValidatePredicates {
        @Test
        void shouldNotIgnoreCase() {
            String text = ${EjbTestFixtures.className()}.allItems().get(0).getText();
            Specification<${Entity.className()}> where = ${EntitySpecification.className()}.builder().text(text.toUpperCase()).build();
            List<${Entity.className()}> list = repositoryUnderTest.findAll(where);

            // Typically, Specifications are case-sensitive. This is usually because the database itself
            // is case-sensitive when it comes to matching values in queries. You will want to think about
            // how you want to handle case-sensitivity. It might make sense for lastName of 'smith' to
            // match 'Smith', but it would probably be problematic for resourceId of 'a123b456cde' to match 'A123b456CDe'.
            assertThat(list).isNotNull().isEmpty();
        }

        @Test
        void shouldFindNoneWithAnEmptyValue() {
            Specification<${Entity.className()}> where = ${EntitySpecification.className()}.builder().text("").build();
            List<${Entity.className()}> list = repositoryUnderTest.findAll(where);
            assertThat(list).isNotNull().isEmpty();
        }

        @Test
        void shouldFindMatchingRecords() {
            // Pick a value known to be present in the database
            String text = ${EjbTestFixtures.className()}.allItems().get(1).getText();
            // Construct a Specification to search for that value
            Specification<${Entity.className()}> where = ${EntitySpecification.className()}.builder().text(text).build();

            // Search using the specification
            List<${Entity.className()}> list = repositoryUnderTest.findAll(where);
            // Verify at least one matching record was found
            assertThat(list).isNotNull().isNotEmpty();
        }
    }

}
