<#include "/common/Copyright.ftl">
package ${ConcreteDataStoreImpl.packageName()};

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.given;

import ${Entity.fqcn()};
import ${EntityResource.fqcn()};
import ${EntityToPojoConverter.fqcn()};
import ${ModelTestFixtures.fqcn()};
import ${PojoToEntityConverter.fqcn()};
import ${Repository.fqcn()};
import ${ResourceNotFoundException.fqcn()};
import ${UnprocessableEntityException.fqcn()};
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import reactor.test.StepVerifier;

@ExtendWith(MockitoExtension.class)
@SuppressWarnings("unchecked")
class ${ConcreteDataStoreImpl.testClass()} {

    @Mock
    private ${Repository.className()} mockRepository;

    @Mock
    private ${EntityToPojoConverter.className()} mockEjbToPojoConverter;

    @Mock
    private ${PojoToEntityConverter.className()} mockPojoToEjbConverter;

    @InjectMocks
    private ${ConcreteDataStoreImpl.className()} dataStoreUnderTest;

    // -------------------------------------------------------
    // create
    // -------------------------------------------------------

    @Test
    void whenCreate_withValidPojo_expectResourceIdReturned() {
        ${EntityResource.className()} pojo = ${ModelTestFixtures.className()}.oneWithoutResourceId();
        ${Entity.className()} entity = ${Entity.className()}.builder().resourceId("abc123").text(pojo.getText()).build();
        given(mockPojoToEjbConverter.convert(any(${EntityResource.className()}.class))).willReturn(entity);
        given(mockRepository.save(any(${Entity.className()}.class))).willReturn(Mono.just(entity));

        StepVerifier.create(dataStoreUnderTest.create${endpoint.entityName}(pojo))
                .expectNext("abc123")
                .verifyComplete();
    }

    @Test
    void whenCreate_converterReturnsNull_expectUnprocessableEntityException() {
        ${EntityResource.className()} pojo = ${ModelTestFixtures.className()}.oneWithoutResourceId();
        given(mockPojoToEjbConverter.convert(any(${EntityResource.className()}.class))).willReturn(null);

        StepVerifier.create(dataStoreUnderTest.create${endpoint.entityName}(pojo))
                .expectError(${UnprocessableEntityException.className()}.class)
                .verify();
    }

    // -------------------------------------------------------
    // findByResourceId
    // -------------------------------------------------------

    @Test
    void whenFindByResourceId_entityFound_expectPojoReturned() {
        ${EntityResource.className()} expected = ${ModelTestFixtures.className()}.oneWithResourceId();
        ${Entity.className()} entity = ${Entity.className()}.builder().resourceId(expected.getResourceId()).text(expected.getText()).build();
        given(mockRepository.findByResourceId(expected.getResourceId())).willReturn(Mono.just(entity));
        given(mockEjbToPojoConverter.convert(any(${Entity.className()}.class))).willReturn(expected);

        StepVerifier.create(dataStoreUnderTest.findByResourceId(expected.getResourceId()))
                .expectNext(expected)
                .verifyComplete();
    }

    @Test
    void whenFindByResourceId_converterReturnsNull_expectResourceNotFoundException() {
        ${Entity.className()} entity = ${Entity.className()}.builder().resourceId("someId").text("text").build();
        given(mockRepository.findByResourceId("someId")).willReturn(Mono.just(entity));
        given(mockEjbToPojoConverter.convert(any(${Entity.className()}.class))).willReturn(null);

        StepVerifier.create(dataStoreUnderTest.findByResourceId("someId"))
                .expectError(${ResourceNotFoundException.className()}.class)
                .verify();
    }

    // -------------------------------------------------------
    // findById
    // -------------------------------------------------------

    @Test
    void whenFindById_entityFound_expectPojoReturned() {
        ${EntityResource.className()} expected = ${ModelTestFixtures.className()}.oneWithResourceId();
        ${Entity.className()} entity = ${Entity.className()}.builder().id(1L).resourceId(expected.getResourceId()).text(expected.getText()).build();
        given(mockRepository.findById(1L)).willReturn(Mono.just(entity));
        given(mockEjbToPojoConverter.convert(any(${Entity.className()}.class))).willReturn(expected);

        StepVerifier.create(dataStoreUnderTest.findById(1L))
                .expectNext(expected)
                .verifyComplete();
    }

    @Test
    void whenFindById_converterReturnsNull_expectResourceNotFoundException() {
        ${Entity.className()} entity = ${Entity.className()}.builder().id(1L).text("text").build();
        given(mockRepository.findById(1L)).willReturn(Mono.just(entity));
        given(mockEjbToPojoConverter.convert(any(${Entity.className()}.class))).willReturn(null);

        StepVerifier.create(dataStoreUnderTest.findById(1L))
                .expectError(${ResourceNotFoundException.className()}.class)
                .verify();
    }

    // -------------------------------------------------------
    // update
    // -------------------------------------------------------

    @Test
    void whenUpdate_entityFound_expectUpdatedPojoReturned() {
        ${EntityResource.className()} resource = ${ModelTestFixtures.className()}.oneWithResourceId();
        ${Entity.className()} entity = ${Entity.className()}.builder().resourceId(resource.getResourceId()).text(resource.getText()).build();
        given(mockRepository.findByResourceId(resource.getResourceId())).willReturn(Mono.just(entity));
        given(mockRepository.save(any(${Entity.className()}.class))).willReturn(Mono.just(entity));
        given(mockEjbToPojoConverter.convert(any(${Entity.className()}.class))).willReturn(resource);

        StepVerifier.create(dataStoreUnderTest.update${endpoint.entityName}(resource))
                .expectNext(resource)
                .verifyComplete();
    }

    // -------------------------------------------------------
    // deleteByResourceId
    // -------------------------------------------------------

    @Test
    void whenDeleteByResourceId_expectCountReturned() {
        given(mockRepository.deleteByResourceId("someId")).willReturn(Mono.just(1L));

        StepVerifier.create(dataStoreUnderTest.deleteByResourceId("someId"))
                .expectNext(1L)
                .verifyComplete();
    }

    // -------------------------------------------------------
    // findAllByText
    // -------------------------------------------------------

    @Test
    void whenFindAllByText_expectMatchingItemsReturned() {
        ${EntityResource.className()} item = ${ModelTestFixtures.className()}.oneWithResourceId();
        ${Entity.className()} entity = ${Entity.className()}.builder().resourceId(item.getResourceId()).text(item.getText()).build();
        given(mockRepository.findAllByText(item.getText())).willReturn(Flux.just(entity));
        given(mockEjbToPojoConverter.convert(any(${Entity.className()}.class))).willReturn(item);

        StepVerifier.create(dataStoreUnderTest.findAllByText(item.getText()))
                .expectNext(item)
                .verifyComplete();
    }

    // -------------------------------------------------------
    // findAll
    // -------------------------------------------------------

    @Test
    void whenFindAll_expectAllItemsReturned() {
        ${EntityResource.className()} item = ${ModelTestFixtures.className()}.oneWithResourceId();
        ${Entity.className()} entity = ${Entity.className()}.builder().resourceId(item.getResourceId()).text(item.getText()).build();
        given(mockRepository.findAll()).willReturn(Flux.just(entity));
        given(mockEjbToPojoConverter.convert(any(${Entity.className()}.class))).willReturn(item);

        StepVerifier.create(dataStoreUnderTest.findAll())
                .expectNext(item)
                .verifyComplete();
    }
}
