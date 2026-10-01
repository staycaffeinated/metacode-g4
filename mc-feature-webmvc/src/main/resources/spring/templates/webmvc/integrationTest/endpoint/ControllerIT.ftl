<#include "/common/Copyright.ftl">

package ${Controller.packageName()};

<#if endpoint.isWithTestContainers()>
import ${AbstractPostgresIntegrationTest.fqcn()};
import org.springframework.context.annotation.Import;
import org.testcontainers.junit.jupiter.Testcontainers;
</#if>
import ${EntityResource.fqcn()};
import ${EntityRequest.fqcn()};
import ${Entity.fqcn()};
import ${PojoToEntityConverter.fqcn()};
import ${EntityToPojoConverter.fqcn()};
import ${RegisterDatabaseProperties.fqcn()};
import ${Repository.fqcn()};
import ${Routes.fqcn()};
import ${EjbTestFixtures.fqcn()};
import tools.jackson.databind.json.JsonMapper;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.Arguments;
import org.junit.jupiter.params.provider.MethodSource;
import org.junit.jupiter.params.provider.ValueSource;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.assertj.MockMvcTester;
import org.springframework.test.web.servlet.assertj.MvcTestResult;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.stream.Stream;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.boot.test.context.SpringBootTest.WebEnvironment.RANDOM_PORT;


@SpringBootTest(webEnvironment = RANDOM_PORT)
@AutoConfigureMockMvc
<#if endpoint.isWithPostgres() && endpoint.isWithTestContainers()>
@Testcontainers
class ${Controller.integrationTestClass()} extends ${AbstractPostgresIntegrationTest.className()} {
<#else>
class ${Controller.integrationTestClass()} implements ${RegisterDatabaseProperties.className()} {
</#if>
    private final MockMvcTester mockMvcTester;
    private final JsonMapper jsonMapper;
    private final ${Repository.className()} ${endpoint.entityVarName}Repository;

    private List<${Entity.className()}> ${endpoint.entityVarName}List = null;

    @Autowired
    public ${Controller.integrationTestClass()}(MockMvcTester mockMvcTester, JsonMapper jsonMapper, ${Repository.className()} repository) {
        this.mockMvcTester = mockMvcTester;
        this.jsonMapper = jsonMapper;
        this.${endpoint.entityVarName}Repository = repository;
    }

    @BeforeEach
    void configureSystemUnderTest() {
        ${endpoint.entityVarName}Repository.saveAll(${EjbTestFixtures.className()}.allItems());
        ${endpoint.entityVarName}List = ${endpoint.entityVarName}Repository.findAll();
    }

    @AfterEach
    void tearDownEachTime() {
        ${endpoint.entityVarName}Repository.deleteAll();
    }


    /*
     * FindById
     */
    @Nested
    class ValidateFindById {
        @Test
        void shouldFind${endpoint.entityName}ById() {
            ${Entity.className()} ejb = ${endpoint.entityVarName}List.get(0);
            String publicId = ejb.getResourceId();

            findSpecificEntity(publicId).assertThat().hasStatus(HttpStatus.OK)
                .bodyJson()
                .extractingPath("$")
                .convertTo(${EntityResource.className()}.class)
                .satisfies(e -> assertThat(e.getResourceId()).isEqualTo(publicId));
        }
    }

    /*
     * Create method
     */
    @Nested
    class ValidateCreate${endpoint.entityName} {
        @Test
        void shouldCreateNew${endpoint.entityName}() throws Exception {
            String attributeValue = "I am a new resource";
            ${EntityResource.className()} resource = ${EntityResource.className()}.builder().text(attributeValue).build();

            createEntity(resource).assertThat()
                    .hasStatus(HttpStatus.CREATED)
                    .hasContentTypeCompatibleWith(MediaType.APPLICATION_JSON)
                    .bodyJson()
                    .extractingPath("$")
                    .convertTo(${EntityResource.className()}.class)
                    .satisfies(e -> assertThat(e.getResourceId()).isNotEmpty())
                    .satisfies(e -> assertThat(e.getText()).isEqualTo(attributeValue));
        }

        /**
         * Verify the controller's data validation catches malformed inputs,
         * such as missing required fields, and returns either 'unprocessable entity'
         * or 'bad request'.
         */
        @Test
        void shouldReturn4xxWhenCreateNew${endpoint.entityName}WithoutText() throws Exception {
            ${EntityResource.className()} resource = ${EntityResource.className()}.builder().build();

            // Oddly, depending on whether the repository uses Postgres or H2, there are two
            // different outcomes. With H2, the controller's @Validated annotation is
            // applied and a 400 status code is returned. With Postgres, the @Validated
            // is ignored and a 422 error occurs when the database catches the invalid data.
            // Given that, we only check for a 4xx error.
            createEntity(resource).assertThat().hasStatus4xxClientError();
        }
    }


    /*
     * Update method
     */
    @Nested
    class ValidateUpdate${endpoint.entityName} {

        @Test
        void shouldUpdate${endpoint.entityName}() throws Exception {
            ${Entity.className()} ejb = ${endpoint.entityVarName}List.get(0);
            ${EntityResource.className()} pojo = new ${EntityToPojoConverter.className()}().convert(ejb);

            updateEntity(ejb.getResourceId(), pojo)
                    .assertThat()
                    .hasStatus(HttpStatus.OK)
                    .hasContentTypeCompatibleWith(MediaType.APPLICATION_JSON)
                    .bodyJson().extractingPath("$").convertTo(${EntityResource.className()}.class)
                    .satisfies(e -> assertThat(e.getResourceId()).isEqualTo(ejb.getResourceId()))
                    .satisfies(e -> assertThat(e.getText()).isEqualTo(pojo.getText()));
        }
    }

    /*
     * Delete method
     */
    @Nested
    class ValidateDelete${endpoint.entityName} {
        @Test
        void shouldDelete${endpoint.entityName}() {
            ${Entity.className()} pojo = ${endpoint.entityVarName}List.get(0);

            deleteEntity(pojo.getResourceId()).assertThat().hasStatus(HttpStatus.OK);
        }
    }

    // ---------------------------------------------------------------------------------------------------------------
    //
    // Helper methods
    //
    // ---------------------------------------------------------------------------------------------------------------
    
    /**
     * Submits a findAll request
     */
    protected MvcTestResult findAllEntities() {
        return mockMvcTester.get()
                    .uri( ${Routes.className()}.${endpoint.routeConstants.findAll}  )
                    .accept(MediaType.APPLICATION_JSON, MediaType.APPLICATION_PROBLEM_JSON)
                    .contentType(MediaType.APPLICATION_JSON)
                    .exchange();
    }


    /**
     * Submits a findOne request
     */
    protected MvcTestResult findSpecificEntity(String resourceId) {
        return mockMvcTester.get()
                .uri( ${Routes.className()}.${endpoint.routeConstants.findOne}, resourceId )
                .accept(MediaType.APPLICATION_JSON, MediaType.APPLICATION_PROBLEM_JSON)
                .contentType(MediaType.APPLICATION_JSON)
                .exchange();
    }

    /**
     * Submits a findByTextAttribute request
     */
    protected MvcTestResult searchByTextAttribute(String attributeValue) {
        return mockMvcTester.get()
                .uri(${Routes.className()}.${endpoint.routeConstants.findByProperty})
                .param(${endpoint.entityName}.Fields.TEXT, URLEncoder.encode(attributeValue, StandardCharsets.UTF_8))
                .accept(MediaType.APPLICATION_JSON, MediaType.APPLICATION_PROBLEM_JSON)
                .contentType(MediaType.APPLICATION_JSON)
                .exchange();
    }

    /**
     * Submits an RSQL search request
     */
    protected MvcTestResult search(String rsqlQuery) {
        return mockMvcTester.get()
                .uri(${Routes.className()}.${endpoint.routeConstants.search})
                .param("q", rsqlQuery)
                .accept(MediaType.APPLICATION_JSON)
                .contentType(MediaType.APPLICATION_JSON)
                .exchange();
    }

    /**
     * Submits a Delete request
     */
    protected MvcTestResult deleteEntity(String resourceId) {
        return mockMvcTester.delete()
                .uri(${Routes.className()}.${endpoint.routeConstants.delete},resourceId)
                .accept(MediaType.APPLICATION_JSON, MediaType.APPLICATION_PROBLEM_JSON)
                .exchange();
    }

    /**
     * Submits a well-formed update request
     */
    protected MvcTestResult updateEntity(${endpoint.pojoName} pojo) throws Exception {
        return updateEntity(pojo.getResourceId(), pojo);
    }

    /**
     * Submits an update request, with support for a badly formed request
     * where the ID in the query string and the ID in the payload do not match.
     */
    protected MvcTestResult updateEntity(String resourceId, ${endpoint.pojoName} pojo) throws Exception {
        ${EntityRequest.className()} request = ${EntityRequest.className()}.fromDomain(pojo);
        return mockMvcTester.put()
                    .uri(${endpoint.entityName}Routes.${endpoint.routeConstants.update}, resourceId)
                    .accept(MediaType.APPLICATION_JSON, MediaType.APPLICATION_PROBLEM_JSON)
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(jsonMapper.writeValueAsString(request))
                    .exchange();
    }

    /**
     * Create an entity
     */
    protected MvcTestResult createEntity(${endpoint.pojoName} pojo) throws Exception {
        ${EntityRequest.className()} request = ${EntityRequest.className()}.fromDomain(pojo);
        return mockMvcTester
                    .post()
                    .uri(${endpoint.entityName}Routes.${endpoint.routeConstants.create})
                    .accept(MediaType.APPLICATION_JSON, MediaType.APPLICATION_PROBLEM_JSON)
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(jsonMapper.writeValueAsString(request))
                    .exchange();
    }
}
