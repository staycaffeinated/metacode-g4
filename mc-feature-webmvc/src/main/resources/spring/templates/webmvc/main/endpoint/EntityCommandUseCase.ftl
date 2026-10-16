<#include "/common/Copyright.ftl">
package ${EntityCommandUseCase.packageName()};

import ${EntityResource.fqcn()};
import java.util.Optional;

public interface ${EntityCommandUseCase.className()} {

    ${EntityResource.className()} create${endpoint.entityName}(@jakarta.validation.Valid ${EntityResource.className()} resource);

    Optional<${EntityResource.className()}> update${endpoint.entityName}(${EntityResource.className()} resource);

    Optional<${EntityResource.className()}> delete${endpoint.entityName}ByResourceId(String resourceId);
}
