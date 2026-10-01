<#include "/common/Copyright.ftl">
package ${EntityToPojoConverter.packageName()};

import ${Entity.fqcn()};
import ${EntityResource.fqcn()};
import lombok.NonNull;
import org.springframework.core.convert.converter.Converter;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
public class ${EntityToPojoConverter.className()} implements Converter<${Entity.className()}, ${EntityResource.className()}> {

/**
* Convert the source object of type {@code ${endpoint.ejbName}} to target type {@code ${endpoint.pojoName}}.
*
* @param source the source object to convert, which must be an instance of {@code ${endpoint.ejbName}} (never {@code null})
* @return the converted object, which must be an instance of {@code ${endpoint.pojoName}} (potentially {@code null})
* @throws IllegalArgumentException if the source cannot be converted to the desired target type
*/
@Override
public ${EntityResource.className()} convert(@NonNull ${Entity.className()} source) {
    return ${EntityResource.className()}.builder()
        .resourceId( source.getResourceId() )
        .text( source.getText() )
        .build();
    }

    /**
     * Convert a list of EJBs into POJOs
     */
    public List<${EntityResource.className()}> convert (@NonNull List<${Entity.className()}> sourceList) {
        return sourceList.stream().map(this::convert).toList();
    }
}