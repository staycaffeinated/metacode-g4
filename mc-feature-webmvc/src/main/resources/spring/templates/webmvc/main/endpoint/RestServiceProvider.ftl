<#include "/common/Copyright.ftl">

package ${ServiceImpl.packageName()};

import lombok.NonNull;
import ${EntityResource.fqcn()};
import ${ConcreteDataStoreApi.fqcn()};
import ${OnCreateAnnotation.fqcn()};
import ${OnUpdateAnnotation.fqcn()};
import ${EntityCommandUseCase.fqcn()};
import ${EntityQueryUseCase.fqcn()};

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
public class ${ServiceImpl.className()} implements ${EntityCommandUseCase.className()}, ${EntityQueryUseCase.className()} {

    private final ${ConcreteDataStoreApi.className()} ${ConcreteDataStoreApi.varName()};

    public ${ServiceImpl.className()}(${ConcreteDataStoreApi.className()} ${ConcreteDataStoreApi.varName()})
    {
      this.${ConcreteDataStoreApi.varName()} = ${ConcreteDataStoreApi.varName()};
    }


    @Override
    @Transactional(readOnly = true)
    public Page<${EntityResource.className()}> findAll${endpoint.entityName}(Pageable pageable) {
        return ${ConcreteDataStoreApi.varName()}.search("", pageable);
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<${EntityResource.className()}> find${endpoint.entityName}ByResourceId(String id) {
        return ${ConcreteDataStoreApi.varName()}.findByResourceId ( id );
    }

    @Override
    @Transactional(readOnly = true)
    public Page<${EntityResource.className()}> findByAttribute(@NonNull String attributeValue, Pageable pageable) {
        return ${ConcreteDataStoreApi.varName()}.findByAttribute(attributeValue, pageable);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<${EntityResource.className()}> search(@NonNull String rsqlQuery, Pageable pageable) {
        return ${ConcreteDataStoreApi.varName()}.search(rsqlQuery, pageable);
    }

    @Override
    @Transactional
    public ${EntityResource.className()} create${endpoint.entityName}( @NonNull ${endpoint.pojoName} resource ) {
        return ${ConcreteDataStoreApi.varName()}.save(resource);
    }

    @Override
    @Transactional
    public Optional<${endpoint.pojoName}> update${endpoint.entityName}(@NonNull ${endpoint.pojoName} resource ) {
        return ${ConcreteDataStoreApi.varName()}.update(resource);
    }

    @Override
    @Transactional
    public Optional<${endpoint.pojoName}> delete${endpoint.entityName}ByResourceId(@NonNull String id) {
        return ${ConcreteDataStoreApi.varName()}.deleteByResourceId(id);
    }
}
