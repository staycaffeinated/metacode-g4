<#include "/common/Copyright.ftl">

package ${Entity.packageName()};

import ${EntityResource.fqcn()};
import jakarta.persistence.Column;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.SequenceGenerator;
import jakarta.validation.constraints.NotEmpty;
import lombok.*;
import org.springframework.data.annotation.Id;
import org.springframework.data.domain.Persistable;
import org.springframework.data.relational.core.mapping.Table;


@Table(name="${endpoint.tableName}")
@EqualsAndHashCode(of = {"resourceId"})
@NoArgsConstructor
@AllArgsConstructor
public class ${Entity.className()} implements Persistable<Long> {

    @NoArgsConstructor(access = AccessLevel.PRIVATE)
    public static class Columns {
        public static final String ID = "id";
        // Be aware some databases want column names in camelCase, some want snake_case.
        public static final String RESOURCE_ID = "resourceId";
        public static final String TEXT = "text";
    }

    /*
     * This identifier is never exposed to the outside world because
     * database-generated Ids are commonly sequential values that a hacker can easily guess.
     */
    @Id
    <#if (endpoint.isWithPostgres())>
    @SequenceGenerator(name = "${endpoint.lowerCaseEntityName}_generator", sequenceName = "${endpoint.lowerCaseEntityName}_seq", allocationSize = 1)
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "${endpoint.lowerCaseEntityName}_generator")
    <#else>
    @GeneratedValue
    </#if>
    @Column(name=Columns.ID)
    private Long id;

    /**
     * This is the identifier exposed to the outside world.
     * This is a secure random value with at least 160 bits of entropy, making it difficult for a hacker to guess.
     * This is a unique value in the database. This value can be a positive or negative number.
     */
    @Column(name=Columns.RESOURCE_ID, nullable=false)
    private String resourceId;

    @Column(name=Columns.TEXT, nullable = false)
    @NotEmpty(message = "Text cannot be empty")
    private String text;

    @Override
    public boolean isNew() {
        return id == null;
    }


    public ${Entity.className()} copyMutableFieldsFrom(${EntityResource.className()} pojo) {
        this.text = pojo.getText();
        return this;
    }

    public static Builder builder() { return new DefaultBuilder(); }

    /*
     * Getters and Setters. Once you settle on variable names,
     * move to Lombok if you wish. The code generator starts
     * with sample instance variables which most likely are not
     * what you want. When an instance variable is renamed,
     * the lombok get/set methods frequently don't get updated
     * everywhere in the code to reflect the name change, leading
     * to compile errors. With explicit get/set methods, IDEs
     * easily refactor name changes.
     */
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getResourceId() {
        return resourceId;
    }

    public void setResourceId(String resourceId) {
        this.resourceId = resourceId;
    }

    public String getText() {
        return text;
    }

    public void setText(String text) {
        this.text = text;
    }

    /*
    * The Builder interface
    */
    public interface Builder {
        Builder id(Long id);

        Builder resourceId(String resourceId);

        Builder text(String text);

        ${Entity.className()} build();
    }

    /*
     * The concrete implementation
     */
    private static class DefaultBuilder implements Builder {
        private Long id;
        private String resourceId;
        private String text;

        @Override
        public Builder id(Long id) {
            this.id = id;
            return this;
        }


        @Override
        public Builder resourceId(String resourceId) {
            this.resourceId = resourceId;
            return this;
        }

        @Override
        public Builder text(String text) {
            this.text = text;
            return this;
        }

        @Override
        public ${Entity.className()} build() {
            ${Entity.className()} ejb = new ${Entity.className()}();
            ejb.id = id;
            ejb.resourceId = resourceId;
            ejb.text = text;
            return ejb;
        }
    }
}