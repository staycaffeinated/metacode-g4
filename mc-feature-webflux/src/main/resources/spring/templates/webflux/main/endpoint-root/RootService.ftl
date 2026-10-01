<#-- @ftlroot "../../../.." -->
<#include "/common/Copyright.ftl">
package ${RootService.packageName()};

import org.springframework.stereotype.Service;

/**
 * Empty implementation of a Service
 */
// Because sonarqube complains about doNothing returning a constant value
@SuppressWarnings("java:S3400")
@Service
public class ${RootService.className()} {

    int doNothing() { return 0; }
}
