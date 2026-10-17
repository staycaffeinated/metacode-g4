<#include "/common/Copyright.ftl">

package ${ServiceImpl.packageName()};

import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import ${EntityResource.fqcn()};
import ${ConcreteDataStoreApi.fqcn()};
import ${OnCreateAnnotation.fqcn()};
import ${OnUpdateAnnotation.fqcn()};
import ${ResourceNotFoundException.fqcn()};
import ${ResourceIdSupplier.fqcn()};
import ${ServiceApi.fqcn()};

import org.springframework.stereotype.Service;

import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

@Slf4j
@Service
@RequiredArgsConstructor
public class ${ServiceImpl.className()} implements ${ServiceApi.className()} {

    private final ${ConcreteDataStoreApi.className()} dataStore;
    private final ${ResourceIdSupplier.className()} resourceIdSupplier;


    public Flux<${EntityResource.className()}> findAll${endpoint.entityName}s() {
        return dataStore.findAll();
    }


    public Mono<${EntityResource.className()}> findByResourceId(String id) throws ${ResourceNotFoundException.className()} {
        return dataStore.findByResourceId(id);
    }


    public Flux<${EntityResource.className()}> findAllByText(@NonNull String text) {
        return dataStore.findAllByText(text);
    }


    public Mono<String> create${endpoint.entityName}( @NonNull ${EntityResource.className()} resource ) {
        resource.setResourceId(resourceIdSupplier.nextResourceId());
        return dataStore.create${endpoint.entityName}(resource);
    }


    public Mono<${EntityResource.className()}> update${endpoint.entityName}( @NonNull ${EntityResource.className()} resource ) {
        return dataStore.update${endpoint.entityName}(resource);
    }


    public Mono<Long> delete${endpoint.entityName}ByResourceId(@NonNull String id) {
        return dataStore.deleteByResourceId(id);
    }
}
