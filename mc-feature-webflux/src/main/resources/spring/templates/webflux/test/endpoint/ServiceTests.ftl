<#include "/common/Copyright.ftl">
package ${ServiceImpl.packageName()};

import ${ConcreteDataStoreApi.fqcn()};
import ${ConcreteDataStoreImpl.fqcn()};
import ${Repository.fqcn()};
import ${EntityToPojoConverter.fqcn()};
import ${PojoToEntityConverter.fqcn()};
import ${EntityResource.fqcn()};
import ${ModelTestFixtures.fqcn()};
import ${UnprocessableEntityException.fqcn()};
import ${SecureRandomSeries.fqcn()};
import ${ResourceIdSupplier.fqcn()};

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.junit.jupiter.MockitoExtension;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import reactor.test.StepVerifier;

import java.time.Duration;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.*;

/**
 * Unit tests of the ${endpoint.entityName} service
 */
@ExtendWith(MockitoExtension.class)
@SuppressWarnings({"java:1201"})
class ${ServiceImpl.testClass()} {
    @Mock
    private ${ConcreteDataStoreApi.className()} mockDataStore;

    @InjectMocks
    private ${ServiceImpl.className()} serviceUnderTest;

    private final ${ResourceIdSupplier.className()} randomSeries = () -> UUID.randomUUID().toString();

    @Test
    void shouldFindAll${endpoint.entityName}s() {
        Flux<${endpoint.pojoName}> itemList = ${ModelTestFixtures.className()}.FLUX_ITEMS;
        given(mockDataStore.findAll()).willReturn(itemList);

        Flux<${endpoint.pojoName}> stream = serviceUnderTest.findAll${endpoint.entityName}s();

        StepVerifier.create(stream).expectSubscription().expectNextCount(${ModelTestFixtures.className()}.ALL_ITEMS.size()).verifyComplete();
    }


    @Test
    void shouldFind${endpoint.entityName}ByResourceId() {
        /*
         * Mock the repository finding a given ${endpoint.ejbName}
         */
        ${endpoint.pojoName} expectedItem = ${ModelTestFixtures.className()}.oneWithResourceId();
        String expectedId = randomSeries.nextResourceId();
        expectedItem.setResourceId(expectedId);
        Mono<${endpoint.pojoName}> rs = Mono.just(expectedItem);
        given(mockDataStore.findByResourceId(any(String.class))).willReturn(rs);

        /*
         * When: the service is asked to find an instance by its resourceId
         */
        Mono<${endpoint.pojoName}> publisher = serviceUnderTest.findByResourceId(expectedId);

        /*
         * Expect: the returned stream to only contain the resource requested
         */
        StepVerifier.create(publisher)
                .expectSubscription()
                .consumeNextWith(item -> assertThat(item.getResourceId()).isEqualTo(expectedId))
                .verifyComplete();
    }


    @Test
    void shouldFindAllByText() {
        /*
         * Mock the repository returning a flux stream of instances that all have matching values
         * in the column being searched.
         */
        final String expectedText = ${ModelTestFixtures.className()}.allItemsWithSameText().get(0).getText();
        Flux<${endpoint.pojoName}> expectedRows = Flux.fromIterable(${ModelTestFixtures.className()}.allItemsWithSameText());
        given(mockDataStore.findAllByText(expectedText)).willReturn(expectedRows);

        /*
         * When: the service is asked to find all instances having the same value in a particular column
         */
        Flux<${endpoint.pojoName}> publisher = serviceUnderTest.findAllByText(expectedText);

        /*
         * Expect: the result set to contain the same instances found by the repository
         */
        StepVerifier.create(publisher)
                .expectSubscription()
                .consumeNextWith(item -> assertThat(item.getText()).isEqualTo(expectedText))
                .consumeNextWith(item -> assertThat(item.getText()).isEqualTo(expectedText))
                .consumeNextWith(item -> assertThat(item.getText()).isEqualTo(expectedText))
                .verifyComplete();
    }


    @Test
    void shouldCreate${endpoint.entityName}() {
        // Given
        String expectedResourceId = randomSeries.nextResourceId();
        // what the client submits to the service
        ${endpoint.pojoName} expectedPOJO = ${ModelTestFixtures.className()}.oneWithoutResourceId();
        given(mockDataStore.create${endpoint.entityName}(any(${endpoint.pojoName}.class))).willReturn(Mono.just(expectedResourceId));

        // When
        Mono<String> publisher = serviceUnderTest.create${endpoint.entityName}(expectedPOJO);

        // Then
        StepVerifier.create(publisher.log("testCreate : "))
                .expectSubscription().consumeNextWith(id -> assertThat(id).isEqualTo(expectedResourceId)).verifyComplete();

    }


    @Test
    void shouldUpdate${endpoint.entityName}() {
        // Given
        // what the client submits
        ${endpoint.pojoName} submittedPOJO = ${ModelTestFixtures.className()}.oneWithResourceId();
        Mono<${endpoint.pojoName}> reply = Mono.justOrEmpty(submittedPOJO);
        when(mockDataStore.update${endpoint.entityName}(any(${endpoint.pojoName}.class))).thenReturn(reply);

        // When
        Mono<${endpoint.pojoName}> publisher = serviceUnderTest.update${endpoint.entityName}(submittedPOJO);

        // Then
   		  StepVerifier.create(publisher).expectSubscription().consumeNextWith(
				    v -> assertThat(v.getResourceId()).isEqualTo(submittedPOJO.getResourceId())).verifyComplete();


        verify(mockDataStore, times(1)).update${endpoint.entityName}(any(${endpoint.pojoName}.class));
    }


    @Test
    void shouldDelete${endpoint.entityName}() {
        // The data store returns 1, to indicate 1 row was deleted
        given(mockDataStore.deleteByResourceId(any(String.class))).willReturn(Mono.just(1L));

        final String idToDelete = randomSeries.nextResourceId();
        Mono<Long> publisher = serviceUnderTest.delete${endpoint.entityName}ByResourceId(idToDelete);
        
        StepVerifier.create(publisher).expectSubscription().expectNextCount(1L).verifyComplete();

        verify(mockDataStore, times(1)).deleteByResourceId(any(String.class));
    }


	@Test
    @SuppressWarnings("all")
	void whenDeleteNull${endpoint.entityName}_expectNullPointerException() {
		assertThrows(NullPointerException.class, () -> serviceUnderTest.delete${endpoint.entityName}ByResourceId((String) null));
	}

	@Test
	void whenFindNonExistingEntity_expectEmptyResultSet() {
		given(mockDataStore.findByResourceId(any())).willReturn(Mono.empty());

		Mono<${endpoint.pojoName}> publisher = serviceUnderTest.findByResourceId(randomSeries.nextResourceId());

		StepVerifier.create(publisher).expectSubscription().expectNextCount(0).verifyComplete();
	}

	@Test
    @SuppressWarnings("all")
	void whenUpdateOfNull${endpoint.entityName}_expectNullPointerException() {
		assertThrows(NullPointerException.class, () -> serviceUnderTest.update${endpoint.entityName}(null));
	}

	@Test
    @SuppressWarnings("all")
	void whenFindAllByNullText_expectNullPointerException() {
		assertThrows(NullPointerException.class, () -> serviceUnderTest.findAllByText(null));
	}

	@Test
    @SuppressWarnings("all")
	void whenCreateNull${endpoint.entityName}_expectNullPointerException() {
		assertThrows(NullPointerException.class, () -> serviceUnderTest.create${endpoint.entityName}(null));
	}

	@Test
	void whenTheDataStoreSignalsAConversionFailure_expectUnprocessableEntityException() {
        // given
        given(mockDataStore.create${endpoint.pojoName}(any(${endpoint.pojoName}.class)))
                .willReturn(Mono.error(new UnprocessableEntityException("conversion failed")));

        ${endpoint.pojoName} sample = ${ModelTestFixtures.className()}.oneWithoutResourceId();

        // when/then
        // @formatter:off
    	StepVerifier.create(serviceUnderTest.create${endpoint.pojoName}(sample))
                    .expectSubscription()
				    .expectError(UnprocessableEntityException.class)
  				    .verify(Duration.ofMillis(1000));
  		// @formatter:on
	}
}