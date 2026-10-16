<#include "/common/Copyright.ftl">
package ${EntityQueryUseCase.packageName()};

import ${EntityResource.fqcn()};
import java.util.Optional;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface ${EntityQueryUseCase.className()} {

    Page<${EntityResource.className()}> findAll${endpoint.entityName}(Pageable pageable);

    Optional<${EntityResource.className()}> find${endpoint.entityName}ByResourceId(String id);

    Page<${EntityResource.className()}> search(String rsqlQuery, Pageable pageable);

    Page<${EntityResource.className()}> findByAttribute(String attributeValue, Pageable pageable);
}
