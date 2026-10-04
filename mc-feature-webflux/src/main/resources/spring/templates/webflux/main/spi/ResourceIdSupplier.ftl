<#include "/common/Copyright.ftl">
package ${ResourceIdSupplier.packageName()};

/**
 * A provider of resource Ids. Resource Ids can be exposed to client
 * applications and, therefore, should be:
 *
 * <ul>
 * <li>hard to guess (e.g., cryptographically strong)</li>
 * <li>URL-friendly</li>
 * <li>have good entropy (e.g., 160-bit entropy)</li>
 * </ul>
 * This is _not_ a replacement of the database's or the Hibernate
 * database record ID generator.
 */
public interface ResourceIdSupplier {
    String nextResourceId();
}
