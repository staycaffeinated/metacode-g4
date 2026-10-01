<#include "/common/Copyright.ftl">
package ${ResourceIdTrait.packageName()};

/**
 * A trait for objects that are resourceId-aware
 */
public interface ${ResourceIdTrait.className()}<T> {
    T getResourceId();
}
