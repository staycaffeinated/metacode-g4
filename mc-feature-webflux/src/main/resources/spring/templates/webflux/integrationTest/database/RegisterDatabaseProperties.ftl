<#include "/common/Copyright.ftl">
package ${RegisterDatabaseProperties.packageName()};

import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;

public interface ${RegisterDatabaseProperties.className()} {

    @DynamicPropertySource
    public static void registerDatabaseProperties(DynamicPropertyRegistry registry) {
        // R2DBC connection is configured via application.yml (spring.r2dbc.*).
        // Override here if switching to Testcontainers or a non-default data source
    }
}