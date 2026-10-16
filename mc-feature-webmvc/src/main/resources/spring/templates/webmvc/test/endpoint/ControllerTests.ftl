<#include "/common/Copyright.ftl">

package ${Controller.packageName()};

import ${Entity.fqcn()};
import ${EntityResource.fqcn()};
import ${ModelTestFixtures.fqcn()};
import ${SecureRandomSeries.fqcn()};
import ${ResourceIdSupplier.fqcn()};
import ${GlobalExceptionHandler.fqcn()};
import ${EntityCommandUseCase.fqcn()};
import ${EntityQueryUseCase.fqcn()};
import ${EntityRequest.fqcn()};
import tools.jackson.databind.json.JsonMapper;
import jakarta.validation.ConstraintViolationException;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;
import org.mockito.Mockito;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.HateoasPageableHandlerMethodArgumentResolver;
import org.springframework.data.web.PageableHandlerMethodArgumentResolver;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.assertj.MockMvcTester;
import org.springframework.test.web.servlet.assertj.MvcTestResult;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.transaction.TransactionSystemException;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.reset;

class ${Controller.testClass()} {

    @MockitoBean
    private ${EntityCommandUseCase.className()} commandUseCase;

    @MockitoBean
    private ${EntityQueryUseCase.className()} queryUseCase;

    private MockMvcTester mockMvcTester;

    private final JsonMapper jsonMapper = new JsonMapper();

    private Page<${EntityResource.className()}> pageOfData;

    private final ${ResourceIdSupplier.className()} randomSeries = new ${SecureRandomSeries.className()}();

    @BeforeEach
    void configureSystemUnderTest() {
        commandUseCase = Mockito.mock(${EntityCommandUseCase.className()}.class);
        queryUseCase = Mockito.mock(${EntityQueryUseCase.className()}.class);
        var pageableResolver = new HateoasPageableHandlerMethodArgumentResolver();

        var mockMvc = MockMvcBuilders.standaloneSetup(new ${Controller.className()}(commandUseCase, queryUseCase))
                                       .setCustomArgumentResolvers(pageableResolver, new PageableHandlerMethodArgumentResolver())
                                       .setControllerAdvice(new GlobalExceptionHandler(new JsonMapper()))
                                       .build();
        mockMvcTester = MockMvcTester.create(mockMvc);

        var ${endpoint.entityVarName}List = ${ModelTestFixtures.className()}.allItems();
        pageOfData = new PageImpl<>(${endpoint.entityVarName}List);
    }

    @AfterEach
    void tearDownEachTime() {
        reset ( commandUseCase, queryUseCase );
    }

    @Nested
    class FindAllUseCases {
        @Test
        void shouldFetchAll${endpoint.entityName}s() {
            given(queryUseCase.findAll${endpoint.entityName}(any(Pageable.class))).willReturn(pageOfData);

            var jsonPathToId = "$.[0]." + ${EntityResource.className()}.Fields.RESOURCE_ID;

            findAllEntities()
                .assertThat()
                .hasStatus(HttpStatus.OK)
                .hasContentTypeCompatibleWith(MediaType.APPLICATION_JSON)
                .bodyJson()
                .hasPathSatisfying(jsonPathToId, path -> assertThat(path).isNotEmpty());
        }
    }

    @Nested
    class FindByIdUseCases {
        @Test
        void shouldFind${endpoint.entityName}ById() {
            // given
            ${EntityResource.className()} ${endpoint.entityVarName} = ${ModelTestFixtures.className()}.oneWithResourceId();
            String resourceId = ${endpoint.entityVarName}.getResourceId();

            given(queryUseCase.find${endpoint.entityName}ByResourceId( resourceId ))
                .willReturn(Optional.of(${endpoint.entityVarName}));

            // when/then
            findSpecificEntity(resourceId)
                .assertThat()
                .hasStatus(HttpStatus.OK)
                .hasContentTypeCompatibleWith(MediaType.APPLICATION_JSON)
                .bodyJson()
                .extractingPath("$")
                .asMap()
                .containsEntry(${EntityResource.className()}.Fields.RESOURCE_ID, resourceId)
                .containsEntry(${EntityResource.className()}.Fields.TEXT, ${endpoint.entityVarName}.getText());
        }

        @Test
        void shouldReturn404WhenFetchingNonExisting${endpoint.entityName}() {
            // given
            String resourceId = randomSeries.nextResourceId();
            given(queryUseCase.find${endpoint.entityName}ByResourceId( resourceId )).willReturn(Optional.empty());

            // when/then
            findSpecificEntity(resourceId).assertThat().hasStatus(HttpStatus.NOT_FOUND);
        }
    }

    @Nested
    class Create${endpoint.entityName}UseCases {
        @Test
        void shouldCreateNew${endpoint.entityName}() throws Exception {
            // given
            ${EntityResource.className()} resourceBeforeSave = ${ModelTestFixtures.className()}.oneWithoutResourceId();
            ${EntityResource.className()} resourceAfterSave = ${ModelTestFixtures.className()}.copyOf(resourceBeforeSave);
            resourceAfterSave.setResourceId(randomSeries.nextResourceId());
            given(commandUseCase.create${endpoint.entityName}( any(${EntityResource.className()}.class))).willReturn(resourceAfterSave);

            // when/then
            createEntity(resourceBeforeSave)
                .assertThat()
                .hasStatus(HttpStatus.CREATED)
                .bodyJson()
                .extractingPath("$")
                .asMap()
                .containsEntry(${EntityResource.className()}.Fields.TEXT, resourceAfterSave.getText())
                .containsKey(${EntityResource.className()}.Fields.RESOURCE_ID);
        }

        @Test
        void whenDatabaseThrowsException_expectUnprocessableEntityResponse() throws Exception {
            // given the database throws an exception when the entity is saved
            given(commandUseCase.create${endpoint.entityName}( any(${EntityResource.className()}.class))).willThrow(TransactionSystemException.class);
            ${EntityResource.className()} resource = ${EntityResource.className()}.builder().build();

            createEntity(resource).assertThat().hasStatus(HttpStatus.UNPROCESSABLE_CONTENT);
        }
    }

    @Nested
    class Update${endpoint.entityName}UseCases {
        @Test
        void shouldUpdate${endpoint.entityName}() throws Exception {
            // given
            String resourceId = randomSeries.nextResourceId();
            ${EntityResource.className()} ${endpoint.entityVarName} = ${EntityResource.className()}.builder().resourceId(resourceId).text("sample text").build();
            given(queryUseCase.find${endpoint.entityName}ByResourceId(resourceId)).willReturn(Optional.of(${endpoint.entityVarName}));
            given(commandUseCase.update${endpoint.entityName}(any(${EntityResource.className()}.class))).willReturn(Optional.of(${endpoint.entityVarName}));

            // when/then
            updateEntity(resourceId, ${endpoint.entityVarName}).assertThat().hasStatus(HttpStatus.OK);
        }

        @Test
        void shouldReturn404WhenUpdatingNonExisting${endpoint.entityName}() throws Exception {
            // given
            String resourceId = randomSeries.nextResourceId();
            given(queryUseCase.find${endpoint.entityName}ByResourceId(resourceId)).willReturn(Optional.empty());

            // when/then
            ${EntityResource.className()} resource = ${EntityResource.className()}.builder().resourceId(resourceId).text("updated text").build();

            updateEntity(resource).assertThat().hasStatus(HttpStatus.NOT_FOUND);
        }

        @Test
        void shouldReturn422WhenIdsMismatch() throws Exception {
            // given
            String resourceId = randomSeries.nextResourceId();
            String mismatchingId = randomSeries.nextResourceId();
            given(queryUseCase.find${endpoint.entityName}ByResourceId(resourceId)).willReturn(Optional.empty());

            ${EntityResource.className()} resource = ${EntityResource.className()}.builder().resourceId(mismatchingId).text("updated text").build();

            updateEntity(resourceId, resource).assertThat().hasStatus(HttpStatus.UNPROCESSABLE_CONTENT);
        }
    }

    @Nested
    class Delete${endpoint.entityName}UseCases {
        @Test
        void shouldDelete${endpoint.entityName}() {
            // given
            ${EntityResource.className()} ${endpoint.entityVarName} = ${ModelTestFixtures.className()}.oneWithResourceId();
            String resourceId = ${endpoint.entityVarName}.getResourceId();

            given(commandUseCase.delete${endpoint.entityName}ByResourceId(resourceId)).willReturn(Optional.of(${endpoint.entityVarName}));

            // when/then
            deleteEntity(resourceId)
                .assertThat()
                .hasStatus(HttpStatus.OK)
                .bodyJson()
                .extractingPath("$")
                .asMap()
                .containsKey(${EntityResource.className()}.Fields.RESOURCE_ID);
        }

        @Test
        void shouldReturn404WhenDeletingNonExisting${endpoint.entityName}() {
            String resourceId = randomSeries.nextResourceId();
            given(queryUseCase.find${endpoint.entityName}ByResourceId(resourceId)).willReturn(Optional.empty());

            deleteEntity(resourceId).assertThat().hasStatus(HttpStatus.NOT_FOUND);
        }
    }

    @Nested
    class SearchUseCases {
        @ParameterizedTest
        @ValueSource(strings = {
            "text!='Foo Bar'",
            "text*='Foo'",
            "resourceId>0"})
        void shouldReturnSomethingFromQuery(String rsqlQuery) {
            given (queryUseCase.search(any(String.class), any(Pageable.class))).willReturn(pageOfData);
            search(rsqlQuery).assertThat().hasStatus(HttpStatus.OK);
        }
    }

    // ---------------------------------------------------------------------------------------------------------------
    //
    // Helper methods
    //
    // ---------------------------------------------------------------------------------------------------------------

    protected MvcTestResult findAllEntities() {
        return mockMvcTester.get()
                            .uri( ${Routes.className()}.${endpoint.routeConstants.findAll}  )
                            .accept(MediaType.APPLICATION_JSON, MediaType.APPLICATION_PROBLEM_JSON)
                            .contentType(MediaType.APPLICATION_JSON)
                            .exchange();
    }

    protected MvcTestResult findSpecificEntity(String resourceId) {
        return mockMvcTester.get()
                            .uri( ${Routes.className()}.${endpoint.routeConstants.findOne}, resourceId )
                            .accept(MediaType.APPLICATION_JSON, MediaType.APPLICATION_PROBLEM_JSON)
                            .contentType(MediaType.APPLICATION_JSON)
                            .exchange();
    }

    protected MvcTestResult searchByTextAttribute(String attributeValue) {
        return mockMvcTester.get()
                            .uri(${Routes.className()}.${endpoint.routeConstants.findByProperty})
                            .param(${EntityResource.className()}.Fields.TEXT, attributeValue)
                            .accept(MediaType.APPLICATION_JSON, MediaType.APPLICATION_PROBLEM_JSON)
                            .contentType(MediaType.APPLICATION_JSON)
                            .exchange();
    }

    protected MvcTestResult search(String rsqlQuery) {
        return mockMvcTester.get()
                            .uri(${Routes.className()}.${endpoint.routeConstants.search})
                            .param("q", rsqlQuery)
                            .accept(MediaType.APPLICATION_JSON)
                            .contentType(MediaType.APPLICATION_JSON)
                            .exchange();
    }

    protected MvcTestResult deleteEntity(String resourceId) {
        return mockMvcTester.delete()
                            .uri(${Routes.className()}.${endpoint.routeConstants.delete},resourceId)
                            .accept(MediaType.APPLICATION_JSON, MediaType.APPLICATION_PROBLEM_JSON)
                            .exchange();
    }

    protected MvcTestResult updateEntity(${EntityResource.className()} pojo) throws Exception {
        return updateEntity(pojo.getResourceId(), pojo);
    }

    protected MvcTestResult updateEntity(String resourceId, ${EntityResource.className()} pojo) throws Exception {
        ${EntityRequest.className()} request = ${EntityRequest.className()}.fromDomain(pojo);
        return mockMvcTester
                    .put()
                    .uri(${Routes.className()}.${endpoint.routeConstants.update}, resourceId)
                    .accept(MediaType.APPLICATION_JSON, MediaType.APPLICATION_PROBLEM_JSON)
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(jsonMapper.writeValueAsString(request))
                    .exchange();
    }

    protected MvcTestResult createEntity(${EntityResource.className()} pojo) throws Exception {
        ${EntityRequest.className()} request = ${EntityRequest.className()}.fromDomain(pojo);
        return mockMvcTester
                    .post()
                    .uri(${Routes.className()}.${endpoint.routeConstants.create})
                    .accept(MediaType.APPLICATION_JSON, MediaType.APPLICATION_PROBLEM_JSON)
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(jsonMapper.writeValueAsString(request))
                    .exchange();
    }
}
