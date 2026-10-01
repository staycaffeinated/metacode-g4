<#include "/common/Copyright.ftl">

package ${ServiceImpl.packageName()};


import ${Entity.fqcn()};
import ${EntityResource.fqcn()};
import ${ModelTestFixtures.fqcn()};
import ${SecureRandomSeries.fqcn()};
import ${ResourceIdSupplier.fqcn()};
import ${ConcreteDataStoreApi.fqcn()};
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.BDDAssertions.then;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;

/**
* Unit tests of {@link ${ServiceImpl.className()} }
*/
@ExtendWith(MockitoExtension.class)
@SuppressWarnings({"all"})
class ${ServiceImpl.testClass()} {

    @InjectMocks
    private ${ServiceImpl.className()} serviceUnderTest;

    @Mock
    private ${ConcreteDataStoreApi.className()} ${endpoint.entityVarName}DataStore;

    @Mock
    private ${ResourceIdSupplier.className()} mockResourceIdSupplier;

    final ${ResourceIdSupplier.className()} resourceIdSupplier = new ${SecureRandomSeries.className()}();

    private List<${EntityResource.className()}> ${endpoint.entityVarName}List;
    private Page<${EntityResource.className()}> pageOfData;

    @BeforeEach
    void setUpEachTime() {
        ${endpoint.entityVarName}List = new ArrayList<>();
        ${endpoint.entityVarName}List.addAll(${endpoint.pojoName}TestFixtures.allItems());
        pageOfData = new PageImpl<>(${endpoint.entityVarName}List);
    }

    /**
     * Unit tests of the findAll method
     */
    @Nested
    class FindAllTests {

        @Test
        void shouldReturnAllRowsWhenRepositoryIsNotEmpty() {
            given(${endpoint.entityVarName}DataStore.search(any(String.class), any(Pageable.class))).willReturn( pageOfData );

            Page<${EntityResource.className()}> result = serviceUnderTest.findAll${endpoint.entityName}(Pageable.unpaged());

            then(result).isNotNull();       // must never return null
            then(result.getContent()).hasSameSizeAs(pageOfData.getContent()); // expect all rows returned
        }

        @Test
            void shouldReturnEmptyListWhenRepositoryIsEmpty() {
            given( ${endpoint.entityVarName}DataStore.search(any(String.class), any(Pageable.class))).willReturn(Page.empty());

            Page<${EntityResource.className()}> result = serviceUnderTest.findAll${endpoint.entityName}(Pageable.unpaged());

            then(result).isNotNull();               // must never get null back
            then(result.getContent()).isEmpty();    // expect no content for this edge case
        }
    }

    @Nested
    class FindByAttributeTests {
        /*
        * Happy path - some rows match the given text
        */
        @Test
        @SuppressWarnings("unchecked")
        void shouldReturnRowsWhenRowsWithTextExists() {
            // given: the datastore contains records that satisfy the search criteria
            Pageable pageable = PageRequest.of(0,25);
            Page<${EntityResource.className()}> page = new PageImpl<>(${endpoint.entityVarName}List, pageable, ${endpoint.entityVarName}List.size());
            given(${endpoint.entityVarName}DataStore.findByAttribute(any(String.class), any(Pageable.class))).willReturn(page);

            // when: findByAttribute searches for records having a known-to-exist text value...
            Page<${EntityResource.className()}> result = serviceUnderTest.findByAttribute("text", pageable);

            // then: a non-empty page of results is returned
            then(result).isNotNull();       // must never return null

            // depending on which is smaller, the sample size or the page size, we expect that many rows back
            then(result.getContent().size()).isEqualTo(Math.min(${endpoint.entityVarName}List.size(), pageable.getPageSize()));
        }

        @Test
        @SuppressWarnings("unchecked")
        void shouldReturnEmptyListWhenNoDataFound() {
            // given: the data store contains no records matching the search criteria
            given( ${endpoint.entityVarName}DataStore.findByAttribute(any(String.class), any(Pageable.class))).willReturn( Page.empty() );

            // when: a search is made
            Pageable pageable = PageRequest.of(1,10);
            Page<${EntityResource.className()}> result = serviceUnderTest.findByAttribute("foo", pageable);

            // expect: an empty, non-null result is returned
            then(result).isNotNull();       // must never get null back
            then(result.hasContent()).isFalse();   // must have no content for this edge case
        }

        @Test
        @SuppressWarnings("all")
        void shouldThrowNullPointerExceptionWhen${endpoint.entityName}IsNull() {
            Pageable pageable = PageRequest.of(0,20);
            assertThrows (NullPointerException.class, () ->  serviceUnderTest.findByAttribute(null, pageable));
        }
    }

    @Nested
    class Find${endpoint.entityName}ByResourceIdTests {
        /*
        * Happy path - finds the entity in the database
        */
        @Test
        void shouldReturnOneWhenRepositoryContainsMatch() {
            // given
            ${EntityResource.className()} item = ${ModelTestFixtures.className()}.oneWithoutResourceId();
            String expectedId = item.getResourceId();
            Optional<${EntityResource.className()}> expected = Optional.of(item);
            given(${endpoint.entityVarName}DataStore.findByResourceId(expectedId)).willReturn(expected);

            // when/then
            Optional<${EntityResource.className()}> actual = serviceUnderTest.find${endpoint.entityName}ByResourceId(expectedId);

            assertThat(actual).isNotNull().isPresent();
            assertThat(actual.get().getResourceId()).isEqualTo(expectedId);
        }

        /*
        * Test scenario when no such entity exists in the database
        */
        @Test
        void shouldReturnEmptyWhenRepositoryDoesNotContainMatch() {
        given(${endpoint.entityVarName}DataStore.findByResourceId(any())).willReturn(Optional.empty());

        // when/then
        Optional<${endpoint.pojoName}> actual = serviceUnderTest.find${endpoint.entityName}ByResourceId(resourceIdSupplier.nextResourceId());

        assertThat(actual).isNotNull().isNotPresent();
        }
    }

    @Nested
    class Create${endpoint.entityName}Tests {

        /*
         * happy path should create a new entity
         */
        @Test
        void shouldCreateOneWhen${endpoint.entityName}IsWellFormed() {
            // given: when the datastore inserts an item, the persisted version is returned
            final ${EntityResource.className()} incoming = ${ModelTestFixtures.className()}.oneWithResourceId();
            final ${EntityResource.className()} expected = ${ModelTestFixtures.className()}.copyOf(incoming);
            expected.setResourceId(resourceIdSupplier.nextResourceId());  // because inserted records are assigned a unique resourceId
            given(${endpoint.entityVarName}DataStore.save(any())).willReturn(expected);

            // when: the service inserts a new item
            ${EntityResource.className()} actual = serviceUnderTest.create${endpoint.entityName}(incoming);

            // expect: the persisted version is not null, has a resourceId, and its general state is preserved
            assertThat(actual).isNotNull();
            assertThat(actual.getResourceId()).isNotNull();
            assertThat(actual.getText()).isEqualTo(expected.getText());
        }

        @Test
        @SuppressWarnings("all")
        void shouldThrowNullPointerExceptionWhen${endpoint.entityName}IsNull() {
            Exception exception = assertThrows (NullPointerException.class, () ->  serviceUnderTest.create${endpoint.entityName}(null));
        }
    }

    @Nested
    class Update${endpoint.entityName}Tests {
        /*
        * Happy path - updates an existing entity
        */
        @Test
        void shouldUpdateWhenEntityIsFound() {
            // given: the datastore successfully updates the record (a matching record is found in the database)
            ${EntityResource.className()} changedVersion = ${ModelTestFixtures.className()}.oneWithResourceId();
            String resourceId = changedVersion.getResourceId();
            given(${endpoint.entityVarName}DataStore.update(any(${EntityResource.className()}.class))).willReturn(Optional.of(changedVersion));

            // when: the service is asked to update the item
            Optional<${EntityResource.className()}> optional = serviceUnderTest.update${endpoint.entityName}(changedVersion);

            // then: the updated item is returned, with its fields preserved
            then(optional).isNotNull();
            then(optional.isPresent()).isTrue();
            if (optional.isPresent()) {
                then (optional.get().getResourceId()).isEqualTo(resourceId);
                then (optional.get().getText()).isEqualTo(changedVersion.getText());
            }
        }

        /*
        * When no database record is found, the update should return an empty result
        */
        @Test
        void shouldReturnEmptyOptionWhenEntityIsNotFound() {
            // given: no such entity exists in the database...
            given(${endpoint.entityVarName}DataStore.update(any())).willReturn(Optional.empty());

            // when: the service is asked to update an item that cannot be found in the database
            ${endpoint.pojoName} changedVersion = ${endpoint.entityName}TestFixtures.oneWithResourceId();
            Optional<${EntityResource.className()}> result = serviceUnderTest.update${endpoint.entityName}(changedVersion);

            // expect: an empty Optional is returned
            then(result.isEmpty()).isTrue();
        }

        @Test
        @SuppressWarnings("all")
        void shouldThrowExceptionWhenArgumentIsNull() {
            assertThrows(NullPointerException.class, () -> serviceUnderTest.update${endpoint.entityName}(null));
        }
    }

    @Nested
    class Delete${endpoint.entityName}Tests {
        /*
         * Happy path - deletes an entity
         */
        @Test
        void shouldDeleteWhenEntityExists()  {
            String knownId = ${endpoint.entityName}TestFixtures.oneWithResourceId().getResourceId();
            serviceUnderTest.delete${endpoint.entityName}ByResourceId(knownId);

            // Verify the deleteByResourceId method was invoked
            verify(${endpoint.entityVarName}DataStore, times(1)).deleteByResourceId(any(String.class));
        }

        /*
         * When deleting a non-existing EJB, silently return
         */
        @Test
        void shouldSilentlyReturnWhenEntityDoesNotExist() {
            serviceUnderTest.delete${endpoint.entityName}ByResourceId("BlueyBingo12345");

            // Verify the deleteByResourceId method was invoked
            verify(${endpoint.entityVarName}DataStore, times(1)).deleteByResourceId(any(String.class));
        }

        @Test
        @SuppressWarnings("all")
        void shouldThrowExceptionWhenArgumentIsNull() {
            assertThrows(NullPointerException.class, () -> serviceUnderTest.delete${endpoint.entityName}ByResourceId(null));
        }
    }

    @Nested
    class SearchUseCases {
        @Test
        void shouldAcquireSearchResults() {
            Pageable pageable = PageRequest.of(0, 25);
            Page<${EntityResource.className()}> page = new PageImpl<>(${endpoint.entityVarName}List, pageable, ${endpoint.entityVarName}List.size());
            given(${endpoint.entityVarName}DataStore.search(any(String.class), any(Pageable.class))).willReturn(page);

            Page<${EntityResource.className()}> rs = serviceUnderTest.search("foo==bar", Pageable.unpaged());
            assertThat(rs).isNotNull();
        }

        @Test
        void shouldThrowExceptionIfQueryIsNull() {
            assertThrows(NullPointerException.class, () -> serviceUnderTest.search(null, Pageable.unpaged()));
        }
    }
}
