<#include "/common/Copyright.ftl">

package ${Controller.packageName()};

<#if endpoint.isWithPostgres() && endpoint.isWithTestContainers()>
import ${PostgresDbContainerTests.fqcn()};
</#if>
import ${RegisterDatabaseProperties.fqcn()};
import ${Repository.fqcn()};
import ${EjbTestFixtures.fqcn()};
import ${Entity.fqcn()};
import ${EntityResource.fqcn()};
import ${ModelTestFixtures.fqcn()};
import ${TestTableInitializer.fqcn()};
import lombok.extern.slf4j.Slf4j;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.data.r2dbc.core.R2dbcEntityTemplate;
import org.springframework.http.MediaType;
<#if (endpoint.isWithTestContainers())>
</#if>
import org.springframework.test.web.reactive.server.FluxExchangeResult;
import org.springframework.test.web.reactive.server.WebTestClient;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import reactor.test.StepVerifier;

/**
 * Integration tests of ${endpoint.entityName}Controller
 */
@ComponentScan(basePackageClasses = { ${TestTableInitializer.className()}.class })
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@Slf4j
<#if (endpoint.isWithPostgres() && endpoint.isWithTestContainers())>
class ${Controller.integrationTestClass()} extends ${PostgresDbContainerTests.className()} {
<#else>
class ${Controller.integrationTestClass()} implements ${RegisterDatabaseProperties.className()} {
</#if>
   private static final String PATH_TO_TEXT = "$." + ${endpoint.entityName}.Fields.TEXT;
   private static final String PATH_TO_RESOURCE_ID = "$." + ${endpoint.entityName}.Fields.RESOURCE_ID;

   @LocalServerPort
   int port;
<#noparse>
   @Value("${spring.webflux.base-path}")
</#noparse>
   String applicationBasePath;
   private WebTestClient client;

   @Autowired
   private ${Repository.className()} repository;

    @Autowired
    R2dbcEntityTemplate template;

   /*
    * Use this to fetch a record known to exist. The underlying database record
    * is created in the @BeforeEach method.
    */
   private String knownResourceId;

   	@Autowired
    public void setApplicationContext(ApplicationContext context) {
        this.client = WebTestClient.bindToApplicationContext(context).configureClient().build();
    }

    @BeforeEach
    void insertTestRecordsIntoDatabase() {
        repository.deleteAll().block();
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
        ${Entity.className()} item = repository.findAll().blockFirst();
        if (item != null) {
            knownResourceId = item.getResourceId();
        }
    }

    @Test
    void shouldGetAll${endpoint.entityName}s() {
        // @formatter:off
        sendFindAll${endpoint.entityName}sRequest()
            .expectStatus().isOk()
            .expectHeader().contentType(MediaType.APPLICATION_JSON)
            .expectBody().jsonPath("$.[0].text")
            .isNotEmpty().jsonPath("$.[0].resourceId").isNotEmpty();
        // @formatter:on
    }

    @Test
    void shouldGetExisting${endpoint.entityName}() {
        // formatter:off
        sendFindOne${endpoint.entityName}Request(knownResourceId).expectStatus().isOk()
            .expectHeader().contentType(MediaType.APPLICATION_JSON)
            .expectBody()
            .jsonPath(PATH_TO_RESOURCE_ID).isNotEmpty()
            .jsonPath(PATH_TO_TEXT).isNotEmpty();
        // formatter:on
    }

    @Test
    void shouldCreateNew${endpoint.entityName}() {
        ${EntityResource.className()} pojo = ${ModelTestFixtures.className()}.oneWithoutResourceId();

        // @formatter:off
        sendCreate${endpoint.entityName}Request(pojo)
            .expectStatus().isCreated()
            .expectHeader().contentType(MediaType.APPLICATION_JSON);
        // @formatter:on
    }

    @Test
    void shouldUpdateAnExisting${endpoint.entityName}() {
        // Pick one of the persisted instances for an update.
        // Any one will do, as long as it's been persisted.
        ${Entity.className()} targetEntity = ${EjbTestFixtures.className()}.allItems().get(0);

        // Create an empty POJO and set the fields to update
        // (in this example, the text field).
        // The resourceId indicates which instance to update.
        ${EntityResource.className()} updatedItem = ${EntityResource.className()}.builder().build();
        updatedItem.setText("My new text");
        updatedItem.setResourceId(targetEntity.getResourceId());

        sendUpdate${endpoint.entityName}Request(updatedItem).expectStatus().isOk();
    }

    @Test
    void shouldQuietlyDeleteExistingEntity() {
        // Pick one of the persisted instances to delete
        ${Entity.className()} existingItem = ${EjbTestFixtures.className()}.allItems().get(1);
        sendDelete${endpoint.entityName}Request(existingItem.getResourceId()).expectStatus().isNoContent();
    }

    @Test
    void shouldReturnNotFoundWhenResourceDoesNotExist() {
        // @formatter:off
        String validId = ${ModelTestFixtures.className()}.oneWithResourceId().getResourceId();
        sendFindOne${endpoint.entityName}Request(validId).expectStatus().isNotFound()
            .expectHeader().contentType(MediaType.APPLICATION_PROBLEM_JSON)
            .expectBody()
                // I've seen stack traces come back both ways
                .jsonPath("$.stackTrace").doesNotExist()
                .jsonPath("$.trace").doesNotExist();
        // @formatter:on
    }
    
    @Test
    void shouldReturnBadRequestWhenConstraintViolation() {
        // The Problem library provides default handling of constraint violations.
        // The Problem library _does_ send back a stack trace, which is
        // usually a bad idea for client-facing applications, since stack traces leak information.
        // @formatter:off
        sendFindOne${endpoint.entityName}Request("iAmABadRequestId").expectStatus().isBadRequest()
            .expectHeader().contentType(MediaType.APPLICATION_PROBLEM_JSON);
        // @formatter:on
    }    

    @Test
    void shouldGet${endpoint.entityName}AsStream() {
        FluxExchangeResult<${endpoint.pojoName}> result
                = this.client.get()
                      .uri(${endpoint.entityName}Routes.${endpoint.routeConstants.stream})
                      .accept(MediaType.TEXT_EVENT_STREAM)
                      .exchange()
                      .expectStatus().isOk()
                      .returnResult(${endpoint.pojoName}.class);


        Flux<${endpoint.pojoName}> events = result.getResponseBody();

        StepVerifier.create(events)
                    .expectSubscription()
                    .expectNextMatches(p -> p.getResourceId() != null)
   			        .thenCancel().verify();
    }

    /* -----------------------------------------------------------------------
     * Helper methods
     * ----------------------------------------------------------------------- */

    WebTestClient.ResponseSpec sendFindOne${endpoint.entityName}Request(String id) {
        return this.client.get().uri(${Routes.className()}.${endpoint.routeConstants.findOne}.replaceAll("\\{id}", id))
            .accept(MediaType.APPLICATION_JSON).exchange();
    }

    WebTestClient.ResponseSpec sendFindAll${endpoint.entityName}sRequest() {
        return this.client.get().uri(${Routes.className()}.${endpoint.routeConstants.findAll})
            .accept(MediaType.APPLICATION_JSON).exchange();
    }

    WebTestClient.ResponseSpec sendCreate${endpoint.entityName}Request(${endpoint.entityName} pojo) {
        ${EntityRequest.className()} request = ${EntityRequest.className()}.fromDomain(pojo);

        return this.client.post().uri(${Routes.className()}.${endpoint.routeConstants.create})
            .contentType(MediaType.APPLICATION_JSON)
            .body(Mono.just(request), ${EntityRequest.className()}.class).exchange();
    }

    WebTestClient.ResponseSpec sendUpdate${endpoint.entityName}Request(${endpoint.entityName} pojo) {
        ${EntityRequest.className()} request = ${EntityRequest.className()}.fromDomain(pojo);

        return this.client.put().uri(${Routes.className()}.${endpoint.routeConstants.update}.replaceAll("\\{id}", pojo.getResourceId()))
            .contentType(MediaType.APPLICATION_JSON)
            .body(Mono.just(request), ${EntityRequest.className()}.class).exchange();
    }

    WebTestClient.ResponseSpec sendDelete${endpoint.entityName}Request(String resourceId) {
        return this.client.delete().uri(${Routes.className()}.${endpoint.routeConstants.delete}.replaceAll("\\{id}", resourceId)).exchange();
    }
}
