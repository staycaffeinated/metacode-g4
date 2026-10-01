<#include "/common/Copyright.ftl">
package ${UpdateAwareConverter.packageName()};

import org.springframework.core.convert.converter.Converter;

/**
 * Implement this interface to copy updated fields from a DTO to an existing EJB.
 * A new EJB instance is not created; the presumption is that updated values
 * received in a DTO need to be copied to the EJB so the persisted representation
 * of an entity can be updated. To have a consistent style of applying updates
 * to the EJBs, this interface is introduced.
 */
public interface ${UpdateAwareConverter.className()}<S,T> extends Converter<S,T> {
    T copyUpdates(S source, T target);
}