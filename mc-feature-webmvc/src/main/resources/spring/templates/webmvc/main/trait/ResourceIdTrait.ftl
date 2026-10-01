<#include "/common/Copyright.ftl">
package ${ResourceIdTrait.packageName()};

/**
 * A trait for objects that have resourceId's
 */
public interface ${ResourceIdTrait.className()}<T> {
    T getResourceId();
}