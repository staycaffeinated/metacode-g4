<#include "/common/Copyright.ftl">
package ${ServiceApi.packageName()};

import ${EntityResource.fqcn()};
import ${ResourceNotFoundException.fqcn()};
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

public interface ${ServiceApi.className()} {

    Flux<${EntityResource.className()}> findAll${endpoint.entityName}s();

    Flux<${EntityResource.className()}> findAllByText(String text);

    Mono<String> create${endpoint.entityName}(${EntityResource.className()} resource);

    Mono<${EntityResource.className()}> update${endpoint.entityName}(${EntityResource.className()} resource);

    Mono<Long> delete${endpoint.entityName}ByResourceId(String id);

    Mono<${EntityResource.className()}> findByResourceId(String id) throws ${ResourceNotFoundException.className()};
}
