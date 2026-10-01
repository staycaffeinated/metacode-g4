<#include "/common/Copyright.ftl">
package ${EntityResource.packageName()};

import ${ResourceIdTrait.fqcn()};
import lombok.AccessLevel;
import lombok.NoArgsConstructor;


public class ${EntityResource.className()} implements ${ResourceIdTrait.className()}<String> {

    @NoArgsConstructor(access = AccessLevel.PRIVATE)
    public static class Fields {
        public static final String RESOURCE_ID = "resourceId";
        public static final String TEXT = "text";
    }

    private String resourceId;
    private String text;

    /**
     * Returns a Builder for this class
     */
    public static Builder builder() {
        return new DefaultBuilder();
    }

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
        Builder resourceId(String resourceId);
        Builder text(String text);
        ${EntityResource.className()} build();
    }

    public static class DefaultBuilder implements Builder {
        private String resourceId;
        private String text;

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
        public ${EntityResource.className()} build() {
            ${EntityResource.className()} pojo = new ${EntityResource.className()}();
            pojo.resourceId = resourceId;
            pojo.text = text;
            return pojo;
        }
    }
}