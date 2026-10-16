<#include "/common/Copyright.ftl">
package ${EntitySpecification.packageName()};

import ${Entity.fqcn()};
import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.CriteriaQuery;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;
import org.springframework.data.jpa.domain.Specification;

import java.util.ArrayList;
import java.util.List;

public class ${EntitySpecification.className()} implements Specification<${Entity.className()}> {

    private final String text;

    private ${EntitySpecification.className()}(Builder builder) {
        this.text = builder.text;
    }

    @Override
    public Predicate toPredicate(Root<${Entity.className()}> root, CriteriaQuery<?> query, CriteriaBuilder cb) {
        List<Predicate> predicates = new ArrayList<>();
        if (text != null && !text.isEmpty()) {
            predicates.add(cb.equal(root.get("text"), text));
        }
        return cb.and(predicates.toArray(new Predicate[0]));
    }

    public static Builder builder() {
        return new Builder();
    }

    public static class Builder {
        private String text;

        public Builder text(String text) {
            this.text = text;
            return this;
        }

        public ${EntitySpecification.className()} build() {
            return new ${EntitySpecification.className()}(this);
        }
    }
}
