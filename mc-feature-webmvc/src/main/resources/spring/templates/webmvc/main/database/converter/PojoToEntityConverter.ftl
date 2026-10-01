<#include "/common/Copyright.ftl">

package ${PojoToEntityConverter.packageName()};

import ${EntityResource.fqcn()};
import ${Entity.fqcn()};
import ${UpdateAwareConverter.fqcn()};
import lombok.NonNull;
import org.springframework.core.convert.converter.Converter;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
public class ${PojoToEntityConverter.className()} implements ${UpdateAwareConverter.className()}<${EntityResource.className()}, ${Entity.className()}> {
    /**
     * Convert the source object of type {@code ${endpoint.pojoName}} to target type {@code ${endpoint.ejbName}}.
     *
     * @param resource the source object to convert, which must be an instance of {@code ${endpoint.pojoName}} (never {@code null})
     * @return the converted object, which must be an instance of {@code ${endpoint.ejbName}} (potentially {@code null})
     * @throws IllegalArgumentException if the source cannot be converted to the desired target type
     */
    @Override
    public ${Entity.className()} convert (@NonNull ${EntityResource.className()} resource) {
        return ${Entity.className()}.builder()
                .resourceId(resource.getResourceId())
                .text(resource.getText())
                .build();
    }

    /**
     * Convert a list of POJOs into EJBs
     */
    public List<${Entity.className()}> convert (@NonNull List<${EntityResource.className()}> sourceList) {
        return sourceList.stream().map(this::convert).toList();
    }

    /**
     * Modifies `target` by copying the mutable fields from `source` into `target`.
     * The general idea is to apply updates to an EJB so the EJB can be persisted with the changed values.
     * An interface is used to provide a consistent style of applying updates.
     * @param source the DTO containing updated values; if `null` then `target` is returned unchanged.
     * @param target the EJB being updated
     * @return the updated EJB
     */
    @Override
    public ${Entity.className()} copyUpdates (@NonNull ${EntityResource.className()} source, @NonNull ${Entity.className()} target) {
        // Update this method as the POJO and EJB are filled out with more attributes.
        // You want to copy mutable fields of the POJO to the EJB. The general idea is to
        // update the EJB to match the POJO so the EJB can be persisted with the changes.
        target.setText(source.getText());
        return target;
    }
}
