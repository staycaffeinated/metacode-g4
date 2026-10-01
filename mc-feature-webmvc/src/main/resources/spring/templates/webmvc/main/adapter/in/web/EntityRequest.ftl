<#include "/common/Copyright.ftl">
package ${EntityRequest.packageName()};

import ${AlphabeticAnnotation.fqcn()};
import ${OnCreateAnnotation.fqcn()};
import ${OnUpdateAnnotation.fqcn()};
import ${ResourceIdAnnotation.fqcn()};
import ${EntityResource.fqcn()};
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Null;

/**
 * Inbound DTO for create and update operations.
 * Carries Jackson deserialization and validation annotations to allow the domain
 * model (${EntityResource.className()}) to stay free of framework dependencies.
*/

public record ${EntityRequest.className()}(
    @Null(groups = OnCreate.class) @NotNull(groups = OnUpdate.class) @ResourceId String resourceId,
    @NotEmpty @Alphabetic String text)
{
    public static ${EntityRequest.className()} fromDomain(${EntityResource.className()} domain) {
        return new ${EntityRequest.className()}(domain.getResourceId(), domain.getText());
    }

    public ${EntityResource.className()} toDomain() {
        return ${EntityResource.className()}.builder().resourceId(resourceId).text(text).build();
    }

}