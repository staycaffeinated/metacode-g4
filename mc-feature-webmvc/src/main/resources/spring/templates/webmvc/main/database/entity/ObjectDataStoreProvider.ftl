<#include "/common/Copyright.ftl">
package ${ConcreteDataStoreImpl.packageName()};

import ${EntitySpecification.fqcn()};
import ${EntityToPojoConverter.fqcn()};
import ${UpdateAwareConverter.fqcn()};
import ${ResourceIdSupplier.fqcn()};
import ${ConcreteDataStoreApi.fqcn()};
import ${BadRequestException.fqcn()};
import ${EntityResource.fqcn()};
import ${Entity.fqcn()};
import ${Repository.fqcn()};
import cz.jirutka.rsql.parser.RSQLParserException;
import io.github.perplexhub.rsql.RSQLJPASupport;
import lombok.NonNull;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Optional;

/**
 * ${endpoint.entityName} DataStore provider. Wraps persistence to separate
 * data storage concerns from the persistence provider.
 */
@Component
public class ${ConcreteDataStoreImpl.className()} implements ${ConcreteDataStoreApi.className()} {

    private static final int DEFAULT_ROW_LIMIT = 20;

    private final ${Repository.className()} repository;
    private final ${EntityToPojoConverter.className()} mapEjbToPojo;
    private final ${UpdateAwareConverter.className()}<${EntityResource.className()}, ${Entity.className()}> mapPojoToEjb;
    private final ResourceIdSupplier resourceIdSupplier;

    public ${ConcreteDataStoreImpl.className()}(
            ${Repository.className()} repository,
            ${EntityToPojoConverter.className()} ejbToPojoConverter,
            ${UpdateAwareConverter.className()}<${EntityResource.className()}, ${Entity.className()}> pojoToEntityConverter,
            ResourceIdSupplier resourceIdSupplier) {
        this.repository = repository;
        this.mapEjbToPojo = ejbToPojoConverter;
        this.mapPojoToEjb = pojoToEntityConverter;
        this.resourceIdSupplier = resourceIdSupplier;
    }

    @Override
    public Optional<${EntityResource.className()}> findByResourceId(@NonNull String resourceId) {
        return repository.findByResourceId(resourceId).map(mapEjbToPojo::convert);
    }

    @Override
    public Page<${EntityResource.className()}> findByAttribute(@NonNull String attributeValue, Pageable pageable) {
        Specification<${Entity.className()}> where =
                ${EntitySpecification.className()}.builder().text(attributeValue).build();
        return toPage(repository.findAll(where, pageable), pageable);
    }

    @Override
    public Page<${EntityResource.className()}> search(@NonNull String searchQuery, Pageable pageable) {
        try {
            Page<${Entity.className()}> resultSet;
            if (searchQuery.isEmpty()) {
                resultSet = repository.findAll(pageable);
            } else {
                Specification<${Entity.className()}> where = RSQLJPASupport.toSpecification(searchQuery);
                resultSet = repository.findAll(where, pageable);
            }
            return toPage(resultSet, pageable);
        } catch (RSQLParserException e) {
            throw new BadRequestException(e.getLocalizedMessage());
        }
    }

    @Override
    public List<${EntityResource.className()}> findAll() {
        return findAll(DEFAULT_ROW_LIMIT);
    }

    public List<${EntityResource.className()}> findAll(int limit) {
        return repository.findAll(PageRequest.of(0, pageLimit(limit))).stream()
                .map(mapEjbToPojo::convert)
                .toList();
    }

    @Override
    public ${EntityResource.className()} save(@NonNull ${EntityResource.className()} item) {
        ${Entity.className()} ejb = mapPojoToEjb.convert(item);
        ejb.setResourceId(resourceIdSupplier.nextResourceId());
        ${Entity.className()} managedEntity = repository.save(ejb);
        return mapEjbToPojo.convert(managedEntity);
    }

    @Override
    public Optional<${EntityResource.className()}> update(${EntityResource.className()} item) {
        Optional<${Entity.className()}> optional = repository.findByResourceId(item.getResourceId());
        if (optional.isPresent()) {
            ${Entity.className()} ejb = optional.get();
            mapPojoToEjb.copyUpdates(item, ejb);
            ${Entity.className()} managed = repository.save(ejb);
            ${EntityResource.className()} updated = mapEjbToPojo.convert(managed);
            return Optional.of(updated);
        }
        return Optional.empty();
    }

    @Override
    public Optional<${EntityResource.className()}> deleteByResourceId(@NonNull String resourceId) {
        return repository.findByResourceId(resourceId).map(entity -> {
            ${EntityResource.className()} pojo = mapEjbToPojo.convert(entity);
            repository.delete(entity);
            return pojo;
        });
    }

    protected int pageLimit(int preferredLimit) {
        return preferredLimit > 0 ? preferredLimit : DEFAULT_ROW_LIMIT;
    }

    private Page<${EntityResource.className()}> toPage(Page<${Entity.className()}> resultSet, Pageable pageable) {
        List<${EntityResource.className()}> list = resultSet.stream().map(mapEjbToPojo::convert).toList();
        return new PageImpl<>(list, pageable, resultSet.getTotalElements());
    }
}
