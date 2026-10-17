<#include "/common/Copyright.ftl">
package ${ConcreteDataStoreApi.packageName()};

import ${EntityResource.fqcn()};
import ${AbstractDataStoreApi.fqcn()};
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

/**
 * DataStore interface for {@link ${EntityResource.className()}} domain objects.
 */
public interface ${ConcreteDataStoreApi.className()} extends ${AbstractDataStoreApi.className()}<${EntityResource.className()}> {

    Mono<String> create${endpoint.entityName}(${EntityResource.className()} pojo);

    Mono<${EntityResource.className()}> update${endpoint.entityName}(${EntityResource.className()} pojo);
}
