<#include "/common/Copyright.ftl">
package ${EntitySpecification.packageName()};

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;

import ${Entity.fqcn()};
import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.CriteriaQuery;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
@SuppressWarnings("unchecked")
class ${EntitySpecification.testClass()} {

    @Mock
    private Root<${Entity.className()}> mockRoot;

    @Mock
    private CriteriaQuery<?> mockQuery;

    @Mock
    private CriteriaBuilder mockCriteriaBuilder;

    @Mock
    private Predicate mockPredicate;

    // -------------------------------------------------------
    // toPredicate
    // -------------------------------------------------------

    @Test
    void whenTextIsNull_expectNoEqualPredicateAdded() {
        ${EntitySpecification.className()} spec = ${EntitySpecification.className()}.builder()
                .text(null)
                .build();

        spec.toPredicate(mockRoot, mockQuery, mockCriteriaBuilder);

        verify(mockCriteriaBuilder, never()).equal(any(), any());
    }

    @Test
    void whenTextIsSet_expectEqualPredicateAdded() {
        given(mockCriteriaBuilder.equal(any(), eq("sample"))).willReturn(mockPredicate);
        given(mockCriteriaBuilder.and(any(Predicate[].class))).willReturn(mockPredicate);

        ${EntitySpecification.className()} spec = ${EntitySpecification.className()}.builder()
                .text("sample")
                .build();

        spec.toPredicate(mockRoot, mockQuery, mockCriteriaBuilder);

        verify(mockCriteriaBuilder).equal(any(), eq("sample"));
    }
}
