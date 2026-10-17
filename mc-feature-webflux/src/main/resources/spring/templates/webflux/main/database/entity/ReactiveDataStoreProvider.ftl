<#include "/common/Copyright.ftl">
package ${ConcreteDataStoreImpl.packageName()};

import ${PojoToEntityConverter.fqcn()};
import ${EntityToPojoConverter.fqcn()};
import ${EntityResource.fqcn()};
import ${UnprocessableEntityException.fqcn()};
import ${ResourceNotFoundException.fqcn()};
import ${Repository.fqcn()};
import ${ConcreteDataStoreApi.fqcn()};
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

@Component
@RequiredArgsConstructor
@Slf4j
public class ${ConcreteDataStoreImpl.className()} implements ${ConcreteDataStoreApi.className()} {

    private final ${Repository.className()} repository;
    private final ${EntityToPojoConverter.className()} ejbToPojoConverter;
    private final ${PojoToEntityConverter.className()} pojoToEjbConverter;

    @Override
    public Mono<String> create${endpoint.entityName}(${EntityResource.className()} pojo) {
        ${Entity.className()} entity = pojoToEjbConverter.convert(pojo);
        if (entity == null) {
            return Mono.error(new ${UnprocessableEntityException.className()}());
        }
        return repository.save(entity).map(${Entity.className()}::getResourceId);
    }

    @Override
    public Mono<${EntityResource.className()}> update${endpoint.entityName}(${EntityResource.className()} resource) {
        return repository.findByResourceId(resource.getResourceId())
                .flatMap(ejb -> {
                    pojoToEjbConverter.copyUpdates(resource, ejb);
                    return repository.save(ejb).mapNotNull(ejbToPojoConverter::convert);
                });
    }

    @Override
    public Mono<${EntityResource.className()}> findByResourceId(String id) {
        return repository.findByResourceId(id).flatMap(entity -> {
            ${EntityResource.className()} pojo = ejbToPojoConverter.convert(entity);
            if (pojo == null) {
                return Mono.error(new ${ResourceNotFoundException.className()}(id));
            }
            return Mono.just(pojo);
        });
    }

    @Override
    public Mono<${EntityResource.className()}> findById(Long id) {
        return repository.findById(id).flatMap(entity -> {
            ${EntityResource.className()} pojo = ejbToPojoConverter.convert(entity);
            if (pojo == null) {
                return Mono.error(new ${ResourceNotFoundException.className()}(String.valueOf(id)));
            }
            return Mono.just(pojo);
        });
    }

    @Override
    public Mono<Long> deleteByResourceId(String id) {
        return repository.deleteByResourceId(id);
    }

    @Override
    public Flux<${EntityResource.className()}> findAllByText(String text) {
        return repository.findAllByText(text).mapNotNull(ejbToPojoConverter::convert);
    }

    @Override
    public Flux<${EntityResource.className()}> findAll() {
        return repository.findAll().mapNotNull(ejbToPojoConverter::convert);
    }
}
