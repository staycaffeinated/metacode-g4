<#include "/common/Copyright.ftl">
package ${EntityResponse.packageName()};

import ${EntityResource.fqcn()};

/**
 * Outbound DTO for ${EntityResource.className()} responses.
 * Decouples the API contract from the domain model so domain changes
 * do not silently alter the wire format.
 */
public record ${EntityResponse.className()}(String resourceId, String text) {
    public static ${EntityResponse.className()} fromDomain(${EntityResource.className()} pojo) {
        return new ${EntityResponse.className()}(pojo.getResourceId(), pojo.getText());
    }
}