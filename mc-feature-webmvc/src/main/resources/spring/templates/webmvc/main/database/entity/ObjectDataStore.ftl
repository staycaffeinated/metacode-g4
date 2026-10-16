<#include "/common/Copyright.ftl">
package ${ConcreteDataStoreApi.packageName()};

import ${EntityResource.fqcn()};
import ${AbstractDataStoreApi.fqcn()};
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.Optional;

/**
 * DataStore interface for {@link ${EntityResource.className()}} domain objects.
 */
public interface ${ConcreteDataStoreApi.className()} extends ${AbstractDataStoreApi.className()}<${EntityResource.className()}> {

    Page<${EntityResource.className()}> findByAttribute(String attributeValue, Pageable pageable);

    Page<${EntityResource.className()}> search(String searchQuery, Pageable pageable);
}
