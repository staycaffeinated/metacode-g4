<#include "/common/Copyright.ftl">
package ${ConcreteDataStoreImpl.packageName()};

import static org.assertj.core.api.Assertions.assertThat;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.mockStatic;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;

import ${BadRequestException.fqcn()};
import ${Entity.fqcn()};
import ${EntityResource.fqcn()};
import ${EntityToPojoConverter.fqcn()};
import ${EjbTestFixtures.fqcn()};
import ${ModelTestFixtures.fqcn()};
import ${PojoToEntityConverter.fqcn()};
import ${Repository.fqcn()};
import ${ResourceIdSupplier.fqcn()};
import cz.jirutka.rsql.parser.RSQLParserException;
import io.github.perplexhub.rsql.RSQLJPASupport;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.MockedStatic;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;

import java.util.List;
import java.util.Optional;

@ExtendWith(MockitoExtension.class)
@SuppressWarnings("unchecked")
class ${ConcreteDataStoreImpl.testClass()} {

    @Mock
    private ${Repository.className()} mockRepository;

    @Mock
    private ${EntityToPojoConverter.className()} mockEjbConverter;

    @Mock
    private ${PojoToEntityConverter.className()} mockPojoConverter;

    @Mock
    private ${ResourceIdSupplier.className()} mockResourceIdSupplier;

    // Explicit construction avoids @InjectMocks ambiguity: both converter mocks share a common
    // supertype, so Mockito cannot reliably distinguish them by generic type at runtime.
    private ${ConcreteDataStoreImpl.className()} dataStoreUnderTest;

    private List<${EntityResource.className()}> pojoList;
    private List<${Entity.className()}> ejbList;

    @BeforeEach
    void setUp() {
        dataStoreUnderTest = new ${ConcreteDataStoreImpl.className()}(
                mockRepository,
                mockEjbConverter,
                mockPojoConverter,
                mockResourceIdSupplier);
        pojoList = ${ModelTestFixtures.className()}.allItems();
        ejbList = ${EjbTestFixtures.className()}.allItems();
    }

    // -------------------------------------------------------
    // findByResourceId
    // -------------------------------------------------------

    @Nested
    class FindByResourceIdTests {

        @Test
        void whenEntityExists_expectPojoReturned() {
            ${Entity.className()} ejb = ${EjbTestFixtures.className()}.oneWithResourceId();
            ${EntityResource.className()} expected = ${ModelTestFixtures.className()}.oneWithResourceId();
            given(mockRepository.findByResourceId(ejb.getResourceId())).willReturn(Optional.of(ejb));
            given(mockEjbConverter.convert(ejb)).willReturn(expected);

            Optional<${EntityResource.className()}> result = dataStoreUnderTest.findByResourceId(ejb.getResourceId());

            assertThat(result).isPresent();
            assertThat(result.get().getResourceId()).isEqualTo(expected.getResourceId());
        }

        @Test
        void whenEntityDoesNotExist_expectEmptyOptional() {
            given(mockRepository.findByResourceId(any())).willReturn(Optional.empty());

            Optional<${EntityResource.className()}> result = dataStoreUnderTest.findByResourceId("unknownId");

            assertThat(result).isNotPresent();
        }

        @Test
        void whenNullResourceId_expectNullPointerException() {
            assertThrows(NullPointerException.class, () -> dataStoreUnderTest.findByResourceId(null));
        }
    }

    // -------------------------------------------------------
    // findByAttribute
    // -------------------------------------------------------

    @Nested
    class FindByAttributeTests {

        @Test
        void whenAttributeMatches_expectPageReturned() {
            Pageable pageable = PageRequest.of(0, 10);
            Page<${Entity.className()}> ejbPage = new PageImpl<>(ejbList, pageable, ejbList.size());
            given(mockRepository.findAll(any(Specification.class), any(Pageable.class))).willReturn(ejbPage);
            given(mockEjbConverter.convert(any(${Entity.className()}.class))).willReturn(${ModelTestFixtures.className()}.oneWithResourceId());

            Page<${EntityResource.className()}> result = dataStoreUnderTest.findByAttribute("sample text", pageable);

            assertThat(result).isNotNull();
            assertThat(result.getContent()).isNotEmpty();
        }

        @Test
        void whenNullAttributeValue_expectNullPointerException() {
            assertThrows(NullPointerException.class,
                    () -> dataStoreUnderTest.findByAttribute(null, PageRequest.of(0, 10)));
        }
    }

    // -------------------------------------------------------
    // search
    // -------------------------------------------------------

    @Nested
    class SearchTests {

        @Test
        void whenQueryIsEmpty_expectFindAllCalled() {
            Pageable pageable = PageRequest.of(0, 10);
            Page<${Entity.className()}> ejbPage = new PageImpl<>(ejbList, pageable, ejbList.size());
            given(mockRepository.findAll(any(Pageable.class))).willReturn(ejbPage);
            given(mockEjbConverter.convert(any(${Entity.className()}.class))).willReturn(${ModelTestFixtures.className()}.oneWithResourceId());

            Page<${EntityResource.className()}> result = dataStoreUnderTest.search("", pageable);

            assertThat(result).isNotNull();
            verify(mockRepository, times(1)).findAll(any(Pageable.class));
        }

        @Test
        void whenQueryIsNonEmpty_expectSpecificationUsed() {
            Pageable pageable = PageRequest.of(0, 10);
            Page<${Entity.className()}> ejbPage = new PageImpl<>(ejbList, pageable, ejbList.size());
            given(mockRepository.findAll(any(Specification.class), any(Pageable.class))).willReturn(ejbPage);
            given(mockEjbConverter.convert(any(${Entity.className()}.class))).willReturn(${ModelTestFixtures.className()}.oneWithResourceId());

            Page<${EntityResource.className()}> result = dataStoreUnderTest.search("text==\"sample\"", pageable);

            assertThat(result).isNotNull();
            verify(mockRepository, times(1)).findAll(any(Specification.class), any(Pageable.class));
        }

        @Test
        void whenRsqlParserExceptionThrown_expectBadRequestException() {
            Pageable pageable = PageRequest.of(0, 10);
            try (MockedStatic<RSQLJPASupport> mockedRsql = mockStatic(RSQLJPASupport.class)) {
                mockedRsql.when(() -> RSQLJPASupport.toSpecification(any(String.class)))
                          .thenThrow(new RSQLParserException(new RuntimeException("bad query")));

                assertThrows(${BadRequestException.className()}.class,
                        () -> dataStoreUnderTest.search("invalid==", pageable));
            }
        }

        @Test
        void whenNullSearchQuery_expectNullPointerException() {
            assertThrows(NullPointerException.class,
                    () -> dataStoreUnderTest.search(null, PageRequest.of(0, 10)));
        }
    }

    // -------------------------------------------------------
    // findAll
    // -------------------------------------------------------

    @Nested
    class FindAllTests {

        @Test
        void whenFindAll_expectDefaultLimitUsed() {
            Page<${Entity.className()}> ejbPage = new PageImpl<>(ejbList);
            given(mockRepository.findAll(any(Pageable.class))).willReturn(ejbPage);
            given(mockEjbConverter.convert(any(${Entity.className()}.class))).willReturn(${ModelTestFixtures.className()}.oneWithResourceId());

            List<${EntityResource.className()}> result = dataStoreUnderTest.findAll();

            assertThat(result).isNotNull();
        }

        @Test
        void whenFindAllWithPositiveLimit_expectLimitHonored() {
            Page<${Entity.className()}> ejbPage = new PageImpl<>(ejbList);
            given(mockRepository.findAll(any(Pageable.class))).willReturn(ejbPage);
            given(mockEjbConverter.convert(any(${Entity.className()}.class))).willReturn(${ModelTestFixtures.className()}.oneWithResourceId());

            List<${EntityResource.className()}> result = dataStoreUnderTest.findAll(5);

            assertThat(result).isNotNull();
        }
    }

    // -------------------------------------------------------
    // save
    // -------------------------------------------------------

    @Nested
    class SaveTests {

        @Test
        void whenSave_expectResourceIdAssignedAndPojoReturned() {
            ${EntityResource.className()} incoming = ${ModelTestFixtures.className()}.oneWithoutResourceId();
            ${Entity.className()} ejb = ${EjbTestFixtures.className()}.oneWithResourceId();
            ${EntityResource.className()} expected = ${ModelTestFixtures.className()}.oneWithResourceId();
            given(mockPojoConverter.convert(any(${EntityResource.className()}.class))).willReturn(ejb);
            given(mockRepository.save(any(${Entity.className()}.class))).willReturn(ejb);
            given(mockEjbConverter.convert(any(${Entity.className()}.class))).willReturn(expected);
            given(mockResourceIdSupplier.nextResourceId()).willReturn(expected.getResourceId());

            ${EntityResource.className()} result = dataStoreUnderTest.save(incoming);

            assertThat(result).isNotNull();
            assertThat(result.getResourceId()).isEqualTo(expected.getResourceId());
        }

        @Test
        void whenNullItem_expectNullPointerException() {
            assertThrows(NullPointerException.class, () -> dataStoreUnderTest.save(null));
        }
    }

    // -------------------------------------------------------
    // update
    // -------------------------------------------------------

    @Nested
    class UpdateTests {

        @Test
        void whenEntityFound_expectUpdatedPojoReturned() {
            ${EntityResource.className()} resource = ${ModelTestFixtures.className()}.oneWithResourceId();
            ${Entity.className()} ejb = ${EjbTestFixtures.className()}.oneWithResourceId();
            given(mockRepository.findByResourceId(resource.getResourceId())).willReturn(Optional.of(ejb));
            given(mockRepository.save(any(${Entity.className()}.class))).willReturn(ejb);
            given(mockEjbConverter.convert(any(${Entity.className()}.class))).willReturn(resource);

            Optional<${EntityResource.className()}> result = dataStoreUnderTest.update(resource);

            assertThat(result).isPresent();
            assertThat(result.get().getResourceId()).isEqualTo(resource.getResourceId());
        }

        @Test
        void whenEntityNotFound_expectEmptyOptional() {
            ${EntityResource.className()} resource = ${ModelTestFixtures.className()}.oneWithResourceId();
            given(mockRepository.findByResourceId(any())).willReturn(Optional.empty());

            Optional<${EntityResource.className()}> result = dataStoreUnderTest.update(resource);

            assertThat(result).isNotPresent();
        }
    }

    // -------------------------------------------------------
    // deleteByResourceId
    // -------------------------------------------------------

    @Nested
    class DeleteTests {

        @Test
        void whenEntityFound_expectDeleteCalledAndPojoReturned() {
            ${Entity.className()} ejb = ${EjbTestFixtures.className()}.oneWithResourceId();
            ${EntityResource.className()} pojo = ${ModelTestFixtures.className()}.oneWithResourceId();
            given(mockRepository.findByResourceId(ejb.getResourceId())).willReturn(Optional.of(ejb));
            given(mockEjbConverter.convert(ejb)).willReturn(pojo);

            Optional<${EntityResource.className()}> result = dataStoreUnderTest.deleteByResourceId(ejb.getResourceId());

            assertThat(result).isPresent();
            verify(mockRepository, times(1)).delete(ejb);
        }

        @Test
        void whenEntityNotFound_expectEmptyOptionalAndNoDelete() {
            given(mockRepository.findByResourceId(any())).willReturn(Optional.empty());

            Optional<${EntityResource.className()}> result = dataStoreUnderTest.deleteByResourceId("unknownId");

            assertThat(result).isNotPresent();
            verify(mockRepository, times(0)).delete(any(${Entity.className()}.class));
        }

        @Test
        void whenNullResourceId_expectNullPointerException() {
            assertThrows(NullPointerException.class, () -> dataStoreUnderTest.deleteByResourceId(null));
        }
    }

    // -------------------------------------------------------
    // pageLimit
    // -------------------------------------------------------

    @Nested
    class PageLimitTests {

        @Test
        void whenPositiveLimit_expectLimitReturned() {
            assertThat(dataStoreUnderTest.pageLimit(5)).isEqualTo(5);
        }

        @Test
        void whenZeroLimit_expectDefaultReturned() {
            assertThat(dataStoreUnderTest.pageLimit(0)).isEqualTo(20);
        }

        @Test
        void whenNegativeLimit_expectDefaultReturned() {
            assertThat(dataStoreUnderTest.pageLimit(-1)).isEqualTo(20);
        }
    }
}
